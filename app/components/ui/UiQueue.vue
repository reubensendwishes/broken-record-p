<template>
    <UiModal
        class="queue"
        has-backdrop
        :label-id="labelId"
        :has-actions="false"
        @close="emit('close')"
    >
        <template #header>
            <div class="modal-header-content d-flex-row">
                <template v-if="isSearchBarOpen">
                    <UiButton
                        class="back-btn text-primary"
                        @click="isSearchBarOpen = false"
                    >
                        <UiGSymbol>arrow_back</UiGSymbol>
                    </UiButton>
                    <UiSearchBar
                        id="queue-search-bar"
                        :placeholder="searchBarPlaceholder"
                        @close="isSearchBarOpen = false"
                    />
                </template>
                <template v-else>
                    <h3 :id="labelId" class="title text-truncate">
                        {{ title }}
                    </h3>
                    <UiButton
                        class="search-btn text-primary"
                        @click="isSearchBarOpen = true"
                    >
                        <UiGSymbol> search </UiGSymbol>
                    </UiButton>
                </template>
            </div>
        </template>
        <template #default>
            <UiItems
                :color="itemsColor"
                item-indent="0"
                :items="items"
                v-slot="{ item, index }"
            >
                <UiButton
                    :class="'text-' + itemsColor"
                    class="item-content"
                    width="100%"
                    @click="emit('jump', item.id, index)"
                >
                    <div class="btn-content d-flex-row">
                        <span> {{ item.name }}</span>
                        <div
                            v-if="currentItemId === item.id"
                            class="current-icon-wrapper"
                        >
                            <UiGSymbol>pin_drop</UiGSymbol>
                        </div>
                    </div>
                </UiButton>
            </UiItems>
        </template>
    </UiModal>
</template>

<script setup lang="ts" generic="T extends { name: string; id: string }">
    // types
    type Props = {
        items: T[]
        title: string
        searchBarPlaceholder: string
        currentItemId: string
        itemsColor?: 'primary' | 'secondary'
        labelId: string
    }
    type Emits = {
        jump: [id: string, index: number]
        close: []
    }

    // props
    const {
        items,
        title,
        searchBarPlaceholder,
        itemsColor = 'secondary',
        labelId,
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    const isSearchBarOpen = ref(false)
</script>

<style scoped>
    .modal-header-content {
        align-items: center;
        gap: 10px;
        height: 46px;
    }
    .title {
        margin-left: 6px;
        font-size: 24px;
        font-weight: 600;
    }
    .search-btn {
        margin-left: auto;
    }
    .current-icon-wrapper {
        margin-left: auto;
    }
</style>
