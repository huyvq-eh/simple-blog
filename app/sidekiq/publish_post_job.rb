class PublishPostJob
  include Sidekiq::Job
  sidekiq_options queue: 'default', retry: 3

  def perform(post_id)
    Rails.logger.info "Publishing post with id: #{post_id}"
    return if post_id.blank?

    post = Post.find_by(id: post_id)
    unless post.present?
      Rails.logger.error "Post with id #{post_id} not found"
      return
    end

    post.update_attribute(:published, true)
  end
end
