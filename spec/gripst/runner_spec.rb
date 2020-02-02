# frozen_string_literal: true

RSpec.describe Gripst::Runner do
  describe 'clone' do
    it 'when clone succeeds it returns true' do
      config = Gripst::Config.new(git: HappyGit, auth_token: 'asdf')
      result = Gripst::Runner.new(config: config).clone(123)
      expect(result).to eq true
    end

    it 'when clone fails it returns false' do
      config = Gripst::Config.new(git: SadGit, auth_token: '123')
      result = Gripst::Runner.new(config: config).clone(123)
      expect(result).to eq false
    end
  end

  describe 'all_gist_ids' do
    it 'returns ids from all the gists that git can fetch' do
      config = Gripst::Config.new(git_hub: GHMock, auth_token: '123')
      result = Gripst::Runner.new(config: config).all_gist_ids
      expect(result).to eq Array(1..3) # see GHMock
    end
  end

  class HappyGit
    def self.clone(_, _, _)
      true
    end
  end

  class SadGit
    def self.clone(_, _, _)
      raise StandardError
    end
  end

  class GHMock
    def self.gists
      Array(1..3).map { |id| Struct.new(:id).new(id) }
    end
  end
end
