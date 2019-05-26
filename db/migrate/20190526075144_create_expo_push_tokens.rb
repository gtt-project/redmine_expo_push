class CreateExpoPushTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :expo_push_tokens do |t|
      t.references :user, foreign_key: true
      t.string :token, null: false
    end
  end
end
