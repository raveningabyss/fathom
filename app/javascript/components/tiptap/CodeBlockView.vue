<script setup lang="ts">
import { NodeViewWrapper, NodeViewContent, nodeViewProps } from '@tiptap/vue-3'

const props = defineProps(nodeViewProps)

const languages = [
  { value: '', label: 'Auto-detect' },
  { value: 'plaintext', label: 'Plain text' },
  { value: 'javascript', label: 'JavaScript' },
  { value: 'typescript', label: 'TypeScript' },
  { value: 'python', label: 'Python' },
  { value: 'ruby', label: 'Ruby' },
  { value: 'php', label: 'PHP' },
  { value: 'java', label: 'Java' },
  { value: 'kotlin', label: 'Kotlin' },
  { value: 'swift', label: 'Swift' },
  { value: 'c', label: 'C' },
  { value: 'cpp', label: 'C++' },
  { value: 'csharp', label: 'C#' },
  { value: 'go', label: 'Go' },
  { value: 'rust', label: 'Rust' },
  { value: 'bash', label: 'Bash' },
  { value: 'shell', label: 'Shell' },
  { value: 'sql', label: 'SQL' },
  { value: 'json', label: 'JSON' },
  { value: 'yaml', label: 'YAML' },
  { value: 'xml', label: 'HTML / XML' },
  { value: 'css', label: 'CSS' },
  { value: 'scss', label: 'SCSS' },
  { value: 'less', label: 'Less' },
  { value: 'markdown', label: 'Markdown' },
  { value: 'graphql', label: 'GraphQL' },
  { value: 'diff', label: 'Diff' },
  { value: 'ini', label: 'INI' },
  { value: 'makefile', label: 'Makefile' },
]

function onLanguageChange(event: Event) {
  const value = (event.target as HTMLSelectElement).value
  props.updateAttributes({ language: value || null })
}
</script>

<template>
  <node-view-wrapper class="tiptap-code-block">
    <select
      contenteditable="false"
      class="tiptap-code-block-lang"
      :value="node.attrs.language ?? ''"
      @change="onLanguageChange"
    >
      <option v-for="lang in languages" :key="lang.label" :value="lang.value">{{ lang.label }}</option>
    </select>
    <pre><node-view-content as="code" /></pre>
  </node-view-wrapper>
</template>
