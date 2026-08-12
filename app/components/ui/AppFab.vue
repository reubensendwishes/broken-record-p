<template>
    <Teleport to="#teleports">
        <UiAppButton
            :class="[`bg-${color}`]"
            class="app-fab text-inverse"
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
        </UiAppButton>
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
    .app-fab {
        z-index: v-bind(zIndex);
        position: fixed;
        right: calc(20px + env(safe-area-inset-right));
        bottom: calc(20px + env(safe-area-inset-bottom));
    }
    .app-fab.bg-primary {
        box-shadow: 0 0 16px var(--color-primary);
    }
    .app-fab.bg-secondary {
        box-shadow: 0 0 16px var(--color-secondary);
    }
</style>
