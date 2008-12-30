module HelloCreature
  module Mailer
    ENDPOINT_URL = "http://hellocreature.com"
    ENDPOINT_PATH = "/messages"

    # Tries to load EM, then curb, then falls back to net/http as the driver to use to make the http post
    def self.include_driver
      begin
        require 'eventmachine'
        require File.dirname(__FILE__) + '/../patches/em/basic_auth'
        ActionMailer::Base.send(:include, ::HelloCreature::Mailer::Drivers::EventMachine)
      rescue LoadError 
        require 'curb'
        puts "HelloCreature::Mailer: Could not find EventMachine (recommended), falling back to Curb"
        ActionMailer::Base.send(:include,  ::HelloCreature::Mailer::Drivers::Curb)
      rescue LoadError
        puts "HelloCreature::Mailer: Could not find EventMachine or Curb, falling back to net/http"
        require 'net/http'
        ActionMailer::Base.send(:include, ::HelloCreature::Mailer::Drivers::NetHttp)
      end      
    end

  end
end

require 'hellocreature/mailer/drivers'
