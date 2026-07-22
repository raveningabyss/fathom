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
      redirect_to edit_admin_post_path(@post)
    else
      render inertia: 'admin/posts/Edit',
        props: { post: @post.as_json, errors: @post.errors.to_hash.transform_values(&:first) },
        status: :unprocessable_content
    end
  end

  def destroy
    if @post.destroy
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

  def post_params
    params.require(:post).permit(:title, :slug, :excerpt, :content)
  end
end
