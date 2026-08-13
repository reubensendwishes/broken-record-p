<template>
    <Teleport to="#teleports">
        <div v-bind="$attrs" class="toast-container">
            <TransitionGroup name="toasts">
                <div
                    v-for="toast in toasts"
                    :key="toast.id"
                    class="toast d-flex-row border-primary bg-default text-primary"
                >
                    <div class="icon-wrapper">
                        <UiGSymbol>{{ toastIcon(toast.type) }}</UiGSymbol>
                    </div>
                    <p class="toast-message">{{ toast.message }}</p>
                    <UiButton
                        class="text-primary"
                        @click="removeToast(toast.id)"
                    >
                        <UiGSymbol>close</UiGSymbol>
                    </UiButton>
                </div>
            </TransitionGroup>
        </div>
    </Teleport>
</template>

<script setup lang="ts">
    defineOptions({
        inheritAttrs: false,
    })

    const { toasts, removeToast } = useToasts()

    const toastIcon = (type: 'success' | 'error') => {
        if (type === 'success') {
            return 'check_circle'
        } else if (type === 'error') {
            return 'error'
        }
    }
</script>

<style scoped>
    .toast-container {
        position: fixed;
        width: fit-content;
        height: fit-content;
        right: calc(20px + env(safe-area-inset-right));
        top: calc(20px + env(safe-area-inset-top));
        align-items: end;
        z-index: 2000;
    }
    .toasts-enter-active,
    .toasts-leave-active {
        transition:
            opacity 0.5s ease,
            transform 0.5s ease;
    }
    .toasts-leave-active:not(:last-child) {
        position: absolute;
    }
    .toasts-move {
        transition: transform 0.5s ease;
    }
    .toasts-enter-from,
    .toasts-leave-to {
        opacity: 0;
        transform: translateX(100%);
    }
    .toast {
        gap: 10px;
        width: fit-content;
        max-width: 400px;
        padding: calc(24px + env(safe-area-inset-top))
            calc(24px + env(safe-area-inset-right))
            calc(24px + env(safe-area-inset-bottom))
            calc(24px + env(safe-area-inset-left));
        border-radius: 10px;
        align-items: center;
        box-shadow: 0 0 16px var(--color-primary);
        margin-left: auto;
    }
    .toast:not(:last-child) {
        margin-bottom: 20px;
    }
    .icon-wrapper {
        padding: 6px;
    }
    .toast-message {
        overflow-wrap: break-word;
        overflow: auto;
    }
</style>
