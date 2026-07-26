export type Medium = {
  id: number
  media_url: string
  created_at: string
}

export type MediumPostUsage = {
  post_id: number
  title: string
  caption: string | null
  cover_image: boolean
}
