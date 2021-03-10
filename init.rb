require 'redmine'

require 'redmine_expo_push'
require 'redmine_expo_push/hooks'

Rails.configuration.to_prepare do
  RedmineExpoPush.setup
end

Redmine::Plugin.register :redmine_expo_push do
  name 'Redmine Expo Push Notifications Plugin'
  author 'Jens Krämer, Georepublic'
  author_url 'https://hub.georepublic.net/gtt/redmine_expo_push'
  description 'Notify mobile app users through push notifications'
  version '1.0.0'

  requires_redmine version_or_higher: '4.0.0'

  settings default: {
    'experience_id' => "@owner/slug(projectname)",
  }, partial: 'settings/expo_push_settings'

end
