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
                    {{ title }}
                </h3>
                <UiButton class="close-btn text-primary" @click="emit('close')">
                    <UiGSymbol>close</UiGSymbol>
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
            <UiItems item-indent="0px" :items="displayItems" v-slot="{ item }">
                <slot :item="item" />
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
        title: string
        placeholder: string
    }
    type Emits = {
        close: []
    }
    type Slots = {
        default(props: { item: T }): unknown
    }

    // props
    const { items, title, placeholder } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    // slots
    defineSlots<Slots>()

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
            return 'No tracks available'
        }
        return 'No results found'
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
