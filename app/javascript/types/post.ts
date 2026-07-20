export type PostStatus = 'published' | 'draft'

export type Post = {
  id: number
  title: string
  status: PostStatus
  updatedAt: string
}
