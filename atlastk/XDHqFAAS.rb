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

module XDHqFAAS
	require 'XDHqSHRD'

	require 'socket'
	require 'pp'

	VERSION_ = "0.13.1"

	@_readMutex_ = Mutex.new
	# Staying on conditional variable, because a mutex
	# can not be locked twice by same thread,
	# and not be unlocked by another thread.
	# Also, there are no semaphores in Ruby.
	@_readCondVar_ = ConditionVariable.new

	def self.waitForInstance_
		@_readMutex_.synchronize {
			@_readCondVar_.wait(@_readMutex_)
		}
	end
		
	def self.instanceDataRead_
		@_readMutex_.synchronize {
			@_readCondVar_.signal
		}
	end
	
	class Instance
		attr_accessor :language

		def initialize
			@readMutex_ = Mutex.new
	# Staying on conditional variable, because a mutex
	# can not be locked twice by same thread,
	# and not be unlocked by another thread.
	# Also, there are no semaphores in Ruby.
			@readCondVar_ = ConditionVariable.new
			@quit = false
			@language = nil
		end
		def set(thread,id)
			@thread = thread
			@id = id
		end
		def getId
			return @id
		end
		def setQuitting
			@quit = true
		end
		def waitForData
			@readMutex_.synchronize {
				@readCondVar_.wait(@readMutex_)
			}
			if @quit
				XDHqFAAS::instanceDataRead_()
				Thread.exit()
			end	
		end
		def dataAvailable
			@readMutex_.synchronize {
				@readCondVar_.signal
			}
		end
	end

	def XDHq::l
		caller_infos = caller.first.split(":")
		puts "#{caller_infos[0]} - #{caller_infos[1]}"  
	end

	FAAS_PROTOCOL_LABEL_ = "4c837d30-2eb5-41af-9b3d-6c8bf01d8dbf"
	FAAS_PROTOCOL_VERSION_ = "1"
	MAIN_PROTOCOL_LABEL_ = "22bb5d73-924f-473f-a68a-14f41d8bfa83"
	MAIN_PROTOCOL_VERSION_ = "0"
	SCRIPTS_VERSION_ = "0"

	FORBIDDEN_ID_ = -1
	CREATION_ID_ = -2
	CLOSING_ID_ = -3
	HEAD_RETRIEVING_ID_ = -4

	BROADCAST_ACTION_ID_ = -3
	HEAD_SENDING_ID_ = -4

	@pAddr = "faas.q37.info"
	@pPort = 53700
	@wAddr = ""
	@wPort = ""
	@cgi = "xdh"

	@instances = {}
	@writeMutex = Mutex.new
	@headContent = ""
	@token = ""

	def self.getWriteMutex
		@writeMutex
	end

	@REPLit = 
	<<~HEREDOC
	node -e "require('http').createServer(function (req, res)
	{res.end(\\"<html><body><iframe style='border-style: none; width: 100%%;height: 100%%' src='https://atlastk.org/repl_it.php?url=%s'></iframe></body></html>\\");process.exit();}).listen(8080)"
	HEREDOC

	def XDHq::getEnv(name, value = "")
		return XDHqSHRD::getEnv(name, value);
	end

	def self.tokenEmpty?()
		return @token.empty?() || @token[0] == "&"
	end
	
	def self.init
		token = ""

		case XDHq::getEnv("ATK").upcase
		when ""
		when "NONE"
		when "DEV"
			@pAddr = "localhost"
			@wPort = "8080"
			puts("\tDEV mode !")
		when "TEST"
			@cgi = "xdh_"
		when "REPLIT"
			# Just to filter out this case.
		else
			abort("Bad 'ATK' environment variable value : should be 'DEV' or 'TEST' !")
		end

		@pAddr = XDHq::getEnv("ATK_PADDR", @pAddr)
		@pPort = XDHq::getEnv("ATK_PPORT", @pPort.to_s())
		@wAddr = XDHq::getEnv("ATK_WADDR", @wAddr)
		@wPort = XDHq::getEnv("ATK_WPORT", @wPort)

		if @wAddr.empty?
			@wAddr = @pAddr
		end

		if !@wPort.empty?
			@wPort = ":" + @wPort
		end

		if self.tokenEmpty?()
			token = XDHq::getEnv("ATK_TOKEN")
		end

		if !token.empty?
			@token = "&" + token
		end
	end

	init()

	def self.writeByte(byte)
		@socket.write(byte.chr())
	end
	def self.writeUInt(value)
		result = (value & 0x7F).chr()
		value >>= 7

		while value != 0
			result = ((value & 0x7f) | 0x80).chr() + result
			value >>= 7
		end

		@socket.write(result.to_s())
	end
	def self.writeSInt(value)
		self.writeUInt( value < 0 ? ( ( -value - 1 ) << 1 ) | 1 : value << 1 )
  end
	def self.writeString(string)
		writeUInt(string.bytes.length())
		@socket.write(string)
	end
	def self.writeStrings(strings)
		writeUInt(strings.length())
	
		for string in strings
			writeString(string)
		end
	end
	def self.getByte
		return @socket.recv(1).unpack('C')[0].to_i
	end
	def self.getUInt
		byte = getByte()
		value = byte & 0x7f
	
  	while (byte & 0x80) != 0    # For Ruby, 0 == true
			byte = getByte()
			value = (value << 7) + (byte & 0x7f)
		end
	
		return value
	end
	def self.getSInt
		value = getUInt()
		
		return ( value & 1 ) != 0 ? -( ( value >> 1 ) + 1 ) : value >> 1
  end
	def self.getString
		size = getUInt()

		if size != 0    # For Ruby, 0 == true
			return @socket.recv(size)
		else
			return ""
		end
	end
	def self.getStrings
		amount = getUInt()
		strings = []

		while amount != 0    # For Ruby, 0 == true
			strings.push(getString())
			amount -= 1
		end

		return strings
	end
	def self.dismiss(id)
		@writeMutex.synchronize {
			writeSInt(id)
			writeString("#Dismiss_1")	
		}
	end
	def self.report(message)
		@writeMutex.synchronize {
			writeSInt(-1)
			writeString("#Inform_1")	
			writeString(message)	
		}
	end
	def self.handshakeFaaS
		@writeMutex.synchronize {
			writeString(FAAS_PROTOCOL_LABEL_)
			writeString(FAAS_PROTOCOL_VERSION_)
			writeString("RBY " + VERSION_)
		}

		error = getString()

		if !error.empty?()
			abort error
		end

		notification = getString()

		if !notification.empty?()
			puts(notification)
		end
	end
	def self.handshakeMain
		@writeMutex.synchronize {
			writeString(MAIN_PROTOCOL_LABEL_)
			writeString(MAIN_PROTOCOL_VERSION_)
			writeString(SCRIPTS_VERSION_)
		}

		error = getString()

		if !error.empty?()
			abort error
		end

		notification = getString()

		if !notification.empty?()
			puts(notification)
		end
	end
	def self.handshakes
		handshakeFaaS
		handshakeMain
	end
	def self.ignition
		@writeMutex.synchronize {
			writeString(@token)
			# writeString(@headContent) # Dedicated request since FaaS protocol v1.
			writeString(@wAddr)
			writeString("")	# Currently not used ; for future use.
		}

		@token = getString()

		if tokenEmpty?()
			abort(getString())
		end

		if $wPort != ":0"
			url = getString()

			puts(url)
			puts("".rjust(url.length,'^'))
			puts("Open above URL in a web browser (click, right click or copy/paste). Enjoy!\n")
			if (XDHqSHRD::isREPLit?())
				system(@REPLit % [url])
			elsif (XDHq::getEnv("ATK").upcase != "NONE")
				XDHqSHRD::open(url)
			end
		end
	end
	def self.serve(callback, userCallback,callbacks)
		while true
			id = getSInt()
			
			if id == FORBIDDEN_ID_ # Should not happen.
				abort("Received unexpected undefined command id!")
			elsif id == CREATION_ID_    # Value reporting a new front-end.
				id = getSInt()  # The id of the new front-end.

				if @instances.has_key?(id)
					report("Instance of id '#{id}' exists but should not !")
				end

				instance = Instance.new
				instance.set(callback.call(userCallback.call(),callbacks,instance),id)
				@instances[id]=instance
			elsif id == CLOSING_ID_  # Value reporting the closing of a session.
				id = getSInt()

				if !@instances.has_key?(id)
					report("Instance of id '#{id}' not available for destruction!")
				else
					@instances[id].setQuitting
					@instances[id].dataAvailable()

					waitForInstance_()
					
					@instances.delete(id)
				end
			elsif id == HEAD_RETRIEVING_ID_
				@writeMutex.synchronize {
					XDHqFAAS::writeSInt(HEAD_SENDING_ID_)
					XDHqFAAS::writeString(@headContent)
				}
			elsif !@instances.has_key?(id)
				report("Unknown instance of id '#{id}'!")
				dismiss(id)
			else
				instance = @instances[id]

				if instance.language.nil?
					instance.language = getString()
				else
					instance.dataAvailable()
					
					waitForInstance_()
				end
			end
		end
	end
	def XDHqFAAS::launch(callback,userCallback,callbacks,headContent)
		Thread::abort_on_exception = true
		@headContent = headContent

		puts "Connecting to '#{@pAddr}:#{@pPort}'…"

		begin
			@socket = TCPSocket.new(@pAddr, @pPort)
		rescue StandardError
			abort("Unable to connect to '#{@pAddr}:#{@pPort}': #{$!}!")
		end

		puts "Connected to '#{@pAddr}:#{@pPort}'."

		self.handshakes()

		self.ignition()

		self.serve(callback,userCallback,callbacks)
  end
  def XDHqFAAS::broadcastAction(action,id)
		@writeMutex.synchronize {
			XDHqFAAS::writeSInt(BROADCAST_ACTION_ID_)
			XDHqFAAS::writeString(action)
			XDHqFAAS::writeString(id)
	}
  end 
	class DOM
		def initialize(instance)
			@instance = instance
			@firstLaunch = true
		end
		def waitForData_()
			@instance.waitForData()
		end
		def getAction()
			if @firstLaunch
				@firstLaunch = false
			else
				XDHqFAAS::getWriteMutex.synchronize {
					XDHqFAAS::writeSInt(@instance.getId())
					XDHqFAAS::writeString("#StandBy_1")
				}
			end

			waitForData_()

			id, action = [XDHqFAAS::getString(), XDHqFAAS::getString()]

			XDHqFAAS::instanceDataRead_()

			return action,id
		end
		def call(command, type, *args)
			i = 0
			amount = args.length
			
			XDHqFAAS::getWriteMutex.synchronize {
				XDHqFAAS::writeSInt(@instance.getId())
				XDHqFAAS::writeString(command)
				XDHqFAAS::writeUInt(type)

				while amount != 0    # For Ruby, 0 == true
					if args[i].is_a?( String )
						XDHqFAAS::writeUInt(XDHqSHRD::STRING)
						XDHqFAAS::writeString(args[i])
					else
						XDHqFAAS::writeUInt(XDHqSHRD::STRINGS)
						XDHqFAAS::writeStrings(args[i])
					end

					i += 1
					amount -= 1
				end

				XDHqFAAS::writeUInt(XDHqSHRD::VOID)
			}

			case type
			when XDHqSHRD::VOID
			when XDHqSHRD::STRING
				waitForData_()
				string = XDHqFAAS::getString()
				XDHqFAAS::instanceDataRead_()
				return string
			when XDHqSHRD::STRINGS
				waitForData_()
				strings = XDHqFAAS::getStrings()
				XDHqFAAS::instanceDataRead_()
				return strings
			else
				abort("Unknown return type !!!")
			end
		end
	end
end
