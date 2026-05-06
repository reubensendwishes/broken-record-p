<template>
    <div>Waiting for login...</div>
</template>

<script setup lang="ts">
    // supabase
    const user = useSupabaseUser()
    const redirectInfo = useSupabaseCookieRedirect()

    watch(
        user,
        () => {
            if (user.value) {
                const path = redirectInfo.pluck()
                return navigateTo(path || '/')
            }
        },
        { immediate: true },
    )
</script>
