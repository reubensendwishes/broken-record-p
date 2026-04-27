<template>
    <div class="float-label-field text-primary">
        <input
            :id="fieldData.id"
            v-model="inputContent"
            class="float-input bg-primary-subtle text-primary"
            :type="fieldData.type"
            :maxlength="fieldData.maxLength"
            @[blurEvent]="emit('blur')"
        />
        <label
            :class="formData && 'floating'"
            class="float-label"
            :for="fieldData.id"
            >{{ fieldData.label }}
        </label>
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
</script>

<style scoped>
    .float-label-field {
        position: relative;
        margin-bottom: 6px;
    }
    .float-input {
        width: 100%;
        outline: none;
        border: none;
        height: 50px;
        border-radius: 10px;
        padding: 14px 0 0 10px;
    }
    .float-input:focus {
        border: 2px solid var(--color-primary);
        padding-left: 8px;
    }
    .float-label {
        position: absolute;
        transform-origin: left;
        top: 50%;
        left: 10px;
        transform: translateY(-50%);
        transition: transform 0.1s;
        cursor: text;
    }
    .float-input:focus + .float-label,
    .float-label.floating {
        transform: translateY(calc(-50% - 14px)) scale(0.5);
    }
</style>
