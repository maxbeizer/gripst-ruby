# frozen_string_literal: true

require 'find'
require 'tmpdir'

module Gripst
  class Runner
    attr_reader :tmpdir
    ParamObj = Struct.new(:id, :path)

    def initialize(config:)
      @config = config
      @auth_token = config.auth_token
      @git_hub = config.git_hub
      @git = config.git
      @tmpdir = Dir.mktmpdir
    end

    def all_gist_ids
      @git_hub.gists.map(&:id)
    end

    def clone(id)
      @git.clone "https://#{@auth_token}@gist.github.com/#{id}.git", id, :path => "#{tmpdir}"
      true
    rescue StandardError => e
      $stderr.puts "ERROR: git fell down on #{id}"
      $stderr.puts "ERROR: #{e}"
      false
    end

    def run(regex, id)
      return unless clone(id)

      Find.find("#{tmpdir}/#{id}") do |path|
        param_obj = ParamObj.new(id, path)
        return Find.prune if git_dir? param_obj
        loop_through_lines_of_a_gist(regex, param_obj) if File.file? path
      end
    end

    private

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
  end
end
