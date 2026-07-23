import { Node, mergeAttributes } from '@tiptap/core'
import { VueNodeViewRenderer } from '@tiptap/vue-3'
import ImageFigureView from './ImageFigureView.vue'

export type ImageFigureAlign = 'left' | 'center' | 'right'

export type ImageFigureAttrs = {
  id: string
  src: string
  alt?: string | null
  width?: number | null
  align?: ImageFigureAlign
}

declare module '@tiptap/core' {
  interface Commands<ReturnType> {
    imageFigure: {
      setImageFigure: (attrs: ImageFigureAttrs) => ReturnType
      setImageFigureAlign: (align: ImageFigureAlign) => ReturnType
    }
  }
}

export const ImageFigure = Node.create({
  name: 'imageFigure',
  group: 'block',
  content: 'inline*',
  isolating: true,
  defining: true,

  addAttributes() {
    return {
      id: {
        default: null,
        parseHTML: element => element.getAttribute('data-media-id'),
        renderHTML: attrs => attrs.id ? { 'data-media-id': attrs.id } : {},
      },
      src: { default: null },
      alt: { default: null },
      width: { default: null },
      align: { default: 'center' },
    }
  },

  parseHTML() {
    return [{ tag: 'figure[data-type="image-figure"]' }]
  },

  renderHTML({ node, HTMLAttributes }) {
    return [
      'figure',
      mergeAttributes(HTMLAttributes, { 'data-type': 'image-figure', 'data-align': node.attrs.align }),
      ['img', { src: node.attrs.src, alt: node.attrs.alt, width: node.attrs.width }],
      ['figcaption', 0],
    ]
  },

  addNodeView() {
    return VueNodeViewRenderer(ImageFigureView)
  },

  addCommands() {
    return {
      setImageFigure: (attrs: ImageFigureAttrs) => ({ commands }) => {
        return commands.insertContent({ type: this.name, attrs })
      },
      setImageFigureAlign: (align: ImageFigureAlign) => ({ commands }) => {
        return commands.updateAttributes(this.name, { align })
      },
    }
  },
})
