<template>
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
            class: computed(() => isDarkMode.value && 'dark'),
        },
        bodyAttrs: {
            class: ['bg-default', 'text-primary'],
        },
    })
</script>
