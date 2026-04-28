<template>
    <div
        class="search-bar text-primary-emphasis bg-primary-subtle pill-border d-flex-row"
    >
        <ui-g-symbol class="search-icon" font-size="30px">search</ui-g-symbol>
        <input
            :id="id"
            v-model.trim="searchQuery"
            enterkeyhint="search"
            class="search-input bg-primary-subtle"
            type="search"
            :placeholder="placeholder"
            @keydown.enter="emit('keydown-enter', searchQuery)"
        />
        <ui-app-button
            v-if="searchQuery"
            class="text-primary cancel-button"
            @click="searchQuery = ''"
        >
            <ui-g-symbol font-size="30px">close</ui-g-symbol>
        </ui-app-button>
    </div>
</template>

<script setup lang="ts">
    // types
    type Props = {
        id: string
        placeholder?: string
    }
    type Emits = {
        'keydown-enter': [searchQuery: string]
    }

    // props
    const { id, placeholder = '搜尋' } = defineProps<Props>()

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
