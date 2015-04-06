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
        store.set_default_paths

        begin
          store.add_file File.join(SSL_CHECK_ROOT_DIR,'ca-bundle', 'ca-bundle.crt')
        rescue OpenSSL::X509::StoreError
          # If the certificate is already present,
          # we don't really care
        end

        @ca_bundle.each do |ca_cert|
          begin
            store.add_cert ca_cert.to_x509
          rescue OpenSSL::X509::StoreError
          end
        end

        store.verify(@peer_cert.to_x509)
      end
    end
  end
end
