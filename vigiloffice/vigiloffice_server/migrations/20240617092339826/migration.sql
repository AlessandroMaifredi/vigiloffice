BEGIN;

--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "device_mac_idx" ON "devices" USING btree ("macAddress");
CREATE INDEX "type_idx" ON "devices" USING btree ("type");
--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "hvac_mac_idx" ON "hvacs" USING btree ("macAddress");
--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "lamp_mac_idx" ON "lamps" USING btree ("macAddress");
--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "parking_mac_idx" ON "parkings" USING btree ("macAddress");

--
-- MIGRATION VERSION FOR vigiloffice
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vigiloffice', '20240617092339826', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240617092339826', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
