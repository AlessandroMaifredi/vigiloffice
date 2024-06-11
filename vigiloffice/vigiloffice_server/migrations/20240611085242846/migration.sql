BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "devices" ALTER COLUMN "status" DROP NOT NULL;

--
-- MIGRATION VERSION FOR vigiloffice
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('vigiloffice', '20240611085242846', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240611085242846', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
