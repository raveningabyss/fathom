class RemoveCaptionFromMedia < ActiveRecord::Migration[8.1]
  def change
    remove_column :media, :caption, :string
  end
end
