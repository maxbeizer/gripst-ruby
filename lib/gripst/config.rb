# frozen_string_literal: true

module Gripst
  # A class to hold configuration for Gripst
  class Config
    attr_reader :git_hub,
                :git,
                :auth_token

    def initialize(git_hub: GitHub, auth_token: nil, git: Git, env: ENV, config_path: nil)
      @env = env
      @git_hub = git_hub
      @config_path = config_path || @env['HOME'] + '/.gripst'
      @auth_token = auth_token || fetch_auth_token
      @git = git
    end

    def setup
      @git_hub = @git_hub.login_with_oauth(auth_token)
      @git_hub.auto_paginate = true
      self
    end

    private

    def fetch_auth_token
      @env['GITHUB_USER_ACCESS_TOKEN'] || git_hub.get_auth_token(@config_path)
    end
  end
end
