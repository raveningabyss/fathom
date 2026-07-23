class DestroyOrphanMediaJob < ApplicationJob
  queue_as :default

  def perform
    Medium.expired.find_each do |medium|
      Backblaze::Client.new.delete_object(key: medium.key)
      medium.destroy!
    end
  end
end
