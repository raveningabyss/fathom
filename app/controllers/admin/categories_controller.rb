class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    categories = Category.order(:name).includes(:posts).map { |category|
      { id: category.id, name: category.name, posts_count: category.posts.size }
    }

    respond_to do |format|
      format.html { render inertia: 'admin/categories/Index', props: { categories: categories } }
      format.json { render json: { categories: categories } }
    end
  end

  def show
    render inertia: 'admin/categories/Show', props: {
      category: @category.as_json(only: [:id, :name]),
      posts: @category.posts.as_json(only: [:id, :title])
    }
  end

  def new
    redirect_to admin_categories_path
  end

  def edit
    redirect_to admin_categories_path
  end

  def create
    category = Category.new(category_params)

    if category.save
      respond_to do |format|
        format.json { render json: { id: category.id, name: category.name }, status: :created }
        format.html { redirect_to admin_categories_path }
      end
    else
      render json: { errors: category.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    if @category.destroy
      flash[:notice] = 'Category destroyed.'
      head :no_content
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_content
    end
  end

  def unlink
    post = Current.user.posts.find(params[:post_id])
    post.update!(category_id: nil) if post.category_id == params[:id].to_i
    head :no_content
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
