<template>
    <Teleport to="#teleports">
        <div
            v-bind="$attrs"
            :class="isMenuExpanded && 'expand'"
            class="fab-menu"
            @focusin.stop
        >
            <UiBackdrop
                v-if="isMenuExpanded"
                class="fab-menu-backdrop"
                @click="isMenuExpanded = false"
            />
            <ul class="fab-menu-list">
                <li class="fab-menu-item">
                    <UiButton
                        ref="toggle-btn"
                        padding-x="15px"
                        padding-y="15px"
                        rounded-left="9999px"
                        rounded-right="9999px"
                        class="toggle-btn fab-menu-btn text-inverse bg-primary"
                        @click="isMenuExpanded = !isMenuExpanded"
                    >
                        <UiGSymbol>add</UiGSymbol>
                    </UiButton>
                </li>
                <template v-if="isMenuExpanded">
                    <li
                        v-for="item in fabItems"
                        :key="item.name"
                        class="fab-menu-item"
                    >
                        <UiButton
                            padding-x="18px"
                            padding-y="18px"
                            rounded-left="9999px"
                            rounded-right="9999px"
                            class="fab-menu-btn text-primary bg-default"
                            @click="emit('click', item.name)"
                        >
                            {{ item.name }}</UiButton
                        >
                    </li>
                </template>
            </ul>
        </div>
    </Teleport>
</template>

<script setup lang="ts" generic="T extends string">
    import type { FabItems } from '~/types'

    // types
    type Props = {
        zIndex?: number
        fabItems: FabItems<T>
    }
    type Emits = {
        click: [name: T]
    }

    // props
    const { zIndex = 800, fabItems } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    // options
    defineOptions({ inheritAttrs: false })

    const isMenuExpanded = defineModel<boolean>('is-expanded', {
        required: false,
    })

    const toggleBtnRef = useTemplateRef('toggle-btn')
    const focusToggleBtn = () => {
        toggleBtnRef.value?.$el.focus()
    }

    watch(isMenuExpanded, async (newVal) => {
        if (newVal) {
            focusToggleBtn()
            document.body.addEventListener('focusin', focusToggleBtn)
        } else {
            document.body.removeEventListener('focusin', focusToggleBtn)
        }
    })
</script>

<style scoped>
    .fab-menu {
        z-index: v-bind(zIndex);
        position: fixed;
        inset: 0;
        pointer-events: none;
    }
    .fab-menu-list {
        display: flex;
        flex-direction: column-reverse;
        gap: 10px;
        align-items: flex-end;
        position: absolute;
        right: calc(
            20px + max(env(safe-area-inset-left), env(safe-area-inset-right))
        );
        bottom: calc(20px + env(safe-area-inset-bottom));
        pointer-events: auto;
    }
    .fab-menu-btn.toggle-btn {
        transition: transform 0.5s;
        box-shadow: 0 0 16px var(--color-primary);
    }
    .fab-menu.expand .fab-menu-btn.toggle-btn {
        transform: rotate(45deg);
    }
</style>
