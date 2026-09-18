<template>
    <div class="dropdown">
        <UiListBox
            v-if="isListOpen"
            ref="list-box"
            v-focus
            :aria-label="title"
            :color="color"
            :class="'border-' + color"
            :options="options"
            :selected-option-id="selectedOptionId"
            :style="floatingStyles"
            @select:option="
                (id: string) => {
                    emit('select:option', id)
                }
            "
            @keydown.esc.prevent="emit('close')"
        />
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
    import type ListBox from '@/components/ui/ListBox.vue'

    // types
    type Props = {
        color?: 'primary' | 'secondary'
        title: string
        isListOpen: boolean
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
        isListOpen,
        options,
        trigger,
        selectedOptionId,
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    const listBoxRef =
        useTemplateRef<ComponentExposed<typeof ListBox>>('list-box')
    const reference = computed(() => trigger)
    const dropdownListRef = computed(() => listBoxRef.value?.el ?? null)
    const { floatingStyles } = useFloating(reference, dropdownListRef, {
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

    const handlePointerDown = (event: Event) => {
        const target = event.target as HTMLElement
        if (
            dropdownListRef.value &&
            !dropdownListRef.value.contains(target) &&
            trigger &&
            !trigger.contains(target)
        ) {
            emit('close')
        }
    }
    watch(
        () => isListOpen,
        (newValue) => {
            if (newValue) {
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
    .list-box {
        padding: 10px;
    }
</style>
