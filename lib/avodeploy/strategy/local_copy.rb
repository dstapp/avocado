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

AvoDeploy::Deployment.configure do

	task :check_local_tools, before: :deploy, scope: :local, visibility: :private do
		check_util_availability [ 'tar' ].concat(@scm.cli_utils)
	end

	task :check_remote_system, before: :deploy, scope: :remote, visibility: :private do
		check_util_availability [ 'tar' ]
	end

	task :check_temp_existance, after: :deploy do
		if File.exist?('.avocado-tmp')
			raise RuntimeError, 'The avocado tmp directory (.avocado-tmp) does already exist. That may indicate that another deployment is already running.'
		end
	end

	task :switch_to_temp_dir, after: :check_temp_existance do
		command "mkdir .avocado-tmp/"
		chdir ".avocado-tmp/"
	end

	task :checkout_from_scm, after: :switch_to_temp_dir do
		@scm.checkout_from_remote(get(:repo_url), 'working-copy', get(:branch))
	end

	task :chdir_to_working_copy, after: :checkout_from_scm do
		chdir "working-copy/"
	end

	task :get_scm_info, after: :chdir_to_working_copy do
		set :revision, @scm.revision
	end

	task :delete_ignored_files, after: :get_scm_info do
		files_to_delete = [ 'Avofile' ].concat(get(:ignore_files)).concat(@scm.scm_files)

		command "rm -rfv #{files_to_delete.join(' ')}"
	end

	task :create_revision_file, after: :delete_ignored_files do
		command "echo '#{get(:revision)}' > REVISION"
	end

	task :create_deployment_tarball, after: :create_revision_file do
		command "tar cvfz ../deploy.tar.gz ."
	end

	task :switch_to_parent_dir, after: :create_deployment_tarball do
		chdir "../"
	end

	task :upload, after: :switch_to_parent_dir do
		targets.each_pair do |key, target|
			copy_to_target(target, 'deploy.tar.gz', '/tmp/deploy.tar.gz')
		end
	end

	task :create_deploy_dir, after: :upload, scope: :remote do
		command "if [ ! -d '#{get(:deploy_dir)}' ]; then mkdir -p #{get(:deploy_dir)}; fi"
	end

	task :unpack, after: :create_deploy_dir, scope: :remote do
		command "tar xvfz /tmp/deploy.tar.gz -C #{get(:deploy_dir)}/"
	end

	task :cleanup_remote, after: :unpack, scope: :remote do
		command "rm /tmp/deploy.tar.gz"
	end 

	task :log_deployment, after: :cleanup_remote, scope: :remote do
		command "echo '[#{Time.now.strftime('%Y-%m-%d %H-%M-%S')}] revision #{get(:revision)} deployed by #{ENV['USER']}' >> #{get(:log_file)}"
	end

	task :cleanup_local, after: :cleanup_remote do
		chdir "../"
		command "rm -rf .avocado-tmp"
	end

end