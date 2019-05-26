class ExpoPushToken < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :token
  validates_presence_of :user
end

