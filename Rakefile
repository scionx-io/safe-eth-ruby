# frozen_string_literal: true

require "rake"
require "rake/testtask"

$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "safe_eth_ruby/version"

task(default: [:test, :rubocop])

desc "run test suite"
Rake::TestTask.new(:test) do |t|
  t.libs << "lib" << "test"
  t.pattern = "test/**/*_test.rb" # This line runs all test files.
  t.verbose = true
end

task :rubocop do
  if RUBY_ENGINE == "ruby"
    require "rubocop/rake_task"
    RuboCop::RakeTask.new
  end
end

task gem: :build
task :build do
  system "gem build safe_eth_ruby.gemspec"
end

task install: :build do
  system "gem install safe-eth-ruby-#{Safe::VERSION}.gem"
end

task :console do
  exec "irb -I lib -r safe"
end
