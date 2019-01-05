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

module XDHqSHRD
	XDHqSHRD::VOID = 0
	XDHqSHRD::STRING = 1
	XDHqSHRD::STRINGS = 2

	def XDHqSHRD::open(document)
		opener, suffix = case RbConfig::CONFIG['host_os']
		when /mswin|mingw/ then ["start /B ", ""]
		when /cygwin/ then ["cygstart ", " &" ]
		when /darwin/	then ["open ", " &"]
		else ["xdg-open ", " &"]
		end

	    system opener + document + suffix
	end

	def XDHqSHRD::isDev?()
		return ENV.include?("EPEIOS_SRC")
	end
end