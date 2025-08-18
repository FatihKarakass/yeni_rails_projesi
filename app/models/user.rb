# email:string
# password_digest:string
# password:string virtual
# password_confirmation:string virtual


class User < ApplicationRecord
    has_many :x_posts, dependent: :destroy
    has_secure_password
    has_many :x_accounts, dependent: :destroy

    validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "must be a valid email address" }
    validates :x_id, uniqueness: true, allow_nil: true

    # X kullanıcısı olup olmadığını kontrol et
    def x_user?
        x_id.present?
    end

    # Görüntülenecek ismi döndür
    def display_name
        x_user? ? x_name : email.split('@').first
    end

    # Profil resmini döndür
    def profile_image
        x_profile_image_url.presence || "https://via.placeholder.com/40"
    end


end
