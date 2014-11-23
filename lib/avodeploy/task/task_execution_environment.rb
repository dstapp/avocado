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

module AvoDeploy
  module Task
    class TaskExecutionEnvironment

      attr_accessor :scm

      # Initialized the environment
      #
      # @param config [Hash] deployment configuration
      def initialize(config)
        # @todo check
        @config = config
      end

      # Runs a task without dependencies
      #
      # @param task_name [Symbol] task name to execute
      # @return [Object] the task result
      def run_nodeps(task_name)
        AvoDeploy::Deployment.instance.task_manager.invoke_task_oneshot(task_name)
      end

      # Runs a task chain
      #
      # @param task_name [Symbol] task name to invoke
      def run(task_name)
        AvoDeploy::Deployment.instance.task_manager.invoke_task_chain_containing(task_name)
      end

      # Checks, if all utilities are available for the deployment process
      # to be executed
      #
      # @param utils [Array] array with utilities to check
      def check_util_availability(utils, system_name)
        begin
          utils.each do |util|
            if command("command -v #{util} >/dev/null 2>&1 || exit 1;").retval == 1
              msg = "command line utility '#{util}' is not installed #{system_name}"

              raise RuntimeError, msg
            end
          end
        rescue Exception => e
          handle_abort e
        end
      end

      # Returns the logger instance
      #
      # @return [Logger] log instance
      def log
        AvoDeploy::Deployment.instance.log
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
        @config[key]
      end

      # Shorthand for exception handling
      #
      # @param e [Exception] the exception to handle
      def handle_abort(e)
        AvoDeploy::Deployment.instance.handle_abort(e)
      end

    end
  end
end