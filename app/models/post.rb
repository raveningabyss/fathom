class Post < ApplicationRecord
  belongs_to :user

  has_many :post_media, dependent: :destroy
  has_many :media, through: :post_media

  attribute :status, :string, default: "draft"
end
