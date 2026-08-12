<template>
    <Teleport to="#teleports">
        <UiButton
            :class="[`bg-${color}`]"
            class="fab text-inverse"
            v-bind="$attrs"
            rounded-left="9999px"
            rounded-right="9999px"
            padding-x="15px"
            padding-y="15px"
            height="60px"
            :is-disabled="isDisabled"
            @click="emit('click')"
        >
            <slot />
        </UiButton>
    </Teleport>
</template>

<script setup lang="ts">
    // types
    type Props = {
        zIndex?: number
        color?: 'primary' | 'secondary'
        isDisabled?: boolean
    }
    type Emits = {
        click: []
    }
    // props
    const {
        zIndex = 700,
        color = 'primary',
        isDisabled = false,
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    // options
    defineOptions({
        inheritAttrs: false,
    })
</script>

<style scoped>
    .fab {
        z-index: v-bind(zIndex);
        position: fixed;
        right: calc(20px + env(safe-area-inset-right));
        bottom: calc(20px + env(safe-area-inset-bottom));
    }
    .fab.bg-primary {
        box-shadow: 0 0 16px var(--color-primary);
    }
    .fab.bg-secondary {
        box-shadow: 0 0 16px var(--color-secondary);
    }
</style>
