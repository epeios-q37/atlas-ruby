=begin
MIT License

Copyright (c) 2018 Claude SIMON (https://q37.info/s/rmnmqd49)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
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

			if dom.isQuitting?
				break
			end

			self.call_(callbacks[action], userObject, dom, id, action)
		end

		# puts "Quitting thread!"
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

	def Atlas::broadcastAction(action, id="")
		XDHq.broadcastAction(action, id)
	end

	def Atlas::readAsset(path, dir="")
		return XDHq::readAsset(path, dir)
	end
end