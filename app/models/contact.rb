# == Schema Information
#
# Table name: contacts
#
#  id           :bigint           not null, primary key
#  carrier_type :text
#  documents    :text             default([]), is an Array
#  first_name   :text
#  last_name    :text
#  opted_in     :boolean
#  phone_number :text
#  renewal_date :date
#  response     :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Contact < ApplicationRecord
  has_many :messages, -> { order(created_at: :asc) }
  has_many :inbound_messages, -> { inbound.order(created_at: :asc) }, class_name: 'Message'
  has_many :outbound_messages, -> { outbound.order(created_at: :asc) }, class_name: 'Message'

  scope :opted_in, -> { where(opted_in: true) }
  scope :mobile, -> { where(carrier_type: 'mobile') }
  scope :received_message, ->(message_class) { joins(:messages).merge(Message.with_type(message_class)).distinct }
  scope :not_received_message, ->(message_class) { where.not(id: unscoped.received_message(message_class).select(:id)) }
  scope :with_enrollment_documents, -> { where.not(enrollment_documents: []) }
  scope :no_response, -> { where(response: "no") }

  def phone_number=(value)
    super(PhoneNumber.format(value))
  end
end
