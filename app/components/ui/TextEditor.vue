<template>
    <div
        ref="text-editor"
        :class="textEditorClass"
        class="text-editor"
        :contenteditable="isEditable"
        @input="handleInput"
        @blur="handleBlur"
        @paste.prevent="handlePaste"
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

    const clean = (content: string) => {
        return content
            .replace(/[^\p{L}\p{N}\p{P}\p{M}\u00A0 ]/gu, '')
            .replace(/(\p{M}{3})\p{M}+/gu, '$1')
    }
    const normalize = (target: HTMLElement) => {
        const content = target.textContent
        if (content === '' && target.innerHTML === '<br>') {
            target.innerHTML = ''
        }
        let normalizedContent
        normalizedContent = clean(content)
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

        const selection = window.getSelection()
        const caretOffset = selection?.focusOffset ?? 0

        const newOffset = clean(target.textContent.slice(0, caretOffset)).length
        target.textContent = normalizedContent

        const node = target.firstChild
        if (node && selection) {
            const pos = Math.min(newOffset, node.textContent?.length ?? 0)
            const range = document.createRange()
            range.setStart(node, pos)
            range.collapse(true)
            selection.removeAllRanges()
            selection.addRange(range)
        }
    }
    const handlePaste = (event: ClipboardEvent) => {
        if (!event.clipboardData) return
        const text = event.clipboardData.getData('text/plain')

        const selection = window.getSelection()
        if (!selection || !selection.rangeCount) return

        const range = selection.getRangeAt(0)
        range.deleteContents()
        const node = document.createTextNode(text)
        range.insertNode(node)

        range.setStartAfter(node)
        range.collapse(true)
        selection.removeAllRanges()
        selection.addRange(range)

        const target = event.currentTarget as HTMLElement
        target.normalize()
        normalize(target)
    }
    const handleInput = (event: Event) => {
        const target = event.target as HTMLElement
        normalize(target)
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
            return [`bg-${color}-subtle`]
        }
        return ['text-truncate']
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
        outline: none;
        width: fit-content;
        max-width: 100%;
    }
</style>
