class ExpoPushToken < ActiveRecord::Base
  belongs_to :user

  validates :token, presence: true, uniqueness: { scope: :user }
  validates :user,  presence: true
end

