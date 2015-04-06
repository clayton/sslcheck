require "sslcheck/version"
require 'openssl'
require 'active_support/all'

module SSLCheck
  # Your code goes here...
end

SSL_CHECK_ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require 'sslcheck/certificate'
require 'sslcheck/validator'
require 'sslcheck/certificate_client'
require 'sslcheck/parser'
require 'sslcheck/generic_error'
require 'sslcheck/check'
require 'sslcheck/client'
require 'sslcheck/validators/generic_validator'
require 'sslcheck/validators/errors'
require 'sslcheck/validators/common_name'
require 'sslcheck/validators/issue_date'
require 'sslcheck/validators/expiration_date'
require 'sslcheck/validators/ca_bundle'
