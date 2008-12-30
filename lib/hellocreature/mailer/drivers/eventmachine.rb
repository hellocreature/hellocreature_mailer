module HelloCreature
  module Mailer
    module Drivers
      module EventMachine
        
        def perform_delivery_hellocreature_with_driver( mail )
          settings = hellocreature_mailer_settings
          mail_string = mail.encoded.gsub(/\r/, '')
          raw_post_content = "message=#{CGI.escape(mail_string)}"
          
          send_mail_proc = proc do |stop_event_loop|
            
            client = ::EventMachine::Protocols::HttpClient.request(
              :host=>::HelloCreature::Mailer::ENDPOINT_URL,
              :port=>80, 
              :verb=>:post, 
              :request=>::HelloCreature::Mailer::ENDPOINT_PATH, 
              :content=>raw_post_content,
              :contenttype=>"application/x-www-form-urlencoded",
              :basic_auth => {:username => settings[:email], :password => settings[:api_key]}
	      )
            
            client.callback do |r| 
              ::EventMachine.stop if stop_event_loop
            end
            
            client.errback do |e|
              puts "HelloCreature Mailer: Delivery Error #{e}"
              ::EventMachine.stop if stop_event_loop
            end
            
          end 
          
          if ::EventMachine.reactor_running?
            send_mail_proc.call(false)
          else
            ::EventMachine.run do
              send_mail_proc.call(true)
            end
          end
          
        rescue RuntimeError
          # we revert to net/http if we get a runtime error, as it means that for some reason EM is not working
          puts "HelloCreature::Mailer: EventMachine Runtime Error, falling back to net/http"
          require 'net/http'
          ActionMailer::Base.send(:include, ::HelloCreature::Mailer::Drivers::NetHttp)
          perform_delivery_hellocreature_with_driver( mail )
        end
        
      end
    end  
  end
end
