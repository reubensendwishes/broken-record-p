<template>
    <Teleport to="#teleports">
        <div v-bind="$attrs" class="modal" @keydown.esc="emit('close')">
            <UiBackdrop
                v-if="hasBackdrop"
                class="modal-backdrop"
                @click="emit('close')"
            />
            <div
                ref="modal-content"
                v-focus
                tabindex="-1"
                class="modal-content bg-default d-flex-column"
                @focusin.stop
            >
                <template v-if="slots.header">
                    <div class="modal-header">
                        <slot name="header" />
                    </div>
                    <div :class="`bg-${color}-subtle`" class="divider" />
                </template>

                <div class="modal-body">
                    <slot />
                </div>
                <div v-if="hasActions" class="modal-actions d-flex-row">
                    <UiButton
                        :class="`text-${color}`"
                        class="cancel-btn"
                        @click="emit('close')"
                    >
                        取消
                    </UiButton>
                    <div class="primary-action">
                        <slot name="primary-action" />
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>

<script setup lang="ts">
    // types
    type Props = {
        color?: 'primary' | 'secondary'
        hasBackdrop?: boolean
        zIndex?: number
        hasActions?: boolean
    }
    type Emits = {
        close: []
    }
    type Slots = {
        default(): unknown
        header(): unknown
        'primary-action'(): unknown
    }

    // emits
    const emit = defineEmits<Emits>()

    // props
    const {
        hasBackdrop = false,
        zIndex = 1000,
        hasActions = true,
        color = 'primary',
    } = defineProps<Props>()

    // slots
    const slots = defineSlots<Slots>()

    // options
    defineOptions({
        inheritAttrs: false,
    })

    const modalContentRef = useTemplateRef('modal-content')

    const focusModal = () => {
        modalContentRef.value?.focus()
    }
    onMounted(() => {
        document.body.addEventListener('focusin', focusModal)
    })
    onBeforeUnmount(() => {
        document.body.removeEventListener('focusin', focusModal)
    })
    useHead({
        bodyAttrs: {
            class: 'no-scroll',
        },
    })
</script>

<style scoped>
    .modal {
        z-index: v-bind(zIndex);
        position: fixed;
        inset: 0;
    }
    .modal-content {
        position: absolute;
        inset: 50% auto auto 50%;
        transform: translate(-50%, -50%);
        width: 100%;
        max-width: 400px;
        border-radius: 20px;
        padding: 20px
            calc(
                clamp(
                        0px,
                        env(safe-area-inset-right) - 50dvw + 200px,
                        env(safe-area-inset-right)
                    ) +
                    20px
            )
            20px
            calc(
                clamp(
                        0px,
                        env(safe-area-inset-left) - 50dvw + 200px,
                        env(safe-area-inset-left)
                    ) +
                    20px
            );
        max-height: 100dvh;
    }
    .modal-content > *:not(:last-child) {
        margin-bottom: 20px;
    }
    .divider {
        height: 2px;
    }
    .modal-body {
        overflow: auto;
        overflow-wrap: break-word;
    }
    .modal-actions {
        justify-content: center;
        gap: 10px;
    }
</style>
