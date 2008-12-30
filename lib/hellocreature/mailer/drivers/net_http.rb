module HelloCreature
  module Mailer
    module Drivers
      module NetHttp

        def perform_delivery_hellocreature_with_driver( mail )
          settings = hellocreature_mailer_settings
          url = URI.parse(::HelloCreature::Mailer::ENDPOINT_URL + ::HelloCreature::Mailer::ENDPOINT_PATH)
          req = Net::HTTP::Post.new(url.path)
          req.basic_auth settings[:email], settings[:api_key]
          req.set_form_data({'message'=>mail.to_s})
          res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
          case res
          when Net::HTTPSuccess
            # Delivery succeeded
          else
            puts "HelloCreature Mailer: Delivery Error"
          end
        end
      end
    end
  end
end
