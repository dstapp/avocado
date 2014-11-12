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

class Hash

  # Inserts a Key/Value-Pair at a specific position of in a Hash
  #
  # @param position [Symbol] the position to add the new pair, either `:before` or `:after` 
  def insert_at(position, key, kvpair)
    raise ArgumentError, 'position must be either :before or :after' unless [:before, :after].include?(position)

    arr = to_a
    pos = arr.index(arr.assoc(key))

    if pos && position == :after
      pos += 1
    end

    if pos
      arr.insert(pos, kvpair)
    else
      arr << kvpair
    end

    replace Hash[arr]
  end
end