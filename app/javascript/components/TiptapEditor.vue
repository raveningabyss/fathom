<script setup lang="ts">
import { computed, ref } from 'vue'
import { useEditor, EditorContent } from '@tiptap/vue-3'
import type { Node as ProseMirrorNode } from '@tiptap/pm/model'
import StarterKit from '@tiptap/starter-kit'
import Placeholder from '@tiptap/extension-placeholder'
import { TableKit } from '@tiptap/extension-table'
import TextAlign from '@tiptap/extension-text-align'
import { createLowlight, common } from 'lowlight'
import { ImageFigure } from './tiptap/ImageFigure'
import { CodeBlock } from './tiptap/CodeBlock'
import '@catppuccin/highlightjs/css/catppuccin-mocha.css'
import {
  AlignCenter,
  AlignJustify,
  AlignLeft,
  AlignRight,
  ArrowDownToLine,
  ArrowLeftToLine,
  ArrowRightToLine,
  ArrowUpToLine,
  Bold,
  ChevronDown,
  Code,
  Combine,
  Heading1,
  Heading2,
  Heading3,
  Image as ImageIcon,
  Italic,
  Link2,
  List,
  ListOrdered,
  Minus,
  PanelLeftClose,
  PanelTopClose,
  Pilcrow,
  Quote,
  Redo2,
  Split,
  SquareCode,
  Table as TableIcon,
  Trash2,
  Underline,
  Undo2,
  Upload,
} from '@lucide/vue'
import Button from '@/components/Button.vue'
import { confirmMediaUploaded, createMedia, deleteMedia, uploadToPresignedUrl } from '@/composables/useMediaUpload'

const content = defineModel<string>({ default: '' })

const openLinkModifier = navigator.platform.includes('Mac') ? '⌘' : 'Ctrl'
const lowlight = createLowlight(common)

let contentSyncTimeout: ReturnType<typeof setTimeout> | undefined

const editor = useEditor({
  content: content.value,
  extensions: [
    StarterKit.configure({ link: { openOnClick: false }, codeBlock: false }),
    CodeBlock.configure({ lowlight }),
    Placeholder.configure({ placeholder: 'Write your blog post...' }),
    TableKit.configure({ table: { resizable: true } }),
    ImageFigure,
    TextAlign.configure({ types: ['heading', 'paragraph'] }),
  ],
  onUpdate: ({ editor, transaction }) => {
    const before = collectImageFigureIds(transaction.before)
    const after = collectImageFigureIds(transaction.doc)
    for (const id of before) {
      if (!after.has(id)) deleteMedia(id)
    }

    // getHTML() serializes the whole doc (including any embedded base64 images) —
    // doing that on every keystroke is what was causing the typing lag.
    clearTimeout(contentSyncTimeout)
    contentSyncTimeout = setTimeout(() => {
      content.value = editor.getHTML()
    }, 300)
  }
})

function onContentClick(event: MouseEvent) {
  const link = (event.target as HTMLElement).closest('a')
  if (link && (event.ctrlKey || event.metaKey)) {
    event.preventDefault()
    window.open(link.getAttribute('href') ?? '', '_blank', 'noopener,noreferrer')
    return
  }

  if (event.target === event.currentTarget) {
    editor.value?.chain().focus('end').run()
  }
}

const TOOLTIP_MAX_WIDTH = 240
const EDGE_PADDING = 8
const linkTooltip = ref<{ href: string, style: Record<string, string> } | null>(null)

function onContentMouseOver(event: MouseEvent) {
  const link = (event.target as HTMLElement).closest('a')
  if (!link) return

  const rect = link.getBoundingClientRect()
  const halfWidth = TOOLTIP_MAX_WIDTH / 2
  const center = rect.left + rect.width / 2

  let horizontal: Record<string, string>
  if (center - halfWidth < EDGE_PADDING) {
    // Not enough room to center — hug the link's own left edge instead of jumping to a clamped position.
    horizontal = { left: `${rect.left}px` }
  } else if (center + halfWidth > window.innerWidth - EDGE_PADDING) {
    horizontal = { right: `${window.innerWidth - rect.right}px` }
  } else {
    horizontal = { left: `${center}px`, transform: 'translateX(-50%)' }
  }

  const showBelow = rect.top < 32
  const vertical: Record<string, string> = showBelow
    ? { top: `${rect.bottom + 8}px` }
    : { bottom: `${window.innerHeight - rect.top + 8}px` }

  linkTooltip.value = {
    href: link.getAttribute('href') ?? '',
    style: { ...horizontal, ...vertical },
  }
}

