# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}.git"
end

gemspec

group :test do
  gem "dotenv"
  gem "rubocop", "~> 1.61.0"
  gem "rubocop-shopify", "~> 2.12.0", require: false
  gem "rubocop-performance", require: false
end
