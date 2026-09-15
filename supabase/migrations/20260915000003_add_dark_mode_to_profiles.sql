-- Persist the user's dark mode preference so it survives across devices.
ALTER TABLE "public"."profiles"
    ADD COLUMN "dark_mode" boolean DEFAULT false NOT NULL;