function onContentMouseOut(event: MouseEvent) {
  if ((event.target as HTMLElement).closest('a')) linkTooltip.value = null
}

type ToolbarItem =
  | { type: 'divider' }
  | { type: 'button', label: string, icon: typeof Bold, isActive: boolean, run: () => void }

const toolbarItems = computed<ToolbarItem[]>(() => {
  if (!editor.value) return []
  const e = editor.value

  return [
    { type: 'button', label: 'Bold', icon: Bold, isActive: e.isActive('bold'), run: () => e.chain().focus().toggleBold().run() },
    { type: 'button', label: 'Italic', icon: Italic, isActive: e.isActive('italic'), run: () => e.chain().focus().toggleItalic().run() },
    { type: 'button', label: 'Underline', icon: Underline, isActive: e.isActive('underline'), run: () => e.chain().focus().toggleUnderline().run() },
    { type: 'divider' },
    { type: 'button', label: 'Blockquote', icon: Quote, isActive: e.isActive('blockquote'), run: () => e.chain().focus().toggleBlockquote().run() },
    { type: 'button', label: 'Inline code', icon: Code, isActive: e.isActive('code'), run: () => e.chain().focus().toggleCode().run() },
    { type: 'button', label: 'Code block', icon: SquareCode, isActive: e.isActive('codeBlock'), run: () => e.chain().focus().toggleCodeBlock().run() },
    { type: 'divider' },
    { type: 'button', label: 'Bullet list', icon: List, isActive: e.isActive('bulletList'), run: () => e.chain().focus().toggleBulletList().run() },
    { type: 'button', label: 'Ordered list', icon: ListOrdered, isActive: e.isActive('orderedList'), run: () => e.chain().focus().toggleOrderedList().run() },
    { type: 'divider' },
    { type: 'button', label: 'Align left', icon: AlignLeft, isActive: e.isActive('imageFigure') ? e.isActive('imageFigure', { align: 'left' }) : e.isActive({ textAlign: 'left' }), run: () => e.isActive('imageFigure') ? e.chain().focus().setImageFigureAlign('left').run() : e.chain().focus().setTextAlign('left').run() },
    { type: 'button', label: 'Align center', icon: AlignCenter, isActive: e.isActive('imageFigure') ? e.isActive('imageFigure', { align: 'center' }) : e.isActive({ textAlign: 'center' }), run: () => e.isActive('imageFigure') ? e.chain().focus().setImageFigureAlign('center').run() : e.chain().focus().setTextAlign('center').run() },
    { type: 'button', label: 'Align right', icon: AlignRight, isActive: e.isActive('imageFigure') ? e.isActive('imageFigure', { align: 'right' }) : e.isActive({ textAlign: 'right' }), run: () => e.isActive('imageFigure') ? e.chain().focus().setImageFigureAlign('right').run() : e.chain().focus().setTextAlign('right').run() },
    { type: 'button', label: 'Justify', icon: AlignJustify, isActive: e.isActive({ textAlign: 'justify' }), run: () => e.chain().focus().setTextAlign('justify').run() },
    { type: 'divider' },
    { type: 'button', label: 'Horizontal rule', icon: Minus, isActive: false, run: () => e.chain().focus().setHorizontalRule().run() },
  ]
})

const blockTypes = [
  { label: 'Normal Text', icon: Pilcrow, isActive: (e: NonNullable<typeof editor.value>) => e.isActive('paragraph'), run: (e: NonNullable<typeof editor.value>) => e.chain().focus().setParagraph().run() },
  { label: 'Heading 1', icon: Heading1, isActive: (e: NonNullable<typeof editor.value>) => e.isActive('heading', { level: 1 }), run: (e: NonNullable<typeof editor.value>) => e.chain().focus().toggleHeading({ level: 1 }).run() },
  { label: 'Heading 2', icon: Heading2, isActive: (e: NonNullable<typeof editor.value>) => e.isActive('heading', { level: 2 }), run: (e: NonNullable<typeof editor.value>) => e.chain().focus().toggleHeading({ level: 2 }).run() },
  { label: 'Heading 3', icon: Heading3, isActive: (e: NonNullable<typeof editor.value>) => e.isActive('heading', { level: 3 }), run: (e: NonNullable<typeof editor.value>) => e.chain().focus().toggleHeading({ level: 3 }).run() },
]

