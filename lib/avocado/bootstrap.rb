=begin
  AVOCADO
  The flexible and easy to use deployment framework for web applications

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License Version 2
  as published by the Free Software Foundation.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
=end

module Avocado
	class Bootstrap
		# Runs the avocado bootstrap
		#
		# @param stage [Symbol] the stage to bootstrap
		# @param verbose [Boolean] run in verbose mode
		# @param debug [Boolean] run in boolean mode
		def self.run(stage, verbose = false, debug = false)
			if stage.is_a?(String)
				stage = stage.to_sym
			end

			require File.join(File.dirname(__FILE__), 'core_ext/string_colors.rb')
			require File.join(File.dirname(__FILE__), 'core_ext/hash_insert_at.rb')

			require File.join(File.dirname(__FILE__), 'task/task.rb')
			require File.join(File.dirname(__FILE__), 'task/task_dependency.rb')
			require File.join(File.dirname(__FILE__), 'task/task_manager.rb')
			require File.join(File.dirname(__FILE__), 'task/task_execution_environment.rb')
			require File.join(File.dirname(__FILE__), 'task/local_task_execution_environment.rb')
			require File.join(File.dirname(__FILE__), 'task/remote_task_execution_environment.rb')

			require File.join(File.dirname(__FILE__), 'scm_provider/scm_provider.rb')
			require File.join(File.dirname(__FILE__), 'scm_provider/git_scm_provider.rb')

			require File.join(File.dirname(__FILE__), 'multi_io.rb')
			require File.join(File.dirname(__FILE__), 'command_execution_result.rb')
			require File.join(File.dirname(__FILE__), 'target.rb')
			require File.join(File.dirname(__FILE__), 'config.rb')
			require File.join(File.dirname(__FILE__), 'deployment.rb')

			begin
				# defaults
				Avocado::Deployment.configure do
					set :stage, stage
				end

				if File.exist?(Dir.pwd.concat('/Avofile')) == false
					raise RuntimeError, 'Could not find Avofile. Run `avo install` first.'
				end

				instance = Avocado::Deployment.instance

				# load user config initially to determine strategy
				begin
					load File.join(Dir.pwd, 'Avofile')
				rescue RuntimeError => e
					# `find_chain_index_containing': could not find a chain containing task create_deployment_tarball (RuntimeError)
					# error not neccessary because dependencies are not loaded
				end

				if debug
					instance.log.level = Logger::DEBUG
				elsif verbose
					instance.log.level = Logger::INFO
				else
					instance.log.level = instance.config.get(:log_level)
				end

				instance.log.debug "Loading deployment strategy #{instance.config.get(:strategy).to_s}..."

				# load strategy
				# @todo pruefen
				require File.join(File.dirname(__FILE__), "strategy/base.rb")
				require File.join(File.dirname(__FILE__), "strategy/#{instance.config.get(:strategy).to_s}.rb")


				instance.log.debug "Loading user configuration..."

				# override again by user config to allow manipulation of tasks
				load File.join(Dir.pwd, 'Avofile')
			rescue Exception => e
				Avocado::Deployment.instance.log.error e.message.red
				
				Kernel.exit(true)
			end

			Avocado::Deployment.instance
		end
	end
end