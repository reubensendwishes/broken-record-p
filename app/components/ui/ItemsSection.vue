<template>
    <section class="items-section">
        <header class="d-flex-row">
            <div v-if="slots.leading" class="leading">
                <slot name="leading" />
            </div>
            <h2 v-if="slots.title" class="title text-truncate">
                <slot name="title" />
            </h2>
        </header>
        <div class="divider bg-primary-subtle" />
        <UiItems v-slot="{ item }" :items="items" gap="10px" item-indent="46px">
            <slot name="item" :item="item" />
        </UiItems>
        <UiEmptyMessage
            v-if="items.length === 0"
            :empty-message="emptyMessage"
        />
        <div v-if="viewAllRoute" class="link-wrapper">
            <UiLink
                :to="viewAllRoute"
                rounded-left="9999px"
                rounded-right="9999px"
                padding-x="10px"
                padding-y="4px"
                class="view-all-link border-secondary text-secondary"
            >
                <span class="btn-text">View all</span>
                <UiGSymbol font-size="20px">arrow_forward</UiGSymbol>
            </UiLink>
        </div>
    </section>
</template>

<script setup lang="ts" generic="T extends { id: string; name: string }">
    import type { RouteLocationRaw } from 'vue-router'

    // types
    type Props = {
        items: T[]
        emptyMessage: string
        viewAllRoute?: RouteLocationRaw
    }
    type Slots = {
        leading(): unknown
        title(): unknown
        item(props: { item: T }): unknown
    }

    // props
    const { items, emptyMessage, viewAllRoute } = defineProps<Props>()

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
    .link-wrapper {
        text-align: end;
    }
    .view-all-link {
        margin: 0 auto;
        font-size: 16px;
        justify-content: center;
        align-items: center;
        gap: 6px;
    }
    .items-section > *:not(:last-child) {
        margin-bottom: 10px;
    }
</style>