const blockTypeMenuOpen = ref(false)
const activeBlockType = computed(() => {
  if (!editor.value) return blockTypes[0]
  return blockTypes.find(blockType => blockType.isActive(editor.value!)) ?? blockTypes[0]
})

function setBlockType(blockType: typeof blockTypes[number]) {
  if (!editor.value) return
  blockType.run(editor.value)
  blockTypeMenuOpen.value = false
}

const linkMenuOpen = ref(false)
const linkUrl = ref('')

function openLinkMenu() {
  linkUrl.value = editor.value?.getAttributes('link').href ?? ''
  linkMenuOpen.value = true
}

function applyLink() {
  if (!editor.value) return
  if (!linkUrl.value) {
    editor.value.chain().focus().extendMarkRange('link').unsetLink().run()
  } else {
    editor.value.chain().focus().extendMarkRange('link').setLink({ href: linkUrl.value }).run()
  }
  linkMenuOpen.value = false
}

const imageMenuOpen = ref(false)
const imageUrl = ref('')
const imageFileInput = ref<HTMLInputElement>()

function openImageMenu() {
  imageUrl.value = ''
  imageMenuOpen.value = true
}

function collectImageFigureIds(doc: ProseMirrorNode) {
  const ids = new Set<string>()
  doc.descendants((node) => {
    if (node.type.name === 'imageFigure' && node.attrs.id) ids.add(String(node.attrs.id))
  })
  return ids
}

function setImageFigureAttrsById(id: string, attrs: Record<string, unknown>) {
  const e = editor.value
  if (!e) return

  e.state.doc.descendants((node, pos) => {
    if (node.type.name === 'imageFigure' && String(node.attrs.id) === id) {
      e.view.dispatch(e.state.tr.setNodeMarkup(pos, undefined, { ...node.attrs, ...attrs }))
      return false
    }
  })
}

async function uploadFile(file: File) {
  if (!editor.value) return

  const objectUrl = URL.createObjectURL(file)
  const { id, presignedUrl } = await createMedia()

  editor.value.chain().focus().setImageFigure({ src: objectUrl, id: String(id) }).run()

  await uploadToPresignedUrl(presignedUrl, file)
  const publicUrl = await confirmMediaUploaded(id)
  setImageFigureAttrsById(String(id), { src: publicUrl })
  URL.revokeObjectURL(objectUrl)
}

async function applyImageUrl() {
  if (!imageUrl.value) return
  imageMenuOpen.value = false

  const sourceResponse = await fetch(imageUrl.value)
  const blob = await sourceResponse.blob()
  const filename = imageUrl.value.split('/').pop()?.split('?')[0] || 'image'
  await uploadFile(new File([blob], filename, { type: blob.type }))
}

async function onImageFileChange(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return

  input.value = ''
  imageMenuOpen.value = false
  await uploadFile(file)
}

const tableMenuOpen = ref(false)

const tableActions = computed(() => {
  if (!editor.value) return []
  const e = editor.value

  if (!e.isActive('table')) {
    return [
      { label: 'Insert table', icon: TableIcon, disabled: false, run: () => e.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run() },
    ]
  }

  return [
    { label: 'Add row above', icon: ArrowUpToLine, disabled: false, run: () => e.chain().focus().addRowBefore().run() },
    { label: 'Add row below', icon: ArrowDownToLine, disabled: false, run: () => e.chain().focus().addRowAfter().run() },
    { label: 'Delete row', icon: Trash2, disabled: false, run: () => e.chain().focus().deleteRow().run() },
    { label: 'Add column left', icon: ArrowLeftToLine, disabled: false, run: () => e.chain().focus().addColumnBefore().run() },
    { label: 'Add column right', icon: ArrowRightToLine, disabled: false, run: () => e.chain().focus().addColumnAfter().run() },
    { label: 'Delete column', icon: Trash2, disabled: false, run: () => e.chain().focus().deleteColumn().run() },
    { label: 'Merge cells', icon: Combine, disabled: !e.can().mergeCells(), run: () => e.chain().focus().mergeCells().run() },
    { label: 'Split cell', icon: Split, disabled: !e.can().splitCell(), run: () => e.chain().focus().splitCell().run() },
    { label: 'Toggle header row', icon: PanelTopClose, disabled: false, run: () => e.chain().focus().toggleHeaderRow().run() },
    { label: 'Toggle header column', icon: PanelLeftClose, disabled: false, run: () => e.chain().focus().toggleHeaderColumn().run() },
    { label: 'Delete table', icon: Trash2, disabled: false, run: () => e.chain().focus().deleteTable().run() },
  ]
})

