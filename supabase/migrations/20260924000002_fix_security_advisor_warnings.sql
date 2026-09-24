-- Resolve Security Advisor warnings.

-- function_search_path_mutable: pin search_path like the rest of our functions.
ALTER FUNCTION "public"."normalize_display_name"() SET "search_path" TO 'public';
ALTER FUNCTION "public"."check_sections_limit"() SET "search_path" TO 'public';
ALTER FUNCTION "public"."check_bars_limit"() SET "search_path" TO 'public';
ALTER FUNCTION "public"."text_array_max_length"("text"[], integer) SET "search_path" TO 'public';

-- anon/authenticated_security_definer_function_executable: these are trigger functions,
-- so API roles never need EXECUTE. Triggers do not check EXECUTE when they fire.
REVOKE EXECUTE ON FUNCTION "public"."enforce_rate_limit"() FROM PUBLIC, "anon", "authenticated";
REVOKE EXECUTE ON FUNCTION "public"."handle_new_user"() FROM PUBLIC, "anon", "authenticated";
REVOKE EXECUTE ON FUNCTION "public"."prevent_exceed_max_record_tracks"() FROM PUBLIC, "anon", "authenticated";
REVOKE EXECUTE ON FUNCTION "public"."prevent_exceed_max_user_records"() FROM PUBLIC, "anon", "authenticated";
REVOKE EXECUTE ON FUNCTION "public"."prevent_exceed_max_user_tracks"() FROM PUBLIC, "anon", "authenticated";

-- rls_auto_enable is an event trigger function created outside our migrations,
-- so only revoke when it exists.
DO $$
BEGIN
    IF to_regprocedure('public.rls_auto_enable()') IS NOT NULL THEN
        REVOKE EXECUTE ON FUNCTION "public"."rls_auto_enable"() FROM PUBLIC, "anon", "authenticated";
    END IF;
END
$$;
