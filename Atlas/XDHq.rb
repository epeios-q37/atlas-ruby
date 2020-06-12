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

module XDHq
	require 'XDHqFAAS'
	require 'uri'

	$dir = ""

	$VOID=XDHqSHRD::VOID
	$STRING=XDHqSHRD::STRING
	$STRINGS=XDHqSHRD::STRINGS

	def XDHq::split(keysAndValues)
		keys = []
		values = []

		keysAndValues.each do |key, value|
			keys.push(key)
			values.push(value)
		end

		return keys, values
	end

	def XDHq::unsplit(keys, values)
		i = 0
		keysAndValues = {}
		length = keys.length()

		while i < length
			keysAndValues[keys[i]] = values[i]
			i += 1
		end

		return keysAndValues
	end

	def XDHq::getAssetPath(dir)
		if XDHqSHRD::isDev?()
			return File.join("/home/csimon/epeios/tools/xdhq/examples/common/", dir)
		else
			return File.join(Dir.pwd,dir)
		end
	end

	def XDHq::getAssetFilename(path, dir)
		return File.join(XDHq::getAssetPath(dir),path)
	end

	def XDHq::readAsset(path, dir = "")
		return File.read(XDHq::getAssetFilename(path,dir), :encoding => 'UTF-8')
	end

	class DOM
		def initialize(id)
			@dom = XDHqFAAS::DOM.new(id)
		end

		private def unsplit(*args)
			return XDHq.unsplit(*args)
		end

		private def split(*args)
			return XDHq.split(*args)
		end

		private def call(command, type, *args)
			return @dom.call(command,type,*args)
		end

		def getAction
			return @dom.getAction()
		end

		def isQuitting?
			return @dom.isQuitting?
		end

		private def execute(type, script)
			return call("Execute_1" ,type, script)
		end

		def executeVoid(script)
			execute($VOID, script)
		end
	
		def executeString(script)
			return execute($STRING, script)
		end
	
		def executeStrings(script)
			return execute($STRINGS, script)
		end
	
		def alert(message)
			call( "Alert_1", $STRING, message)
		# For the return value being 'STRING' instead of 'VOID',
		# see the 'alert' primitive in 'XDHqXDH'.
		end

		def confirm?(message)
			return call("Confirm_1", $STRING, message) == "true"
		end

		private def handleLayout(variant, id, xml, xslFilename = "")
			call("HandleLayout_1", $VOID, variant, id, if xml.is_a?( String ) then xml else xml.toString() end, xslFilename)
		end

		def prependLayout(id, html)
			handleLayout("Prepend", id, html)
		end

		def setLayout(id, html)
			handleLayout("Set", id, html)
		end

		def appendLayout(id, html)
			handleLayout("Append", id, html)
		end

		private def handleLayoutXSL(variant, id, xml, xsl)
			xslURL = xsl

			if true	# Testing if 'SlfH' or 'FaaS' mode when available.
				xslURL = "data:text/xml;charset=utf-8," + URI::encode(XDHq::readAsset( xsl, $dir ))
			end

			handleLayout(variant, id, xml, xslURL )
		end

		def prependLayoutXSL(id, xml, xsl)
			handleLayoutXSL("Prepend", id, xml, xsl)
		end

		def setLayoutXSL(id, xml, xsl)
			handleLayoutXSL("Set", id, xml, xsl)
		end

		def appendLayoutXSL(id, xml, xsl)
			handleLayoutXSL("Append", id, xml, xsl)
		end
	
		def getContents(ids)
			return unsplit(ids, call("GetContents_1", $STRINGS, ids))
		end

		def getContent(id)
			return getContents([id])[id]
		end

		def setContents(idsAndContents)
			ids, contents = split(idsAndContents)
			call("SetContents_1", $VOID, ids, contents)
		end

		def setContent(id, content)
			setContents({id => content})
		end

=begin	
		def createElement(name, id = "" )
			return call( "CreateElement_1", $STRING, 2, name, id, 0 )
		end
	
		def insertChild(child, id)
			call( "InsertChild_1", $VOID, 2, child, id, 0 )
		end
=end	

		private def handleClasses(variant, idsAndClasses)
			ids, classes = split(idsAndClasses)
	
			call("HandleClasses_1", $VOID, variant, ids, classes)
		end
	
		def addClasses(idsAndClasses)
			handleClasses("Add", idsAndClasses)
		end
	
		def removeClasses(idsAndClasses)
			handleClasses("Remove", idsAndClasses)
		end
	
		def toggleClasses(idsAndClasses)
			handleClasses("Toggle", idsAndClasses)
		end
	
		def addClass(id, clas)
			addClasses({id => clas})
		end
	
		def removeClass(id, clas )
			removeClasses({id => clas})
		end
	
		def toggleClass(id, clas)
			toggleClasses({id => clas})
		end
	
		def enableElements(ids)
			call("EnableElements_1", $VOID, ids)
		end
	
		def enableElement(id)
			enableElements([id])
		end
	
		def disableElements(ids)
			call("DisableElements_1", $VOID, ids)
		end
	
		def disableElement(id)
			disableElements([id])
		end
	
		def setAttribute(id, name, value )
			call("SetAttribute_1", $VOID, id, name, value )
		end
	
		def getAttribute(id, name)
			return call("GetAttribute_1", $STRING, id, name )
		end
	
		def removeAttribute(id, name )
			call("RemoveAttribute_1", $VOID, id, name )
		end
	
		def setProperty(id, name, value )
			call("SetProperty_1", $VOID, id, name, value )
		end
	
		def getProperty(id, name )
			return call("GetProperty_1", _STRING, id, name )
		end

		def focus(id)
			call("Focus_1", $VOID, id )
		end
	end

	def XDHq::launch(callback,userCallback,callbacks,headContent, dir)
		$dir = dir
		XDHqFAAS.launch(callback, userCallback, callbacks, headContent)
	end

	def XDHq::broadcastAction(action,id)
		XDHqFAAS.broadcastAction(action,id)
	end
end
