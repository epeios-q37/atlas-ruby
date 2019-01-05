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

	def Atlas::thread(userObject,dom,callbacks)
		while true
			action, id = dom.getAction()

			callbacks[action].call(userObject,dom,id)
		end
	end

	def Atlas::launch(callbacks,new,headContent="",dir="")
		XDHq.launch(headContent,dir)

		while true
			thread = Thread.new(new.call(),XDHq::DOM.new(),callbacks) do |userObject,dom,callbacks| thread(userObject, dom, callbacks) end
			$threads << thread
		end
	end

	def Atlas::readAsset(path, dir="")
		return XDHq::readAsset(path, dir)
	end
end

=begin
trap("INT") {
		pp($threads)
		pp(Thread.list)
  puts "trapping"
		XDHq::l
  $Thread.list.each{|t|
    puts "killing"
    Thread.kill t
		}
		XDHq::l
		exit 130
		XDHq::l
		abort( "Yo !")
		XDHq::l
}
=end