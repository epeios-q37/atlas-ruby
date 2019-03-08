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

def acConnect(userObject, dom, id)
	dom.setLayout("", $body)
	dom.focus("input")
end

def acSubmit(userObject, dom, id)
	dom.alert("Hello, " + dom.getContent("input") + "!")
	dom.focus("input")
end

def acClear(userObject, dom, id)
	if dom.confirm?("Are you sure?")
		dom.setContent("input", "")
	end
	dom.focus("input")
end

callbacks = {
	"" => method(:acConnect),  # This key is the action label dor a new connection.
	"Submit" => method(:acSubmit),
	"Clear" => method(:acClear),
}

Atlas.launch(callbacks,-> () {}, head)
