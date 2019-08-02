class OptInMessage < CampaignMessage
  attr_reader :contact

  def self.recipients
    Contact.not_received_message(self).where(opted_in: nil)
  end

  def initialize(contact)
    @contact = contact
  end

  def send_message
    body = "Louisiana Medicaid is testing out a text message reminder program. "\
           "Would you like to receive reminders, notices and confirmations about the enrollment and renewal processes? "\
           "These texts will be in addition to any letters and calls you already receive. "\
           "Please reply with YES or NO. You can opt out of the service at any time."

    message = contact.messages.create!(
      message_type: self.class.name,
      to_phone_number: contact.phone_number,
      body: body
    )

    SmsService.send_message(message)
  end

  def on_reply(message)
    clean_reply = message.body.downcase.strip

    if clean_reply.match Regexp.union([/\Ay\z/, /yes/i])
      contact.update opted_in: true

      body = "You have opted in to text messages about your Medicaid case. "\
             "You can opt out of this service at any time by replying with STOP."

      message = contact.messages.create!(
        message_type: self.class.name,
        to_phone_number: contact.phone_number,
        body: body
      )

      SmsService.send_message(message)
    elsif clean_reply.match Regexp.union([/\An\z/, /no/i])
      contact.update opted_in: false

      body = "You have opted out. You will not receive any more text messages from Medicaid."

      message = contact.messages.create!(
        message_type: self.class.name,
        to_phone_number: contact.phone_number,
        body: body
      )

      SmsService.send_message(message)
    end
  end
end
