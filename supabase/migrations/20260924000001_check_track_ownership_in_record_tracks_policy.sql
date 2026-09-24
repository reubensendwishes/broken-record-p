-- The previous policy only checked that the record belongs to the user, so a user could
-- link someone else's track into their own record. Also require the track to be theirs
-- on INSERT/UPDATE. USING stays record-only so existing rows remain readable/deletable.
DROP POLICY "users can access own record_tracks" ON "public"."record_tracks";

CREATE POLICY "users can access own record_tracks" ON "public"."record_tracks"
    USING ((EXISTS ( SELECT 1
       FROM "public"."records"
      WHERE (("records"."id" = "record_tracks"."record_id") AND ("records"."user_id" = "auth"."uid"())))))
    WITH CHECK (((EXISTS ( SELECT 1
       FROM "public"."records"
      WHERE (("records"."id" = "record_tracks"."record_id") AND ("records"."user_id" = "auth"."uid"()))))
      AND (EXISTS ( SELECT 1
       FROM "public"."tracks"
      WHERE (("tracks"."id" = "record_tracks"."track_id") AND ("tracks"."user_id" = "auth"."uid"()))))));
