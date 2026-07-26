export type PostStatus = 'published' | 'draft'

export type Post = {
  id: number
  user_id: number
  title: string
  slug: string
  excerpt: string
  content: string
  cover_image_url: string
  category_id: number | null
  tag_ids?: number[]
  status: PostStatus
  created_at: string
  updated_at: string
}
