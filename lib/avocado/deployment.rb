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
	class Deployment

		attr_accessor :config
		attr_accessor :task_manager
		attr_reader :log
		attr_reader :log_file

		# Initializes the deployment
		def initialize
			@stages = {}
			@task_manager = Avocado::TaskManager.new
			@config = Avocado::Config.new

			@log = ::Logger.new(STDOUT)
		end

		# Configures the deployment
		#
		# @param block [Block] configuration block
		def self.configure(&block)
			@instance = self.instance
			@instance.config.instance_eval(&block)

			# @todo check config and throw exception
		end

		# Returns the deployment instance
		#
		# @return [Deployment] the deployment instance
		def self.instance
			if @instance.nil?
				@instance = self.new
			end

			@instance
		end

		# Handles exceptions
		#
		# @param [Exception] the exception to handle
		def handle_abort(e)
			if e.class != SystemExit
				@log.error e.message.red
				@log.info "cleaning up..."

				task_manager.invoke_task_oneshot(:cleanup_local)

				#if e.kind_of?(::Net::SSH::AuthenticationFailed) == false
				#	task_manager.invoke_task_oneshot(:cleanup_remote)
				#end
				
				Kernel.exit(true)
			end
		end
				
	end
end