function runTableAction(action: { disabled: boolean, run: () => void }) {
  if (action.disabled) return
  action.run()
  tableMenuOpen.value = false
}
</script>

<template>
  <div class="flex min-h-0 flex-1 flex-col overflow-hidden rounded-lg border border-white/[0.08] bg-surface-raised">
    <div v-if="editor" class="flex flex-wrap items-center gap-0.5 border-b border-white/[0.08] px-2 py-1.5">
      <div class="relative">
        <button
          type="button"
          class="flex items-center gap-1 rounded-md px-2 py-1.5 text-sm text-white/70 transition-colors hover:bg-white/5 hover:text-white cursor-pointer"
          @click="blockTypeMenuOpen = !blockTypeMenuOpen"
        >
          <component :is="activeBlockType.icon" class="h-4 w-4" />
          {{ activeBlockType.label }}
          <ChevronDown class="h-3.5 w-3.5" />
        </button>

        <div v-if="blockTypeMenuOpen" class="fixed inset-0 z-40" @click="blockTypeMenuOpen = false" />

        <div
          v-if="blockTypeMenuOpen"
          class="absolute left-0 top-full z-50 mt-1 w-40 overflow-hidden rounded-lg border border-white/[0.08] bg-surface-raised shadow-xl"
        >
          <button
            v-for="blockType in blockTypes"
            :key="blockType.label"
            type="button"
            class="flex w-full items-center gap-2 px-3 py-2 text-left text-sm transition-colors hover:bg-white/5 hover:text-white cursor-pointer"
            :class="activeBlockType.label === blockType.label ? 'text-primary' : 'text-white/80'"
            @click="setBlockType(blockType)"
          >
            <component :is="blockType.icon" class="h-4 w-4" />
            {{ blockType.label }}
          </button>
        </div>
      </div>

      <div class="mx-1 h-5 w-px bg-white/[0.08]" />

      <div class="relative">
        <button
          type="button"
          class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:bg-white/5 cursor-pointer"
          :class="editor.isActive('link') ? 'bg-primary/15 text-primary' : 'text-white/70 hover:text-white'"
          @click="openLinkMenu"
        >
          <Link2 class="h-4 w-4" />
        </button>

        <div v-if="linkMenuOpen" class="fixed inset-0 z-40" @click="linkMenuOpen = false" />

        <div
          v-if="linkMenuOpen"
          class="absolute left-0 top-full z-50 mt-1 flex w-64 items-center gap-2 rounded-lg border border-white/[0.08] bg-surface-raised p-2 shadow-xl"
        >
          <input
            v-model="linkUrl"
            type="text"
            placeholder="https://example.com"
            class="min-w-0 flex-1 rounded-md border-0 bg-white/5 px-2 py-1.5 text-sm text-white placeholder-white/30 outline-none focus:ring-2 focus:ring-primary/30"
            @keydown.enter="applyLink"
          />
          <Button type="button" @click="applyLink">Apply</Button>
        </div>
      </div>

      <div class="relative">
        <button
          type="button"
          class="flex h-8 w-8 items-center justify-center rounded-md text-white/70 transition-colors hover:bg-white/5 hover:text-white cursor-pointer"
          @click="openImageMenu"
        >
          <ImageIcon class="h-4 w-4" />
        </button>

        <div v-if="imageMenuOpen" class="fixed inset-0 z-40" @click="imageMenuOpen = false" />

        <div
          v-if="imageMenuOpen"
          class="absolute left-0 top-full z-50 mt-1 flex w-72 flex-col gap-2 rounded-lg border border-white/[0.08] bg-surface-raised p-2 shadow-xl"
        >
          <div class="flex items-center gap-2">
            <input
              v-model="imageUrl"
              type="text"
              placeholder="https://example.com/image.png"
              class="min-w-0 flex-1 rounded-md border-0 bg-white/5 px-2 py-1.5 text-sm text-white placeholder-white/30 outline-none focus:ring-2 focus:ring-primary/30"
              @keydown.enter="applyImageUrl"
            />
            <Button type="button" @click="applyImageUrl">Add</Button>
          </div>

          <button
            type="button"
            class="flex items-center justify-center gap-1.5 rounded-md border border-dashed border-white/15 px-2 py-1.5 text-xs text-white/60 transition-colors hover:border-primary/40 hover:text-white cursor-pointer"
            @click="imageFileInput?.click()"
          >
            <Upload class="h-3.5 w-3.5" />
            Upload from device
          </button>
          <input ref="imageFileInput" type="file" accept="image/*" class="hidden" @change="onImageFileChange" />
        </div>
      </div>

      <template v-for="(item, index) in toolbarItems" :key="index">
        <div v-if="item.type === 'divider'" class="mx-1 h-5 w-px bg-white/[0.08]" />
        <button
          v-else
          type="button"
          class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:bg-white/5 cursor-pointer"
          :class="item.isActive ? 'bg-primary/15 text-primary' : 'text-white/70 hover:text-white'"
          :title="item.label"
          @click="item.run()"
        >
          <component :is="item.icon" class="h-4 w-4" />
        </button>
      </template>

      <div class="mx-1 h-5 w-px bg-white/[0.08]" />

      <div class="relative">
        <button
          type="button"
          class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:bg-white/5 cursor-pointer"
          :class="editor.isActive('table') ? 'bg-primary/15 text-primary' : 'text-white/70 hover:text-white'"
          title="Table"
          @click="tableMenuOpen = !tableMenuOpen"
        >
          <TableIcon class="h-4 w-4" />
        </button>

        <div v-if="tableMenuOpen" class="fixed inset-0 z-40" @click="tableMenuOpen = false" />

        <div
          v-if="tableMenuOpen"
          class="absolute left-0 top-full z-50 mt-1 w-44 overflow-hidden rounded-lg border border-white/[0.08] bg-surface-raised shadow-xl"
        >
          <button
            v-for="action in tableActions"
            :key="action.label"
            type="button"
            class="flex w-full items-center gap-2 px-3 py-2 text-left text-sm transition-colors disabled:cursor-not-allowed disabled:opacity-40"
            :class="action.disabled ? 'text-white/40' : 'text-white/80 hover:bg-white/5 hover:text-white cursor-pointer'"
            :disabled="action.disabled"
            @click="runTableAction(action)"
          >
            <component :is="action.icon" class="h-4 w-4" />
            {{ action.label }}
          </button>
        </div>
      </div>

      <div class="mx-1 h-5 w-px bg-white/[0.08]" />

      <button
        type="button"
        class="flex h-8 w-8 items-center justify-center rounded-md text-white/70 transition-colors hover:bg-white/5 hover:text-white disabled:opacity-30 cursor-pointer disabled:cursor-not-allowed"
        :disabled="!editor.can().undo()"
        @click="editor.chain().focus().undo().run()"
      >
        <Undo2 class="h-4 w-4" />
      </button>
      <button
        type="button"
        class="flex h-8 w-8 items-center justify-center rounded-md text-white/70 transition-colors hover:bg-white/5 hover:text-white disabled:opacity-30 cursor-pointer disabled:cursor-not-allowed"
        :disabled="!editor.can().redo()"
        @click="editor.chain().focus().redo().run()"
      >
        <Redo2 class="h-4 w-4" />
      </button>
    </div>

    <div
      class="prose prose-invert max-w-none min-h-0 flex-1 overflow-y-auto p-4 prose-a:text-primary prose-p:my-3 prose-headings:my-3 prose-ul:my-2 prose-ol:my-2 prose-li:my-0 prose-blockquote:my-2 prose-hr:my-4"
      @click="onContentClick"
      @mouseover="onContentMouseOver"
      @mouseout="onContentMouseOut"
    >
      <editor-content :editor="editor" />
    </div>

    <Teleport to="body">
      <div
        v-if="linkTooltip"
        class="fixed z-50 max-w-[240px] rounded-md bg-surface-raised px-2 py-1.5 text-xs text-white shadow-xl"
        :style="linkTooltip.style"
      >
        <p class="truncate">{{ linkTooltip.href }}</p>
        <p class="mt-0.5 text-white/40">{{ openLinkModifier }}+Click to open</p>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
