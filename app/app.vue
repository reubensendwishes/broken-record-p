<template>
    <NuxtRouteAnnouncer />
    <NuxtPage />
    <UiConfirmDialog v-if="confirmDialogState.isOpen" />
    <UiToastContainer />
</template>
<script lang="ts" setup>
    const { confirmDialogState } = useConfirm()
    useHead({
        bodyAttrs: {
            class: ['bg-default', 'text-primary'],
        },
    })
</script>
