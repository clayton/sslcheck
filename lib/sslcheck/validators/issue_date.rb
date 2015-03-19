require 'date'

module SSLCheck
  module Validators
    class IssueDate < GenericValidator
      def validate(clock=DateTime)
        return nil if clock.now > @peer_cert.not_before
        SSLCheck::Errors::Validation::NotYetIssued.new({:name => "Not Yet Issues", :message => "This certificate is not valid until #{@peer_cert.not_before}."})
      end
    end
  end
end
