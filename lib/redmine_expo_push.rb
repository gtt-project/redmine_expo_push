module RedmineExpoPush
  def self.setup
    # RedmineExpoPush::Patches::MailerPatch.apply
    RedmineExpoPush::Patches::UserPatch.apply
  end
end
