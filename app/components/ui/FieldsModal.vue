<template>
    <UiModal
        :color="color"
        has-backdrop
        class="fields-modal"
        :class="`text-${color}`"
        @close="emit('close')"
    >
        <template #header>
            <h3 class="modal-title">
                {{ title }}
            </h3>
        </template>
        <template #default>
            <div role="group" class="modal-fields d-flex-column">
                <template v-for="(field, index) in fields" :key="field.id">
                    <div
                        v-if="field.type === 'input'"
                        :class="`text-${color}`"
                        class="modal-field d-flex-column"
                    >
                        <label :for="field.id" class="fields-modal-label">
                            {{ field.label }}
                        </label>
                        <input
                            :id="field.id"
                            :ref="
                                (el) => {
                                    inputRefs[field.id] = el as HTMLInputElement
                                }
                            "
                            :value="field.value"
                            :type="field.inputType"
                            class="modal-input"
                            :placeholder="field.placeholder"
                            @input="handleInput($event, field.id)"
                            @compositionend="
                                handleCompositionend($event, field.id)
                            "
                        />
                        <p
                            v-if="field.helper"
                            :class="`text-muted`"
                            class="field-helper"
                        >
                            {{ field.helper }}
                        </p>
                        <p v-if="field.error" class="field-error">
                            {{ field.error }}
                        </p>
                    </div>
                    <UiSelector
                        v-if="field.type === 'selector'"
                        :color="color"
                        :selector="field"
                        class="fields-modal-field"
                        @increment:index="emit('increment:index', field.id)"
                        @decrement:index="emit('decrement:index', field.id)"
                    />
                    <hr
                        v-if="index !== fields.length - 1"
                        :class="`bg-${color}-subtle`"
                        class="field-divider"
                    />
                </template>
            </div>
        </template>
        <template #primary-action>
            <UiButton
                :class="`text-${color}`"
                :is-disabled="isDisabled"
                @click="!isDisabled && emit('primary-action')"
            >
                {{ primaryActionName }}
            </UiButton>
        </template>
    </UiModal>
</template>

<script setup lang="ts">
    import type { FieldsModalField } from '~/types'

    // types
    type Props = {
        title: string
        color?: 'primary' | 'secondary'
        fields: FieldsModalField[]
        primaryActionName: string
        changeCheck?: boolean
        isSubmitting: boolean
    }
    type Emits = {
        'primary-action': []
        close: []
        input: [inputEl: HTMLInputElement, fieldId: string]
        'increment:index': [id: string]
        'decrement:index': [id: string]
    }

    // emits
    const emit = defineEmits<Emits>()

    // props
    const {
        title,
        fields,
        color = 'primary',
        primaryActionName,
        changeCheck = false,
        isSubmitting = false,
    } = defineProps<Props>()

    const oldFields = ref(structuredClone(fields.map((field) => toRaw(field))))
    const isModified = computed(() => {
        return oldFields.value.some((oldfield, index) => {
            if (oldfield.type === 'input' && fields[index]!.type === 'input') {
                return oldfield.value !== fields[index]!.value
            } else if (
                oldfield.type === 'selector' &&
                fields[index]!.type === 'selector'
            ) {
                return oldfield.currentIndex !== fields[index]!.currentIndex
            }
        })
    })
    const inputRefs = ref<Record<string, HTMLInputElement>>({})
    const isDisabled = computed(() => {
        return (
            fields.some((field) => {
                return field.type === 'input' && (!field.value || field.error)
            }) ||
            (changeCheck && !isModified.value) ||
            isSubmitting
        )
    })
    const handleInput = (event: InputEvent, fieldId: string) => {
        if (event.isComposing) return
        emit('input', event.target as HTMLInputElement, fieldId)
    }
    const handleCompositionend = (event: CompositionEvent, fieldId: string) => {
        emit('input', event.target as HTMLInputElement, fieldId)
    }
</script>

<style scoped>
    .modal-title {
        font-size: 24px;
        text-align: center;
        font-weight: 600;
    }
    .modal-fields {
        gap: 20px;
    }
    .modal-field {
        text-align: center;
    }
    .modal-field > *:not(:last-child) {
        margin-bottom: 10px;
    }
    .field-error,
    .field-helper {
        text-align: start;
        font-size: 16px;
    }
    .modal-input[type='number']::-webkit-outer-spin-button,
    .modal-input[type='number']::-webkit-inner-spin-button {
        -webkit-appearance: none;
        appearance: none;
        margin: 0;
    }
    .modal-input[type='number'] {
        -moz-appearance: textfield;
        appearance: textfield;
    }
    .fields-modal.text-primary .modal-input::placeholder {
        color: var(--color-primary-subtle);
    }
    .fields-modal.text-secondary .modal-input::placeholder {
        color: var(--color-secondary-subtle);
    }
    .field-divider {
        border: none;
        height: 1px;
    }
</style>
