class AddCoverImageToPostMedia < ActiveRecord::Migration[8.1]
  def change
    add_column :post_media, :cover_image, :boolean, default: false, null: false
  end
end
