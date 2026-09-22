<template>
    <UiBottomSheet
        label="網頁使用者選單"
        class="app-user-menu"
        has-backdrop
        @close="emit('close')"
    >
        <template #default>
            <UiItems
                v-slot="{ item }"
                color="primary"
                item-indent="0px"
                :items="details"
            >
                <div class="item-wrapper">
                    <UiButton
                        width="100%"
                        text-align="start"
                        class="text-primary"
                        :aria-haspopup="item.haspopup"
                        @click="item.handler"
                    >
                        {{ item.name }}
                    </UiButton>
                </div>
            </UiItems>
        </template>
    </UiBottomSheet>
</template>

<script setup lang="ts">
    // types
    type Emits = {
        close: []
    }

    // emits
    const emit = defineEmits<Emits>()

    const supabase = useSupabaseClient()
    const { confirm } = useConfirm()
    const { addToast } = useToasts()

    const details = [
        {
            id: useId(),
            name: '設定',
            handler() {
                navigateTo('/settings')
            },
        },
        {
            id: useId(),
            name: '登出',
            haspopup: 'dialog',
            async handler() {
                const result = await confirm('確定要登出嗎？')
                if (result) {
                    const { error } = await supabase.auth.signOut()
                    if (error) {
                        addToast('登出失敗', 'error')
                    }
                }
            },
        },
    ]
</script>

<style scoped>
    .item-wrapper:not(:last-child) {
        padding-bottom: 10px;
        border-bottom: 1px solid var(--color-primary-subtle);
    }
</style>
