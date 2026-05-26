const confirmDialogState = ref<{
    isOpen: boolean
    message: string
    resolve: ((value: unknown) => void) | null
}>({
    isOpen: false,
    message: '',
    resolve: null,
})

export default function useConfirm() {
    const confirm = (message: string) => {
        confirmDialogState.value.isOpen = true
        confirmDialogState.value.message = message
        return new Promise((resolve) => {
            confirmDialogState.value.resolve = resolve
        })
    }
    const answer = (value: boolean) => {
        confirmDialogState.value.isOpen = false
        confirmDialogState.value.resolve?.(value)
        confirmDialogState.value.resolve = null
        confirmDialogState.value.message = ''
    }
    return { confirmDialogState, confirm, answer }
}
