class XPostJob < ApplicationJob
  queue_as :default

  # ActiveJob GlobalID sayesinde modeli direkt alabiliriz
  def perform(x_post)
    binding.pry
    return if x_post.published?
    return if x_post.publish_at.present? && x_post.publish_at > Time.current

    x_post.publish_to_x!
  end
end