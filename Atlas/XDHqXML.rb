=begin
 Copyright (C) 2018 Claude SIMON (http://q37.info/contact/).

	This file is part of XDHq.

	XDHq is free software: you can redistribute it and/or
	modify it under the terms of the GNU Affero General Public License as
	published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

	XDHq is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	Affero General Public License for more details.

	You should have received a copy of the GNU Affero General Public License
	along with XDHq If not, see <http://www.gnu.org/licenses/>.
=end

module XDHqXML
	class XML
		private def write(value)
			@xml += value.to_s() + "\0"
		end

		def initialize(rootTag)
			@xml = ""
			write("dummy")
			write(rootTag)
		end

		def pushTag(tag)
			@xml += '>'
			write(tag)
		end

		def popTag()
			@xml += '<'
		end

		def setAttribute(name,value)
			@xml += 'A'
			write(name)
			write(value)
		end

		def setValue(value)
			@xml += "V"
			write(value)
		end

		def toString()
			return @xml
		end
	end
end