require 'spec_helper'

module SSLCheck
  describe 'Checking Certificates' do
    context "when the certificate is missing" do
      before do
        SSLCheck::Client.timeout_seconds = 1
        @check = Check.new.check("nossl.com")
      end
      it 'should not be valid' do
        expect(@check.valid?).to_not be
      end
      it 'should have errors' do
        expect(@check.errors).to_not be_empty
      end
    end
    context "when the certificate is valid" do
      before do
        @check = Check.new.check("letsencrypt.org")
      end
      it 'should be valid' do
        expect(@check.valid?).to be
      end
      it 'should not have any errors' do
        expect(@check.errors).to be_empty
      end
      it 'should know the peer certificate' do
        expect(@check.peer_cert).to be
      end
      it 'should know the ca bundle' do
        expect(@check.ca_bundle).to be
      end
    end
    xcontext "when the certificate is on a subdomain, but not a wildcard cert" do
      before do
        @check = Check.new.check("https://www.httpbin.org")
      end
      it 'should be valid' do
        expect(@check.valid?).to be
      end
      it 'should not have any errors' do
        expect(@check.errors).to be_empty
      end
    end
    context "when the common name is not correct" do
      before do
        @check = Check.new.check('https://wrong.host.badssl.com/')
      end
      it 'should not be valid' do
        expect(@check.valid?).to_not be
      end
      it 'should have errors' do
        expect(@check.errors).to_not be_empty
      end
    end
  end
end
