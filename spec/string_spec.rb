# frozen_string_literal: true

RSpec.describe String do
  context "colors" do
    it "makes a string red" do
      expect("foo".red).to eq red("foo")
    end

    it "makes a string green" do
      expect("foo".green).to eq green("foo")
    end

    it "makes a string yellow" do
      expect("foo".yellow).to eq yellow("foo")
    end

    it "makes a string pink" do
      expect("foo".pink).to eq pink("foo")
    end
  end

  private

  def red(str)
    do_color(str, 31)
  end

  def green(str)
    do_color(str, 32)
  end

  def yellow(str)
    do_color(str, 33)
  end

  def pink(str)
    do_color(str, 35)
  end

  def do_color(str, code)
    "\e[#{code}m#{str}\e[0m"
  end
end
