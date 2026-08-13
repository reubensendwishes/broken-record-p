<template>
    <Teleport to="#teleports">
        <div v-bind="$attrs" class="bottom-sheet" @keydown.esc="emit('close')">
            <UiBackdrop
                v-if="hasBackdrop"
                class="sheet-backdrop"
                @click="emit('close')"
            />
            <div
                ref="sheet-content"
                v-focus="hasBackdrop"
                tabindex="-1"
                :class="hasBackdrop && 'has-backdrop'"
                class="sheet-content bg-default"
                @focusin.stop
            >
                <div v-if="slots.header" class="sheet-header">
                    <slot name="header" />
                </div>
                <div class="sheet-body">
                    <slot />
                </div>
                <div v-if="hasActions" class="sheet-actions d-flex-row">
                    <UiButton
                        class="cancel-btn text-primary"
                        @click="emit('close')"
                    >
                        取消
                    </UiButton>
                    <div v-if="slots['primary-action']" class="primary-action">
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
        zIndex = 900,
        hasActions = false,
    } = defineProps<Props>()

    // slots
    const slots = defineSlots<Slots>()

    // options
    defineOptions({ inheritAttrs: false })

    const sheetContentRef = useTemplateRef('sheet-content')

    const focusSheet = () => {
        sheetContentRef.value?.focus()
    }
    onMounted(() => {
        if (hasBackdrop) {
            document.body.addEventListener('focusin', focusSheet)
        }
    })
    onBeforeUnmount(() => {
        if (hasBackdrop) {
            document.body.removeEventListener('focusin', focusSheet)
        }
    })
    useHead({
        bodyAttrs: {
            class: hasBackdrop ? 'no-scroll' : '',
        },
    })
</script>

<style scoped>
    .bottom-sheet {
        z-index: v-bind(zIndex);
        position: fixed;
        inset: 0;
        pointer-events: none;
    }
    .sheet-content {
        position: absolute;
        bottom: 0;
        left: 50%;
        transform: translateX(-50%);
        border-radius: 20px 20px 0 0;
        padding: 20px
            calc(
                clamp(
                        0px,
                        env(safe-area-inset-right) - 50dvw + 200px,
                        env(safe-area-inset-right)
                    ) +
                    20px
            )
            calc(20px + env(safe-area-inset-bottom))
            calc(
                clamp(
                        0px,
                        env(safe-area-inset-left) - 50dvw + 200px,
                        env(safe-area-inset-left)
                    ) +
                    20px
            );
        pointer-events: auto;
        width: min(400px, 100%);
    }
    .sheet-content:not(.has-backdrop) {
        box-shadow: 0 -6px 10px rgba(var(--color-primary-rgb), 0.2);
    }
    .sheet-body {
        overflow: auto;
    }
    .sheet-actions {
        justify-content: center;
        gap: 10px;
    }
</style>
