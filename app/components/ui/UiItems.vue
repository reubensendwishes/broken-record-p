<template>
    <ul class="items d-flex-column">
        <li
            v-for="(item, index) in items"
            :key="item.id"
            class="item text-secondary"
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
    }
    type Slots = {
        default(props: { item: T; index: number }): unknown
    }

    // props
    const { items, itemIndent = '52px', gap = '10px' } = defineProps<Props>()

    // slots
    defineSlots<Slots>()

    const releaseCapture = (event: PointerEvent) => {
        const target = event.target as HTMLElement
        if (!target) return
        target.releasePointerCapture(event.pointerId)
    }

    const dividerBottom = computed(() => {
        return `-${parseInt(gap) / 2 + 1}px`
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
        background-color: var(--color-secondary-subtle);
    }
</style>
