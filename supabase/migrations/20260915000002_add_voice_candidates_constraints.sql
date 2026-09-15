-- Cap voice candidate lists at 3 entries, and each voice name at 100 characters.
CREATE FUNCTION "public"."text_array_max_length"("arr" "text"[], "max_len" integer) RETURNS boolean
    LANGUAGE "sql" IMMUTABLE
    AS $$
        SELECT COALESCE(MAX(char_length(elem)), 0) <= max_len FROM unnest(arr) AS elem;
    $$;

ALTER TABLE "public"."profiles"
    ADD CONSTRAINT "en_us_voice_candidates_count" CHECK (array_length("en_us_voice_candidates", 1) IS NULL OR array_length("en_us_voice_candidates", 1) <= 3),
    ADD CONSTRAINT "en_us_voice_candidates_item_length" CHECK ("public"."text_array_max_length"("en_us_voice_candidates", 100)),
    ADD CONSTRAINT "zh_tw_voice_candidates_count" CHECK (array_length("zh_tw_voice_candidates", 1) IS NULL OR array_length("zh_tw_voice_candidates", 1) <= 3),
    ADD CONSTRAINT "zh_tw_voice_candidates_item_length" CHECK ("public"."text_array_max_length"("zh_tw_voice_candidates", 100));
