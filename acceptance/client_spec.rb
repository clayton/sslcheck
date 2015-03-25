require 'spec_helper'

module SSLCheck
  describe 'Client' do
    context "Getting Certificates" do
      context "When Things Go Well" do
        it 'should have the host name' do
          sut = Client.new
          response = sut.get('https://www.sslinsight.com')
          expect(response.host_name).to eq("www.sslinsight.com")
        end

        it 'should have the peer certificate' do
          sut = Client.new
          response = sut.get('https://www.sslinsight.com')
          expect(response.peer_cert).to be_a(SSLCheck::Certificate)
        end

        it 'should have the peer cert chain' do
          sut = Client.new
          response = sut.get('https://www.sslinsight.com')
          expect(response.ca_bundle.first).to be_a(SSLCheck::Certificate)
        end
      end

      context "when the URL is missing the protocol" do
        it 'should still provide a hostname for the response' do
          sut = Client.new
          response = sut.get('www.sslinsight.com')
          expect(response.host_name).to eq("www.sslinsight.com")
        end
      end

      context "when the URL has an http protocol" do
        it 'should still provide a hostname for the response' do
          sut = Client.new
          response = sut.get('http://www.sslinsight.com')
          expect(response.host_name).to eq("www.sslinsight.com")
        end
      end

      context "When the URL is not a real TLD or gTLD" do
        it 'should raise a connection error' do
          sut = Client.new
          response = sut.get("https://www.domain.does.not.exist.aljdahkqhb")
          expect(response.errors.first).to be_a(SSLCheck::Errors::Connection::SocketError)
        end
      end

      context "When the URL is malformed" do
        it 'should raise an invalid URI error' do
          sut = Client.new
          response = sut.get('this is not even close to a valid url.com')
          expect(response.errors.first).to be_a(SSLCheck::Errors::Connection::InvalidURI)
        end
      end

      context "When there is no SSL Certificate present" do
        it 'should raise a verification error' do
          sut = Client.new
          response = sut.get('http://www.claytonlz.com')
          expect(response.errors.first).to be_a(SSLCheck::Errors::Connection::SSLVerify)
        end
      end

      context "When the certificate is self-signed" do
        it 'should raise a verification error' do
          sut = Client.new
          response = sut.get('https://www.pcwebshop.co.uk')
          expect(response.errors.first).to be_a(SSLCheck::Errors::Connection::SSLVerify)
        end
      end
    end
  end
end
