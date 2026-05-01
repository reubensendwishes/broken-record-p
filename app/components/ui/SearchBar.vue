<template>
    <div
        class="search-bar text-primary-emphasis bg-primary-subtle pill-border d-flex-row"
    >
        <UiGSymbol class="search-icon" font-size="30px">search</UiGSymbol>
        <input
            :id="id"
            v-model.trim="searchQuery"
            enterkeyhint="search"
            class="search-input bg-primary-subtle"
            type="search"
            :placeholder="placeholder"
            :aria-label="label"
            @keydown.enter="emit('keydown-enter', searchQuery)"
        />
        <UiAppButton
            v-if="searchQuery"
            class="text-primary cancel-button"
            @click="searchQuery = ''"
        >
            <UiGSymbol font-size="30px">close</UiGSymbol>
        </UiAppButton>
    </div>
</template>

<script setup lang="ts">
    // types
    type Props = {
        id: string
        label?: string
        placeholder?: string
    }
    type Emits = {
        'keydown-enter': [searchQuery: string]
    }

    // props
    const { id, label = '搜尋欄', placeholder = '搜尋' } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()
    const searchQuery = ref('')
</script>

<style scoped>
    .search-bar {
        border: none;
        overflow: hidden;
        position: relative;
        align-items: center;
    }
    .search-icon {
        position: absolute;
        left: 10px;
        top: 50%;
        transform: translateY(-50%);
        pointer-events: none;
    }
    .search-input {
        flex-grow: 1;
        height: 50px;
        padding: 10px 10px 10px 50px;
    }
    .search-input::placeholder {
        color: var(--color-primary);
    }
    .cancel-button {
        margin-right: 4px;
    }
</style>
