<template>
    <div
        ref="text-editor"
        :class="textEditorClass"
        class="text-editor"
        :contenteditable="isEditable"
        @blur="handleBlur"
        @input="handleInput"
        @keydown.enter.prevent="textEditorRef?.blur()"
        @keydown.esc="emit('close')"
    >
        {{ textContent }}
    </div>
</template>

<script setup lang="ts">
    // types
    type Props = {
        isEditable: boolean
        textContent: string
        graphemeLimit?: number
        color: 'primary' | 'secondary'
    }
    type Emits = {
        commit: [newContent: string]
        close: []
        input: [content: string]
    }

    // props
    const {
        isEditable,
        textContent,
        graphemeLimit = 40,
        color,
    } = defineProps<Props>()

    // emits
    const emit = defineEmits<Emits>()

    const handleInput = (event: Event) => {
        const target = event.target as HTMLElement
        const content = target.textContent
        if (content === '' && target.innerHTML === '<br>') {
            target.innerHTML = ''
        }
        let normalizedContent

        normalizedContent = content
            .replace(/[^\p{L}\p{N}\p{P}\p{M} ]/gu, '')
            .replace(/(\p{M}{3})\p{M}+/gu, '$1')
        if (
            Array.from(new Intl.Segmenter().segment(normalizedContent)).length >
            graphemeLimit
        ) {
            normalizedContent = Array.from(
                new Intl.Segmenter().segment(normalizedContent),
            )
                .slice(0, graphemeLimit)
                .map(({ segment }) => segment)
                .join('')
        }

        if (normalizedContent === content) return
        target.textContent = normalizedContent
    }
    const handleBlur = (event: Event) => {
        const target = event.target as HTMLElement
        if (!target) return
        target.textContent = target.textContent.trim()
        if (target.textContent === '') {
            target.textContent = textContent
        }
        emit('commit', target.textContent)
    }
    const textEditorRef = useTemplateRef('text-editor')
    const textEditorClass = computed(() => {
        if (isEditable) {
            return [`bg-${color}-subtle`, 'editable']
        }
        return ''
    })

    watch(
        () => isEditable,
        async (newValue) => {
            if (newValue && textEditorRef.value) {
                await nextTick()
                textEditorRef.value.focus()
                const range = document.createRange()
                range.selectNodeContents(textEditorRef.value)
                range.collapse(false)
                const selection = window.getSelection()
                if (!selection) return
                selection.removeAllRanges()
                selection.addRange(range)
            }
        },
    )
    const setTextContent = (value: string) => {
        if (!textEditorRef.value) return
        textEditorRef.value.textContent = value
    }
    const revert = () => {
        if (!textEditorRef.value) return
        textEditorRef.value.textContent = textContent
    }

    defineExpose({ setTextContent, revert })
</script>

<style scoped>
    .text-editor {
        padding: 6px;
        white-space: nowrap;
        text-overflow: ellipsis;
        overflow: hidden;
        outline: none;
        width: fit-content;
        max-width: 100%;
    }
    .text-editor.editable {
        text-overflow: initial;
        overflow: auto;
    }
</style>
