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
    class LocalTaskExecutionEnvironment < TaskExecutionEnvironment

      # Initialized the environment
      #
      # @param config [Hash] deployment configuration
      def initialize(config)
        super

        @dir = Dir.pwd
      end

      # Checks, if all utilities are available for the deployment process
      # to be executed
      #
      # @param utils [Array] array with utilities to check
      def check_util_availability(utils)
        super(utils, 'locally')
      end

      # Changes the directory for commands to be executed in
      #
      # @param dir [String] the directory to change to
      def chdir(dir)
        log.debug "changing directory [#{dir.yellow}] " + "locally".cyan

        Dir.chdir(dir)
        @dir = Dir.pwd
      end

      # Returns the current working directory
      #
      # @return [String] current working directory
      def cwd
        @dir
      end

      # Returns all target systems to deploy to
      #
      # @return [Hash] hash of target systems
      def targets
        AvoDeploy::Deployment.instance.config.targets
      end

      # Copies a file to a remote system (= target)
      #
      # @param target [Target] the target system to deploy to
      # @param file [String] the local file to upload
      # @param remote [String] path on the remote system
      def copy_to_target(target, file, remote)
        log = AvoDeploy::Deployment.instance.log

        log.info "started upload of file #{file} to #{target.name}"

        Net::SSH.start(
            target.config[:host],
            target.config[:user],
            {
              :port => target.config[:port]
            }
        ) do |session|
          session.scp.upload!(file, remote, :recursive => true) do |ch, name, sent, total|
            percentage = 0

            begin
              percentage = (sent.to_f * 100 / total.to_f).to_i
            rescue Exception => e
              AvoDeploy::Deployment.instance.handle_abort(e)
            end
          end
        end

        log.info "upload completed"
      end

      # Executes a command locally in the current directory
      #
      # @param cmd [String] the command to execute
      # @return [CommandExecutionResult] result of the command exection
      def command(cmd)
        log = AvoDeploy::Deployment.instance.log

        log.info "Executing [" + cmd.yellow + "] " + "locally".cyan

        result = AvoDeploy::CommandExecutionResult.new

        begin
          stdout, stderr, status = ::Open3.capture3(cmd, :chdir => cwd())

          result.stdin = cmd
          result.stdout = stdout
          result.stderr = stderr
          result.retval = status.exitstatus

          if result.stdout.nil? == false && result.stdout.empty? == false
            log.debug 'Stdout: ' + result.stdout.green
          end

          if result.stderr.nil? == false && result.stderr.empty? == false
            log.debug 'Stderr: ' + result.stderr.red
          end

          log.debug 'Retval: ' + result.retval.to_s
        rescue Exception => e
          handle_abort e
        end

        result
      end

    end
  end
end