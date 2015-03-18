module SSLCheck
  module Errors
    module Connection
      class InvalidURI < GenericError; end
      class SSLVerify < GenericError; end
    end

    module Validation
      class CommonNameMismatch < GenericError;end
      class NotYetIssued < GenericError;end
      class CertificateExpired < GenericError;end
    end
  end
end
