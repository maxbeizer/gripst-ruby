# frozen_string_literal: true

RSpec.describe Gripst do
  before :all do
    $stderr.reopen '/dev/null', 'w'
  end

  context 'without a user_access_token' do
    it '#initialized? returns false' do
      stub_const('ENV', { 'GITHUB_USER_ACCESS_TOKEN' => nil })
      gripst_without_token = Gripst::Gripst.new
      expect(gripst_without_token.initialized?).to be false
    end
  end

  context 'with a user_access_token' do
    let(:gripst_with_token) { Gripst::Gripst.new }

    before :each do
      stub_const('ENV', { 'GITHUB_USER_ACCESS_TOKEN' => 'asdf' })
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

  describe '#clone' do
    let(:gripst) { Gripst::Gripst.new }

    before :each do
      stub_const('ENV', { 'GITHUB_USER_ACCESS_TOKEN' => 'asdf' })
    end

    context 'with no error' do
      it 'returns true' do
        allow(Git).to receive(:clone).and_return true
        expect(gripst.clone('123')).to eq true
      end
    end

    context 'with error' do
      it 'returns false' do
        allow(Git).to receive(:clone).and_raise StandardError
        expect(gripst.clone('123')).to eq false
      end
    end
  end

  describe '#run' do
    let(:gripst) { Gripst::Gripst.new }

    before :each do
      stub_const('ENV', { 'GITHUB_USER_ACCESS_TOKEN' => 'asdf' })
    end

    context 'when clone fails' do
      it 'returns silently' do
        allow(gripst).to receive(:clone).and_return false
        expect(gripst).to receive(:loop_through_lines_of_a_gist).exactly(0).times
        gripst.run('asdf', 'asdf')
      end
    end

    context 'when clone succeeds' do
      it 'returns with Find.prune if the path is a git dir' do
        allow(gripst).to receive(:clone).and_return true
        path = '.git'
        allow(Find).to receive(:find).and_yield path
        allow(gripst).to receive(:git_dir?).and_return true
        expect(Find).to receive(:prune)
        gripst.run('asdf', 'asdf')
      end
    end
  end
end
