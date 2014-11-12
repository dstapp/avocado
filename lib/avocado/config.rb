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
	class Config

		attr_reader :config
		attr_reader :stages
		attr_reader :targets

		# Intializes the config object
		def initialize
			@config = setup_config_defaults
			@stages = {}
			@targets = {}
		end

		# Sets a configuration item
		#
		# @param key [Symbol] configuration key
		# @param value [mixed] configuration value
		def set(key, value)
			@config[key] = value
		end

		# Returns a configuration item if set
		#
		# @param key [Symbol] configuration key
		# @return [mixed] configuration value
		def get(key)
			raise ArgumentError, "key #{key} is not set" unless @config.has_key?(key)

			@config[key]
		end

		# Defines a task
		# 
		# @param name [Symbol] task name
		# @param options [Hash] task options
		# @param block [Block] the code to be executed when the task is started 
		def task(name, options = {}, &block)
			Avocado::Deployment.instance.task_manager.add_task(name, options, &block)
		end

		# Defines a stage
		#
		# @param name [Symbol] stage name
		# @param options [Hash] stage options
		# @param block [Block] the stage configuration 
		def setup_stage(name, options = {}, &block)
			if options.has_key?(:desc)
				stages[name] =  options[:desc]
			end

			if name == get(:stage)
				instance_eval(&block)
			end
		end

		# Defines a deployment target
		#
		# @param name [Symbol] the deployment targets' name
		# @param options [Hash] target options
		def target(name, options = {})
			@targets[name] = Avocado::Target.new(name, options)
		end

		# Merges the configuration with another config hash
		#
		# @param other_config [Hash] configuration hash
		# @return [Hash] the merged hash
		def merge(other_config)
			@config.merge(other_config)
		end

		private
			# Sets up configuration defaults
			#
			# @return [Hash] configuration defaults
			def setup_config_defaults
				{
					:project_name => '',
					:scm => :git,
					:repo_url => '',
					:branch => :master,
					:ssh_host => '',
					:ssh_user => 'root',
					:ssh_auth => :pubkey,
					:deploy_dir => '/var/www/',
					:stage => :production,
					:strategy => :local_copy,
					:ignore_files => [],
					:log_level => Logger::WARN,
				}
			end

	end
end