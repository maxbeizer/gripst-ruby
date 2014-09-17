require 'spec_helper'
require_relative '../gripst'
require 'pry'

describe Gripst do
  context 'without a user_access_token' do
    let(:gripst_without_token) { Gripst.new }

    it '#initialized? returns false' do
      expect(gripst_without_token.initialized?).to be false
    end
  end

  context 'with a user_access_token' do
    let(:gripst_with_token) { Gripst.new }

    it '#initialized? returns true' do
      stub_const('ENV', {'GITHUB_USER_ACCESS_TOKEN' => 'asdf'})
      expect(gripst_with_token.initialized?).to be true
    end
  end
end
