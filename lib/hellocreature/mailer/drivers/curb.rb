module HelloCreature
  module Mailer
    module Drivers
      module Curb
        
        def perform_delivery_hellocreature_with_driver( mail )
          ::Curl::Easy.new(::HelloCreature::Mailer::ENDPOINT) do |easy|
            settings = hellocreature_mailer_settings
            easy.userpwd = "#{settings[:email]}:#{settings[:api_key]}" 
            easy.http_post(Curl::PostField.content('message', mail.to_s) )
            puts "HelloCreatureMailer: Authentication error" if easy.response_code == 401
            puts "HelloCreatureMailer: Server Error" if easy.response_code != 202
          end              
        end 
      end
    end
  end
end
