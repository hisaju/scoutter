source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2.1'

# Database
gem 'mysql2', '>= 0.4.4', '< 0.6.0'

# Assets
gem 'bootstrap-sass', '~> 3.3.7'
gem 'bootswatch', github: 'thomaspark/bootswatch'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'phantomjs', '1.9.8'
gem 'meta-tags'
gem 'settingslogic'

# Application server
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false

# Authentication
gem 'sorcery'

# Background Job
gem 'whenever', require: false

# Configuration
gem 'dotenv-rails', require: 'dotenv/rails-now'

# Slim
gem 'slim-rails'
gem 'html2slim'

# bootstrap
gem 'bootstrap', '~> 4.1.3'

# jqury-rails
gem 'jquery-rails'

# font-awesome
gem 'font-awesome-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder

# UI/UX
gem 'rails-i18n', '~> 5.0.0'
gem 'jbuilder', '~> 2.5'
gem 'chart-js-rails'

# Storage
gem 'mini_magick', '~> 4.8'

# Soft delete
gem 'paranoia'

# Model
gem 'active_hash'

# Decorator
gem 'draper'

# Seeds
gem 'seed-fu'

# Pagination
gem 'kaminari'
gem 'kaminari-i18n'
gem 'bootstrap4-kaminari-views'

group :development, :test do
  gem 'capybara'
  gem 'poltergeist'
  # Debugger
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'pry-doc'

  # Code analyze
  gem 'rubocop-rails_config'
  gem 'rails_best_practices'
  gem 'scss_lint', require: false
  gem 'slim_lint'

  # Deploy
  # gem 'capistrano-rails'

  # CLI
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development do
  # Debugger
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
end
