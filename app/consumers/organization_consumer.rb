class OrganizationConsumer < ApplicationConsumer
  attr_reader :message

  def consume
    messages.each do |message|
      payload = message.payload
      next unless payload
      organization = Organization.find_by(id: payload['id'])
      if organization.nil?
        Organization.create!(
          country: payload['country'],
          number_of_employees: payload['number_of_employees'],
          is_csa: payload['is_csa'],
          external_id: payload['external_id']
        )
        Rails.logger.info "Organization created: #{payload['organization_id']}"
      else
        Rails.logger.info "Organization already exists: #{payload['organization_id']}"
      end
      mark_as_consumed(message)
    end
  end
end

