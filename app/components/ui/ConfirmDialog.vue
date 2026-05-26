<template>
    <UiAppModal has-backdrop class="confirm-dialog" @close="answer(false)">
        <template #header
            ><h3 class="text-primary-subtle confirm-title">
                確認視窗
            </h3></template
        >
        <p class="confirm-message">{{ confirmDialogState.message }}</p>
        <template #primary-action>
            <UiAppButton class="text-primary" @click="answer(true)"
                >確認</UiAppButton
            >
        </template>
    </UiAppModal>
</template>

<script setup lang="ts">
    const { answer, confirmDialogState } = useConfirm()
</script>

<style>
    .confirm-dialog .confirm-title {
        text-align: center;
        font-weight: 500;
        font-size: 24px;
    }
</style>
