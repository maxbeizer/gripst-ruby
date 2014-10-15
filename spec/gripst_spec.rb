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

    before :each do
      stub_const('ENV', {'GITHUB_USER_ACCESS_TOKEN' => 'asdf'})
    end

    it '#initialized? returns true' do
      expect(gripst_with_token.initialized?).to be true
    end

    describe "#all_gist_ids" do
      it "returns an array of ids of all gists for a given user" do
        Gist = Struct.new(:id)
        allow(gripst_with_token).to receive(:client).and_return(double('client'))
        allow(gripst_with_token.client).to receive(:gists).and_return([Gist.new(123), Gist.new(234), Gist.new(345)])
        expect(gripst_with_token.all_gist_ids).to include 123, 234, 345
      end
    end
  end
end
