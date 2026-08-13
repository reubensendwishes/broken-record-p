<template>
    <span class="badge pill-border text-inverse" :class="'bg-' + bgColor">
        <slot />
    </span>
</template>

<script setup lang="ts">
    // types
    type Props = {
        paddingX?: string
        paddingY?: string
        bgColor?: 'primary' | 'secondary'
    }

    // props
    const {
        paddingX = '6px',
        paddingY = '6px',
        bgColor = 'primary',
    } = defineProps<Props>()
</script>

<style scoped>
    .badge {
        padding: v-bind(paddingY) v-bind(paddingX);
        white-space: nowrap;
    }
</style>
