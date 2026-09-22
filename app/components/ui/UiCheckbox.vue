<template>
    <div class="checkbox">
        <label
            :key="id"
            :for="id"
            :class="'text-' + color"
            class="checkbox-label d-flex-row"
        >
            <input
                :id="id"
                v-model="model"
                class="checkbox-input pill-border"
                type="checkbox"
                :value="id"
            />
            <span class="checkbox-text text-truncate">
                {{ name }}
            </span>
        </label>
    </div>
</template>

<script setup lang="ts">
    // types
    type Props = {
        id: string
        name: string
        color?: 'primary' | 'secondary'
    }

    // props
    const { id, name, color = 'secondary' } = defineProps<Props>()

    // models
    const model = defineModel<string[]>({ required: true })

    const appConfig = useAppConfig()

    const { isDarkMode } = useDarkMode()
    const shadowColor = computed(() => {
        if (isDarkMode.value) {
            return color === 'primary'
                ? appConfig.color.primary
                : appConfig.dark.secondary
        } else {
            return color === 'primary'
                ? appConfig.color.primary
                : appConfig.color.secondary
        }
    })
</script>

<style scoped>
    .checkbox-label {
        gap: 10px;
        height: 46px;
        align-items: center;
    }
    .checkbox-input {
        height: 24px;
        width: 24px;
        flex-shrink: 0;
        box-shadow: 0 0 0 2px v-bind(shadowColor) inset;
        appearance: none;
        cursor: pointer;
        transition: box-shadow 0.3s;
    }
    .checkbox-input:checked {
        box-shadow: 0 0 0 10px v-bind(shadowColor) inset;
    }
</style>
