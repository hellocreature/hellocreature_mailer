
module ActionMailer
  class Base
   
    cattr_accessor :hellocreature_mailer_settings
    
    def perform_delivery_hellocreature(mail)
      hellocreature_mailer_settings[:evented] ? perform_delivery_hellocreature_evented(mail) : perform_delivery_hellocreature_curl(mail)
    end
    
    def perform_delivery_hellocreature_curl(mail)
      require 'curb'
      ::Curl::Easy.new("http://hellocreature.com/messages") do |easy|
        settings = hellocreature_mailer_settings
        easy.userpwd = "#{settings[:email]}:#{settings[:api_key]}" 
        easy.http_post(Curl::PostField.content('message', mail.to_s) )
        raise "Authentication error" if easy.response_code == 401
        raise "Server Error #{easy.body_str}" if easy.response_code != 202
        #raise "HelloCreauture API Error (please report to support@hellocreature.com)" if easy.body_str != 'Message Queued'
      end              
    end #perform delivery_hellocreature

    # TODO: update to current version of eventmachine basic auth syntax    
    def perform_delivery_hellocreature_evented(mail)
    
      settings = hellocreature_mailer_settings
      mail_string = mail.encoded.gsub(/\r/, '')
      raw_post_content = "message=#{CGI.escape(mail_string)}"
      
      send_mail_proc = proc do |stop_event_loop|
        
        client = EventMachine::Protocols::HttpClient.request(
          :host=>"hellocreature.com",
	        :port=>80, 
	        :verb=>:post, 
	        :request=>"/messages", 
	        :content=>raw_post_content,
	        :contenttype=>"application/x-www-form-urlencoded",
	        :basic_auth => {:username => settings[:email], :password => settings[:api_key]}
	      )
	      
        client.callback do |r| 
          EventMachine.stop if stop_event_loop
        end
        
        client.errback do |e|
          raise "Delivery Error #{e}"
        end
      
      end #send_mail_proc

      if EventMachine.reactor_running?
        send_mail_proc.call(false)
      else
        EventMachine.run_block do
          send_mail_proc.call(true)
        end
      end
    end 
      
    
  end
end



 


