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

    def XDHq::l
        caller_infos = caller.first.split(":")
        puts "#{caller_infos[0]} - #{caller_infos[1]}"  
    end

    $protocolLabel = "3f0aef6b-b893-4ccd-9316-d468588fc572"
    $protocolVersion = "0"

    $pAddr = "atlastk.org"
    $pPort = 53800
    $wAddr = ""
    $wPort = ""
    $cgi = "xdh"

    $headContent = ""
    $token = ""

    def XDHq::getEnv(name, value = "")
        env = ENV[name]

        if env
            return env.strip()
        else
            return value.strip()
        end
    end

    def XDHqDEMO::launch(headContent)
        $headContent = headContent
    end
        
    class DOM
        def getEnv(name, value = "" )
            return XDHq.getEnv(name, value)
        end
        def tokenEmpty?()
            return $token.empty?() || $token[0] == "&"
        end
        def writeSize(size)
            result = (size & 0x7F).chr()
            size >>= 7

            while size != 0
                result = ((size & 0x7f) | 0x80).chr() + result
                size >>= 7
            end

            result = result.to_s()

            @socket.write(result)
        end
        def writeString(string)
            writeSize(string.bytes.length())
            @socket.write(string)
        end
        def writeStrings(strings)
            writeSize(strings.length())
    
            for string in strings
                writeString(string)
            end
        end
        def writeStringNUL(string)
            @socket.write("#{string}\0")
        end
        def getByte()
            return @socket.recv(1).unpack('C')[0]
        end
        def getSize()
            byte = getByte()
            size = byte & 0x7f

            while (byte & 0x80) != 0    # For Ruby, 0 == true
                byte = getByte()
                size = (size << 7) + (byte & 0x7f)
            end

            return size
        end
        def getString
            size = getSize()

            if size != 0    # For Ruby, 0 == true
                return @socket.recv(size)
            else
                return ""
            end
        end
        def getStrings()
            amount = getSize()
            strings = []

            while amount != 0    # For Ruby, 0 == true
                strings.push(getString())
                amount -= 1
            end

            return strings
        end
        def initialize()
            @firstLaunch = true
            token = ""

            getEnv("ATK")

            case getEnv("ATK")
            when ""
            when "DEV"
                $pAddr = "localhost"
                $wPort = "8080"
                puts("\tDEV mode !")
            when "TEST"
                $cgi = "xdh_"
            else
                abort("Bad 'ATK' environment variable value : should be 'DEV' or 'TEST' !")
            end

            $pAddr = getEnv("ATK_PADDR", $pAddr)
            $pPort = getEnv("ATK_PPORT", $pPort.to_s())
            $wAddr = getEnv("ATK_WADDR", $wAddr)
            $wPort = getEnv("ATK_WPORT",$wPort)

            if $wAddr.empty?
                $wAddr = $pAddr
            end

            if !$wPort.empty?
                $wPort = ":" + $wPort
            end

            if tokenEmpty?()
                token = getEnv("ATK_TOKEN")
            end

            if !token.empty?
                $token = "&" + token
            end

            @socket = TCPSocket.new($pAddr, $pPort)

            writeString($token)

            if tokenEmpty?()
                writeString($headContent)

                $token = getString()

                if tokenEmpty?()
                    abort(getString())
                end

                if $wPort != ":0"
                    url = "http://#{$wAddr}#{$wPort}/#{$cgi}.php?_token=#{$token}"

                    puts(url)
                    puts("Open above URL in a web browser. Enjoy!\n")
                    XDHqSHRD::open(url)
                end
            else
                returnedToken = getString()

                if ( returnedToken == "" )
                    abort(getString())
                end

                if getString() != $token
                    abort("Unmatched token !!!")
                end
            end

            writeString($protocolLabel)
            writeString($protocolVersion)

            errorMessage = getString()

            if ( errorMessage != "" )
                abort(errorMessage)
            end

            getString() # Language.
            writeString("RBY")
        end

        def getAction()
            if @firstLaunch
                @firstLaunch = false
            else
                writeStringNUL("StandBy_1")
            end

            id = getString()
            action = getString()

            return action,id
        end

        def call(command, type, *args)
            i = 0
            writeStringNUL(command)

            amount = args[i]
            i += 1

            while amount != 0    # For Ruby, 0 == true
                writeString(args[i])
                i += 1
                amount -= 1
            end

            amount = args[i]
            i += 1

            while amount != 0    # For Ruby, 0 == true
                writeStrings(args[i])
                i += 1
                amount -= 1
            end

            case type
            when XDHqSHRD::VOID
            when XDHqSHRD::STRING
                return getString()
            when XDHqSHRD::STRINGS
                return getStrings()
            else
                abort("Unknown return type !!!")
            end
        end
    end
end