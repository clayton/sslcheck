require 'spec_helper'

module SslCheck
  describe Validator do
    before(:each) do
      @valid   = VALID_CERT
      @invalid = INVALID_CERT
    end
    describe "Checking the cert and ca cert" do
      context "when it's valid" do
        before(:each) do
          @parser = Parser.new(@valid)
        end
        it "should validate certs signed by the ca" do
          sut = Validator.new(@parser)
          expect(sut.validate_certificates).to be
        end
      end
      context "when it's invalid" do
        before(:each) do
          @parser = Parser.new(@invalid)
        end
        it "should not validate bad certs that weren't signed by the ca" do
          sut = Validator.new(@parser)
          expect(sut.validate_certificates).to_not be
        end
      end
      context 'when the ca is missing' do
        before(:each) do
          @parser = Parser.new(MISSING_CA_CERT)
        end
        it "should raise an exception" do
          sut = Validator.new(@parser)
          expect{ sut.validate_certificates }.to raise_exception Validator::MissingCACertificate
        end
      end
    end
    describe "Checking that the common name matches" do
      context 'when it matches' do
        before(:each) do
          @parser = Parser.new(@valid, "www.npboards.com")
        end
        it "should be valid" do
          sut = Validator.new(@parser)
          expect(sut.validate_common_name).to be
        end
      end
      context 'when it does not' do
        before(:each) do
          @parser = Parser.new(@valid, "www.example.org")
        end
        it "should not be valid" do
          sut = Validator.new(@parser)
          expect(sut.validate_common_name).to_not be
        end
      end
      context 'when it is a wildcard certificate' do
        before(:each) do
          @parser = Parser.new(WILDCARD_CERT, "www.squarespace.com")
        end
        it "should be valid" do
          sut = Validator.new(@parser)
          expect(sut.validate_common_name).to be
        end
      end
      context 'when it is a wildcard certificate, but the domain is different' do
        before(:each) do
          @parser = Parser.new(WILDCARD_CERT, "www.example.com")
        end
        it "should not be valid" do
          sut = Validator.new(@parser)
          expect(sut.validate_common_name).to_not be
        end
      end
      context 'when the cert is issues in uppercase, but monitoring lowercase' do
        before(:each) do
          @parser = Parser.new(UPPERCASE_CERT, "www.npboards.com")
        end
        it "should be valid" do
          sut = Validator.new(@parser)
          expect(sut.validate_common_name).to be
        end
      end
      context 'when the cert is issued in lowercase, but monitoring uppercase' do
        before(:each) do
          @parser = Parser.new(UPPERCASE_CERT, "www.NpBoards.com")
        end
        it "should be valid" do
          sut = Validator.new(@parser)
          expect(sut.validate_common_name).to be
        end
      end
    end
    describe "Checking the expiration date" do
      context 'when it is not expired' do
        it "should be valid" do
          not_expired = double(Certificate, :expired? => false)
          parser = double(Parser, :certificate => not_expired,:url => "")
          sut = Validator.new(parser)
          expect(sut.validate_expiration_date).to be
        end
      end
      context 'when it is expired' do
        it "should not be valid" do
          expired = double(Certificate, :expired? => true)
          parser = double(Parser, :certificate => expired,:url => "")
          sut = Validator.new(parser)
          expect(sut.validate_expiration_date).to_not be
        end
      end
    end
    describe "Checking the issue date" do
      context 'when it is not yet issued' do
        it "should not be valid" do
          not_issued = double(Certificate, :expired? => false, :issued? => false)
          parser = double(Parser, :certificate => not_issued, :url => "")
          sut = Validator.new(parser)
          expect(sut.validate_issue_date).to_not be
        end
      end
      context 'when it has been issued' do
        it "should be valid" do
          issued = double(Certificate, :expired? => true, :issued? => true)
          parser = double(Parser, :certificate => issued, :url => "")
          sut = Validator.new(parser)
          expect(sut.validate_issue_date).to be
        end
      end
    end
    describe "Checking Issue and Expiration Dates" do
      context 'when it has been issued, but is expired' do
        it "should not be valid" do
          issued = double(Certificate, :expired? => true, :issued? => true)
          parser = double(Parser, :certificate => issued, :url => "")
          sut = Validator.new(parser)
          expect(sut.validate_dates).to_not be
        end
      end
      context 'when it has not been issued, but is not expired' do
        it "should not be valid" do
          issued = double(Certificate, :expired? => false, :issued? => false)
          parser = double(Parser, :certificate => issued, :url => "")
          sut = Validator.new(parser)
          expect(sut.validate_dates).to_not be
        end
      end
    end
  end
end
