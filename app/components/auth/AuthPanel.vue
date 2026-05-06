<template>
    <div class="auth-wrapper d-flex-row">
        <main class="auth-panel">
            <div class="auth-form-wrapper">
                <div class="auth-header">
                    <UiAppLogo with-text />
                </div>
                <form
                    class="auth-form d-flex-column"
                    novalidate
                    @submit.prevent="emit('submit')"
                >
                    <div
                        v-for="fieldData in fieldDatas"
                        :key="fieldData.id"
                        class="auth-field"
                    >
                        <UiFloatLabelField
                            :listen-to-blur="withValidation"
                            :field-data="fieldData"
                            :form-data="formDatas[fieldData.id]"
                            @input="
                                (value) => {
                                    emit('input', fieldData.id, value)
                                }
                            "
                            @blur="emit('validate', fieldData.id)"
                        />
                        <p
                            v-if="fieldErrors?.[fieldData.id]"
                            class="field-error"
                        >
                            {{ fieldErrors?.[fieldData.id] }}
                        </p>
                        <p
                            v-if="fieldData.helper"
                            class="field-helper text-primary-subtle"
                        >
                            {{ fieldData.helper }}
                        </p>
                    </div>
                    <div v-if="formError" class="form-error">
                        {{ formError }}
                    </div>

                    <UiAppButton
                        rounded-left="10px"
                        rounded-right="10px"
                        padding-x="0px"
                        width="100%"
                        class="text-inverse bg-primary"
                        type="submit"
                        :disabled="isSubmitDisabled"
                    >
                        <slot name="button" />
                    </UiAppButton>
                </form>
            </div>
            <div class="auth-footer font-20">
                <p class="auth-prompt text-primary-subtle d-flex-row">
                    <slot />
                </p>
            </div>
        </main>
    </div>
</template>

<script setup lang="ts" generic="T extends string">
    import type { FieldDatas } from '~/types'

    // types
    type Props = {
        fieldErrors?: { [K in T]: string }
        formError?: string
        fieldDatas: FieldDatas<T>
        formDatas: { [K in T]: string }
        withValidation?: boolean
    }
    type Emit = {
        submit: []
        input: [id: T, value: string]
        validate: [id: T]
    }

    // props
    const {
        fieldErrors = undefined,
        formError = undefined,
        fieldDatas,
        formDatas,
        withValidation = false,
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emit>()

    const isSubmitting = ref(false)
    const isSubmitDisabled = computed(() => {
        if (isSubmitting.value) return true
        if (formDatas) {
            for (const key in formDatas) {
                if (formDatas[key] === '') {
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
</script>

<style>
    .auth-wrapper {
        width: 100%;
        min-height: 100dvh;
        justify-content: center;
        align-items: center;
    }
    .auth-panel {
        width: min(400px, 100%);
    }
    .auth-form-wrapper {
        padding: 40px 20px;
        border: 2px solid var(--color-primary);
        border-radius: 20px;
        margin-bottom: 20px;
    }
    .auth-header {
        margin-bottom: 40px;
        text-align: center;
    }
    .auth-form {
        gap: 20px;
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
    .auth-field > .field-error,
    .auth-field > .field-helper,
    .ahth-form > .form-error {
        font-size: 18px;
    }
</style>
