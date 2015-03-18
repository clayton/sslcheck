module SSLCheck
  module Validators
    class ExpirationDate < GenericValidator
      def validate(clock=DateTime)
        return nil if clock.now < @peer_cert.not_after
        SSLCheck::Errors::Validation::CertificateExpired.new({:name => "Certifiate Expired", :message => "This certificate expired on #{@peer_cert.not_after}."})
      end
    end
  end
end
