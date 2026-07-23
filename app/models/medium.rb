class Medium < ApplicationRecord
  attribute :status, :string, default: 'pending'

  before_create { self.expires_at ||= 1.hour.from_now }

  scope :expired, -> { where(expires_at: ..Time.current) }

  def key
    "media/#{public_id}"
  end
end
