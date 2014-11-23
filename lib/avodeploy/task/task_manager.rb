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
    class TaskManager

      attr_reader :dependencies
      attr_reader :chains

      # Initializes the task manager
      def initialize
        @chains = []
        @remote_env = nil
        @local_env = nil
      end

      # Adds a task to the task manager
      #
      # @param name [Symbol] task name
      # @param options [Hash] task options
      # @param block [Block] code of the task
      def add_task(name, options, &block)
        position = :after
        standalone = true

        if options.has_key?(:before)
          position = :before
        end

        key = name

        if options.has_key?(:before)
          key = options[:before]
          standalone = false
        elsif options.has_key?(:after)
          key = options[:after]
          standalone = false
        end

        if standalone == false
          idx = find_chain_index_containing(key)

          @chains[idx].delete(name)
          @chains[idx].insert_at(position, key, [name, Task.from_task_block(name, options, &block)])

        else
          chain = {}
          chain[name] = Task.from_task_block(name, options, &block)
          @chains << chain
        end
      end

      # Finds a task by its name
      #
      # @param name [Symbol] name of the task
      # @return [Task] the task if found
      def task_by_name(name)
        name = name.to_sym if name.is_a?(String)

        cidx = find_chain_index_containing(name)
        @chains[cidx][name]
      end

      # Finds the chain containing a specifc task
      #
      # @param name [Symbol] task name
      # @param [Integer] chain index
      def find_chain_index_containing(name)
        @chains.each_with_index do |chain, idx|
          if chain.has_key?(name)
            return idx
          end
        end

        raise RuntimeError, "could not find a chain containing task #{name}"
      end

      # Invokes a task without dependencies
      #
      # @param task_name [Symbol] the task name
      def invoke_task_oneshot(task_name)
        task_name = task_name.to_sym if task_name.is_a?(String)

        cidx = find_chain_index_containing(task_name)

        begin
          invoke_task(@chains[cidx][task_name])
        rescue Exception => e
          AvoDeploy::Deployment.instance.handle_abort(e)
        end
      end

      # Invokes the task chain, that contains the requested task
      #
      # @param task_name [Symbol] the task name
      def invoke_task_chain_containing(task_name)
        task_name = task_name.to_sym if task_name.is_a?(String)

        cidx = find_chain_index_containing(task_name)

        begin
          @chains[cidx].each_pair do |name, task|
            invoke_task(task)
          end
        rescue Exception => e
          AvoDeploy::Deployment.instance.handle_abort(e)
        end
      end

      # Executes a task for all defined targets
      #
      # @param task [Task] the task to start
      # @param env [RemoteTaskExecutionEnvironment] the environment
      def execute_for_each_target(task, env)
        raise ArgumentError, 'task must be a task' unless task.kind_of?(Task)
        raise ArgumentError, 'env must be a RemoteTaskExecutionEnvironment' unless env.kind_of?(RemoteTaskExecutionEnvironment)

        avo = AvoDeploy::Deployment.instance

        avo.config.targets.each_pair do |key, target|
          # 'only' check
          next if task.remote_only.nil? == false && ((task.remote_only.is_a?(Array) && task.remote_only.include?(target.name) == false) || (task.remote_only.is_a?(Symbol) && task.remote_only != target.name))

          # 'except' check
          next if task.remote_except.nil? == false && ((task.remote_except.is_a?(Array) && task.remote_except.include?(target.name)) || (task.remote_except.is_a?(Symbol) && task.remote_except == target.name))

          avo.log.info "invoking task #{task.name} for target #{target.name}..."

          env.config.merge!(target.config)
          env.establish_connection

          task.invoke(env)
        end
      end

      # Invokes a task
      #
      # @param task [Task] the task
      def invoke_task(task)
        raise ArgumentError, 'task must be a task' unless task.kind_of?(Task)

        avo = AvoDeploy::Deployment.instance
        env = nil

        if task.scope == :remote
          if @remote_env.nil?
            @remote_env = RemoteTaskExecutionEnvironment.new(avo.config.config)
          end

          env = @remote_env
        elsif task.scope == :local
          if @local_env.nil?
            @local_env = LocalTaskExecutionEnvironment.new(avo.config.config)
          end

          env = @local_env
        else
          raise RuntimeError, 'scope must either be remote or local'
        end

        # @todo this does not belong here
        env.scm = nil

        if avo.config.get(:scm) == :git
          env.scm = AvoDeploy::ScmProvider::GitScmProvider.new(env)
        elsif  avo.config.get(:scm) == :bzr
          env.scm = AvoDeploy::ScmProvider::BzrScmProvider.new(env)
        end

        if env.scm.nil?
          raise RuntimeError, 'No ScmProvider was instantiated'
        end

        # if remote task -> execute for each target
        if task.scope == :remote
          execute_for_each_target(task, env)
        else
          task.invoke(env)
        end
      end

    end
  end
end