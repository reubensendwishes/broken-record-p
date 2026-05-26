<template>
    <Teleport to="#teleports">
        <div v-bind="$attrs" class="modal" @keydown.esc="emit('close')">
            <ui-app-backdrop
                v-if="hasBackdrop"
                class="modal-backdrop"
                @click="emit('close')"
            />
            <div
                ref="modal-content"
                v-focus
                tabindex="-1"
                class="modal-content bg-default"
                @focusin.stop
            >
                <div v-if="slots.header" class="modal-header">
                    <slot name="header" />
                </div>
                <div class="modal-body">
                    <slot />
                </div>
                <div class="modal-actions d-flex-row">
                    <UiAppButton
                        class="cancel-btn text-primary"
                        @click="emit('close')"
                    >
                        取消
                    </UiAppButton>
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
        hasBackdrop?: boolean
        zIndex?: number
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
    const { hasBackdrop = false, zIndex = 1000 } = defineProps<Props>()

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
        width: calc(
            100% - env(safe-area-inset-right) - env(safe-area-inset-left)
        );
        max-width: 400px;
        border-radius: 20px;
        padding: 20px;
    }
    .modal-content > *:not(:last-child) {
        margin-bottom: 20px;
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
