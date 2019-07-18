module RedmineExpoPush
  module Patches
    module MailerPatch

      def self.apply
        Mailer.class_eval do
          class << self
            prepend ClassMethods
          end

          def news_added(user, news)
            redmine_headers 'Project' => news.project.identifier
            @author = news.author
            message_id news
            references news
            @news = news
            @news_url = url_for(:controller => 'news', :action => 'show', :id => news)
            mail :to => user,
              :subject => "#{news.title}"
          end

          def issue_edit(user, journal)
            if journal.new_value_for('status_id')
              issue = journal.journalized
              redmine_headers 'Project' => issue.project.identifier,
                              'Issue-Id' => issue.id,
                              'Issue-Author' => issue.author.login
              redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
              message_id journal
              references issue
              @author = journal.user
              s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
              s << "(#{issue.status.name}) " if journal.new_value_for('status_id')
              s << issue.subject
              @issue = issue
              @user = user
              @journal = journal
              @journal_details = journal.visible_details
              @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")
              mail :to => user,
                :subject => "レポート：[ #{issue.subject} ] の対応状況が更新されました"
            else
              super
            end
          end
        end
      end

      module ClassMethods

        def deliver_mail(mail, &block)
          if perform_deliveries
            notification = nil
            %i(to cc bcc).each do |field|
              receivers = Array(mail.send(field)).flatten.compact
              skip_receivers = []
              receivers.each do |addr|
                user = User.having_mail(addr).first
                if user.present? and user.send_push_notifications?
                  notification ||= RedmineExpoPush::Notification.for(mail)
                  notification.add_recipient user
                  skip_receivers << addr if user.push_skip_emails?
                end
              end
              mail.send "#{field}=", (receivers - skip_receivers)
            end
            notification.deliver if notification
          end

          super
        end

      end

    end
  end
end

