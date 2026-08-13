<template>
    <div
        class="float-label-field text-primary d-flex-row border-primary-subtle"
    >
        <input
            :id="field.id"
            v-model="inputContent"
            class="float-input"
            :type="fieldType"
            :maxlength="field.maxLength"
            @[blurEvent]="emit('blur')"
        />
        <label
            :class="fieldValue && 'floating'"
            class="float-label text-primary-subtle"
            :for="field.id"
            >{{ field.label }}
        </label>
        <UiButton
            v-if="field.type === 'password'"
            class="toggle-visibility-btn text-primary-subtle"
            @click="isPasswordVisible = !isPasswordVisible"
        >
            <UiGSymbol v-show="isPasswordVisible">visibility</UiGSymbol>
            <UiGSymbol v-show="!isPasswordVisible">visibility_off</UiGSymbol>
        </UiButton>
    </div>
</template>

<script setup lang="ts">
    import type { AuthField } from '~/types'

    // types
    type Props = {
        field: AuthField
        listenToBlur?: boolean
        fieldValue: string
    }
    type Emits = {
        blur: []
        input: [value: string]
    }

    // props
    const { field, listenToBlur = false, fieldValue } = defineProps<Props>()

    // Emits
    const emit = defineEmits<Emits>()

    const inputContent = computed({
        get() {
            return fieldValue
        },
        set(newValue) {
            emit('input', newValue)
        },
    })
    const blurEvent = computed(() => (listenToBlur ? 'blur' : ''))

    const isPasswordVisible = ref(false)

    const fieldType = computed(() => {
        if (field.type === 'password' && isPasswordVisible.value) {
            return 'text'
        }
        return field.type
    })
</script>

<style scoped>
    .float-label-field {
        position: relative;
        align-items: center;
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
        padding: 14px 0 0 8px;
    }
    .float-input:-webkit-autofill {
        -webkit-text-fill-color: var(--color-primary);
        -webkit-box-shadow: 0 0 0 1000px var(--color-background) inset;
    }
    .float-label {
        position: absolute;
        transform-origin: top left;
        top: 50%;
        left: 8px;
        transform: translateY(-50%);
        transition: transform 0.2s;
        pointer-events: none;
    }
    .float-input:focus + .float-label,
    .float-label.floating {
        transform: translateY(calc(-50% - 10px)) scale(0.5);
    }
    .toggle-visibility-btn {
        margin-right: 0px;
    }
</style>
