module SSLCheck
  module Validators
    class CommonName < GenericValidator
      def validate
        return nil if common_name_matches?
        SSLCheck::Errors::Validation::CommonNameMismatch.new({:name => "Common Name Mismatch", :message => "This certificate is not valid for #{@common_name}."})
      end

    private
      def common_name_matches?
        matching_wildcard_domain || alternate_common_name_match || direct_common_name_match
      end

      def matching_wildcard_domain
        true if (@peer_cert.common_name.match(/\*\./) && @common_name.include?(@peer_cert.common_name.gsub(/\*\./,'')))
      end

      def direct_common_name_match
        @peer_cert.common_name.downcase == @common_name.downcase
      end

      def alternate_common_name_match
        @peer_cert.alternate_common_names.include?(@common_name.downcase)
      end
    end
  end
end
