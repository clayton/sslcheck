module SSLCheck
  module Errors
    class Validation
      attr_accessor :name, :message
      def initialize(opts={})
        self.name = opts[:name]
        self.message = opts[:message]
      end

      def to_s
        "[#{self.name}] #{self.message}"
      end
    end

    class CommonNameMismatch < Validation;end
  end
end
