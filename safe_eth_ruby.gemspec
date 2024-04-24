# encoding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib/", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "safe/version"

Gem::Specification.new do |s|
  s.name        = "safe_eth_ruby"
  s.version     = Safe::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Ruby library for interacting with Gnosis Safe Smart Wallets."
  s.description = "The Safe gem simplifies Gnosis Safe integration in Ruby apps, managing multisig transactions."
  s.authors     = ["Bolo Michelin"]
  s.email       = ["bolo@scionx.io"]
  s.homepage    = "https://github.com/scionx-io/safe-eth-ruby"
  s.license     = "MIT"

  s.required_ruby_version     = ">= 2.6.0"
  s.required_rubygems_version = ">= 1.3.7"

  s.metadata["source_code_uri"] = s.homepage
  s.metadata["changelog_uri"] = "#{s.homepage}/blob/main/CHANGELOG.md"
  s.metadata["allowed_push_host"] = "https://rubygems.org"
  s.metadata["github_repo"] = s.homepage

  s.files = Dir.glob("lib/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) } + ["LICENSE.txt", "README.md"]
  s.extra_rdoc_files = ["README.md"]

  s.require_paths = ["lib"]

  s.add_development_dependency("minitest")
  s.add_development_dependency("rake", "~> 13.0")
  # Add other dependencies here
  s.add_dependency("abi_coder_rb", "~> 0.2.8")
  s.add_dependency("eth", "~> 0.5.11")
end
