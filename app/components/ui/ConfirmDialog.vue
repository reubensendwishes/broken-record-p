<template>
    <UiModal has-backdrop class="confirm-dialog" @close="answer(false)">
        <template #header
            ><h3 class="text-primary-subtle confirm-title">
                確認視窗
            </h3></template
        >
        <p class="confirm-message">{{ confirmDialogState.message }}</p>
        <template #primary-action>
            <UiButton class="text-primary" @click="answer(true)">確認</UiButton>
        </template>
    </UiModal>
</template>

<script setup lang="ts">
    const { answer, confirmDialogState } = useConfirm()
</script>

<style scoped>
    .confirm-dialog .confirm-title {
        text-align: center;
        font-weight: 500;
        font-size: 24px;
    }
</style>
