class User < ApplicationRecord
    attr_accessor :remember_token, :activation_token

    before_save :downcase_email
    before_create :create_activation_digest
    validates :name, presence: true, length: { maximum: 50 }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }

    has_secure_password
    validates :password, presence: true, length: { minimum: 6 },
              allow_nil: true

    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ?
        BCrypt::Engine::MIN_COST : BCrypt::Engine.cost 

        BCrypt::Password.create(string, cost: cost)
    end

    def self.new_token
        SecureRandom.urlsafe_base64
    end

    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(self.remember_token))
        self.remember_digest
    end

    def session_token
        self.remember_digest || self.remember
    end

    def authenticated?(token)
        return false if self.remember_digest.nil?
        BCrypt::Password.new(self.remember_digest).is_password?(token)
    end

    def forget 
        update_attribute(:remember_digest, nil)
    end

    private def downcase_email
      self.email = self.email.downcase
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(self.activation_token)
    end
end
