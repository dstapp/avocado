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
    class BzrScmProvider < ScmProvider

      # Initializes the provider
      #
      # @param env [TaskExecutionEnvironment] Environment for the commands to be executed in
      def initialize(env)
        super(env)
      end

      # Checks out repository code from a system and switches to the given branch
      #
      # @param url [String] the repository location
      # @param local_dir [String] path to the working copy
      # @param branch [String] the branch to check out, not used here because branches are encoded in the bazaar urls
      # @param tag [String] tag to check out
      def checkout_from_remote(url, local_dir, branch, tag = nil)
        cmd = "bzr co --lightweight #{url} #{local_dir}"

        if tag.nil? == false
          cmd += " -r tag:#{tag}"
        end

        res = @env.command(cmd)
        raise RuntimeError, "Could not checkout from bzr url #{url}" unless res.retval == 0
      end

      # Returns the current revision of the working copy
      #
      # @return [String] the current revision of the working copy
      def revision
        res = @env.command('bzr revno --tree')

        res.stdout.gsub("\n", '')
      end

      # Finds files that differ between two revisions and returns them
      # as a array
      #
      # @param rev1 [String] sha1
      # @param rev2 [String] sha1
      #
      # @return [Array]
      def diff_files_between_revisions(rev1, rev2)
        # same revision, nothing changed
        if rev1 == rev2
          return []
        end

        # exclude rev1 itself
        rev1 = rev1.to_i + 1

        res = @env.command("bzr log -r#{rev1}..#{rev2} -v --short")

        files = []

        res.stdout.lines.each do |line|
          line.strip!
          next unless line.start_with?('A') || line.start_with?('M')

          files << line[3, line.length]
        end

        files
      end

      # Finds files unknown file in the working directory and returns them
      # as a array
      #
      # @return [Array]
      def unknown_files_in_workdir
        res = @env.command("bzr status --short | grep '^? ' | awk '/^? (.*)$/ {print $2}'")
        res.stdout.lines
      end

      # Returns scm files to be executed in the deployment process
      #
      # @return [Array] array of scm control files
      def scm_files
        ['.bzr', '.bzrignore']
      end

      # Returns the scm tools that have to be installed on specific systems
      #
      # @return [Array] array of utilities
      def cli_utils
        ['bzr']
      end

    end
  end
end