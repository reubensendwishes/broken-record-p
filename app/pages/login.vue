<template>
    <NuxtLayout name="centered">
        <main id="main">
            <AuthPanel
                ref="auth-panel"
                :fields="fields"
                :field-values="fieldValues"
                :form-error="formError"
                feature="login"
                @input="handleInput"
                @submit="handleSubmit"
                @google="handleGoogleLogin"
            >
                <span>沒有帳號嗎?</span>
                <UiLink to="/signup" class="text-primary">註冊</UiLink>
            </AuthPanel>
        </main>
    </NuxtLayout>
</template>

<script setup lang="ts">
    import AuthPanel from '@/components/auth/AuthPanel.vue'
    import type { AuthFields } from '@/types/index'
    import type { ComponentExposed } from 'vue-component-type-helpers'

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

    const authPanelRef =
        useTemplateRef<ComponentExposed<typeof AuthPanel>>('auth-panel')

    const login = async (captchaToken: string) => {
        const { error } = await supabase.auth.signInWithPassword({
            email: fieldValues.value['login-email'],
            password: fieldValues.value['login-password'],
            options: { captchaToken: captchaToken },
        })
        if (error) {
            formError.value = '登入失敗'
            authPanelRef.value?.resetCaptcha()
        }
    }

    const isSubmitting = ref(false)
    const handleSubmit = async (token: string) => {
        if (isSubmitting.value || user.value) return
        isSubmitting.value = true
        try {
            await login(token)
        } catch {
            formError.value = '登入失敗'
        } finally {
            isSubmitting.value = false
        }
    }

    const handleGoogleLogin = async () => {
        const { error } = await supabase.auth.signInWithOAuth({
            provider: 'google',
            options: { redirectTo: `${window.location.origin}/confirm` },
        })
        if (error) {
            formError.value = '登入失敗'
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
