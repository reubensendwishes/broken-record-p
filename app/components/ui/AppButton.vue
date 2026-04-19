<template>
    <button :type="type" @[buttonEvent]="handler">
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
        handler?: (...args: unknown[]) => unknown
    }

    // props
    const {
        type = 'button',
        paddingX = '6px',
        paddingY = '6px',
        roundedLeft = '0px',
        roundedRight = '0px',
        width = 'fit-content',
        handler = undefined,
    } = defineProps<Props>()

    const buttonEvent = computed(() => {
        return handler && 'click'
    })
</script>

<style scoped>
    button {
        padding: v-bind(paddingY) v-bind(paddingX);
        border-radius: v-bind(roundedLeft) v-bind(roundedRight)
            v-bind(roundedLeft);
        width: v-bind(width);
    }
</style>
