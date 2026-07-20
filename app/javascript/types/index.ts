export type FlashData = {
  notice?: string
  alert?: string
}

export type SharedProps = {
  current_user: {
    id: number
    username: string
    email: string
  }
}
