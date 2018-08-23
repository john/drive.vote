# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task default: 'bundler:audit'

# Hook webpack to run along with asset precompilation.
Rake::Task['assets:precompile'].enhance ['webpacker:compile']

namespace :foreman do
  task :prod do
    sh "bundle exec foreman start -f Procfile"
  end

  task :dev do
    sh "bundle exec foreman start -f Procfile.dev"
  end
end

namespace :deploy do

  task :dev do
    sh "./deploy.sh development us-west-2"
  end

  task :prod do
    sh "./deploy.sh production us-west-2"
  end
end
