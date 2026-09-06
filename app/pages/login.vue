<template>
    <NuxtLayout name="centered">
        <main>
            <AuthPanel
                :fields="fields"
                :field-values="fieldValues"
                :form-error="formError"
                @input="handleInput"
                @submit="handleSubmit"
            >
                <template #button>Log In</template>
                <span>Don't have an account?</span>
                <UiLink to="/signup" class="text-primary">Sign Up</UiLink>
            </AuthPanel>
        </main>
    </NuxtLayout>
</template>

<script setup lang="ts">
    import type { AuthFields } from '~/types'

    // page meta
    definePageMeta({
        middleware: 'guest',
        layout: false,
    })

    // types
    type LoginFieldId = 'login-email' | 'login-password'

    // supabase
    const supabase = useSupabaseClient()
    const user = useSupabaseUser()

    const fields: AuthFields<LoginFieldId> = [
        {
            id: 'login-email',
            type: 'email',
            label: '電子郵件地址',
        },
        {
            id: 'login-password',
            type: 'password',
            label: '密碼',
            maxLength: 12,
        },
    ]
    const fieldValues = ref<{ [K in LoginFieldId]: string }>(
        Object.fromEntries(fields.map((data) => [data.id, ''])) as {
            [K in LoginFieldId]: string
        },
    )
    const formError = ref('')
    const handleInput = (id: LoginFieldId, value: string) => {
        fieldValues.value[id] = value
        formError.value = ''
    }

    const login = async () => {
        const { error } = await supabase.auth.signInWithPassword({
            email: fieldValues.value['login-email'],
            password: fieldValues.value['login-password'],
        })
        if (error) {
            formError.value = '登入失敗'
        }
    }

    const isSubmitting = ref(false)
    const handleSubmit = async () => {
        if (isSubmitting.value || user.value) return
        isSubmitting.value = true
        try {
            await login()
        } catch {
            formError.value = '登入失敗'
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
