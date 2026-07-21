<script setup lang="ts">
import { computed, ref } from 'vue'
import { NodeViewWrapper, NodeViewContent, nodeViewProps } from '@tiptap/vue-3'

const props = defineProps(nodeViewProps)

const isEmpty = computed(() => props.node.content.size === 0)

const liveWidth = ref<number | null>(null)
const width = computed(() => liveWidth.value ?? props.node.attrs.width ?? null)

function startResize(event: MouseEvent) {
  event.preventDefault()

  const media = (event.currentTarget as HTMLElement).parentElement
  const startWidth = media?.getBoundingClientRect().width ?? props.node.attrs.width ?? 300
  const startX = event.clientX

  liveWidth.value = startWidth

  const onMouseMove = (moveEvent: MouseEvent) => {
    liveWidth.value = Math.max(80, startWidth + (moveEvent.clientX - startX))
  }

  const onMouseUp = () => {
    if (liveWidth.value) props.updateAttributes({ width: Math.round(liveWidth.value) })
    liveWidth.value = null
    window.removeEventListener('mousemove', onMouseMove)
    window.removeEventListener('mouseup', onMouseUp)
  }

  window.addEventListener('mousemove', onMouseMove)
  window.addEventListener('mouseup', onMouseUp)
}
</script>

<template>
  <node-view-wrapper
    as="figure"
    class="tiptap-image-figure"
    :class="[`align-${node.attrs.align ?? 'center'}`, { 'is-selected': selected }]"
  >
    <div class="tiptap-image-figure-media" contenteditable="false" :style="width ? { width: `${width}px` } : undefined">
      <img :src="node.attrs.src" :alt="node.attrs.alt" draggable="false" />
      <div class="tiptap-image-figure-handle" @mousedown="startResize" />
    </div>

    <div class="tiptap-image-figure-caption-wrap">
      <node-view-content as="figcaption" class="tiptap-image-figure-caption" />
      <span v-if="isEmpty" class="tiptap-image-figure-caption-placeholder">Add a caption…</span>
    </div>
  </node-view-wrapper>
</template>
