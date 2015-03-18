module SSLCheck
  module Errors
    class GenericError
      attr_accessor :name, :type, :message
      def initialize(opts={})
        self.name    = opts[:name]
        self.type    = opts[:type]
        self.message = opts[:message]
      end
      def to_s
        "[#{self.name}] #{self.message}"
      end
    end
  end
end
