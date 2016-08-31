require 'yaml'
 
namespace :pg do
  def conf
    @conf ||= YAML.load_file("#{Rails.root}/config/database.yml")
  end

  def environment
   'development'
  end

  def username
    @username ||= conf[environment]['username']
  end

  def get_password
    @password ||= conf[environment]['password']
  end

  def database
    @database ||= conf[environment]['database']
  end

  def datadir
    @datadir ||= "#{Rails.root}/db/postgres"
  end

  def logfile
    @logfile ||= "#{Rails.root}/log/postgres.log"
  end

  desc "Initialize data directory."
  task :init do
    %x[mkdir #{datadir}]
    %x[initdb #{datadir}]
  end

  desc "Create database user and initial database for Postgres DB."
  task :create_user do
    %x[createuser -d -R -S -w #{username}]
    %x[psql -d template1 -c "ALTER USER #{username} WITH PASSWORD '#{get_password}';"]
  end

  desc "Drop user and DB."
  task :drop do
    Rake::Task['pg:kill_sessions'].invoke
    Rake::Task['db:drop'].invoke
    %x[dropuser #{username}]
  end

  desc "Run when postgres has never been configured for this app. Ends with running postgres server that you can create tables on."
  task :first_run do
    Rake::Task['pg:init'].invoke
    Rake::Task['pg:start'].invoke
    Rake::Task['pg:create_user'].invoke
    Rake::Task['db:setup'].invoke
  end

  desc "Kill all existing PG sessions."
  task :kill_sessions do
    %x[ps -ef | grep "postgres: #{username} #{database}" | grep -v 'grep' | awk '{print $2}' | xargs kill]
  end

  desc "Starts the postgres daemon."
  task :start do
    result = %x[pg_ctl -D #{datadir} -l #{logfile} -w start]
    puts result
  end

  desc "Stops the postgres daemon."
  task :stop do
    result = %x[pg_ctl -D #{datadir} -s -m fast stop]
    puts result
  end
end
