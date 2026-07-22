class Post < ApplicationRecord
  belongs_to :user

  attribute :status, :string, default: "draft"
end
