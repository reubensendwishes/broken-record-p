<template>
    <div class="material-symbols-rounded" translate="no">
        <slot />
    </div>
</template>

<script setup lang="ts">
    // types
    type Props = {
        fontSize?: `${number}px`
        fill?: 0 | 1
        opsz?: 20 | 24 | 40 | 48
    }

    // props
    const { fontSize = '30px', fill = 0, opsz = 24 } = defineProps<Props>()
</script>

<style>
    .material-symbols-rounded {
        width: fit-content;
        font-family: 'Material Symbols Rounded';
        font-size: v-bind(fontSize);
        font-variation-settings:
            'FILL' v-bind(fill),
            'opsz' v-bind(opsz);
    }
</style>
