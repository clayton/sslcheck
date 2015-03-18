module SSLCheck
  module Validators
    class CABundle < GenericValidator
      def validate
        return nil if verified_certificate?
        SSLCheck::Errors::Validation::CABundleVerification.new({:name => "Certificate Authority Verification", :message => "The Certificate could not be verified using the supplied Certificate Authority (CA) Bundle."})
      end

    private
      def verified_certificate?
        return false if @ca_bundle.empty?

        store = OpenSSL::X509::Store.new

        @ca_bundle.each do |ca_cert|
          store.add_cert ca_cert.to_x509
        end

        store.verify(@peer_cert.to_x509)
      end
    end
  end
end
