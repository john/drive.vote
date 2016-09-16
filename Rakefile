# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

# Hook webpack to run along with asset precompilation.
Rake::Task['assets:precompile'].enhance ['webpack:compile']

namespace :foreman do
  task :prod do
    sh "bundle exec foreman start -f Procfile"
  end

  task :dev do
    sh "bundle exec foreman start -f Procfile.dev"
  end
end

artifact_file = 'tmp/deploy_artifact.zip'

namespace :deploy do
  task :dev do
    # TODO(awong): Add warning for dirty tree.

    # Precompile all assets first so if there are errors, this task bails early.
    # This generates files in public/assets and public/webpack.
    Rake::Task['assets:precompile'].invoke

    # Snapshot the source code from HEAD into the deploy artifact.
    # This will NOT contain the precompiled assets.
    sh "git archive -o #{artifact_file} HEAD"

    # Add in the precompiled assets to the deploy file.
    sh "zip -ru #{artifact_file} public/assets"
    sh "zip -ru #{artifact_file} public/webpack"

    sh "source venv/bin/activate; eb deploy drivevote-dev"
  end
end
