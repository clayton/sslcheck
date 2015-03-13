require 'spec_helper'

module SSLCheck
  describe 'Checking Certificates' do
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
