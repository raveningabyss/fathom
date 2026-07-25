export function csrfHeaders() {
  return {
    'Content-Type': 'application/json',
    'X-CSRF-Token': (document.querySelector('meta[name="csrf-token"]') as HTMLMetaElement).content,
    'Accept': 'application/json',
  }
}

export async function deleteMedia(id: string | number) {
  await fetch(`/admin/media/${id}`, { method: 'DELETE', headers: csrfHeaders() })
}

export async function createMedia() {
  const response = await fetch('/admin/media', { method: 'POST', headers: csrfHeaders() })
  const { id, presigned_url } = await response.json()
  return { id: id as number, presignedUrl: presigned_url as string }
}

export async function uploadToPresignedUrl(presignedUrl: string, file: File) {
  const response = await fetch(presignedUrl, {
    method: 'PUT',
    body: file,
    headers: { 'Content-Type': file.type },
  })
  if (!response.ok) throw new Error('Failed to upload file')
}

export async function confirmMediaUploaded(id: string | number) {
  const response = await fetch(`/admin/media/${id}/mark_as_uploaded`, {
    method: 'PATCH',
    headers: csrfHeaders(),
  })
  if (!response.ok) throw new Error('Failed to confirm upload')

  const { public_url } = await response.json()
  return public_url as string
}

export async function uploadMedia(file: File) {
  const { id, presignedUrl } = await createMedia()
  await uploadToPresignedUrl(presignedUrl, file)
  const publicUrl = await confirmMediaUploaded(id)
  return { id, publicUrl }
}
