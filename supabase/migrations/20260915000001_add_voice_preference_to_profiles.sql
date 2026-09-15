-- Store an ordered candidate list of speech synthesis voice names per language,
-- so a user's voice preference can be restored on a new device when a match exists.
ALTER TABLE "public"."profiles"
    ADD COLUMN "en_us_voice_candidates" "text"[] DEFAULT '{}'::"text"[] NOT NULL,
    ADD COLUMN "zh_tw_voice_candidates" "text"[] DEFAULT '{}'::"text"[] NOT NULL;
