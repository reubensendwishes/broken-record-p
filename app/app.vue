<template>
    <NuxtRouteAnnouncer />
    <NuxtPage />
</template>
<script lang="ts" setup>
    useHead({
        bodyAttrs: {
            class: ['bg-default', 'text-primary'],
        },
    })
</script>

<style scoped></style>
