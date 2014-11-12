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

class String

  # Paints the string red on CLI
	def red
    "\033[31m#{self}\033[0m"
  end
	
  # Paints the string green on CLI
  def green
    "\033[32m#{self}\033[0m" 
  end
	
  # Paints the string cyan on CLI
  def cyan
    "\033[36m#{self}\033[0m" 
  end
	
  # Paints the string yellow on CLI
  def yellow
    "\e[33m#{self}\e[0m" 
  end
	
  # Paints the string gray on CLI
  def gray
    "\033[37m#{self}\033[0m" 
  end
end