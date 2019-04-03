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

module XDHq
	require 'XDHqDEMO'
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
			return File.join("/cygdrive/h/hg/epeios/tools/xdhq/examples/common/", dir)
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
			@dom = XDHqDEMO::DOM.new(id)
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

		def getAction()
			return @dom.getAction()
		end

		def execute(script)
			return call("Execute_1" ,$STRING, 1, script, 0)
		end
	
		def alert(message)
			call( "Alert_1", $STRING, 1, message, 0 )
		# For the return value being 'STRING' instead of 'VOID',
		# see the 'alert' primitive in 'XDHqXDH'.
		end

		def confirm?(message)
			return call("Confirm_1", $STRING, 1, message, 0) == "true"
		end

		def setLayout(id, xml, xslFilename = "")
			call("SetLayout_1", $VOID, 3, id, xml, xslFilename, 0)
		end

		def setLayoutXSL(id, xml, xsl)
			xslURL = xsl

			if true	# Testing if 'PROD' or 'DEMO' mode when available.
				xslURL = "data:text/xml;charset=utf-8," + URI::encode(XDHq::readAsset( xsl, $dir ))
			end
			setLayout( id, if xml.is_a?( String ) then xml else xml.toString() end, xslURL )
		end
	
		def getContents(ids)
			return unsplit(ids, call("GetContents_1", $STRINGS, 0, 1, ids))
		end

		def getContent(id)
			return getContents([id])[id]
		end

		def setContents(idsAndContents)
			ids, contents = split(idsAndContents)
			call("SetContents_1", $VOID, 0, 2, ids, contents)
		end

		def setContent(id, content)
			setContents({id => content})
		end

		def setTimeout(delay,action )
			call( "SetTimeout_1", $VOID, 2, delay.to_s(), action, 0 )
		end
	
		def createElement(name, id = "" )
			return call( "CreateElement_1", $STRING, 2, name, id, 0 )
		end
	
		def insertChild(child, id)
			call( "InsertChild_1", $VOID, 2, child, id, 0 )
		end
	
		def dressWidgets(id)
			return call( "DressWidgets_1", $VOID, 1, id, 0 )
		end
	
		private def handleClasses(command, idsAndClasses)
			ids, classes = split(idsAndClasses)
	
			call(command, $VOID, 0, 2, ids, classes)
		end
	
		def addClasses(idsAndClasses)
			handleClasses("AddClasses_1", idsAndClasses)
		end
	
		def removeClasses(idsAndClasses)
			handleClasses("RemoveClasses_1", idsAndClasses)
		end
	
		def toggleClasses(idsAndClasses)
			handleClasses("ToggleClasses_1", idsAndClasses)
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
			call("EnableElements_1", $VOID, 0, 1, ids)
		end
	
		def enableElement(id)
			enableElements([id])
		end
	
		def disableElements(ids)
			call("DisableElements_1", $VOID, 0, 1, ids)
		end
	
		def disableElement(id)
			disableElements([id])
		end
	
		def setAttribute(id, name, value )
			call("SetAttribute_1", $VOID, 3, id, name, value, 0 )
		end
	
		def getAttribute(id, name)
			return call("GetAttribute_1", $STRING, 2, id, name, 0 )
		end
	
		def removeAttribute(id, name )
			call("RemoveAttribute_1", $VOID, 2, id, name, 0 )
		end
	
		def setProperty(id, name, value )
			call("SetProperty_1", $VOID, 3, id, name, value, 0 )
		end
	
		def getProperty(id, name )
			return call("GetProperty_1", _STRING, 2, id, name, 0 )
		end

		def focus(id)
			call("Focus_1", $VOID, 1, id, 0)
		end
	end

	def XDHq::launch(callback,userCallback,callbacks,headContent, dir)
		$dir = dir
		XDHqDEMO.launch(callback, userCallback, callbacks, headContent)
	end

end