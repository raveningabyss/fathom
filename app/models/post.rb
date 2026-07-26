class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  has_many :post_media, dependent: :destroy
  has_many :media, through: :post_media

  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  attribute :status, :string, default: "draft"
end