:deep(.ProseMirror) {
  outline: none;
}

:deep(.ProseMirror p.is-editor-empty:first-child::before) {
  content: attr(data-placeholder);
  float: left;
  height: 0;
  color: rgb(255 255 255 / 0.3);
  pointer-events: none;
}

:deep(.ProseMirror blockquote p::before),
:deep(.ProseMirror blockquote p::after) {
  content: none;
}

:deep(.ProseMirror code) {
  border-radius: 0.375rem;
  background: rgb(255 255 255 / 0.1);
  padding: 0.125rem 0.375rem;
  font-family: ui-monospace, monospace;
  font-size: 0.85em;
  font-weight: 400;
  color: var(--color-primary);
}

:deep(.ProseMirror code::before),
:deep(.ProseMirror code::after) {
  content: none;
}

:deep(.tiptap-code-block) {
  position: relative;
  margin: 0.75rem 0;
}

:deep(.tiptap-code-block pre) {
  margin: 0;
  overflow-x: auto;
  border-radius: 0.5rem;
  background: #1e1e2e;
  padding: 0.875rem 1rem;
}

:deep(.tiptap-code-block pre code) {
  border-radius: 0;
  background: transparent;
  padding: 0;
  font-size: 0.85em;
  color: #cdd6f4;
}

