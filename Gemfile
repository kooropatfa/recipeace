source 'https://rubygems.org'
git_source(:github) { |repo| 'https://github.com/#{repo}.git' }

ruby '3.2.2'

gem 'rails', "~> 7.0.5"
gem 'sprockets-rails'
gem 'pg', "~> 1.1"
gem 'puma', "~> 5.0"
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder'
gem 'tzinfo-data', platforms: %i[ mingw mswin x64_mingw jruby ]
gem 'bootsnap', require: false
# gem 'redis'

group :development, :test do
  gem 'debug', platforms: %i[ mri mingw x64_mingw ]
  gem 'pry-rails'
  gem 'dotenv-rails'
end

group :development do
  gem 'web-console'
  gem 'spring'
  gem 'rubocop'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end
