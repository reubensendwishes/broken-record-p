<template>
    <NuxtLink class="link" :to="to">
        <slot />
    </NuxtLink>
</template>

<script setup lang="ts">
    import type { RouteLocationRaw } from 'vue-router'

    // types
    type Props = {
        to: RouteLocationRaw
        paddingX?: `${number}px`
        paddingY?: `${number}px`
        roundedLeft?: `${number}px`
        roundedRight?: `${number}px`
        width?: string
    }

    // props
    const {
        to,
        paddingX = '6px',
        paddingY = '6px',
        roundedLeft = '0px',
        roundedRight = '0px',
        width = 'fit-content',
    } = defineProps<Props>()
</script>

<style scoped>
    .link {
        display: inline-flex;
        padding: v-bind(paddingY) v-bind(paddingX);
        border-radius: v-bind(roundedLeft) v-bind(roundedRight);
        width: v-bind(width);
    }
</style>
