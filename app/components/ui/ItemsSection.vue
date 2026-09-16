<template>
    <section class="items-section">
        <header class="d-flex-row">
            <div v-if="slots.leading" class="leading">
                <slot name="leading" />
            </div>
            <h2 class="title text-truncate">
                {{ title }}
            </h2>
        </header>
        <div class="divider bg-primary-subtle" />
        <UiItems v-slot="{ item }" :items="items" gap="10px" item-indent="46px">
            <slot name="item" :item="item" />
        </UiItems>
        <UiEmptyMessage
            v-if="items.length === 0 && emptyMessage"
            :empty-message="emptyMessage"
        />
        <div v-if="slots.extra" class="section-extra">
            <slot name="extra" />
        </div>
    </section>
</template>

<script setup lang="ts" generic="T extends { id: string; name: string }">
    // types
    type Props = {
        items: T[]
        title: string
        emptyMessage?: string
    }
    type Slots = {
        leading(): unknown
        item(props: { item: T }): unknown
        extra(): unknown
    }

    // props
    const { items, emptyMessage = '' } = defineProps<Props>()

    // slots
    const slots = defineSlots<Slots>()
</script>

<style scoped>
    header {
        align-items: center;
        margin-bottom: 10px;
        gap: 4px;
    }
    .leading {
        padding: 6px;
    }
    .title {
        font-size: 24px;
        font-weight: 600;
    }
    .divider {
        height: 1px;
        margin-bottom: 10px;
    }

    .items-section > *:not(:last-child) {
        margin-bottom: 10px;
    }
</style>
