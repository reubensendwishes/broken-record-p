<template>
    <div
        ref="search-bar"
        class="search-bar d-flex-row border-primary pill-border text-primary-subtle"
    >
        <UiGSymbol class="search-icon">search</UiGSymbol>
        <input
            :id="id"
            v-model.trim="searchQuery"
            enterkeyhint="search"
            class="search-input text-primary"
            type="search"
            :placeholder="placeholder"
            :aria-label="label"
            @keydown.esc="emit('close')"
        />
        <UiButton
            v-if="searchQuery"
            class="text-primary cancel-button"
            @click="searchQuery = ''"
            aria-label="Clear search query"
        >
            <UiGSymbol aria-hidden="true">close</UiGSymbol>
        </UiButton>
    </div>
</template>

<script setup lang="ts">
    // types
    type Props = {
        id: string
        label?: string
        placeholder?: string
        width?: string
    }
    type Emits = {
        close: []
    }

    // props
    const {
        id,
        label = '搜尋欄',
        placeholder = 'Search...',
        width = 'fit-content',
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    // models
    const searchQuery = defineModel<string>()

    const searchBarRef = useTemplateRef('search-bar')

    // exposes
    defineExpose({
        searchBarRef,
    })
</script>

<style scoped>
    .search-bar {
        overflow: hidden;
        position: relative;
        height: 46px;
        width: v-bind(width);
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
        min-width: 0;
        padding: 0 10px 0 50px;
    }
    .search-input::placeholder {
        color: var(--color-primary-subtle);
    }
    .search-bar > .cancel-button {
        margin-right: 4px;
    }
</style>
