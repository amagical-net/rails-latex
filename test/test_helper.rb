ENV['RAILS_ENV'] ||= 'test'
require 'minitest/autorun'

require 'minitest/reporters'
Minitest::Reporters.use!

TMP_DIR = File.expand_path("../tmp",__FILE__)
module Rails
  def self.root
    TMP_DIR
  end

  def self.logger
    Logger.new(STDERR)
  end
end
