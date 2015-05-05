require 'terminal-table'
require 'open3'
require 'net/ssh'
require 'net/scp'

require 'avodeploy/core_ext/string_colors.rb'
require 'avodeploy/core_ext/hash_insert_at.rb'

require 'avodeploy/task/task.rb'
require 'avodeploy/task/task_dependency.rb'
require 'avodeploy/task/task_manager.rb'
require 'avodeploy/task/task_execution_environment.rb'
require 'avodeploy/task/local_task_execution_environment.rb'
require 'avodeploy/task/remote_task_execution_environment.rb'

require 'avodeploy/scm_provider/scm_provider.rb'
require 'avodeploy/scm_provider/git_scm_provider.rb'
require 'avodeploy/scm_provider/bzr_scm_provider.rb'

require 'avodeploy/version.rb'
require 'avodeploy/multi_io.rb'
require 'avodeploy/command_execution_result.rb'
require 'avodeploy/target.rb'
require 'avodeploy/config.rb'
require 'avodeploy/deployment.rb'
require 'avodeploy/bootstrap.rb'

module AvoDeploy
  LIBNAME = 'avodeploy'
  LIBDIR = File.expand_path("../#{LIBNAME}", __FILE__)
end