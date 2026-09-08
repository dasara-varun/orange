BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "category" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "sortOrder" bigint NOT NULL,
    "published" boolean NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "delivery_job" (
    "id" bigserial PRIMARY KEY,
    "orderNumber" text NOT NULL,
    "provider" text NOT NULL,
    "externalId" text,
    "quotePaise" bigint NOT NULL,
    "status" text NOT NULL,
    "trackingUrl" text,
    "riderName" text,
    "riderPhone" text,
    "manualFallback" boolean NOT NULL,
    "notes" text,
    "updatedAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "order_event" (
    "id" bigserial PRIMARY KEY,
    "orderNumber" text NOT NULL,
    "type" text NOT NULL,
    "actorType" text NOT NULL,
    "actorId" text,
    "payload" text,
    "timestamp" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "order_item" (
    "id" bigserial PRIMARY KEY,
    "productSku" text NOT NULL,
    "nameSnapshot" text NOT NULL,
    "unitPricePaise" bigint NOT NULL,
    "quantity" bigint NOT NULL,
    "optionsSnapshot" text,
    "subtotalPaise" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "order_record" (
    "id" bigserial PRIMARY KEY,
    "orderNumber" text NOT NULL,
    "customerPhone" text NOT NULL,
    "customerName" text,
    "deliveryAddress" text NOT NULL,
    "landmark" text,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "distanceKm" double precision NOT NULL,
    "status" text NOT NULL,
    "subtotalPaise" bigint NOT NULL,
    "deliveryFeePaise" bigint NOT NULL,
    "totalPaise" bigint NOT NULL,
    "currency" text NOT NULL,
    "items" json NOT NULL,
    "prepTimeMinutes" bigint,
    "rejectionReason" text,
    "packingChecklistConfirmed" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "outlet" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "phone" text NOT NULL,
    "address" text NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "status" text NOT NULL,
    "serviceRadiusM" bigint NOT NULL,
    "timezone" text NOT NULL,
    "openingTime" text NOT NULL,
    "closingTime" text NOT NULL,
    "minOrderPaise" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "payment_attempt" (
    "id" bigserial PRIMARY KEY,
    "orderNumber" text NOT NULL,
    "provider" text NOT NULL,
    "externalId" text NOT NULL,
    "amountPaise" bigint NOT NULL,
    "status" text NOT NULL,
    "paymentMethod" text,
    "rawReference" text,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product" (
    "id" bigserial PRIMARY KEY,
    "categoryName" text NOT NULL,
    "sku" text NOT NULL,
    "name" text NOT NULL,
    "shortDescription" text,
    "sizeOrServing" text,
    "pricePaise" bigint NOT NULL,
    "offerPricePaise" bigint,
    "availability" boolean NOT NULL,
    "customisable" boolean NOT NULL,
    "vegetarian" boolean NOT NULL,
    "sortOrder" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "refund_record" (
    "id" bigserial PRIMARY KEY,
    "orderNumber" text NOT NULL,
    "amountPaise" bigint NOT NULL,
    "reason" text NOT NULL,
    "status" text NOT NULL,
    "providerReference" text,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR ds_milk_world
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('ds_milk_world', '20260908162316502', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260908162316502', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
