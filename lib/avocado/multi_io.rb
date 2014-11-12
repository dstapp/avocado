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
	class MultiIO
    # Initializes the MultiIO with various target
    #
    # @param targets [Array] targets to handle
	  def initialize(*targets)
	     @targets = targets
	  end

    # Writes to all targets
    # 
    # @param args [mixed] arguments
	  def write(*args)
	    @targets.each {|t| t.write(*args)}
	  end

    # Closes the targets
	  def close
	    @targets.each(&:close)
	  end
	end
end