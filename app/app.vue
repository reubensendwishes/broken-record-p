<template>
    <NuxtRouteAnnouncer />
    <NuxtLayout>
        <NuxtPage />
    </NuxtLayout>
</template>
<script lang="ts" setup>
    useHead({
        bodyAttrs: {
            class: ['bg-default', 'text-primary'],
        },
    })
</script>
