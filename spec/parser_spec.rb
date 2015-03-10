require 'spec_helper'

module SslCheck
  describe Parser do
    context 'When the raw data contains a connection refused' do
      it "should raise an exception" do
        sut = Parser.new(CONNECTION_REFUSED, 'claytonlz.com')
        expect{sut.parse}.to raise_exception(Parser::SSLNotConfigured)
      end
    end
    it "should parse the details out of the s_client results" do
      allow(Validator).to receive(:new).and_return(double(:validate => true))
      sut = Parser.new(VALID_CERT, "www.npboards.com")
      results = sut.parse
      expect(results['valid_certificate']).to eq true
      expect(results['issued_by']).to eq "Go Daddy Secure Certificate Authority - G2"
      expect(results['issued_at']).to eq DateTime.parse("Tue, 17 Jun 2014 18:16:01 +0000")
      expect(results['expires_at']).to eq DateTime.parse("Tue, 17 Jun 2015 18:16:01 +0000")
      expect(results['organizational_unit']).to eq "Domain Control Validated"
      expect(results['common_name']).to eq "www.npboards.com"
      expect(results['issuer_country']).to eq "US"
      expect(results['issuer_state']).to eq "Arizona"
      expect(results['issuer_locality']).to eq "Scottsdale"
      expect(results['issuer_organization']).to eq "GoDaddy.com, Inc."
      expect(results['issuer_common_name']).to eq "Go Daddy Secure Certificate Authority - G2"
    end

    context 'When parsing results with no locality information' do
      it "should parse the details out of the s_client results" do
        allow(Validator).to receive(:new).and_return(double(:validate => true))
        sut = Parser.new(TUMBLER_CERT, "www.tumbler.com")
        results = sut.parse
        expect(results['valid_certificate']).to eq true
        expect(results['organizational_unit']).to eq "Tervis Tumbler"
        expect(results['common_name']).to eq "www.tervis.com"
        expect(results['issuer_country']).to eq "US"
        expect(results['issuer_state']).to eq nil
        expect(results['issuer_locality']).to eq nil
      end

    end
  end
end
