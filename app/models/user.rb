require 'bcrypt'

class User < ActiveRecord::Base
  belongs_to :school
  has_many :messages, foreign_key: :recipient_id
  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id

  validates :email, presence: true
  validates :encrypted_password, presence: true
  validate :must_be_over_18


  def password=(pwd)
    return if pwd.blank?
    # salted = ENV["salt"] + email + pwd
    self.encrypted_password = BCrypt::Password.create(pwd)
  end

  def school_name
    school ? school.name : ''
  end

  def school_name=(name)
    self.school = School.find_or_create_by(name: name)
  end

  def self.login(email, password)
    user = find_by(email: email)
    return nil if !user

    if BCrypt::Password.new(user.encrypted_password) == password
      return user.id
    end
  end

  # def gay?
  #   sexuality == 'Gay'
  # end

  # def appropriate_gender
  #   gay? ? gender : opposite_gender
  # end

  def opposite_gender
    case gender
    when 'male'
      'female'
    when 'female'
      'male'
    else
      raise 'Unknown gender!'
    end
  end

  scope :of_opposite_gender, ->(user) {
    where(gender: user.opposite_gender)
  }

  private

  def must_be_over_18
    if dob.blank? || (dob > 18.years.ago)
      errors.add(:dob, 'must be over 18 to use the site')
    end
  end

end
