<template>
    <div class="float-label-field text-primary bg-primary-subtle d-flex-row">
        <input
            :id="fieldData.id"
            v-model="inputContent"
            class="float-input text-primary"
            :type="fieldType"
            :maxlength="fieldData.maxLength"
            @[blurEvent]="emit('blur')"
        />
        <label
            :class="formData && 'floating'"
            class="float-label"
            :for="fieldData.id"
            >{{ fieldData.label }}
        </label>
        <UiAppButton
            v-if="fieldData.type === 'password'"
            class="toggle-visibility-btn text-primary"
            @click="isPasswordVisible = !isPasswordVisible"
        >
            <UiGSymbol v-show="isPasswordVisible" font-size="30px"
                >visibility</UiGSymbol
            >
            <UiGSymbol v-show="!isPasswordVisible" font-size="30px"
                >visibility_off</UiGSymbol
            >
        </UiAppButton>
    </div>
</template>

<script setup lang="ts">
    import type { FieldData } from '~/types'

    // types
    type Props = {
        fieldData: FieldData
        listenToBlur?: boolean
        formData: string
    }
    type Emits = {
        blur: []
        input: [value: string]
    }

    // props
    const { fieldData, listenToBlur = false, formData } = defineProps<Props>()

    // Emits
    const emit = defineEmits<Emits>()

    const inputContent = computed({
        get() {
            return formData
        },
        set(newValue) {
            emit('input', newValue)
        },
    })
    const blurEvent = computed(() => (listenToBlur ? 'blur' : ''))

    const isPasswordVisible = ref(false)

    const fieldType = computed(() => {
        if (fieldData.type === 'password' && isPasswordVisible.value) {
            return 'text'
        }
        return fieldData.type
    })
</script>

<style>
    .float-label-field {
        position: relative;
        margin-bottom: 6px;
        border-radius: 10px;
        height: 50px;
        overflow: hidden;
    }
    .float-label-field:focus-within {
        border: 2px solid var(--color-primary);
    }
    .float-input {
        width: 100%;
        padding: 16px 0 2px 10px;
    }
    .float-label-field:focus-within > .float-input {
        padding: 14px 0 0 8px;
    }
    .float-input:-webkit-autofill {
        -webkit-text-fill-color: var(--color-primary);
        -webkit-box-shadow: 0 0 0 1000px var(--color-primary-subtle) inset;
    }
    .float-label {
        position: absolute;
        transform-origin: top left;
        top: 50%;
        left: 10px;
        transform: translateY(-50%);
        transition: transform 0.2s;
        pointer-events: none;
    }
    .float-input:focus + .float-label,
    .float-label.floating {
        transform: translateY(calc(-50% - 10px)) scale(0.5);
    }
    .float-label-field:focus-within > .float-label {
        left: 8px;
    }
    .float-label-field > .toggle-visibility-btn {
        margin-right: 2px;
    }
    .float-label-field:focus-within > .toggle-visibility-btn {
        margin-right: 0px;
    }
</style>
