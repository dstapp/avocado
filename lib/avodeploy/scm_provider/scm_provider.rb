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
	module ScmProvider
		# scm provider facade
		class ScmProvider

			# Initializes the scm provider
			#
			# @param env [TaskExecutionEnvironment] env for the commands to be executed in
			# @param scm [Symbol] the scm provider to user
			def initialize(env, scm)
				raise ArgumentError, 'env must be a TaskExecutionEnvironment' unless env.is_a?(AvoDeploy::Task::TaskExecutionEnvironment)

				@env = env
				@real_provider = nil

				if scm == :git
					@real_provider = GitScmProvider.new(env)
				end
			end

			# Checks out repository code from a system and switches to the given branch
			#
			# @param url [String] the repository location
			# @param local_dir [String] path to the working copy
			# @param branch [String] the branch to check out
			def checkout_from_remote(url, local_dir, branch)
				@real_provider.checkout_from_remote(url, local_dir, branch)
			end

			# Returns the current revision of the working copy
			#
			# @return [String] the current revision of the working copy
			def scm_files
				@real_provider.scm_files
			end

			# Returns scm files to be executed in the deployment process
			#
			# @return [Array] array of scm control files
			def cli_utils
				@real_provider.cli_utils
			end

			# Returns the scm tools that have to be installed on specific systems
			#
			# @return [Array] array of utilities
			def revision
				@real_provider.revision
			end
		end
	end
end