require 'spec_helper'

module SSLCheck
  describe Check do
    before do
      @peer_cert       = SSLCheck::Certificate.new(VALID_CERT)
      @ca_parent       = SSLCheck::Certificate.new(CA_PARENT)
      @ca_grand_parent = SSLCheck::Certificate.new(CA_GRAND_PARENT)
      @ca_bundle       = [@ca_parent, @ca_grand_parent]
    end

    it 'should not be failed by default' do
      sut = Check.new(FakeClient.new)
      expect(sut.failed?).to_not be
      expect(sut.errors).to be_empty
    end

    it 'should be invalid by default' do
      sut = Check.new(FakeClient.new)
      expect(sut.valid?).to_not be
    end

    it 'should not be done checking by default' do
      sut = Check.new(FakeClient.new)
      expect(sut.checked?).to_not be
    end

    describe 'checking' do
      it 'should tell the client to get the certs' do
        fake_client = FakeClient.new
        @sut = Check.new(fake_client, FakeValidator.new)
        expect(fake_client).to receive(:get).with("www.example.com").and_return(FakeClientResponse.new)
        @sut.check('www.example.com')
      end

      it 'should expose the certificates that were found' do
        @sut = Check.new(FakeClient.new(FakeClientResponse.new(@peer_cert, @ca_bundle)), FakeValidator.new)
        @sut.check('www.example.com')
        expect(@sut.peer_cert).to be
        expect(@sut.ca_bundle).to be
      end

      it 'should expose the hostname parsed from the URL' do
        @sut = Check.new(FakeClient.new(FakeClientResponse.new(@peer_cert, @ca_bundle, "www.example.com")), FakeValidator.new)
        @sut.check('www.example.com')
        expect(@sut.host_name).to eq("www.example.com")
      end

      it 'should know when the check has completed' do
        @sut = Check.new(FakeClient.new(FakeClientResponse.new(@peer_cert, @ca_bundle)), FakeValidator.new)
        @sut.check('www.example.com')
        expect(@sut.checked?).to be
      end

      it 'should know what URL was checked' do
        @sut = Check.new(FakeClient.new(FakeClientResponse.new(@peer_cert, @ca_bundle)), FakeValidator.new)
        @sut.check('www.example.com')
        expect(@sut.url).to eq("www.example.com")
      end

      context "when there is an error checking the certificate" do
        it 'should not be valid' do
          error = SSLCheck::Errors::GenericError.new({:name => :invalid_uri, :message => "Invalid URI"})
          @sut  = Check.new(FakeClient.new(nil, [error]), FakeValidator.new)
          @sut.check('www.example.com')
          expect(@sut.valid?).to_not be
        end
        context "when the URI is malformed" do
          it 'should add an error to the error list' do
            error = SSLCheck::Errors::GenericError.new({:name => :invalid_uri, :message => "Invalid URI"})
            validator = FakeValidator.new
            @sut  = Check.new(FakeClient.new(nil, [error]), validator)

            expect(validator).to_not receive(:validate)
            @sut.check('www.example.com')
          end
          it 'should not try to validate the certificate' do
            error = SSLCheck::Errors::GenericError.new({:name => :invalid_uri, :message => "Invalid URI"})
            @sut  = Check.new(FakeClient.new(nil, [error]))
            @sut.check('www.example.com')
          end
        end
        context "when there was an OpenSSL error" do
          it 'should add an error to the error list' do
            error = SSLCheck::Errors::GenericError.new({:name => :openssl_error, :message => "OpenSSL Verification Error"})
            @sut  = Check.new(FakeClient.new(nil, [error]))
            @sut.check('www.example.com')
            expect(@sut.errors).to eq([error])
            expect(@sut.failed?).to be
          end
        end
      end
    end

    describe 'validation' do
      it 'should tell the validator to validate the peer certificate' do
        validator = FakeValidator.new
        @sut = Check.new(FakeClient.new(FakeClientResponse.new(@peer_cert, @ca_bundle)), validator)
        expect(validator).to receive(:validate).with("www.example.com", @peer_cert, @ca_bundle)
        @sut.check("www.example.com")
      end
      context "when the certificate is valid" do
        it 'should have no errors' do
          @sut = Check.new(FakeClient.new(FakeClientResponse.new(@peer_cert, @ca_bundle)), FakeValidator.new)
          @sut.check('www.example.com')
          expect(@sut.errors).to eq([])
        end
        it 'should be valid' do
          @sut = Check.new(FakeClient.new(FakeClientResponse.new(@peer_cert, @ca_bundle)), FakeValidator.new)
          @sut.check('www.example.com')
          expect(@sut.valid?).to be
        end
      end
    end
  end
end

class FakeClient
  def initialize(response=nil, errors=[])
    @response = response  || FakeClientResponse.new
    @errors = errors
  end
  def get(url)
    @response

    @errors.each do |error|
      @response.errors << error
    end
    @response
  end
end

class FakeClientResponse
  def initialize(peer_cert=nil, ca_bundle=nil, host_name=nil)
    @peer_cert = peer_cert || SSLCheck::Certificate.new(VALID_CERT)
    @ca_bundle = ca_bundle || [SSLCheck::Certificate.new(CA_PARENT), SSLCheck::Certificate.new(CA_GRAND_PARENT)]
    @host_name = host_name || "www.example.com"
    @errors = []
  end

  def peer_cert
    @peer_cert
  end

  def ca_bundle
    @ca_bundle
  end

  def host_name
    @host_name
  end

  def errors
    @errors
  end
end


class FakeValidator
  def initialize(valid=true, errors=[])
    @valid = valid
    @errors = errors
  end

  def validate(common_name, peer_cert, ca_bundle)
    @valid
  end

  def errors
    @errors
  end
end
