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
  class Bootstrap
    # Runs the avocado bootstrap
    #
    # @param stage [Symbol] the stage to bootstrap
    # @param verbose [Boolean] run in verbose mode
    # @param debug [Boolean] run in boolean mode
    def self.run(stage = :default, verbose = false, debug = false)
      if stage.is_a?(String)
        stage = stage.to_sym
      end

      begin
        # defaults
        AvoDeploy::Deployment.configure do
          set :stage, stage

          setup_stage :default do
            # a default stage is needed for some use cases,
            # especially if you don't know which stages were defined by the user
          end
        end

        if File.exist?(Dir.pwd.concat('/Avofile')) == false
          raise RuntimeError, 'Could not find Avofile. Run `avo install` first.'
        end

        instance = AvoDeploy::Deployment.instance

        # load user config initially to determine strategy
        begin
          load File.join(Dir.pwd, 'Avofile')
        rescue RuntimeError => e
          # `find_chain_index_containing': could not find a chain containing task create_deployment_tarball (RuntimeError)
          # error not neccessary because dependencies are not loaded
        end

        if debug
          instance.log.level = Logger::DEBUG
        elsif verbose
          instance.log.level = Logger::INFO
        else
          instance.log.level = instance.config.get(:log_level)
        end

        instance.log.debug 'Loading user configuration...'
        # override again by user config to allow manipulation of tasks
        load File.join(Dir.pwd, 'Avofile')

        # requested stage was not found
        if instance.config.loaded_stage.nil?
          raise ArgumentError, 'The requested stage does not exist.'
        end
      rescue Exception => e
        if debug
          raise e
        else
          AvoDeploy::Deployment.instance.log.error e.message.red
        end

        Kernel.exit(true)
      end

      AvoDeploy::Deployment.instance
    end
  end
end