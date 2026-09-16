<template>
    <div class="dropdown">
        <UiItems
            v-if="isMenuOpen"
            v-slot="{ item }"
            ref="ui-items"
            v-focus
            :active-item-id="activeOptionId"
            :style="floatingStyles"
            :color="color"
            :class="'border-' + color"
            class="dropdown-menu bg-default"
            gap="0px"
            role="listbox"
            :aria-label="title"
            tabindex="0"
            :aria-activedescendant="activeOptionId"
            :items="options"
            item-indent="0px"
            @keydown.arrow-up.prevent="prev"
            @keydown.arrow-down.prevent="next"
            @keydown.enter.prevent="emit('select:option', activeOptionId)"
            @keydown.space.prevent="emit('select:option', activeOptionId)"
            @keydown.esc.prevent="emit('close')"
        >
            <div
                :id="item.id"
                class="option d-flex-row"
                role="option"
                :aria-selected="selectedOptionId === item.id"
                @click="emit('select:option', item.id)"
            >
                <div class="option-name text-truncate">
                    {{ item.name }}
                </div>
                <UiGSymbol
                    v-if="selectedOptionId === item.id"
                    aria-hidden="true"
                    >check</UiGSymbol
                >
            </div>
        </UiItems>
    </div>
</template>

<script
    setup
    lang="ts"
    generic="
        T extends {
            id: string
            name: string
        }
    "
>
    import {
        useFloating,
        shift,
        flip,
        offset,
        size,
        autoUpdate,
    } from '@floating-ui/vue'
    import type { ComponentExposed } from 'vue-component-type-helpers'
    import UiItems from '@/components/ui/UiItems.vue'

    // types
    type Props = {
        color?: 'primary' | 'secondary'
        title: string
        isMenuOpen: boolean
        options: T[]
        trigger: HTMLElement | null
        selectedOptionId: string
    }
    type Emits = {
        'select:option': [id: string]
        close: []
    }

    // props
    const {
        color = 'primary',
        title,
        isMenuOpen,
        options,
        trigger,
        selectedOptionId,
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    const uiItemsRef =
        useTemplateRef<ComponentExposed<typeof UiItems>>('ui-items')
    const reference = computed(() => trigger)
    const dropdownMenuRef = computed(() => uiItemsRef.value?.el ?? null)
    const { floatingStyles } = useFloating(reference, dropdownMenuRef, {
        whileElementsMounted: autoUpdate,
        placement: 'bottom-start',
        middleware: [
            offset(4),
            shift({ padding: 10 }),
            flip(),
            size({
                apply({ availableHeight, elements }) {
                    Object.assign(elements.floating.style, {
                        maxHeight: `${Math.max(0, availableHeight)}px`,
                    })
                },
            }),
        ],
    })
    const activeOptionId = ref('')
    const prev = () => {
        const currentIndex = options.findIndex(
            (option) => option.id === activeOptionId.value,
        )
        const prevIndex = (currentIndex - 1 + options.length) % options.length
        activeOptionId.value = options[prevIndex]!.id
    }
    const next = () => {
        const currentIndex = options.findIndex(
            (option) => option.id === activeOptionId.value,
        )
        const nextIndex = (currentIndex + 1) % options.length
        activeOptionId.value = options[nextIndex]!.id
    }
    const handlePointerDown = (event: Event) => {
        const target = event.target as HTMLElement
        if (
            dropdownMenuRef.value &&
            !dropdownMenuRef.value.contains(target) &&
            trigger &&
            !trigger.contains(target)
        ) {
            emit('close')
        }
    }
    watch(
        () => isMenuOpen,
        (newValue) => {
            if (newValue) {
                activeOptionId.value = selectedOptionId ?? ''
                document.addEventListener('pointerdown', handlePointerDown)
            } else {
                document.removeEventListener('pointerdown', handlePointerDown)
            }
        },
    )

    onBeforeUnmount(() => {
        document.removeEventListener('pointerdown', handlePointerDown)
    })
</script>

<style scoped>
    .dropdown-menu {
        width: 300px;
        border-radius: 10px;
        padding: 10px;
        z-index: 600;
        overflow-y: auto;
        outline: none;
    }
    .option {
        height: 42px;
        cursor: pointer;
        justify-content: space-between;
        align-items: center;
    }
    .option.text-primary:hover {
        color: var(--color-primary-emphasis);
    }
    .option.text-secondary:hover {
        color: var(--color-secondary-emphasis);
    }
</style>
