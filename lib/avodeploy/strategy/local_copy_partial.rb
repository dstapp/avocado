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

  inherit_strategy :local_copy

  task :get_deployed_revision, after: :chdir_to_working_copy, scope: :remote do
    res = command "cat #{get(:deploy_dir)}/REVISION"

    if get(:deployed_revisions).nil?
      deployed_revisions = {}
    else
      deployed_revisions = get(:deployed_revisions)
    end

    revision = nil

    if res.retval == 0
      # file exists
      revision = res.stdout.lines.first.strip
    end

    deployed_revisions[get(:name)] = revision
    set(:deployed_revisions, deployed_revisions)
  end

  task :create_deployment_tarball, after: :create_revision_file do
    new_revision = get(:revision)

    get(:deployed_revisions).each_pair do |target_name, deployed_revision|
      # determine, which files to exclude
      files_to_delete = ['Avofile'].concat(get(:ignore_files)).concat(@scm.scm_files)

      exclude_param = ''

      files_to_delete.each do |file|
        exclude_param += " --exclude='^#{file}$'"
      end

      # create deployment archive
      if deployed_revision.nil?
        # create full deployment archive
        command "tar cvfz ../deploy_#{target_name.to_s}.tar.gz ."
      else
        # create partial deployment archive
        diff_files = @scm.diff_files_between_revisions(deployed_revision, new_revision)

        # always include the revision file
        # UPDATE: not longer needed because REVISION is in the unknown_files array anyway 
        #diff_files << 'REVISION'

        # include unknown files
        unknown_files = @scm.unknown_files_in_workdir

        File.open("../files_#{target_name.to_s}.txt", 'w') do |f|
          f << diff_files.join("\n")
          f << unknown_files.join("\n")
        end

        command "tar cvfz ../deploy_#{target_name.to_s}.tar.gz -T ../files_#{target_name.to_s}.txt #{exclude_param}"
      end
    end
  end

  task :upload, after: :switch_to_parent_dir do
    targets.each_pair do |key, target|
      copy_to_target(target, "deploy_#{target.name.to_s}.tar.gz", '/tmp/deploy.tar.gz')
    end
  end

end