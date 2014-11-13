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
	class RemoteTaskExecutionEnvironment < TaskExecutionEnvironment

		attr_accessor :config

		# Creates a connection between the local and the remote system over ssh
		def establish_connection
			Avocado::Deployment.instance.log.info "connecting to #{get(:user)}@#{get(:host)}..."

			begin
				@session = ::Net::SSH.start(get(:host), get(:user))
			rescue ::Net::SSH::AuthenticationFailed => e
				handle_abort e
			end
		end

		# Checks, if all utilities are available for the deployment process
		# to be executed
		#
		# @param utils [Array] array with utilities to check
		def check_util_availability(utils)
			super(utils, 'remotely')
		end

		# Executes a command via ssh
		# 
		# @param ssh [Net::SSH::Connection::Session] ssh session
		# @param command [String] the command to execute
		def ssh_exec!(ssh, command)
		  stdout_data = ""
		  stderr_data = ""
		  exit_code = nil
		  exit_signal = nil
		  ssh.open_channel do |channel|
		    channel.exec(command) do |ch, success|
		      unless success
		        abort "FAILED: couldn't execute command (ssh.channel.exec)"
		      end
		      channel.on_data do |ch,data|
		        stdout_data+=data
		      end

		      channel.on_extended_data do |ch,type,data|
		        stderr_data+=data
		      end

		      channel.on_request("exit-status") do |ch,data|
		        exit_code = data.read_long
		      end

		      channel.on_request("exit-signal") do |ch, data|
		        exit_signal = data.read_long
		      end
		    end
		  end
		  ssh.loop

			result = Avocado::CommandExecutionResult.new
			result.stdin = command
			result.stdout = stdout_data
			result.stderr = stderr_data
			result.retval = exit_code

		  result
		end

		# Executes a command on the remote system
		#
		# @param cmd [String] the command to execute
		# @return [CommandExecutionResult] result of the command exection
		def command(cmd)
			Avocado::Deployment.instance.log.info "Executing [" + cmd.yellow + "] on remote " + get(:name).to_s.cyan

			result = Avocado::CommandExecutionResult.new

			begin
				result = ssh_exec!(@session, cmd)
				
				if result.stdout.nil? == false && result.stdout.empty? == false
					Avocado::Deployment.instance.log.debug "Stdout@#{get(:host)}: ".cyan + result.stdout.green
				end

				if result.stderr.nil? == false && result.stderr.empty? == false
					Avocado::Deployment.instance.log.debug "Stderr@#{get(:host)}: ".cyan + result.stderr.red
				end
			rescue Exception => e
				handle_abort e
			end

			result
		end

	end
end