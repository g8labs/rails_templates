#### Template Setup

apply "#{__dir__}/template_helper.rb"

##### HAML

gem 'haml-rails'

##### CoffeeScript

comment_lines 'Gemfile', /coffee-rails/

##### JQuery

comment_lines 'Gemfile', /jquery-rails/

##### PUMA

gem 'puma'

##### Figaro

gem "figaro"

after_bundle do
  run 'figaro install'
end

#### BetterErrors

gem 'better_errors', group: :development

##### Annotate

gem 'annotate', '~> 2.6.6', group: :development

after_bundle do
  generate 'annotate:install'
end

##### Guard-CTags-Bundler

gem 'guard-ctags-bundler', group: :development

after_bundle do
  run 'guard init ctags-bundler'

  gsub_file 'Guardfile', '"spec/support"] do', '"spec/support"], bundler_tags_file: "gem.tags", project_file: "tags", arguments: "-R --languages=ruby --fields=+KSn" do'
end

##### RuboCop

gem 'rubocop', require: false, group: [:development, :test]

after_bundle do
  copy_file "#{__dir__}/.rubocop.yml", ".rubocop.yml"
end

##### Rspec

gem 'rspec-rails', '~> 3.0', group: [:development, :test]

after_bundle do
  generate 'rspec:install'

  remove_lines 'spec/spec_helper.rb', /=begin/
  remove_lines 'spec/spec_helper.rb', /=end/
end

##### Shoulda Matchers

gem 'shoulda-matchers', group: [:development, :test]

after_bundle do
  require_lib 'shoulda/matchers', in: 'spec/rails_helper.rb'
end

##### Database Cleaner

gem 'database_cleaner', group: [:development, :test]

after_bundle do
  require_lib 'database_cleaner', in: 'spec/rails_helper.rb'

  add_config 'spec/rails_helper.rb' do
    <<-EOS
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
    EOS
  end
end

##### FactoryGirl

gem 'factory_girl_rails', group: [:development, :test]

after_bundle do
  add_config 'spec/rails_helper.rb', 'config.include FactoryGirl::Syntax::Methods'
end

##### Faker

gem 'faker', group: [:development, :test]

#### Capistrano

gem_group :development do
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'rvm1-capistrano3', require: false
  gem 'capistrano3-puma'
  gem 'capistrano3-nginx'
  gem 'capistrano-safe-deploy-to'
  gem 'capistrano-bundler'
  gem 'capistrano-files', github: 'bilby91/capistrano-files'
  gem 'capistrano-db-tasks', require: false
end

after_bundle do
  run 'cap install'

  uncomment_lines 'Capfile', /require.*capistrano\/bundler/
  uncomment_lines 'Capfile', /require.*capistrano\/rails\/assets/
  uncomment_lines 'Capfile', /require.*capistrano\/rails\/migrations/

  require_lib 'capistrano/nginx',           in: 'Capfile'
  require_lib 'capistrano/puma',            in: 'Capfile'
  require_lib 'capistrano/puma/monit',      in: 'Capfile'
  require_lib 'capistrano/files',           in: 'Capfile'
  require_lib 'capistrano-db-tasks',        in: 'Capfile'
  require_lib 'capistrano/safe_deploy_to',  in: 'Capfile'
  require_lib 'rvm1/capistrano3',           in: 'Capfile'

  @server_name = ask("Staging's server's name:")
  @nginx_domains = ask("Staging's nginx domains:")

  remove_file 'config/deploy/staging.rb'
  template "#{__dir__}/capistrano/deploy/staging.rb.erb", "config/deploy/staging.rb"

  @server_name = ask("Production's server's name:")
  @nginx_domains = ask("Production's nginx domains:")

  remove_file 'config/deploy/production.rb'
  template "#{__dir__}/capistrano/deploy/production.rb.erb", "config/deploy/production.rb"

  empty_directory 'lib/capistrano/templates'
  directory "#{__dir__}/capistrano/templates", "lib/capistrano/templates", recursive: true

  @repo_url = ask("Repository Url:")

  gsub_file 'config/deploy.rb', 'my_app_name', app_name
  gsub_file 'config/deploy.rb', 'git@example.com:me/my_repo.git', @repo_url

  uncomment_lines 'config/deploy.rb', /set :scm/
  uncomment_lines 'config/deploy.rb', /set :log_level/
  uncomment_lines 'config/deploy.rb', /set :keep_releases/

  gsub_file 'config/deploy.rb', ':keep_releases, 5', ':keep_releases, 10'

  remove_lines 'config/deploy.rb', /namespace :deploy.*/m
  append_to_file 'config/deploy.rb', File.binread("#{__dir__}/capistrano/deploy.rb")
end

##### Generators

after_bundle do
  add_config 'config/application.rb' do
    <<-EOS
    config.generators do |g|
      g.test_framwork :rspec
      g.javascript_engine :js
      g.view_specs false
      g.helper_specs false
    end
    EOS
  end
end

##### Time Zone

after_bundle do
  uncomment_lines 'config/application.rb', /config.time_zone/
  gsub_file 'config/application.rb', 'Central Time (US & Canada)', 'Montevideo'
end

##### RVM

create_file '.ruby-version', 'ruby-2.1.2'
create_file '.ruby-gemset', app_name
run 'rvm use .'

##### Git

after_bundle do
  append_to_file '.gitignore' do
    <<-EOS
# ignore application database
/config/database.yml

*.rbc
capybara-*.html
.rspec
/db/*.sqlite3
/db/*.sqlite3-journal
/public/system
/coverage/
/spec/tmp
**.orig
rerun.txt
pickle-email-*.html

config/initializers/secret_token.rb
config/secrets.yml

/vendor/bundle

# unless supporting rvm < 1.11.0 or doing something fancy, ignore this:
.rvmrc

# if using bower-rails ignore default bower_components path bower.json files
/vendor/assets/bower_components
*.bowerrc
bower.json

# Ignore pow environment settings
.powenv

tags
.tags
.tags1
gem.tags
    EOS
  end

  git :init
  git add: '.'
  git commit: "-a -m 'Initial commit'"
  git remote: "add origin #{@repo_url}"
end

