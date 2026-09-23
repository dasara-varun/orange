import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../generated/protocol.dart';

class CashfreeOrderResponse {
  final String cfOrderId;
  final String orderId;
  final String orderStatus;
  final String paymentSessionId;
  final String? entity;

  CashfreeOrderResponse({
    required this.cfOrderId,
    required this.orderId,
    required this.orderStatus,
    required this.paymentSessionId,
    this.entity,
  });

  factory CashfreeOrderResponse.fromJson(Map<String, dynamic> json) {
    return CashfreeOrderResponse(
      cfOrderId: (json['cf_order_id'] ?? '').toString(),
      orderId: (json['order_id'] ?? '').toString(),
      orderStatus: (json['order_status'] ?? '').toString(),
      paymentSessionId: (json['payment_session_id'] ?? '').toString(),
      entity: json['entity']?.toString(),
    );
  }
}

class CashfreeService {
  static String? _appId;
  static String? _secretKey;
  static String _environment = 'PRODUCTION'; // PRODUCTION or SANDBOX
  static String _apiVersion = '2025-01-01';

  static void _loadConfig() {
    if (_appId != null && _secretKey != null) return;

    _appId = Platform.environment['CASHFREE_APP_ID'];
    _secretKey = Platform.environment['CASHFREE_SECRET_KEY'];
    _environment = Platform.environment['CASHFREE_ENVIRONMENT'] ?? 'PRODUCTION';
    _apiVersion = Platform.environment['CASHFREE_API_VERSION'] ?? '2025-01-01';

    // Fallback: load from .env file candidates if available
    final candidateFiles = [
      File('.env'),
      File('../.env'),
      File('../../.env'),
      File('ds_milk_world/ds_milk_world_server/.env'),
    ];
    for (final envFile in candidateFiles) {
      if (envFile.existsSync()) {
        final lines = envFile.readAsLinesSync();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
          final eqIdx = trimmed.indexOf('=');
          if (eqIdx > 0) {
            final key = trimmed.substring(0, eqIdx).trim();
            final val = trimmed.substring(eqIdx + 1).trim();
            if (key == 'CASHFREE_APP_ID' && (_appId == null || _appId!.isEmpty)) {
              _appId = val;
            } else if (key == 'CASHFREE_SECRET_KEY' && (_secretKey == null || _secretKey!.isEmpty)) {
              _secretKey = val;
            } else if (key == 'CASHFREE_ENVIRONMENT' || key == 'CASHFREE_ENV') {
              _environment = val.toUpperCase();
            } else if (key == 'CASHFREE_API_VERSION') {
              _apiVersion = val;
            }
          }
        }
      }
    }
  }

  static String get baseUrl {
    _loadConfig();
    return _environment.toUpperCase() == 'SANDBOX'
        ? 'https://sandbox.cashfree.com/pg'
        : 'https://api.cashfree.com/pg';
  }

  static String? get appId {
    _loadConfig();
    return _appId;
  }

  static String? get secretKey {
    _loadConfig();
    return _secretKey;
  }

  static String get environment {
    _loadConfig();
    return _environment;
  }

  static String get apiVersion {
    _loadConfig();
    return _apiVersion;
  }

  /// Create a PG order on Cashfree Server-to-Server
  static Future<CashfreeOrderResponse> createOrder(OrderRecord order) async {
    _loadConfig();
    final currentAppId = _appId;
    final currentSecret = _secretKey;

    if (currentAppId == null || currentAppId.isEmpty || currentSecret == null || currentSecret.isEmpty) {
      throw StateError('Cashfree credentials missing: CASHFREE_APP_ID and CASHFREE_SECRET_KEY must be set.');
    }

    final url = Uri.parse('$baseUrl/orders');
    final amountDecimal = (order.totalPaise / 100.0);

    // Clean phone number (must be 10 digits)
    final cleanPhone = order.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final customerId = 'CUST_$cleanPhone';

    final requestBody = {
      'order_id': order.orderNumber,
      'order_amount': amountDecimal,
      'order_currency': 'INR',
      'customer_details': {
        'customer_id': customerId,
        'customer_name': order.customerName ?? 'Customer',
        'customer_email': order.customerEmail?.isNotEmpty == true
            ? order.customerEmail!
            : 'customer@dsmilkworld.isroot.in',
        'customer_phone': cleanPhone.length == 10 ? cleanPhone : '9848012345',
      },
      'order_meta': {
        'return_url': 'https://ds-milk-world.pages.dev/?order_id=${order.orderNumber}',
        'notify_url': 'https://ds-milk-world.pages.dev/api/payment-webhook',
      },
      'order_note': 'DS Milk World Fresh Order #${order.orderNumber}',
    };

    final headers = {
      'Content-Type': 'application/json',
      'x-api-version': _apiVersion,
      'x-client-id': currentAppId,
      'x-client-secret': currentSecret,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return CashfreeOrderResponse.fromJson(data);
    } else {
      final errBody = response.body;
      throw HttpException('Cashfree Order Creation failed [${response.statusCode}]: $errBody');
    }
  }

  /// Check order status directly with Cashfree
  static Future<Map<String, dynamic>> getOrderStatus(String orderNumber) async {
    _loadConfig();
    final currentAppId = _appId;
    final currentSecret = _secretKey;

    if (currentAppId == null || currentSecret == null) {
      throw StateError('Cashfree credentials missing');
    }

    final url = Uri.parse('$baseUrl/orders/$orderNumber');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-version': _apiVersion,
      'x-client-id': currentAppId,
      'x-client-secret': currentSecret,
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw HttpException('Cashfree Get Order failed [${response.statusCode}]: ${response.body}');
    }
  }

  /// Verify incoming webhook HMAC-SHA256 signature
  static bool verifyWebhookSignature({
    required String timestamp,
    required String rawBody,
    required String signature,
  }) {
    _loadConfig();
    final currentSecret = _secretKey;
    if (currentSecret == null || currentSecret.isEmpty) return false;

    try {
      final signedPayload = timestamp + rawBody;
      final hmacSha256 = Hmac(sha256, utf8.encode(currentSecret));
      final digest = hmacSha256.convert(utf8.encode(signedPayload));
      final computed = base64Encode(digest.bytes);
      return computed == signature;
    } catch (_) {
      return false;
    }
  }
}
