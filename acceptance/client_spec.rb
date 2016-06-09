require 'spec_helper'

module SSLCheck
  describe 'Client' do
    context "Getting Certificates" do
      before do
        Client.timeout_seconds = 1
      end

      context "When Things Go Well" do
        it 'should have the host name' do
          sut = Client.new
          response = sut.get('https://letsencrypt.org')
          expect(response.host_name).to eq("letsencrypt.org")
        end

        it 'should have the peer certificate' do
          sut = Client.new
          response = sut.get('https://letsencrypt.org')
          expect(response.peer_cert).to be_a(SSLCheck::Certificate)
        end

        it 'should have the peer cert chain' do
          sut = Client.new
          response = sut.get('https://letsencrypt.org')
          expect(response.ca_bundle.first).to be_a(SSLCheck::Certificate)
        end
      end

      context "when the URL is missing the protocol" do
        it 'should still provide a hostname for the response' do
          sut = Client.new
          response = sut.get('letsencrypt.org')
          expect(response.host_name).to eq("letsencrypt.org")
        end
      end

      context "when the URL has an http protocol" do
        it 'should still provide a hostname for the response' do
          sut = Client.new
          response = sut.get('http://letsencrypt.org')
          expect(response.host_name).to eq("letsencrypt.org")
        end
      end

      context "When the URL is not a real TLD or gTLD" do
        it 'should raise a connection error' do
          Client.timeout_seconds = 1
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
          response = sut.get('http.badssl.com')
          expect(response.errors.first).to be_a(SSLCheck::Errors::Connection::SSLVerify)
        end
      end

      context "When the certificate is self-signed" do
        it 'should raise a verification error' do
          sut = Client.new
          response = sut.get('https://self-signed.badssl.com')
          expect(response.errors.first).to be_a(SSLCheck::Errors::Connection::SSLVerify)
        end
      end
    end
    describe 'Timeout' do
      before do
        Client.timeout_seconds = 30
      end

      it 'should use the timeout value when making connections' do
        expect(Timeout).to receive(:timeout).with(30)
        sut = Client.new
        sut.get('https://letsencrypt.org')
      end
      context 'When the timeout is not set' do
        it 'should default to 30 seconds' do
          expect(SSLCheck::Client.timeout_seconds).to eq(30)
        end
      end
      context 'overriding the default timeout' do
        it 'should use the supplied timeout value' do
          SSLCheck::Client.timeout_seconds = 10
          expect(SSLCheck::Client.timeout_seconds).to eq(10)
        end
        it 'should use the timeout value when making connections' do
          SSLCheck::Client.timeout_seconds = 10
          expect(Timeout).to receive(:timeout).with(10)
          sut = Client.new
          sut.get('https://letsencrypt.org')
        end
      end
      context 'When the timeout expires' do
        it 'should raise a connection error' do
          SSLCheck::Client.timeout_seconds = 1
          sut = Client.new
          response = sut.get("https://www.domain.does.not.exist.aljdahkqhb")
          expect(response.errors.first).to be_a(SSLCheck::Errors::Connection::SocketError)
        end
      end
    end
  end
end
