#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
Bundler.require(:test)
require "dotenv/load"
require "minitest/autorun"

$LOAD_PATH.unshift(File.join(File.expand_path(__dir__), "..", "lib"))
require "safe.rb"
require "eth"
