module SSLCheck
  module Validators
    class GenericValidator
      def initialize(common_name, peer_cert, ca_bundle)
        @common_name = common_name
        @peer_cert = peer_cert
        @ca_bundle = ca_bundle
      end

      def validate
        nil
      end
    end
  end
end
