# frozen_string_literal: true

# Example consumer that prints messages payloads
class UserConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      Rails.logger.info "=== BEGIN: Consuming topic #{message.topic} - #{message.payload} ==="

      payload = message.payload
      p payload["uuid"]

      next unless payload
      user = User.find_by(id: payload["uuid"])
      if user.nil?
        User.create!(email: payload["data"]['email'], password: "password")
        Rails.logger.info "User created: #{payload["uuid"]}"
      else
        Rails.logger.info "User already exists: #{payload['uuid']}"
      end
      mark_as_consumed(message)
    end
  end

end
