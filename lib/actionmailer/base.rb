
module ActionMailer
  class Base
    cattr_accessor :hellocreature_mailer_settings

    def perform_delivery_hellocreature( mail )
      ::HelloCreature::Mailer::include_driver unless self.respond_to?(:perform_delivery_hellocreature_with_driver)
      perform_delivery_hellocreature_with_driver( mail )
    end

  end
end



 


