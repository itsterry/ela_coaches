RSpec.describe Turnstile do
  let(:verify_url) { "https://challenges.cloudflare.com/turnstile/v0/siteverify" }

  describe ".site_key" do
    it "reads the credential" do
      expect(Turnstile.site_key).to eq Rails.application.credentials.dig(:turnstile, :site_key)
    end
  end

  describe ".verified?" do
    it "sends the token, secret and remote ip to cloudflare" do
      request = stub_request(:post, verify_url)
        .with(body: { "secret" => Rails.application.credentials.dig(:turnstile, :secret_key),
                      "response" => "a-token",
                      "remoteip" => "1.2.3.4" })
        .to_return(body: { success: true }.to_json)

      Turnstile.verified?(token: "a-token", ip: "1.2.3.4")

      expect(request).to have_been_requested
    end

    it "is true when cloudflare accepts the token" do
      stub_request(:post, verify_url).to_return(body: { success: true }.to_json)
      expect(Turnstile).to be_verified(token: "a-token", ip: "1.2.3.4")
    end

    it "is false when cloudflare rejects the token" do
      stub_request(:post, verify_url).to_return(body: { success: false }.to_json)
      expect(Turnstile).to_not be_verified(token: "a-token", ip: "1.2.3.4")
    end

    it "is false without a token" do
      expect(Turnstile).to_not be_verified(token: "", ip: "1.2.3.4")
    end

    it "omits the remote ip when it is unknown" do
      request = stub_request(:post, verify_url)
        .with { |sent| !sent.body.include?("remoteip") }
        .to_return(body: { success: true }.to_json)

      Turnstile.verified?(token: "a-token", ip: nil)

      expect(request).to have_been_requested
    end

    context "when cloudflare cannot be reached" do
      before { stub_request(:post, verify_url).to_timeout }

      it { expect(Turnstile).to_not be_verified(token: "a-token", ip: "1.2.3.4") }

      it "reports the error" do
        expect(Rollbar).to receive(:error).with(instance_of(Net::OpenTimeout))
        Turnstile.verified?(token: "a-token", ip: "1.2.3.4")
      end
    end

    context "when cloudflare returns junk" do
      before { stub_request(:post, verify_url).to_return(body: "not json") }

      it { expect(Turnstile).to_not be_verified(token: "a-token", ip: "1.2.3.4") }
    end
  end
end
