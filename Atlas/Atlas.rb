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

$threads = []

module Atlas
	require 'XDHq'
	require 'XDHqXML'

	def Atlas::l()
		caller_infos = caller.first.split(":")
		puts "#{caller_infos[0]}:#{caller_infos[1]}"  
	end

	def Atlas::createXML(rootTag)
		return XDHqXML::XML.new(rootTag)
	end

	def Atlas::createHTML(rootTag = "")
		return Atlas::createXML(rootTag)
	end

	def self.call_(callback, userObject, dom, id, action)
		case callback.arity
		when 0
			return callback.call()
		when 1
			return callback.call(userObject)
		when 2
			return callback.call(userObject, dom)
		when 3
			return callback.call(userObject, dom, id)
		else
			return callback.call(userObject, dom, id, action)
		end
	end

	def Atlas::thread(userObject,dom,callbacks)
		while true
			action, id = dom.getAction()

			self.call_(callbacks[action], userObject, dom, id, action)
		end
	end

	def self.cb(userObject, callbacks,instance)
		return Thread.new(userObject,XDHq::DOM.new(instance),callbacks) do |userObject,dom,callbacks| thread(userObject, dom, callbacks) end
 end

	def Atlas::launch(callbacks,callback = -> () {},headContent="",dir="")
		XDHq.launch(-> (userObject,callbacks,id) {self.cb(userObject,callbacks,id)},callback,callbacks,headContent,dir)
=begin
		while true
			thread = Thread.new(new.call(),XDHq::DOM.new(),callbacks) do |userObject,dom,callbacks| thread(userObject, dom, callbacks) end
			$threads << thread
		end
=end
	end

	def Atlas::readAsset(path, dir="")
		return XDHq::readAsset(path, dir)
	end
end