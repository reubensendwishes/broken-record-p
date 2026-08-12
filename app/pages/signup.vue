<template>
    <authPanel
        :field-errors="fieldErrors"
        :fields="fields"
        :field-values="fieldValues"
        :form-error="formError"
        :with-validation="true"
        @input="handleInput"
        @submit="handleSubmit"
        @validate="handleValidate"
    >
        <template #button>註冊</template>
        <span>已經有帳號?</span>
        <UiAppLink to="/login" class="text-primary">登入</UiAppLink>
    </authPanel>
</template>

<script setup lang="ts">
    import type { FetchError } from 'ofetch'
    import type { AuthFields, Validators } from '~/types'

    // page meta
    definePageMeta({
        middleware: 'guest',
    })

    // types
    type SignupFieldId = 'signup-email' | 'signup-password' | 'signup-username'

    // supabase
    const supabase = useSupabaseClient()
    const user = useSupabaseUser()

    const fields: AuthFields<SignupFieldId> = [
        {
            id: 'signup-email',
            type: 'email',
            label: '電子郵件',
        },
        {
            id: 'signup-password',
            type: 'password',
            label: '密碼',
            helper: '密碼應該至少包含8個字元，並且包含至少1個大寫英文字母、小寫英文字母和數字。',
            maxLength: 72,
        },
        {
            id: 'signup-username',
            type: 'text',
            label: '使用者名稱',
            helper: '使用者名稱只能包含數字、英文字母，以及_-符號，並且_-不能在結尾或開頭出現。',
            maxLength: 30,
        },
    ]
    const fieldValues = ref<{ [K in SignupFieldId]: string }>(
        Object.fromEntries(fields.map((data) => [data.id, ''])) as {
            [K in SignupFieldId]: string
        },
    )
    let usernameCheckCtrl: AbortController | null = null

    const validators: Validators<SignupFieldId> = {
        'signup-email'(value: string) {
            if (!value) return '此欄位爲必填'
            if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(value))
                return 'email格式錯誤'
            return ''
        },
        'signup-password'(value: string) {
            if (!value) return '此欄位爲必填'
            if (value.length < 8) return '至少需要8個字元'
            if (value.length > 72) return '不能超過72個字元'
            if (!/[a-z]/.test(value)) return '至少需要1個小寫字母'
            if (!/[A-Z]/.test(value)) return '至少需要1個大寫字母'
            if (!/[0-9]/.test(value)) return '至少需要1個數字'
            if (!/^[\x21-\x7E]+$/.test(value))
                return '只能包含英文字母、數字與常見符號'

            return ''
        },
        async 'signup-username'(value: string) {
            if (!value) return '此欄位爲必填'
            if (value.length > 30) return '不能超過30個字元'
            if (!/^[\w-]+$/.test(value)) return '不能使用非規定內的特殊字元'
            if (!/^[a-zA-Z0-9](?:[\w-]*[a-zA-Z0-9])?$/.test(value))
                return '不能在結尾使用_或-字元'

            usernameCheckCtrl?.abort()
            usernameCheckCtrl = new AbortController()
            try {
                const res = await $fetch<{ available: boolean }>(
                    '/api/check-username',
                    {
                        query: { username: value },
                        signal: usernameCheckCtrl.signal,
                    },
                )
                if (!res.available) return '使用者名稱已被使用'
            } catch (error) {
                if ((error as Error).name === 'AbortError') return ''
                return (
                    (error as FetchError).data?.message ?? '檢查失敗,請稍後再試'
                )
            }

            return ''
        },
    }
    const fieldErrors = ref<{ [K in SignupFieldId]: string }>(
        Object.fromEntries(fields.map((data) => [data.id, ''])) as {
            [K in SignupFieldId]: string
        },
    )

    const formError = ref('')

    const handleInput = (id: SignupFieldId, value: string) => {
        fieldValues.value[id] = value.trim()
        if (id === 'signup-username') {
            usernameCheckCtrl?.abort()
        }
        fieldErrors.value[id] = ''
        formError.value = ''
    }
    const handleValidate = async (id: SignupFieldId) => {
        if (fieldErrors.value[id]) return
        fieldErrors.value[id] = await validators[id](fieldValues.value[id])
    }
    const signup = async () => {
        for (const id of Object.keys(fieldValues.value) as SignupFieldId[]) {
            fieldErrors.value[id] = await validators[id](fieldValues.value[id])
            if (fieldErrors.value[id]) return
        }

        const { error } = await supabase.auth.signUp({
            email: fieldValues.value['signup-email'],
            password: fieldValues.value['signup-password'],
            options: {
                emailRedirectTo: `${window.location.origin}/confirm`,
                data: {
                    username: fieldValues.value['signup-username'],
                },
            },
        })
        if (error) {
            formError.value = '註冊失敗'
        } else {
            navigateTo('/verify-email')
        }
    }
    const isSubmitting = ref(false)
    const handleSubmit = async () => {
        if (isSubmitting.value || user.value) return
        isSubmitting.value = true
        try {
            await signup()
        } catch {
            formError.value = '註冊失敗'
        } finally {
            isSubmitting.value = false
        }
    }
    watch(
        user,
        () => {
            if (user.value) {
                navigateTo('/')
            }
        },
        { immediate: true },
    )
</script>
