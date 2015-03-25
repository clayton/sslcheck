require 'spec_helper'

module SSLCheck
  describe 'Checking Certificates' do
    context "when the certificate is missing" do
      before do
        @check = Check.new.check("www.claytonlz.com")
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
        @check = Check.new.check("http://www.sslinsight.com")
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
  end
end
