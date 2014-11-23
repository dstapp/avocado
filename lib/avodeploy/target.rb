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
  class Target

    attr_reader :name
    attr_reader :config

    # Initializes the deployment target
    #
    # @param name [Symbol] target name
    # @param config [Hash] target config
    def initialize(name, config)
      @name = name
      @config = default_config.merge(config)
      @config[:name] = name
    end

    private
    # Sets up the config defaults
    #
    # @return [Hash] config defaults
    def default_config
      {
          :name => '',
          :host => nil,
          :user => 'root',
          :auth => :pubkey,
          :deploy_dir => '/var/www/',
          :log_file => '/var/www/deploy.log',
      }
    end

  end
end