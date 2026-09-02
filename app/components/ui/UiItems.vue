<template>
    <ul class="items d-flex-column">
        <li
            v-for="(item, index) in items"
            :key="item.id"
            :class="'text-' + color"
            class="item"
            :data-item-id="item.id"
        >
            <slot :item="item" :index="index" />
        </li>
    </ul>
</template>

<script setup lang="ts" generic="T extends { id: string; name: string }">
    type Props = {
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
        items,
        itemIndent = '50px',
        gap = '10px',
        color = 'secondary',
    } = defineProps<Props>()

    // slots
    defineSlots<Slots>()

    const { isDarkMode } = useDarkMode()
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
