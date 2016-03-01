require 'postmark'

class EmailNotificator

  def self.enabled?
    !ENV['POSTMARK_API_TOKEN'].nil? &&
        !ENV['POSTMARK_FROM'].nil? &&
        !ENV['EMAIL_NOTIFICATION_TO'].nil?
  end

  def self.notify(message)
    return unless enabled?
    begin
      client.deliver(
          from: ENV.fetch('POSTMARK_FROM'),
          to: ENV.fetch('EMAIL_NOTIFICATION_TO'),
          subject: ENV.fetch('EMAIL_NOTIFICATION_SUBJECT', 'Notification from ffgen'),
          text_body: message,
          track_opens: false)
    rescue Exception => e
      puts 'Could not notify Email: ' + e.message
    end
  end

  private

  def self.client
    @client ||= Postmark::ApiClient.new(ENV['POSTMARK_API_TOKEN'])
  end

end
