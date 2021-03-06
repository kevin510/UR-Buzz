class User < ApplicationRecord

  # "has_many" relationships
  has_many :microposts, dependent: :destroy

  has_many :active_relationships, class_name:  "Relationship", foreign_key: "follower_id", dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name:  "Relationship", foreign_key: "followed_id", dependent:   :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  has_many :events_attending, class_name: "Attend", foreign_key: "attendee_id", dependent: :destroy
  has_many :attending, through: :events_attending, source: :attending

  attr_accessor :remember_token

  before_save { self.email = email.downcase }

  validates(:name, presence: true, length: { maximum: 50 })

  # Standard email Regex format
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # Ensures email matches standard email REGEX pattern and other basic validations
  validates(:email, presence: true, length: { maximum: 200 },
            format: { with: EMAIL_REGEX}, uniqueness: { case_sensitive: false })

  # Adds methods to set and authenticate a BCrypt password
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns filtered feed of microposts
  def feed
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.unscoped.all.where("(user_id IN (#{following_ids}) OR user_id = :user_id) AND (eventDate >= :date_now_yesterday)",
                                 user_id: id, date_now_yesterday: DateTime.now.advance(days: -1)).order("eventDate ASC")
  end

  # If there is a search value, find microposts with content matching search string otherwhise return normal feed
  def search(search)
    if search
      feed.where('content LIKE ? OR eventDate LIKE ? OR location LIKE ?',
                 "%#{search}%", "%#{search}%", "%#{search}%")
    else
      feed
    end
  end

  # Creates following relationship between two users
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Deletes following relationship between two users
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the user is following other user
  def following?(other_user)
    following.include?(other_user)
  end

  # Creates an attend relationship between a user and a micropost
  def attend(micropost)
    events_attending.create(attending_id: micropost.id)
  end

  # Deletes the attend relationship between the user and micropost
  def unattend(micropost)
    events_attending.find_by(attending_id: micropost.id).destroy
  end

  # Returns true if the user is attending the event
  def attending?(micropost)
    attending.include?(micropost)
  end

end
