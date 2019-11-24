# frozen_string_literal: true

module Gripst
  # A class to hold configuration for Gripst
  class Config

    attr_reader :github,
                :git,
                :auth_token

    def initialize(github: GitHub, auth_token: nil, git: Git, env: ENV)
      @env = env
      @github = github
      @auth_token = auth_token || fetch_auth_token
      @git = git
    end

    def setup
      @github = @github.login_with_oauth(auth_token)
      self
    end

    private

    def fetch_auth_token
      @env['GITHUB_USER_ACCESS_TOKEN'] || github.get_auth_token
    end
  end
end
