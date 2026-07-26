class Admin::MediaController < Admin::BaseController
  def index
    render inertia: 'admin/media/Index', props: {
      media: current_user_media.order(created_at: :desc).as_json(only: [:id, :media_url, :created_at])
    }
  end

  def show
    medium = current_user_media.find(params[:id])

    render inertia: 'admin/media/Show', props: {
      medium: medium.as_json(only: [:id, :media_url, :created_at]),
      post_media: medium.post_media.includes(:post).map { |post_medium|
        {
          post_id: post_medium.post.id,
          title: post_medium.post.title,
          caption: post_medium.caption
        }
      }
    }
  end

  def create
    medium = Medium.create!(public_id: SecureRandom.uuid_v4, user: Current.user)
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
      flash[:notice] = 'Media destroyed.'
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

  def current_user_media
    Medium.where(status: 'completed', user_id: Current.user.id)
  end

  def backblaze_client
    Backblaze::Client.new
  end
end
