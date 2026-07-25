class CreatePostMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :post_media do |t|
      t.references :post, null: false, foreign_key: true
      t.references :medium, null: false, foreign_key: true
      t.string :caption

      t.timestamps
    end
  end
end
