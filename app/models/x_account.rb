class XAccount < ApplicationRecord
  belongs_to :user
  has_many :x_posts, dependent: :nullify

  validates :username, uniqueness: true, allow_nil: true
end
