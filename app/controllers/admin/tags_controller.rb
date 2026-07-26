class Admin::TagsController < Admin::BaseController
  before_action :set_tag, only: [:show, :edit, :update, :destroy]

  def index
    tags = Tag.order(:name).includes(:posts).map { |tag|
      { id: tag.id, name: tag.name, posts_count: tag.posts.size }
    }

    respond_to do |format|
      format.html { render inertia: 'admin/tags/Index', props: { tags: tags } }
      format.json { render json: { tags: tags } }
    end
  end

  def show
    render inertia: 'admin/tags/Show', props: {
      tag: @tag.as_json(only: [:id, :name]),
      posts: @tag.posts.as_json(only: [:id, :title])
    }
  end

  def new
    redirect_to admin_tags_path
  end

  def edit
    redirect_to admin_tags_path
  end

  def create
    tag = Tag.new(tag_params)

    if tag.save
      respond_to do |format|
        format.json { render json: { id: tag.id, name: tag.name }, status: :created }
        format.html { redirect_to admin_tags_path }
      end
    else
      render json: { errors: tag.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to admin_tags_path
    else
      render json: { errors: @tag.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    if @tag.destroy
      flash[:notice] = 'Tag destroyed.'
      head :no_content
    else
      render json: { errors: @tag.errors.full_messages }, status: :unprocessable_content
    end
  end

  def unlink
    post = Current.user.posts.find(params[:post_id])
    post.post_tags.find_by!(tag_id: params[:id]).destroy
    head :no_content
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name)
  end
end
