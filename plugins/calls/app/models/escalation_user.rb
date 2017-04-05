class EscalationUser < ActiveRecord::Base
  unloadable
  VALID_PHONE_NUMBER_REGEX = /\A\+\d{10}\z|\A\+\d{11}\z|\A\+\d{12}\z/
  validates :phone_number, presence: true, format: { with: VALID_PHONE_NUMBER_REGEX }
end
