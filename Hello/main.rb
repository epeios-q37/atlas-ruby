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

require 'Atlas'

def readAsset(path)
	return Atlas::readAsset(path, "Hello")
end

def acConnect(userObject, dom, id)
	dom.setLayout("", readAsset("Main.html"))
	dom.focus("input")
end

callbacks = {
	"" => method(:acConnect),
	"Typing" => -> (userObject, dom, id) { dom.setContent("name", dom.getContent(id))},
	"Clear" => -> (userObject, dom, id) { if dom.confirm?("Are you sure?") then dom.setContents({"input" => "", "name" => "" }) end }
}

Atlas.launch(callbacks, -> () {}, readAsset("Head.html"))
