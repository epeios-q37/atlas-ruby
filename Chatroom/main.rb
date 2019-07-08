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

$mutex = Mutex.new()
$messages = []
$pseudos = []

def readAsset(path)
	return Atlas::readAsset(path, "Chatroom")
end

class Chatroom
	def initialize()
		@lastMessage = 0
		@pseudo = ""
	end

	def buildXML()
		xml = Atlas.createXML("XDHTML")
		xml.pushTag( "Messages" )
		xml.putAttribute( "pseudo", @pseudo )

		$mutex.synchronize  do
			index = $messages.length() - 1

			while index >= @lastMessage
				message = $messages[index]

				xml.pushTag( "Message" )
				xml.putAttribute( "id", index )
				xml.putAttribute( "pseudo", message['pseudo'] )
				xml.putValue( message['content'] )
				xml.popTag()

				index -= 1
			end

			@lastMessage = $messages.length()
		end

		xml.popTag()

		return xml
	end

	def displayMessages(dom)
		if $messages.length() > @lastMessage
			dom.prependLayoutXSL("Board", buildXML(), "Messages.xsl")
		end
	end

	def handlePseudo(pseudo)
		result = $mutex.synchronize {
			!$pseudos.include?(pseudo.upcase())
		}

		if result
			$pseudos.push(pseudo.upcase())
			@pseudo = pseudo
		end

		return result
	end

	def addMessage(message)
		message = message.strip()

		if message
			puts("'" + @pseudo + "': " + message)

			$mutex.synchronize {
				$messages.push({'pseudo' => @pseudo, 'content' => message})
			}
		end
	end
end

def acConnect( chatroom, dom, id)
	dom.setLayout("", readAsset("Main.html"))
	dom.focus("Pseudo")
	chatroom.displayMessages(dom)
	dom.setTimeout(1000, "Update")
end

def acSubmitPseudo(chatroom, dom, id)
	pseudo = dom.getContent("Pseudo").strip()

	if pseudo.empty?()
		dom.alert("Pseudo. can not be empty !")
		dom.setContent("Pseudo", "")
		dom.focus("Pseudo")
	elsif chatroom.handlePseudo(pseudo)
		dom.addClass("PseudoButton", "hidden")
		dom.disableElements(["Pseudo", "PseudoButton"])
		dom.enableElements(["Message", "MessageButton"])
		dom.setContent("Pseudo", pseudo)
		dom.focus("Message")
		puts("\t>>>> New user: " + pseudo)
	elsif
		dom.alert("Pseudo. not available !")
		dom.setContent("Pseudo", pseudo)
		dom.focus("Pseudo")
	end
end

def acSubmitMessage(chatroom, dom, id)
	message = dom.getContent("Message")
	dom.setContent("Message", "")
	dom.focus("Message")
	chatroom.addMessage(message)
	chatroom.displayMessages(dom)
end

def acUpdate(chatroom, dom, id)
	chatroom.displayMessages(dom)
	dom.setTimeout(1000, "Update")
end

callbacks = {
	"" => method(:acConnect),
	"SubmitPseudo" => method(:acSubmitPseudo),
	"SubmitMessage" => method(:acSubmitMessage),
	"Update" => method(:acUpdate),
}

Atlas.launch(callbacks, ->() {return Chatroom.new()}, readAsset("Head.html"), "Chatroom")