source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.5"

gem "rails", "~> 7.0.3", ">= 7.0.3.1"
gem "mysql2", "~> 0.5"
gem "puma", "~> 5.0"
gem "redis", "~> 4.0"

gem "bootsnap", require: false

group :development, :test do
  gem 'rspec-rails', '~> 6.0.0.rc1'
  gem 'oj'
end

group :test do
  gem 'factory_bot_rails'
end
