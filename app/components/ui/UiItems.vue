<template>
    <ul ref="items" class="items d-flex-column">
        <li
            v-for="(item, index) in items"
            :ref="
                (el) => {
                    itemRefsMap.set(item.id, el as HTMLElement)
                }
            "
            :key="item.id"
            :class="
                activeItemId === item.id
                    ? `text-${color}-emphasis`
                    : `text-${color}`
            "
            class="item"
            :data-item-id="item.id"
        >
            <slot :item="item" :index="index" />
        </li>
    </ul>
</template>

<script setup lang="ts" generic="T extends { id: string; name: string }">
    type Props = {
        activeItemId?: string
        items: T[]
        itemIndent?: string
        gap?: string
        color?: 'primary' | 'secondary'
    }
    type Slots = {
        default(props: { item: T; index: number }): unknown
    }

    // props
    const {
        activeItemId = '',
        items,
        itemIndent = '50px',
        gap = '10px',
        color = 'secondary',
    } = defineProps<Props>()

    // slots
    defineSlots<Slots>()

    const itemRefsMap = ref<Map<string, HTMLElement>>(new Map())
    const itemsRef = useTemplateRef('items')
    defineExpose({ el: itemsRef })

    const { isDarkMode } = await useDarkMode()
    const dividerBottom = computed(() => {
        return `-${parseInt(gap) / 2 + 1}px`
    })
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

    watch(
        () => activeItemId,
        (newId) => {
            const newActiveItemRef = itemRefsMap.value.get(newId)
            if (!newActiveItemRef) return
            newActiveItemRef.scrollIntoView({ block: 'nearest' })
        },
    )
</script>

<style scoped>
    .items {
        gap: v-bind(gap);
    }
    .item {
        padding: 0 0 0 calc(0px + v-bind(itemIndent));
        border-radius: 10px;
        height: fit-content;
        position: relative;
    }
    .item:not(:last-child)::after {
        content: '';
        height: 1px;
        display: block;
        position: absolute;
        inset: auto 0 v-bind(dividerBottom) 0;
        background-color: v-bind(dividerBgColor);
    }
</style>
