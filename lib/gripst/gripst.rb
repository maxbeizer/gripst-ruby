require 'find'
require 'tmpdir'
require 'octokit'
require 'git'
require_relative 'string'
require_relative 'client'
require_relative 'version'

module Gripst
  class Gripst
    attr_reader :tmpdir, :auth_token
    ParamObj = Struct.new(:id, :path)

    def initialize
      @auth_token = retrieve_auth_token
      @tmpdir = Dir.mktmpdir
    end

    def initialized?
      !!auth_token
    end

    def all_gist_ids
      client.gists.map(&:id)
    end

    def clone(id)
      Git.clone "https://#{auth_token}@gist.github.com/#{id}.git", id, :path => "#{tmpdir}"
      true
    rescue => e # TODO figure out what error this is could be and not rescue bare exception
      $stderr.puts "ERROR: git fell down on #{id}"
      $stderr.puts "ERROR: #{e}"
      false
    end

    def run(regex, id)
      Find.find("#{tmpdir}/#{id}") do |path|
        param_obj = ParamObj.new(id, path)
        return Find.prune if git_dir? param_obj
        loop_through_lines_of_a_gist(regex, param_obj) if File.file? path
      end if clone id
    end

    private

    def client
      @client ||= Client.login_with_oauth auth_token
    end

    def loop_through_lines_of_a_gist(regex, param_obj)
      File.new(param_obj.path).each do |line|
        begin
          display_match(param_obj, line) if /#{regex}/.match line
        rescue ArgumentError
          $stderr.puts "Skipping... #{output_info_string(param_obj)} #{$!}"
          sleep 300
        end
      end
    end

    def display_match(param_obj, line)
      puts "#{output_info_string(param_obj)} #{line}"
    end

    def git_dir?(obj)
      obj.path == "#{tmpdir}/#{obj.id}/.git"
    end

    def output_info_string(param_obj)
      "#{param_obj.id.pink} (#{extract_gistfile_name(param_obj.path)})"
    end

    def extract_gistfile_name(path)
      path.split('/')[-1].yellow
    end

    def retrieve_auth_token
      return ENV['GITHUB_USER_ACCESS_TOKEN'] if ENV['GITHUB_USER_ACCESS_TOKEN']
      Client.get_auth_token
    end
  end
end
