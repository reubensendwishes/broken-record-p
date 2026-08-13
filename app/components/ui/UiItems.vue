<template>
    <ul class="items d-flex-column">
        <li
            v-for="(item, index) in items"
            :key="item.id"
            :class="[
                sortableChosenId === item.id && 'sortable-chosen',
                selectedItemId === item.id && 'border-secondary',
                selectedItemId === item.id && 'selected',
            ]"
            class="item text-secondary no-select"
            :data-item-id="item.id"
            @pointerdown="releaseCapture"
        >
            <slot :item="item" :index="index" />
        </li>
    </ul>
</template>

<script setup lang="ts" generic="T extends { id: string; name: string }">
    type Props = {
        items: T[]
        selectedItemId?: string
        sortableChosenId?: string
        itemIndent?: `${number}px`
    }
    type Slots = {
        default(props: { item: T; index: number }): unknown
    }

    // props
    const {
        items,
        selectedItemId = '',
        sortableChosenId = '',
        itemIndent = '52px',
    } = defineProps<Props>()

    // slots
    defineSlots<Slots>()

    const releaseCapture = (event: PointerEvent) => {
        const target = event.target as HTMLElement
        if (!target) return
        target.releasePointerCapture(event.pointerId)
    }
</script>

<style scoped>
    .items {
        margin-bottom: 10px;
        gap: 10px;
    }
    .item {
        padding: 2px 2px 2px calc(2px + v-bind(itemIndent));
        border-radius: 10px;
        overflow: hidden;
        height: fit-content;
    }
    .item.selected {
        padding: 0 0 0 v-bind(itemIndent);
    }
    .item.sortable-chosen {
        box-shadow:
            0px 2px 3px var(--color-secondary-emphasis),
            0px -2px 3px var(--color-secondary-emphasis);
    }
</style>
