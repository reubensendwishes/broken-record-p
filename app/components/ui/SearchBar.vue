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
        />
        <UiAppButton
            v-if="searchQuery"
            class="text-primary cancel-button"
            @click="searchQuery = ''"
        >
            <UiGSymbol>close</UiGSymbol>
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

    // props
    const {
        id,
        label = '搜尋欄',
        placeholder = '搜尋...',
    } = defineProps<Props>()

    // models
    const searchQuery = defineModel<string>()

    const searchBarRef = useTemplateRef('search-bar')

    // exposes
    defineExpose({
        searchBarRef,
    })
</script>

<style>
    .search-bar {
        overflow: hidden;
        position: relative;
        height: 46px;
        width: 100%;
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
        padding: 0 10px 0 50px;
    }
    .search-input::placeholder {
        color: var(--color-primary-subtle);
    }
    .search-bar > .cancel-button {
        margin-right: 4px;
    }
</style>
