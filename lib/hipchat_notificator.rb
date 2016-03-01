require 'hipchat'

class HipchatNotificator

  def self.enabled?
    !ENV['HIPCHAT_TOKEN'].nil?
  end

  def self.notify(message)
    return unless enabled?
    begin
      user.send(message)
    rescue Exception => e
      puts 'Could not notify HipChat: ' + e.message
    end
  end

  private

  def self.user
    @user ||= client.user(ENV.fetch('HIPCHAT_USER'))
  end

  def self.client
    @client ||= HipChat::Client.new(ENV.fetch('HIPCHAT_TOKEN'), api_version: 'v2')
  end

end
