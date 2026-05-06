<template>
    <p class="verify-email">請到電子郵件信箱,接收驗證信，完成註冊驗證</p>
</template>

<script setup lang="ts">
    // page meta
    definePageMeta({
        middleware: 'guest',
    })

    // supabase
    const user = useSupabaseUser()

    watch(
        user,
        () => {
            if (user.value) {
                navigateTo('/')
            }
        },
        { immediate: true },
    )
</script>

<style>
    .verify-email {
        padding-top: 10px;
        text-align: center;
    }
</style>
