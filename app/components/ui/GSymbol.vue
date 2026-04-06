<template>
    <span class="material-symbols-rounded" :style="{ fontSize }">
        <slot />
    </span>
    <span class="material-symbols-rounded" :style="{ fontSize }"
        >play_arrow</span
    >
</template>

<script setup lang="ts">
    // types
    type Props = {
        fontSize?: `${number}px`
        fill?: 0 | 1
        opsz?: 20 | 24 | 40 | 48
    }

    // props
    const { fontSize = '24px', fill = 0, opsz = 24 } = defineProps<Props>()
</script>

<style scoped>
    .material-symbols-rounded {
        font-variation-settings:
            'FILL' v-bind(fill),
            'opsz' v-bind(opsz);
    }
</style>
