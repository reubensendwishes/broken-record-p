<template>
    <UiModal has-backdrop class="confirm-dialog" @close="answer(false)">
        <template #header>
            <h3 class="text-primary confirm-title">Confirm dialog</h3>
        </template>
        <p class="confirm-message">{{ confirmDialogState.message }}</p>
        <template #primary-action>
            <UiButton class="text-primary" @click="answer(true)"
                >confirm</UiButton
            >
        </template>
    </UiModal>
</template>

<script setup lang="ts">
    const { answer, confirmDialogState } = useConfirm()
</script>

<style scoped>
    .confirm-dialog .confirm-title {
        text-align: center;
        font-weight: 600;
        font-size: 24px;
    }
</style>
