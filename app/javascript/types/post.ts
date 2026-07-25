export type PostStatus = 'published' | 'draft'

export type Post = {
  id: number
  user_id: number
  title: string
  slug: string
  excerpt: string
  content: string
  cover_image_url: string
  status: PostStatus
  created_at: string
  updated_at: string
}
