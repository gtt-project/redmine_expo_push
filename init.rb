require File.expand_path('../lib/redmine_expo_push/hooks', __FILE__)

if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
  Rails.application.config.after_initialize do
    RedmineExpoPush.setup
  end
else
  require 'redmine_expo_push'
  Rails.configuration.to_prepare do
    RedmineExpoPush.setup
  end
end

Redmine::Plugin.register :redmine_expo_push do
  name 'Redmine Expo Push Notifications Plugin'
  author 'Jens Krämer, Georepublic'
  author_url 'https://github.com/georepublic'
  url 'https://github.com/gtt-project/redmine_expo_push'
  description 'Notify mobile app users through push notifications'
  version '2.0.0'

  requires_redmine version_or_higher: '4.0.0'

  settings default: {
    'experience_id' => "@owner/slug(projectname)",
  }, partial: 'settings/expo_push_settings'

end
