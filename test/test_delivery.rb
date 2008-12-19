require 'rubygems'
require 'actionmailer'
require 'rmail'
require 'eventmachine'
require '../lib/hellocreature_mailer'

ActionMailer::Base.delivery_method = :hellocreature
ActionMailer::Base.hellocreature_mailer_settings = {
  :email => 'test@hellocreature.com', 
  :api_key => 'secret', 
  :evented => false
}

ActionMailer::Base.default_charset = "utf-8"
    
# note the from domain must match the domainkeys signing domain for 
# testing or the email will not appear to be successfully signed.
class MyMailer < ActionMailer::Base
  def signup_notification
    recipients   "Dave Wilson <recipient_test@hellocreature.com>"
    subject      "New account information"
    from         "Accounts <sender_test@hellocreature.com>"
    body         "Dear Dave Wilson,\n\nThank you for signing up!"
    content_type "text/plain"
  end
end

MyMailer.deliver_signup_notification

# check inbox
