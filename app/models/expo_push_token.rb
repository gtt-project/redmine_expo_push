class ExpoPushToken < ActiveRecord::Base
  belongs_to :user

  validates :token, presence: true, uniqueness: { scope: :user }
  validates :user,  presence: true
  validates :experience_id, presence: true

  after_save :remove_other_experiences

  private

  def remove_other_experiences
    ExpoPushToken.where('user_id=? AND experience_id IS NULL OR experience_id!=?', self.user.id, self.experience_id).delete_all
  end
end
