<template>
    <div class="float-label-field text-primary">
        <input
            :id="fieldData.id"
            v-model="model"
            class="float-input bg-primary-subtle text-primary"
            :type="fieldData.type"
            :maxlength="fieldData.maxLength"
            v-on="validationEvents()"
        />
        <label
            :class="model && 'floating'"
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
        validateOn?: string[]
    }
    type Emits = {
        validate: [type: string]
    }

    // props
    const { fieldData, validateOn = undefined } = defineProps<Props>()

    // Emits
    const emit = defineEmits<Emits>()

    // models
    const model = defineModel<string>({ default: '' })

    const handlerEvent = (event: Event) => {
        emit('validate', event.type)
    }
    const validationEvents = () => {
        if (validateOn) {
            const obj: Record<string, (event: Event) => void> = {}
            validateOn.forEach((eventType) => {
                obj[eventType] = handlerEvent
            })
            return obj
        }
        return {}
    }
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
