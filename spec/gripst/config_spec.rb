# frozen_string_literal: true

RSpec.describe Gripst::Config do
  describe "auth_token" do
    it "can be initialized with config" do
      token = 'token'
      result = Gripst::Config.new(auth_token: token).auth_token
      expect(result).to eq token
    end

    it "checks the environment for a variable" do
      token = 'via_env_token'
      env = { 'GITHUB_USER_ACCESS_TOKEN' => token }
      result = Gripst::Config.new(env: env).auth_token
      expect(result).to eq token
    end

    it "fetches the token via the client if it does not otherwise exist" do
      token = 'via_client_token'
      client = Struct.new(:get_auth_token).new(token)
      result = Gripst::Config.new(github: client).auth_token
      expect(result).to eq token
    end
  end

  describe "github" do
    it "defaults to Gripst::Client" do
      result = subject.github
      expect(result).to eq Client
    end
  end

  describe "git" do
    it "defaults to Git" do
      result = subject.git
      expect(result).to eq Git
    end
  end
end
