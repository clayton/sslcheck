module SSLCheck
  module Errors
    class Validation < GenericError
    end

    module Connection
      class InvalidURI < GenericError; end
      class SSLVerify < GenericError; end
    end

    class CommonNameMismatch < Validation;end
  end
end
