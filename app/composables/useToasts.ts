type Toast = {
    id: string
    timerId: null | ReturnType<typeof setTimeout>
    message: string
    type: 'success' | 'error'
}
const toasts = ref<Toast[]>([])

export default function useToasts() {
    const removeToast = (id: string) => {
        const index = toasts.value.findIndex((toast) => toast.id === id)
        if (index === -1) return
        const timerId = toasts.value[index]!.timerId
        if (timerId) {
            clearTimeout(timerId)
        }
        toasts.value.splice(index, 1)
    }

    const addToast = (message: string, type: 'success' | 'error') => {
        let duration
        if (type === 'success') {
            duration = 3000
        } else if (type === 'error') {
            duration = 5000
        }
        const id = crypto.randomUUID()
        const timerId = setTimeout(() => {
            removeToast(id)
        }, duration)

        toasts.value.push({
            id,
            type,
            message,
            timerId,
        })
        return id
    }

    return { toasts, removeToast, addToast }
}
