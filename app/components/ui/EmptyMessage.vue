<template>
    <p class="text-muted empty-message">
        {{ emptyMessage }}
    </p>
</template>

<script setup lang="ts">
    // types
    type Props = {
        emptyMessage: string
    }
    const { emptyMessage } = defineProps<Props>()
</script>

<style scoped>
    .empty-message {
        text-align: center;
    }
</style>
