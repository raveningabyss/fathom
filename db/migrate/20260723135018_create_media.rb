class CreateMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :media do |t|
      t.timestamps

      t.string :status
      t.uuid :public_id
      t.string :media_url
      t.string :caption
      t.datetime :expires_at
    end
  end
end
