<template>
    <UiModal
        has-backdrop
        label-id="item-picker-title"
        class="item-picker"
        :has-actions="false"
        @close="emit('close')"
    >
        <template #header>
            <div class="wrapper">
                <h3
                    id="item-picker-title"
                    class="title text-truncate text-primary"
                >
                    選取
                </h3>
                <UiButton
                    class="close-btn text-primary"
                    aria-label="關閉選取清單"
                    @click="emit('close')"
                >
                    <UiGSymbol aria-hidden="true">close</UiGSymbol>
                </UiButton>
            </div>
            <UiSearchBar
                id="item-picker-search-bar"
                v-model="searchQuery"
                class="item-picker-search-bar"
                :placeholder="placeholder"
                width="100%"
            />
        </template>
        <template #default>
            <UiItems v-slot="{ item }" item-indent="0px" :items="displayItems">
                <UiButton
                    class="text-secondary item-content text-truncate"
                    width="100%"
                    text-align="start"
                    @click="emit('select:item', item.id)"
                >
                    {{ item.name }}
                </UiButton>
            </UiItems>
            <UiEmptyMessage
                v-if="displayItems.length === 0"
                :empty-message="emptyMessage"
            />
        </template>
    </UiModal>
</template>

<script
    setup
    lang="ts"
    generic="
        T extends {
            name: string
            id: string
        }
    "
>
    // types
    type Props = {
        items: T[]
        placeholder: string
    }
    type Emits = {
        'select:item': [id: string]
        close: []
    }

    // props
    const { items, placeholder } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    const searchQuery = ref('')
    const displayItems = computed(() => {
        return items.filter((item) => {
            return item.name
                .toLowerCase()
                .includes(searchQuery.value.toLowerCase())
        })
    })
    const emptyMessage = computed(() => {
        if (items.length === 0) {
            return '沒有可選取項目。'
        }
        return '無任何搜尋結果。'
    })
</script>

<style scoped>
    .wrapper {
        position: relative;
        text-align: end;
        margin-bottom: 10px;
    }
    .title {
        font-size: 24px;
        line-height: 1.25;
        text-align: center;
        font-weight: 600;
        position: absolute;
        inset: 50% auto auto 50%;
        transform: translate(-50%, -50%);
    }
</style>
