<template>
    <button class="app-button" :type="type" @click="emit('click')">
        <slot />
    </button>
</template>

<script setup lang="ts">
    // types
    type Props = {
        type?: 'submit' | 'button'
        paddingX?: `${number}px`
        paddingY?: `${number}px`
        roundedLeft?: `${number}px`
        roundedRight?: `${number}px`
        width?: 'fit-content' | '100%'
    }
    type Emits = {
        click: []
    }

    // props
    const {
        type = 'button',
        paddingX = '6px',
        paddingY = '6px',
        roundedLeft = '0px',
        roundedRight = '0px',
        width = 'fit-content',
    } = defineProps<Props>()

    const emit = defineEmits<Emits>()
</script>

<style scoped>
    .app-button {
        padding: v-bind(paddingY) v-bind(paddingX);
        border-radius: v-bind(roundedLeft) v-bind(roundedRight);
        width: v-bind(width);
    }
</style>