:deep(.tiptap-code-block-lang) {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  z-index: 2;
  border: none;
  border-radius: 0.375rem;
  background: rgb(255 255 255 / 0.08);
  color: rgb(255 255 255 / 0.6);
  font-size: 0.75rem;
  padding: 0.2rem 1.5rem 0.2rem 0.4rem;
  cursor: pointer;
  outline: none;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%23ffffff99' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 0.35rem center;
}

:deep(.tiptap-code-block-lang:hover) {
  color: white;
  background-color: rgb(255 255 255 / 0.14);
}

:deep(.ProseMirror table) {
  width: 100%;
  margin: 0.75rem 0;
  border-collapse: collapse;
  table-layout: fixed;
  overflow: hidden;
}

:deep(.ProseMirror td),
:deep(.ProseMirror th) {
  position: relative;
  border: 1px solid rgb(255 255 255 / 0.12);
  padding: 0.375rem 0.625rem;
  vertical-align: top;
}

:deep(.ProseMirror th) {
  background: rgb(255 255 255 / 0.06);
  font-weight: 600;
  text-align: left;
}

:deep(.ProseMirror .selectedCell)::after {
  content: '';
  position: absolute;
  inset: 0;
  z-index: 2;
  background: rgb(92 139 214 / 0.2);
  pointer-events: none;
}

:deep(.ProseMirror .column-resize-handle) {
  position: absolute;
  right: -2px;
  top: 0;
  bottom: 0;
  z-index: 3;
  width: 4px;
  background: var(--color-primary);
  pointer-events: none;
}

:deep(.ProseMirror.resize-cursor) {
  cursor: col-resize;
}

:deep(.tiptap-image-figure) {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
  width: fit-content;
  max-width: 100%;
  margin-top: 0.5rem;
  margin-bottom: 0.5rem;
}

:deep(.tiptap-image-figure.align-left) {
  margin-left: 0;
  margin-right: auto;
}

:deep(.tiptap-image-figure.align-center) {
  margin-left: auto;
  margin-right: auto;
}

:deep(.tiptap-image-figure.align-right) {
  margin-left: auto;
  margin-right: 0;
}

:deep(.tiptap-image-figure-media) {
  position: relative;
  display: block;
  max-width: 100%;
  line-height: 0;
}

:deep(.tiptap-image-figure-media img) {
  display: block;
  max-width: 100%;
  height: auto;
  margin: 0;
  padding: 0;
  border-radius: 0.5rem;
}

:deep(.tiptap-image-figure.is-selected .tiptap-image-figure-media img) {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

:deep(.tiptap-image-figure-handle) {
  position: absolute;
  right: 0;
  bottom: 0;
  z-index: 10;
  width: 0.875rem;
  height: 0.875rem;
  border-radius: 9999px;
  border: 2px solid white;
  background: var(--color-primary);
  cursor: nwse-resize;
  opacity: 0;
  transition: opacity 0.15s;
  pointer-events: auto;
}

:deep(.tiptap-image-figure-media:hover .tiptap-image-figure-handle),
:deep(.tiptap-image-figure.is-selected .tiptap-image-figure-handle) {
  opacity: 1;
}

:deep(.tiptap-image-figure-caption-wrap) {
  position: relative;
  width: 100%;
  margin: 0;
  padding: 0;
}

:deep(.tiptap-image-figure-caption) {
  width: 100%;
  min-width: 3rem;
  margin: 0;
  padding: 0;
  line-height: 1.3;
  text-align: center;
  font-size: 0.85em;
  font-style: italic;
  color: rgb(255 255 255 / 0.7);
  outline: none;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

:deep(.tiptap-image-figure-caption-placeholder) {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0;
  padding: 0;
  line-height: 1.3;
  font-size: 0.85em;
  font-style: italic;
  color: rgb(255 255 255 / 0.3);
  white-space: nowrap;
  pointer-events: none;
}
</style>
