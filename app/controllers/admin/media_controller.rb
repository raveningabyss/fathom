class Admin::MediaController < Admin::BaseController
  def index
  end

  def create
    medium = Medium.create!(public_id: SecureRandom.uuid_v4)
    Current.user.posts.find(params[:post_id]).post_media.create!(medium: medium) if params[:post_id]

    render json: {
      id: medium.id,
      presigned_url: backblaze_client.presigned_upload_url(key: medium.key)
    }
  end

  def destroy
    medium = Medium.find(params[:id])
    if medium.destroy
      backblaze_client.delete_object(key: medium.key)
      head :no_content
    else
      render json: { errors: medium.errors.full_messages }, status: :unprocessable_content
    end
  end

  def unlink
    post = Current.user.posts.find(params[:post_id])
    post.post_media.find_by!(medium_id: params[:id]).destroy
    head :no_content
  end

  def mark_as_uploaded
    medium = Medium.find(params[:medium_id])
    public_url = backblaze_client.public_url(medium.key)
    medium.update!(status: 'completed', media_url: public_url)

    render json: {
      id: medium.id,
      public_url: public_url
    }
  end

  private

  def backblaze_client
    Backblaze::Client.new
  end
end
