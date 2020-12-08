class AddExperienceIdToExpoPushTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :expo_push_tokens, :experience_id, :string
  end
end
