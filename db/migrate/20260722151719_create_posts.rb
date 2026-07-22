class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.timestamps

      t.references :user, null: false, foreign_key: true
      t.string :status
      t.string :title
      t.string :slug
      t.string :excerpt
      t.text :content
    end
  end
end
