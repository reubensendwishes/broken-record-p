<template>
    <div class="auth-panel">
        <div class="auth-form-wrapper">
            <div class="auth-header">
                <AppLogo with-text />
            </div>
            <form
                class="auth-form d-flex-column"
                novalidate
                @submit.prevent="handleFormSubmit"
            >
                <div v-for="field in fields" :key="field.id" class="auth-field">
                    <UiFloatLabelField
                        :listen-to-blur="withValidation"
                        :field="field"
                        :field-value="fieldValues[field.id]"
                        @input="
                            (value: string) => {
                                emit('input', field.id, value)
                            }
                        "
                        @blur="emit('validate', field.id)"
                    />
                    <p v-if="fieldErrors?.[field.id]" class="field-error">
                        {{ fieldErrors?.[field.id] }}
                    </p>
                    <p
                        v-if="field.helper"
                        class="field-helper text-primary-subtle"
                    >
                        {{ field.helper }}
                    </p>
                </div>
                <div v-if="formError" class="form-error">
                    {{ formError }}
                </div>

                <UiButton
                    rounded-left="10px"
                    rounded-right="10px"
                    padding-x="0px"
                    width="100%"
                    class="text-inverse bg-primary"
                    type="submit"
                    :disabled="isSubmitDisabled"
                >
                    {{ feature === 'login' ? '登入' : '註冊' }}
                </UiButton>
                <div class="auth-divider">
                    <span>或</span>
                </div>
                <AuthGSIMaterialButton
                    :feature="feature"
                    @click="emit('google')"
                />
            </form>
        </div>
        <div class="auth-footer font-20">
            <p class="auth-prompt text-primary-subtle d-flex-row">
                <slot />
            </p>
        </div>
        <ClientOnly>
            <VueHcaptcha
                ref="hcaptchaRef"
                size="invisible"
                :sitekey="config.public.hcaptchaSiteKey"
            />
        </ClientOnly>
    </div>
</template>

<script setup lang="ts" generic="T extends string">
    import VueHcaptcha from '@hcaptcha/vue3-hcaptcha'
    import type { AuthFields } from '@/types/index'

    // types
    type Props = {
        fieldErrors?: { [K in T]: string }
        formError?: string
        fields: AuthFields<T>
        fieldValues: { [K in T]: string }
        withValidation?: boolean
        feature: 'signup' | 'login'
    }
    type Emit = {
        submit: [captchaToken: string]
        google: []
        input: [id: T, value: string]
        validate: [id: T]
    }

    // props
    const {
        fieldErrors = undefined,
        formError = undefined,
        fields,
        fieldValues,
        withValidation = false,
        feature,
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emit>()

    const isSubmitting = ref(false)
    const isSubmitDisabled = computed(() => {
        if (isSubmitting.value) return true
        if (fieldValues) {
            for (const key in fieldValues) {
                if (fieldValues[key] === '') {
                    return true
                }
            }
        }
        if (fieldErrors) {
            for (const key in fieldErrors) {
                if (fieldErrors[key] !== '') {
                    return true
                }
            }
        }
        if (formError !== '') return true
        return false
    })

    const config = useRuntimeConfig()
    const hcaptchaRef = ref<InstanceType<typeof VueHcaptcha>>()

    const handleFormSubmit = async () => {
        if (isSubmitting.value) return
        isSubmitting.value = true
        try {
            const res = await hcaptchaRef.value?.executeAsync()
            if (!res) return
            emit('submit', res.response)
        } catch {
            // 使用者取消驗證或驗證發生錯誤，不送出表單
        } finally {
            isSubmitting.value = false
        }
    }
    defineExpose({
        resetCaptcha: () => {
            hcaptchaRef.value?.reset()
        },
    })
</script>

<style scoped>
    .auth-panel {
        width: min(400px, 100dvw);
    }
    .auth-form-wrapper {
        padding: 20px;
        border: 2px solid var(--color-primary);
        border-radius: 20px;
        margin-bottom: 20px;
    }
    .auth-header {
        margin-bottom: 20px;
        text-align: center;
    }
    .auth-form {
        gap: 20px;
    }
    .auth-field > *:not(:last-child) {
        margin-bottom: 6px;
    }
    .auth-footer {
        padding: 20px 0;
        border: 2px solid var(--color-primary);
        border-radius: 20px;
    }
    .auth-prompt {
        width: fit-content;
        margin: 0 auto;
        gap: 10px;
        align-items: center;
        line-height: 1;
    }
    .field-error,
    .field-helper,
    .form-error {
        font-size: 16px;
    }
    .auth-divider {
        display: flex;
        align-items: center;
        gap: 10px;
        color: var(--color-muted);
        font-size: 16px;
    }
    .auth-divider::before,
    .auth-divider::after {
        content: '';
        flex: 1;
        height: 1px;
        background-color: var(--color-muted);
    }
</style>
