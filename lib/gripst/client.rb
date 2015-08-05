require 'octokit'
require 'pry'

class Client
  PATH = ENV['HOME'] + '/.gripst'

  class << self
    def get_auth_token
      return oauth_from_file if oauth_from_file
      authorizer = Client.new
      authorizer.authorize
    end

    def login_with_oauth(oauth_token)
      client = Octokit::Client.new :access_token => oauth_token
      client.user.login
      client
    rescue Octokit::Unauthorized
      puts '---'
      puts '---'
      puts '---'
      puts 'Unable to create personal access token on github. Is the gripst application already set? https://github.com/settings/tokens'
      exit
    end

    private

    def oauth_from_file
      File.open PATH, &:readline if File.exists?(PATH) && !File.zero?(PATH)
    end
  end

  attr_reader :username,
              :password

  def initialize
    @username = get_username
    @password = get_password
  end

  def authorize
    begin
      auth_token = client.create_authorization :scopes => ['gists'], :note => 'gripst'
    rescue Octokit::OneTimePasswordRequired
      otp = get_otp
      auth_token = authorize_with_otp otp
    rescue Octokit::Unauthorized
      puts '---'
      puts '---'
      puts '---'
      puts 'Username or password was incorrect'
      exit
    end

    write_auth_token auth_token
    auth_token
  end

  private
  def get_username
    puts 'Enter your GitHub username'
    STDIN.gets.chomp
  end

  def get_password
    begin
      system "stty -echo"
      puts 'Enter your GitHub password'
      puts '(the input will be hidden)'
      STDIN.gets.chomp
    ensure
      system "stty echo"
    end
  end

  def get_otp
    puts 'Looks like you have 2FA. Smart move.'
    puts 'Enter the OTP from GitHub'
    STDIN.gets.chomp
  end

  def client
    @client ||= Octokit::Client.new :login => username,
                                    :password => password
  end

  def authorize_with_otp(token)
    response = client.create_authorization :scopes => ['gist'],
                                           :note => 'gripst',
                                           :headers => { 'X-GitHub-OTP' => token }
    response[:token]
  rescue Octokit::UnprocessableEntity
    puts '---'
    puts '---'
    puts '---'
    puts 'Unable to create personal access token on github. Is the gripst application already set? https://github.com/settings/tokens'
    exit
  end

  def write_auth_token(oauth_token)
    File.new PATH, 'w+' unless File.exists? PATH
    file = File.open PATH, 'w+'
    file << oauth_token
  ensure
    file.close
  end
end
