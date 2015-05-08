module SSLCheck
  module Errors
    module Connection
      class InvalidURI < GenericError; end
      class SSLVerify < GenericError; end
      class SocketError < GenericError; end
      class Timeout < GenericError; end
    end

    module Validation
      class CommonNameMismatch < GenericError;end
      class NotYetIssued < GenericError;end
      class CertificateExpired < GenericError;end
      class CABundleVerification < GenericError;end
    end
  end
end
