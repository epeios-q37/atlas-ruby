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

head = 
<<~HEREDOC
<title>"Hello, World !" example</title>
<link rel="icon" type="image/png" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAMFBMVEUEAvyEhsxERuS8urQsKuycnsRkYtzc2qwUFvRUVtysrrx0ctTs6qTMyrSUksQ0NuyciPBdAAABHklEQVR42mNgwAa8zlxjDd2A4POfOXPmzZkFCAH2M8fNzyALzDlzg2ENssCbMwkMOsgCa858YOjBKxBzRoHhD7LAHiBH5swCT9HQ6A9ggZ4zp7YCrV0DdM6pBpAAG5Blc2aBDZA68wCsZPuZU0BDH07xvHOmAGKKvgMP2NA/Zw7ADIYJXGDgLQeBBSCBFu0aoAPYQUadMQAJAE29zwAVWMCWpgB08ZnDQGsbGhpsgCqBQHNfzRkDEIPlzFmo0T5nzoMovjPHoAK8Zw5BnA5yDosDSAVYQOYMKIDZzkoDzagAsjhqzjRAfXTmzAQgi/vMQZA6pjtAvhEk0E+ATWRRm6YBZuScCUCNN5szH1D4TGdOoSrggtiNAH3vBBjwAQCglIrSZkf1MQAAAABJRU5ErkJggg==" />
HEREDOC

$body =
<<~HEREDOC
<div style="display: table; margin: 50px auto auto auto;">
	<fieldset>
		<input id="input" maxlength="20" placeholder="Enter a name here" type="text"
		       data-xdh-onevent="Submit" value="World"/>
		<div style="display: flex; justify-content: space-around; margin: 5px auto auto auto;">
			<button data-xdh-onevent="Submit">Submit</button>
			<button data-xdh-onevent="Clear">Clear</button>
		</div>
	</fieldset>
</div>
HEREDOC

def acConnect(userObject, dom)
	dom.inner("", $body)
	dom.focus("input")
end

def acSubmit(userObject, dom)
	dom.alert("Hello, " + dom.getValue("input") + "!")
	dom.focus("input")
end

def acClear(userObject, dom)
	if dom.confirm?("Are you sure?")
		dom.setValue("input", "")
	end
	dom.focus("input")
end

callbacks = {
	"" => method(:acConnect),  # This key is the action label dor a new connection.
	"Submit" => method(:acSubmit),
	"Clear" => method(:acClear),
}

Atlas.launch(callbacks,-> () {}, head)
