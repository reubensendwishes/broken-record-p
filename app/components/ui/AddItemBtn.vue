<template>
    <UiButton
        width="100%"
        rounded-left="10px"
        rounded-right="10px"
        :disabled="isDisabled"
        :class="
            type === 'secondary'
                ? ['text-secondary', 'border-secondary']
                : ['text-primary', 'border-primary']
        "
        class="add-item-btn d-flex-row dashed"
        @click="emit('add:item')"
    >
        <UiGSymbol>add_2</UiGSymbol>
        <span>{{ btnName }}</span>
    </UiButton>
</template>

<script setup lang="ts">
    // types
    type Emits = {
        'add:item': []
    }
    type Props = {
        btnName: string
        type?: 'primary' | 'secondary'
        isDisabled?: boolean
    }

    // props
    const {
        btnName,
        type = 'secondary',
        isDisabled = false,
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()
</script>

<style scoped>
    .add-item-btn {
        gap: 10px;
        justify-content: center;
    }
</style>
