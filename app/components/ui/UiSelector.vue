<template>
    <div class="selector">
        <div class="selector-label">{{ selector.label }}</div>
        <div class="selector-body d-flex-row">
            <UiButton
                :disabled="selector.currentIndex === 0"
                class="text-primary prev-btn"
                @click="handleButtonClick('prev')"
            >
                <div class="icon-wrapper">
                    <UiGSymbol class="prev-icon" :opsz="40" font-size="40px"
                        >arrow_left</UiGSymbol
                    >
                </div>
            </UiButton>
            <div class="option-wrapper">
                <Transition :name="transitionName">
                    <div :key="selector.currentIndex" class="option">
                        {{ selector.options[selector.currentIndex]?.name }}
                    </div>
                </Transition>
            </div>
            <UiButton
                :disabled="
                    selector.currentIndex === selector.options.length - 1
                "
                class="text-primary next-btn"
                @click="handleButtonClick('next')"
            >
                <div class="icon-wrapper">
                    <UiGSymbol class="next-icon" :opsz="40" font-size="40px">
                        arrow_right
                    </UiGSymbol>
                </div>
            </UiButton>
        </div>
    </div>
</template>

<script setup lang="ts" generic="R">
    import type { Selector } from '~/types'

    // types
    type Props = {
        selector: Selector
    }
    type Emits = {
        'increment:index': []
        'decrement:index': []
    }

    // props
    const { selector } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    const transitionName = ref('')
    const handleButtonClick = async (name: 'prev' | 'next') => {
        if (name === 'prev') {
            transitionName.value = 'prev'
            await nextTick()
            emit('decrement:index')
        } else {
            transitionName.value = 'next'
            await nextTick()
            emit('increment:index')
        }
    }
</script>

<style scoped>
    .selector > *:not(:last-child) {
        margin-bottom: 10px;
    }

    .selector-label {
        font-weight: 500;
        text-align: center;
    }
    .selector-body {
        justify-content: space-between;
        align-items: center;
    }
    .option-wrapper {
        height: 30px;
        flex-basis: min(100%, 400px);
        display: grid;
        align-items: center;
        overflow: hidden;
    }
    .option {
        text-align: center;
        grid-column: 1;
        grid-row: 1;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
    .prev-enter-from,
    .next-leave-to {
        transform: translateX(-100%);
    }
    .prev-enter-active,
    .prev-leave-active,
    .next-enter-active,
    .next-leave-active {
        transition: transform 0.2s ease;
    }
    .prev-leave-to,
    .next-enter-from {
        transform: translateX(100%);
    }
    .icon-wrapper {
        width: 30px;
        height: 30px;
        overflow: hidden;
    }
    .prev-icon,
    .next-icon {
        margin-top: -5px;
        margin-left: -5px;
    }
</style>
