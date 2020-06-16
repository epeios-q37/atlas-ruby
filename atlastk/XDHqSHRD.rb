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

module XDHqSHRD
	XDHqSHRD::VOID = 0
	XDHqSHRD::STRING = 1
	XDHqSHRD::STRINGS = 2

	def XDHqSHRD::open(document)
		opener, suffix = case RbConfig::CONFIG['host_os']
		when /mswin|mingw/ then ["start /B ", ""]
		when /cygwin/ then ["cygstart ", " &" ]
		when /darwin/	then ["open ", " &"]
		else ["xdg-open ", " &"]
		end

	    system opener + document + suffix
	end

	def XDHqSHRD::isDev?()
		return ENV.include?("Q37_EPEIOS")
	end

	def XDHqSHRD::getEnv(name, value = "")
		env = ENV[name]

		if env
			return env.strip()
		else
			return value.strip()
		end
	end
	
	def XDHqSHRD::isREPLit?()
		return getEnv("ATK") == "REPLit"
	end
end
