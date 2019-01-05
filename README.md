# *Ruby* version of the *Atlas* toolkit

![Ruby logo](https://q37.info/download/assets/Ruby.png "Ruby")


The [*Atlas* toolkit](https://atlastk.org/) is a library dedicated to the handling of web interfaces.

## *Hello, World!*

Here's how a [*Hello, World!*](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) type application made with the *Atlas* toolkit looks like:

![Little demonstration](http://q37.info/download/assets/Hello.gif "A basic example")

For a live demonstration: <http://q37.info/runkit/Hello>.

Source code:

```ruby
require 'Atlas'

head = 
<<~HEREDOC
<title>"Hello, World !" example</title>
<link rel="icon" type="image/png" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAMFBMVEUEAvyEhsxERuS8urQsKuycnsRkYtzc2qwUFvRUVtysrrx0ctTs6qTMyrSUksQ0NuyciPBdAAABHklEQVR42mNgwAa8zlxjDd2A4POfOXPmzZkFCAH2M8fNzyALzDlzg2ENssCbMwkMOsgCa858YOjBKxBzRoHhD7LAHiBH5swCT9HQ6A9ggZ4zp7YCrV0DdM6pBpAAG5Blc2aBDZA68wCsZPuZU0BDH07xvHOmAGKKvgMP2NA/Zw7ADIYJXGDgLQeBBSCBFu0aoAPYQUadMQAJAE29zwAVWMCWpgB08ZnDQGsbGhpsgCqBQHNfzRkDEIPlzFmo0T5nzoMovjPHoAK8Zw5BnA5yDosDSAVYQOYMKIDZzkoDzagAsjhqzjRAfXTmzAQgi/vMQZA6pjtAvhEk0E+ATWRRm6YBZuScCUCNN5szH1D4TGdOoSrggtiNAH3vBBjwAQCglIrSZkf1MQAAAABJRU5ErkJggg==" />
<style type="text/css">
 html, body {height: 100%; padding: 0; margin: 0;}
 .vcenter-out, .hcenter {display: table;  height: 100%;  margin: auto;}
 .vcenter-in {display: table-cell; vertical-align: middle;}
</style>
HEREDOC


$html =
<<~HEREDOC
<div class="vcenter-out">
 <div class="vcenter-in">
  <fieldset>
   <label>Name:</label>
   <input id="input" maxlength="20" placeholder="Enter your name here" type="text" data-xdh-onevent="input|Typing" />
   <button data-xdh-onevent="Clear">Clear</button>
   <hr />
   <h1>
    <span>Hello </span>
    <span style="font-style: italic;" id="name"></span>
    <span>!</span>
   </h1>
  </fieldset>
 </div>
</div>
HEREDOC

def acConnect( hello, dom, id)
  dom.setLayout("", $html)
  dom.focus("input")
end

callbacks = {
  "" => method(:acConnect),
  "Typing" => -> (userObject,dom, id) { dom.setContent("name", dom.getContent(id))},
  "Clear" => -> (userObject,dom, id) { if dom.confirm?("Are you sure?") then dom.setContents({"input" => "", "name" => "" }) end }
 }

Atlas.launch(callbacks,-> () {}, head)
```

## *TodoMVC*

And here's how the *Atlas* toolkit version of the [*TodoMVC*](http://todomvc.com/) application looks like:

![TodoMVC](http://q37.info/download/TodoMVC.gif "The TodoMVC application made with the Atlas toolkit")

For a live demonstration: <http://q37.info/runkit/TodoMVC>.

## Content of the repository

The `Atlas` directory contains the *Ruby* source code of the *Atlas* toolkit, which is not needed to run the examples.

All other directories are examples.

To run an example, launch `ruby -IAtlas <Name>/main.rb`, where `<Name>` is the name of the example (`Blank`, `Chatroom`…).

The *Atlas* toolkit is also available for:

- *Java*: <http://github.com/epeios-q37/atlas-java>
- *Node.js*: <http://github.com/epeios-q37/atlas-node>
- *PHP*: <http://github.com/epeios-q37/atlas-php>
- *Python*: <http://github.com/epeios-q37/atlas-python>

For more information about the *Atlas* toolkit, go to <http://atlastk.org/>.