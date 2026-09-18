<template>
    <ul
        ref="list-box"
        :aria-activedescendant="activeOptionId"
        class="list-box bg-default"
        role="listbox"
        tabindex="0"
        @keydown.arrow-up.prevent="prev"
        @keydown.arrow-down.prevent="next"
        @keydown.enter.prevent="emit('select:option', activeOptionId)"
        @keydown.space.prevent="emit('select:option', activeOptionId)"
    >
        <li
            v-for="option in options"
            :ref="
                (el) => {
                    optionRefsMap.set(option.id, el as HTMLElement)
                }
            "
            :key="option.id"
            :aria-selected="selectedOptionId === option.id"
            :class="
                activeOptionId === option.id
                    ? `text-${color}-emphasis`
                    : `text-${color}`
            "
            class="option d-flex-row"
            role="option"
        >
            <span class="option-name">{{ option.name }}</span>
            <UiGSymbol v-if="selectedOptionId === option.id" aria-hidden="true"
                >check</UiGSymbol
            >
        </li>
    </ul>
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
    // types
    type Props = {
        color?: 'primary' | 'secondary'
        options: T[]
        width?: string
        selectedOptionId: string
    }
    type Emits = {
        'select:option': [id: string]
    }

    // props
    const {
        color = 'primary',
        width = '300px',
        options,
        selectedOptionId,
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    const activeOptionId = ref(selectedOptionId)
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

    const optionRefsMap = ref<Map<string, HTMLElement>>(new Map())
    watch(activeOptionId, (newId) => {
        const newActiveItemRef = optionRefsMap.value.get(newId)
        if (!newActiveItemRef) return
        newActiveItemRef.scrollIntoView({ block: 'nearest' })
    })

    const listBoxRef = useTemplateRef('list-box')
    defineExpose({ el: listBoxRef })

    const { isDarkMode } = useDarkMode()
    const appConfig = useAppConfig()
    const dividerBgColor = computed(() => {
        if (color === 'primary') {
            return isDarkMode.value
                ? appConfig.dark.primarySubtle
                : appConfig.color.primarySubtle
        } else {
            return isDarkMode.value
                ? appConfig.dark.secondarySubtle
                : appConfig.color.secondarySubtle
        }
    })
</script>

<style scoped>
    .list-box {
        width: v-bind(width);
        border-radius: 10px;
        z-index: 600;
        overflow-y: auto;
        outline: none;
    }
    .option {
        border-radius: 10px;
        height: 42px;
        cursor: pointer;
        justify-content: space-between;
        align-items: center;
        position: relative;
    }
    .option.text-primary:hover {
        color: var(--color-primary-emphasis);
    }
    .option.text-secondary:hover {
        color: var(--color-secondary-emphasis);
    }
    .option:not(:last-child)::after {
        content: '';
        height: 1px;
        display: block;
        position: absolute;
        inset: auto 0 0 0;
        background-color: v-bind(dividerBgColor);
    }
</style>
