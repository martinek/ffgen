require 'slack-notifier'

class SlackNotificator

    def self.enabled?
        !ENV['SLACK_WEBHOOK'].nil?
    end

    def self.notify(message)
        return unless enabled?
        begin
            client.ping message
        rescue Exception => e
            puts 'Could not notify Slack: ' + e.message
        end
    end

    private

    def self.client
        @client ||= Slack::Notifier.new ENV['SLACK_WEBHOOK'], username: 'ffgen'
    end

end
