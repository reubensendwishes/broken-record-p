-- Move user-editable settings (dark mode, voice candidates) out of "profiles" into
-- their own table, so RLS can allow users to update these without exposing the rest
-- of "profiles" (username, display_name, created_at) to direct client UPDATE.

CREATE TABLE IF NOT EXISTS "public"."user_settings" (
    "id" "uuid" NOT NULL,
    "dark_mode" boolean DEFAULT false NOT NULL,
    "en_us_voice_candidates" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    "zh_tw_voice_candidates" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    CONSTRAINT "user_settings_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "en_us_voice_candidates_count" CHECK (array_length("en_us_voice_candidates", 1) IS NULL OR array_length("en_us_voice_candidates", 1) <= 3),
    CONSTRAINT "en_us_voice_candidates_item_length" CHECK ("public"."text_array_max_length"("en_us_voice_candidates", 100)),
    CONSTRAINT "zh_tw_voice_candidates_count" CHECK (array_length("zh_tw_voice_candidates", 1) IS NULL OR array_length("zh_tw_voice_candidates", 1) <= 3),
    CONSTRAINT "zh_tw_voice_candidates_item_length" CHECK ("public"."text_array_max_length"("zh_tw_voice_candidates", 100))
);

ALTER TABLE "public"."user_settings" OWNER TO "postgres";

ALTER TABLE ONLY "public"."user_settings"
    ADD CONSTRAINT "user_settings_id_fkey" FOREIGN KEY ("id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

-- Backfill settings rows for existing users from their current profiles columns.
INSERT INTO "public"."user_settings" ("id", "dark_mode", "en_us_voice_candidates", "zh_tw_voice_candidates")
SELECT "id", "dark_mode", "en_us_voice_candidates", "zh_tw_voice_candidates" FROM "public"."profiles";

ALTER TABLE "public"."profiles"
    DROP COLUMN "dark_mode",
    DROP COLUMN "en_us_voice_candidates",
    DROP COLUMN "zh_tw_voice_candidates";

ALTER TABLE "public"."user_settings" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can access own settings" ON "public"."user_settings"
    USING (("id" = "auth"."uid"()))
    WITH CHECK (("id" = "auth"."uid"()));

GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."user_settings" TO "anon";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."user_settings" TO "authenticated";
GRANT REFERENCES,TRIGGER,TRUNCATE,MAINTAIN ON TABLE "public"."user_settings" TO "service_role";
GRANT SELECT, UPDATE ON TABLE "public"."user_settings" TO "authenticated";
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE "public"."user_settings" TO "service_role";

-- New signups now also need a matching settings row alongside their profile row.
CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    INSERT INTO public.profiles (id, username, display_name)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data->>'username',
        'Pig'
    );

    INSERT INTO public.user_settings (id)
    VALUES (NEW.id);

    RETURN NEW;
END
$$;
