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
    class Task

      attr_accessor :name
      attr_accessor :scope
      attr_accessor :visibility
      attr_accessor :block
      attr_accessor :desc
      attr_accessor :remote_only
      attr_accessor :remote_except

      # Creates a new task from a task block in the deployment configuration process
      #
      # @param name [Symbol] name of the task
      # @param options [Hash] command options
      # @param block [Block] code block of the task
      # @return [Task] the task instance
      def self.from_task_block(name, options, &block)
        instance = self.new

        instance.name = name
        instance.block = block

        instance.scope = :local

        if options.has_key?(:scope) && options[:scope] == :remote
          instance.scope = :remote
        end

        instance.visibility = :public

        if options.has_key?(:visibility) && options[:visibility] == :private
          instance.visibility = :private
        end

        if options.has_key?(:desc)
          instance.desc = options[:desc]
        end

        if options.has_key?(:only)
          instance.remote_only = options[:only]
        end

        if options.has_key?(:except)
          instance.remote_except = options[:except]
        end

        instance
      end

      # Runs the code of a task
      #
      # @param env [TaskExecutionEnvironment] the environment to invoke the task in
      # @param options [Hash] a hash contining additional options
      # @return [mixed] result of the code block
      def invoke(env, options = {})
        raise ArgumentError 'env must be a valid TaskExecutionEnvironment' unless env.kind_of?(TaskExecutionEnvironment)

        avo = AvoDeploy::Deployment.instance

        avo.log.debug "Running task #{@name}"

        env.instance_eval(&@block)
      end

    end
  end
end