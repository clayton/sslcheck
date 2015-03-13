require 'spec_helper'

module SSLCheck
  describe 'Client' do
    context "Getting Certificates" do
      context "When Things Go Well" do
        it 'should have the peer certificate' do
          sut = Client.new
          response = sut.get('https://www.sslinsight.com')
          expect(response.peer_cert).to be_a(OpenSSL::X509::Certificate)
        end

        it 'should have the peer cert chain' do
          sut = Client.new
          response = sut.get('https://www.sslinsight.com')
          expect(response.peer_cert_chain.first).to be_a(OpenSSL::X509::Certificate)
        end
      end
      context "When the Url is malformed" do
        it 'should raise an invalid URI error' do
          sut = Client.new
          response = sut.get('this is not even close to a valid url.com')
          expect(response.errors.first).to be_a(Client::Error)
        end
      end

      context "When there is no SSL Certificate present" do
        it 'should raise a verification error' do
          sut = Client.new
          response = sut.get('http://www.claytonlz.com')
          expect(response.errors.first).to be_a(Client::Error)
        end
      end

      context "When the certificate is self-signed" do
        it 'should raise a verification error' do
          sut = Client.new
          response = sut.get('https://www.pcwebshop.co.uk')
          expect(response.errors.first).to be_a(Client::Error)
        end
      end
    end
  end
end
