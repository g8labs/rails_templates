set :temp_dir, '/tmp'

set :linked_files, %w(config/database.yml config/secrets.yml config/application.yml)

set :linked_dirs, %w(tmp/pids tmp/sockets log)

set :file_uploads, [
  {
    origin: 'config/database.yml',
    destination: 'config/database.yml'
  },
  {
    origin: 'config/secrets.yml',
    destination: 'config/secrets.yml'
  },
  {
    origin: 'config/application.yml',
    destination: 'config/application.yml'
  }
]

set :shared_folders, %w(config)

set :app_server_socket, "#{shared_path}/tmp/sockets/puma.sock"

set :db_remote_clean, true
set :disallow_pushing, true

set :puma_threads, [0, 16]
set :puma_workers, 0

set :puma_access_log, -> { File.join(shared_path, 'log', "#{fetch(:puma_env)}.log") }
set :puma_error_log, -> { File.join(shared_path, 'log', "#{fetch(:puma_env)}_error.log") }
set :puma_monit_service_name, fetch(:application)
