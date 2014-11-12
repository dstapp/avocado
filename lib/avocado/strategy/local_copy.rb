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

Avocado::Deployment.configure do

	task :check_local_tools, before: :deploy, scope: :local, visibility: :private do
		check_util_availability [ 'tar' ].concat(@scm.cli_utils)
	end

	task :check_remote_system, before: :deploy, scope: :remote, visibility: :private do
		check_util_availability [ 'tar' ]
	end

	task :check_temp_existance, visibility: :private, after: :deploy, scope: :local do
		if File.exist?('.avocado-tmp')
			raise RuntimeError, 'The avocado tmp directory (.avocado-tmp) does already exist. That may indicate that another deployment is already running.'
		end
	end

	task :switch_to_temp_dir, visibility: :private, after: :check_temp_existance, scope: :local do
		command "mkdir .avocado-tmp/"
		chdir(".avocado-tmp/")
	end

	task :checkout_from_scm, visibility: :private, after: :switch_to_temp_dir, scope: :local do
		@scm.checkout_from_remote(get(:repo_url), 'working-copy', get(:branch))
	end

	task :get_scm_info, visibility: :private, after: :checkout_from_scm, scope: :local do
		chdir("working-copy/")

		set(:revision, @scm.revision)
		
		chdir("../")
	end

	task :delete_ignored_files, visibility: :private, after: :get_scm_info, scope: :local do
		if get(:ignore_files).concat(@scm.scm_files).size > 0
			chdir("working-copy/")
			command "rm -rfv #{get(:ignore_files).concat(@scm.scm_files).join(' ')}"
			chdir("../")
		end
	end

	task :create_revision_file, visibility: :private, after: :delete_ignored_files, scope: :local do
		chdir("working-copy/")
		command "echo '#{get(:revision)}' > REVISION"
		chdir("../")
	end

	task :create_deployment_tarball, visibility: :private, after: :create_revision_file, scope: :local do
		chdir("working-copy/")
		command "tar cvfz ../deploy.tar.gz ."
		chdir("../")
	end

	task :upload, visibility: :private, after: :create_deployment_tarball, scope: :local do
		targets.each_pair do |key, target|
			copy_to_target(target, 'deploy.tar.gz', '/tmp/deploy.tar.gz')
		end
	end

	task :create_deploy_dir, visibility: :private, after: :upload, scope: :remote do
		command "if [ ! -d '#{get(:deploy_dir)}' ]; then mkdir -p #{get(:deploy_dir)}; fi"
	end

	task :unpack, visibility: :private, after: :create_deploy_dir, scope: :remote do
		command "tar xvfz /tmp/deploy.tar.gz -C #{get(:deploy_dir)}/"
	end

	task :cleanup_remote, visibility: :private, after: :unpack, scope: :remote do
		command "rm /tmp/deploy.tar.gz"
	end 

	task :log_deployment, visibility: :private, after: :cleanup_remote, scope: :remote do
		command "echo '[#{ Time.now.strftime('%Y-%m-%d %H-%M-%S')}] revision #{get(:revision)} deployed by #{ENV['USER']}' >> #{get(:log_file)}"
	end

	task :cleanup_local, visibility: :private, after: :cleanup_remote, scope: :local do
		chdir("../")
		command "rm -rf .avocado-tmp"
	end

end