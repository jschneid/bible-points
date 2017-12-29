class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }

  before_save { self.email = email.downcase }
  validates :email, email: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: { minimum: 6 }, allow_nil: true

  attr_accessor :remember_token

  # Returns the hash digest of the given clear-text password string.
  # Source: https://www.railstutorial.org/book/basic_login#code-digest_method
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token (for use in "remember me" cookies).
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    # Only generate a new token if we don't already have an existing one. This allows
    # the "remember me" token to work on multiple browsers/devices, as they'll share the
    # same token (until the token is cleared from the DB upon a Logout action).
    return if remember_token.present?

    self.remember_token = User.new_token
    update_attributes(remember_digest: User.digest(remember_token))
  end

  # Returns true if the given token (from a "remember me" cookie) matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attributes(remember_digest: nil, remember_token: nil)
  end
end
