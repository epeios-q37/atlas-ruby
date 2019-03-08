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

module XDHqDEMO
    require 'XDHqSHRD'

    require 'socket'
    require 'pp'

    class Instance
        def initialize
            @mutex = Mutex.new
            @condVar = ConditionVariable.new
            @handshakeDone = false
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

    @demoProtocolLabel = "877c913f-62df-40a1-bf5d-4bb5e66a6dd9"
    @demoProtocolVersion = "0"
    @mainProtocolLabel = "6e010737-31d8-4be3-9195-c5b5b2a9d5d9"
    @mainProtocolVersion = "0"

    @pAddr = "atlastk.org"
    @pPort = 53800
    @wAddr = ""
    @wPort = ""
    @cgi = "xdh"

    @instances = {}
    @globalMutex = Mutex.new
    @globalCondVar = ConditionVariable.new
    @outputMutex = Mutex.new
    @headContent = ""
    @token = ""

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
        env = ENV[name]

        if env
            return env.strip()
        else
            return value.strip()
        end
    end
    def self.tokenEmpty?()
        return @token.empty?() || @token[0] == "&"
    end
    def self.init
        token = ""

        case XDHq::getEnv("ATK")
        when ""
        when "DEV"
            @pAddr = "localhost"
            @wPort = "8080"
            puts("\tDEV mode !")
        when "TEST"
            @cgi = "xdh_"
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
    def self.writeSize(size)
        result = (size & 0x7F).chr()
        size >>= 7

        while size != 0
            result = ((size & 0x7f) | 0x80).chr() + result
            size >>= 7
        end

        @socket.write(result.to_s())
    end
    def self.writeString(string)
        writeSize(string.bytes.length())
        @socket.write(string)
    end
    def self.writeStrings(strings)
        writeSize(strings.length())
    
        for string in strings
            writeString(string)
        end
    end
    def self.writeStringNUL(string)
        @socket.write("#{string}\0")
    end
    def self.getByte
        return @socket.recv(1).unpack('C')[0]
    end
    def self.getSize
        byte = getByte()
        size = byte & 0x7f

        while (byte & 0x80) != 0    # For Ruby, 0 == true
            byte = getByte()
            size = (size << 7) + (byte & 0x7f)
        end

        return size
    end
    def self.getString
        size = getSize()

        if size != 0    # For Ruby, 0 == true
            return @socket.recv(size)
        else
            return ""
        end
    end
    def self.getStrings
        amount = getSize()
        strings = []

        while amount != 0    # For Ruby, 0 == true
            strings.push(getString())
            amount -= 1
        end

        return strings
    end
    def self.demoHandshake
        @outputMutex.synchronize {
            writeString(@demoProtocolLabel)
            writeString(@demoProtocolVersion)
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
        }

        @token = getString()

        if tokenEmpty?()
            abort(getString())
        end

        if $wPort != ":0"
            url = "http://#{@wAddr}#{@wPort}/#{@cgi}.php?_token=#{@token}"

            puts(url)
            puts("".rjust(url.length,'^'))
            puts("Open above URL in a web browser. Enjoy!\n")
            XDHqSHRD::open(url)
        end
    end
    def self.serve(callback, userCallback,callbacks)
        while true
            id = getByte()

            if id == 255    # Value reporting a new front-end.
                id = getByte()  # The id of the new front-end.

                if @instances.has_key?(id)
                    abort("Instance of id '#{id}' exists but should not !")
                end

                instance = Instance.new
                instance.set(callback.call(userCallback.call(),callbacks,instance),id)
                @instances[id]=instance

                @outputMutex.synchronize {
                    writeByte(id)
                    writeString(@mainProtocolLabel)
                    writeString(@mainProtocolVersion)
                }
            elsif !@instances.has_key?(id)
                abort("Unknown instance of id '#{id}'!")
            elsif !@instances[id].handshakeDone?
                error = getString()

                if !error.empty?()
                    abort( error )
                end

                getString() # Language. Currently ignored.

                @outputMutex.synchronize {
                    writeByte(id)
                    writeString("RBY")
                }
            else
                @instances[id].signal()
                
                @globalMutex.synchronize {
                    @globalCondVar.wait(@globalMutex)
                }
            end
        end
    end
    def XDHqDEMO::launch(callback,userCallback,callbacks,headContent)
        Thread::abort_on_exception = true
        @headContent = headContent

        @socket = TCPSocket.new(@pAddr, @pPort)

        self.demoHandshake()

        self.ignition()

        self.serve(callback,userCallback,callbacks)
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
            XDHqDEMO::signal()
        end
        def getAction()
            if @firstLaunch
                @firstLaunch = false
            else
                XDHqDEMO::lockOutputMutex() # '@outputMutex.synchronize {...}' does not work as '@outputMutex' is not the good one.
                XDHqDEMO::writeByte(@instance.getId())
                XDHqDEMO::writeStringNUL("StandBy_1")
                XDHqDEMO::unlockOutputMutex()
            end
            wait()

            id = XDHqDEMO::getString()
            action = XDHqDEMO::getString()

            signal()

            return action,id
        end
        def call(command, type, *args)
            i = 0
            
            XDHqDEMO::lockOutputMutex() # '@outputMutex.synchronize {...}' does not work as '@outputMutex' is not the good one.
            XDHqDEMO::writeByte(@instance.getId())
            XDHqDEMO::writeStringNUL(command)

            amount = args[i]
            i += 1

            while amount != 0    # For Ruby, 0 == true
                XDHqDEMO::writeString(args[i])
                i += 1
                amount -= 1
            end

            amount = args[i]
            i += 1

            while amount != 0    # For Ruby, 0 == true
                XDHqDEMO::writeStrings(args[i])
                i += 1
                amount -= 1
            end

            XDHqDEMO::unlockOutputMutex()

            case type
            when XDHqSHRD::VOID
            when XDHqSHRD::STRING
                wait()
                string = XDHqDEMO::getString()
                signal()
                return string
            when XDHqSHRD::STRINGS
                wait()
                strings = XDHqDEMO::getStrings()
                signal()
                return strings
            else
                abort("Unknown return type !!!")
            end
        end
    end
end