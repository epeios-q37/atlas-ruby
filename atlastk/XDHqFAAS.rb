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

	class Instance
		def initialize
			@mutex = Mutex.new
			@condVar = ConditionVariable.new
	  @handshakeDone = false
	  @quit = false
		end
		def set(thread,id)
			@thread = thread
			@id = id
		end
		def handshakeDone?
			if @handshakeDone
				return true
			else
				@handshakeDone = true
				return false
			end
		end
		def getId()
			return @id
	end
	def setQuitting
	  @quit = true
	end
	def isQuitting?
	  return @quit
	end
		def wait
			@mutex.synchronize {
				@condVar.wait(@mutex)
			}
		end
		def signal
			@mutex.synchronize {
				@condVar.signal()
			}
		end
	end

	def XDHq::l
		caller_infos = caller.first.split(":")
		puts "#{caller_infos[0]} - #{caller_infos[1]}"  
	end

	@FaaSProtocolLabel = "9efcf0d1-92a4-4e88-86bf-38ce18ca2894"
	@FaaSProtocolVersion = "0"
	@mainProtocolLabel = "bf077e9f-baca-48a1-bd3f-bf5181a78666"
	@mainProtocolVersion = "0"

	@pAddr = "faas1.q37.info"
	@pPort = 53700
	@wAddr = ""
	@wPort = ""
	@cgi = "xdh"

	@instances = {}
	@globalMutex = Mutex.new
	@globalCondVar = ConditionVariable.new
	@outputMutex = Mutex.new
	@headContent = ""
	@token = ""

	@REPLit = 
	<<~HEREDOC
	node -e "require('http').createServer(function (req, res)
	{res.end(\\"<html><body><iframe style='border-style: none; width: 100%%;height: 100%%' src='https://atlastk.org/repl_it.php?url=%s'></iframe></body></html>\\");process.exit();}).listen(8080)"
	HEREDOC

	def self.lockOutputMutex()
		@outputMutex.lock();
	end

	def self.unlockOutputMutex()
		@outputMutex.unlock();
	end


	def self.signal()
		@globalMutex.synchronize {
			@globalCondVar.signal()
		}
	end

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
	def self.handshake
		@outputMutex.synchronize {
			writeString(@FaaSProtocolLabel)
			writeString(@FaaSProtocolVersion)
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
	def self.ignition
		@outputMutex.synchronize {
			writeString(@token)
			writeString(@headContent)
			writeString(@wAddr)
			writeString("RBY")
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
	  
		if id == -1 # Should not happen.
			abort("Received unexpected undefined command id!")
		elsif id == -2    # Value reporting a new front-end.
			id = getSInt()  # The id of the new front-end.

			if @instances.has_key?(id)
				abort("Instance of id '#{id}' exists but should not !")
			end

			instance = Instance.new
			instance.set(callback.call(userCallback.call(),callbacks,instance),id)
			@instances[id]=instance

			@outputMutex.synchronize {
				writeSInt(id)
				writeString(@mainProtocolLabel)
				writeString(@mainProtocolVersion)
			}
	  elsif id == -3  # Value reporting the closing of a session.
		id = getSInt()

		if !@instances.has_key?(id)
		  abort("Instance of id '#{id}' not available for destruction!")
		end
		
		@instances[id].setQuitting
		@instances[id].signal()

		@globalMutex.synchronize {
					@globalCondVar.wait(@globalMutex)
		}
		
	   @instances.delete(id)
			elsif !@instances.has_key?(id)
				abort("Unknown instance of id '#{id}'!")
			elsif !@instances[id].handshakeDone?
				error = getString()

				if !error.empty?()
					abort( error )
				end

				getString() # Language. Currently ignored.
			else
				@instances[id].signal()
				
				@globalMutex.synchronize {
					@globalCondVar.wait(@globalMutex)
				}
			end
		end
	end
	def XDHqFAAS::launch(callback,userCallback,callbacks,headContent)
		Thread::abort_on_exception = true
		@headContent = headContent

		@socket = TCPSocket.new(@pAddr, @pPort)

		self.handshake()

		self.ignition()

		self.serve(callback,userCallback,callbacks)
  end
  def XDHqFAAS::broadcastAction(action,id)
		XDHqFAAS::lockOutputMutex() # '@outputMutex.synchronize {...}' does not work as '@outputMutex' is not the good one.
		XDHqFAAS::writeSInt(-3)
		XDHqFAAS::writeString(action)
		XDHqFAAS::writeString(id)
		XDHqFAAS::unlockOutputMutex()   
  end 
	class DOM
		def initialize(instance)
			@instance = instance
			@firstLaunch = true
		end
		def wait()
			@instance.wait()
		end
		def signal()
			XDHqFAAS::signal()
		end
		def getAction()
			if @firstLaunch
				@firstLaunch = false
			else
				XDHqFAAS::lockOutputMutex() # '@outputMutex.synchronize {...}' does not work as '@outputMutex' is not the good one.
				XDHqFAAS::writeSInt(@instance.getId())
				XDHqFAAS::writeString("#StandBy_1")
				XDHqFAAS::unlockOutputMutex()
			end
			wait()

			id, action = @instance.isQuitting? ? ["", ""] : [XDHqFAAS::getString(), XDHqFAAS::getString()]

	  # signal()
	  # The below 'is_quitting()' method MUST be called, or the library will hang.

			return action,id
	end
	def isQuitting?
	  answer = @instance.isQuitting?

	  # Below line were in 'getAction' above, but, in case of quitting,
	  # '@instance' could already be destroyed here.
	  signal()

	  return answer
	end
		def call(command, type, *args)
			i = 0
			amount = args.length
			
			XDHqFAAS::lockOutputMutex() # '@outputMutex.synchronize {...}' does not work as '@outputMutex' is not the good one.
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

			XDHqFAAS::unlockOutputMutex()

			case type
			when XDHqSHRD::VOID
			when XDHqSHRD::STRING
				wait()
				string = XDHqFAAS::getString()
				signal()
				return string
			when XDHqSHRD::STRINGS
				wait()
				strings = XDHqFAAS::getStrings()
				signal()
				return strings
			else
				abort("Unknown return type !!!")
			end
		end
	end
end
