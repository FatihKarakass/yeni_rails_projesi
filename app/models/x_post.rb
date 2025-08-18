class XPost < ApplicationRecord
  belongs_to :user
  belongs_to :x_account
  
  validates :body, presence: true, length: { maximum: 280 }
  
  before_validation :assign_default_publish_time
  before_validation :assign_default_x_account
  
  scope :scheduled, -> { where('COALESCE(publish_at, scheduled_at) > ?', Time.current) }
  scope :published, -> { where('COALESCE(publish_at, scheduled_at) <= ?', Time.current) }
  
  def effective_publish_time
    publish_at || scheduled_at
  end
  
  def scheduled?
    effective_publish_time > Time.current
  end
  
  def published?
    effective_publish_time <= Time.current
  end

  def publish_to_x!
    raise "X hesabı eksik" unless x_account
    raise "Paylaşılacak içerik boş" if body.to_s.strip.blank?

    client = XPublisher::Client.new(x_account: x_account)
    tweet = client.post(body)
    update!(x_post_id: tweet.id.to_s)
    tweet
  end
  
  after_save_commit :enqueue_publish_job_if_time_changed

  private

  def enqueue_publish_job_if_time_changed
    return unless saved_change_to_publish_at?
    return unless publish_at.present?

    XPostJob.set(wait_until: publish_at).perform_later(self)
  end
  
  def assign_default_publish_time
    self.publish_at ||= scheduled_at || Time.current
  end
  
  def assign_default_x_account
    return if x_account_id.present?
    return if user.nil?
    accounts = user.x_accounts
    self.x_account = accounts.first if accounts.one?
  end
end
