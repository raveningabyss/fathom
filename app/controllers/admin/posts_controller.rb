class Admin::PostsController < Admin::BaseController
  before_action :set_current_post, only: [:edit, :update, :destroy]

  def create
    post = Current.user.posts.create
    redirect_to edit_admin_post_path(post)
  end

  def index
    render inertia: 'admin/posts/Index',
      props: { posts: Current.user.posts.as_json }
  end

  def edit
    render inertia: 'admin/posts/Edit', props: { post: @post.as_json }
  end

  def update
    if @post.update(post_params)
      attach_referenced_media
      redirect_to edit_admin_post_path(@post)
    else
      render inertia: 'admin/posts/Edit',
        props: { post: @post.as_json, errors: @post.errors.to_hash.transform_values(&:first) },
        status: :unprocessable_content
    end
  end

  def destroy
    if @post.destroy
      flash[:notice] = 'Post deleted.'
      redirect_to admin_posts_path
    else
      render inertia: 'admin/posts/Index',
        props: { posts: Current.user.posts.as_json, errors: @post.errors.to_hash.transform_values(&:first) },
        status: :unprocessable_content
    end
  end

  private

  def set_current_post
    @post = Current.user.posts.find(params[:id])
  end

  def attach_referenced_media
    Nokogiri::HTML::DocumentFragment.parse(@post.content.to_s).css('figure[data-media-id]').each do |figure|
      link = @post.post_media.find_or_initialize_by(medium_id: figure['data-media-id'])
      next unless link.medium

      link.update!(caption: figure.at_css('figcaption')&.text.to_s.strip)
      link.medium.update!(expires_at: nil)
    end

    Medium.where(media_url: @post.cover_image_url).update_all(expires_at: nil) if @post.cover_image_url.present?
  end

  def post_params
    params.require(:post).permit(:title, :slug, :excerpt, :content, :cover_image_url)
  end
end
