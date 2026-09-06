<template>
    <a class="skip-link bg-primary text-inverse" href="#main">跳至主要內容</a>
    <NuxtRouteAnnouncer />
    <NuxtPage />
    <UiConfirmDialog v-if="confirmDialogState.isOpen" />
    <UiToastContainer />
</template>
<script lang="ts" setup>
    const { confirmDialogState } = useConfirm()
    const { isDarkMode } = useDarkMode()
    useHead({
        htmlAttrs: {
            lang: 'zh-Hant',
            class: computed(() => isDarkMode.value && 'dark'),
        },
        bodyAttrs: {
            class: ['bg-default', 'text-primary'],
        },
    })
</script>
<style scoped>
    .skip-link {
        position: absolute;
        left: -9999px;
        top: 0;
    }
    .skip-link:focus {
        padding: 6px;
        top: calc(env(safe-area-inset-top) + 2px);
        left: calc(env(safe-area-inset-left) + 2px);
        z-index: 9999;
    }
</style>
