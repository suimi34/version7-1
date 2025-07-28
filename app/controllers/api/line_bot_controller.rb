require "line/bot"

class Api::LineBotController < ActionController::API
  # skip_before_action :verify_authenticity_token

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']

    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end

    events = client.parse_events_from(body)
    Rails.logger.info("Received events: #{events.inspect}")

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        handle_message(event)
      when Line::Bot::Event::Follow
        handle_follow(event)
      when Line::Bot::Event::Unfollow
        handle_unfollow(event)
      else
        Rails.logger.warn("Unhandled event type: #{event.class}")
      end
    end

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new do |config|
      # config.channel_secret = ENV.fetch("LINE_CHANNEL_SECRET")
      config.channel_token = ENV.fetch("LINE_CHANNEL_ACCESS_TOKEN")
    end
  end

  def handle_message(event)
    Rails.logger.info("Handling message event: #{event.inspect}")
  end

  def handle_follow(event)
    Rails.logger.info("Handling follow event: #{event.inspect}")
  end

  def handle_unfollow(event)
    Rails.logger.info("Handling unfollow event: #{event.inspect}")
  end
end
