-- Rename tracks.note to tracks.description
ALTER TABLE "public"."tracks" RENAME COLUMN "note" TO "description";
ALTER TABLE "public"."tracks" RENAME CONSTRAINT "tracks_note_length" TO "tracks_description_length";

-- Add sections.note with length 1~300 or NULL
ALTER TABLE "public"."sections" ADD COLUMN "note" "text";
ALTER TABLE "public"."sections" ADD CONSTRAINT "sections_note_length" CHECK ((("note" IS NULL) OR (("char_length"("note") >= 1) AND ("char_length"("note") <= 300))));
