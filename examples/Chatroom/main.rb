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
			dom.begin("Board", buildXML(), "Messages.xsl")
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
	dom.inner("", readAsset("Main.html"))
	dom.focus("Pseudo")
	chatroom.displayMessages(dom)
end

def acSubmitPseudo(chatroom, dom, id)
	pseudo = dom.getValue("Pseudo").strip()

	if pseudo.empty?()
		dom.alert("Pseudo. can not be empty !")
		dom.setValue("Pseudo", "")
		dom.focus("Pseudo")
	elsif chatroom.handlePseudo(pseudo)
		dom.addClass("PseudoButton", "hidden")
		dom.disableElements(["Pseudo", "PseudoButton"])
		dom.enableElements(["Message", "MessageButton"])
		dom.setValue("Pseudo", pseudo)
		dom.focus("Message")
		puts("\t>>>> New user: " + pseudo)
	elsif
		dom.alert("Pseudo. not available !")
		dom.setValue("Pseudo", pseudo)
		dom.focus("Pseudo")
	end
end

def acSubmitMessage(chatroom, dom, id)
	message = dom.getValue("Message")
	dom.setValue("Message", "")
	dom.focus("Message")
	chatroom.addMessage(message)
	chatroom.displayMessages(dom)
	Atlas.broadcastAction("Update");
end

def acUpdate(chatroom, dom, id)
	chatroom.displayMessages(dom)
end

callbacks = {
	"" => method(:acConnect),
	"SubmitPseudo" => method(:acSubmitPseudo),
	"SubmitMessage" => method(:acSubmitMessage),
	"Update" => method(:acUpdate),
}

Atlas.launch(callbacks, ->() {return Chatroom.new()}, readAsset("Head.html"), "Chatroom")