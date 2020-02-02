# frozen_string_literal: true

RSpec.describe Gripst::Config do
  describe 'auth_token' do
    it 'can be initialized with config' do
      token = 'token'
      result = Gripst::Config.new(auth_token: token).auth_token
      expect(result).to eq token
    end

    it 'checks the environment for a variable' do
      token = 'via_env_token'
      env = { 'GITHUB_USER_ACCESS_TOKEN' => token, 'HOME' => '~' }
      result = Gripst::Config.new(env: env).auth_token
      expect(result).to eq token
    end

    it 'fetches the token via the client if it does not otherwise exist' do
      token = 'via_client_token'
      allow(Gripst::GitHub).to receive(:get_auth_token).and_return(token)
      result = Gripst::Config.new.auth_token
      expect(result).to eq token
    end
  end

  describe 'git_hub' do
    it 'defaults to Gripst::GitHub' do
      result = Gripst::Config.new(auth_token: 'asdf').git_hub
      expect(result).to eq Gripst::GitHub
    end
  end

  describe 'git' do
    it 'defaults to Git' do
      result = Gripst::Config.new(auth_token: 'asdf').git
      expect(result).to eq Git
    end
  end
end
