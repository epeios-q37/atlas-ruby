# *Ruby* version of the *Atlas* toolkit

![For Ruby](http://q37.info/download/assets/Ruby.png "Ruby logo")

![Version 0.7.1](https://img.shields.io/static/v1.svg?&color=90b4ed&label=Version&message=0.7.1 )

A fast and easy way to add a graphical user interface to your *Ruby* programs.

With the *Atlas* toolkit, you obtain hybrid programs. Like desktop applications, the same code can handle both [front and back ends](http://q37.info/s/px7hhztd), and, like web applications, the programs will be reachable from all over the internet.

## *Hello, World!*

Here's how a [*Hello, World!*](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) type program made with the *Atlas* toolkit looks like:

![Little demonstration](http://q37.info/download/assets/Hello.gif "A basic example")

- `git clone http://github.com/epeios-q37/atlas-ruby`
- `cd atlas-ruby`
- `ruby -IAtlas Hello/Hello.rb`

For a live demonstration: <http://q37.info/runkit/Hello>.

Source code:

```ruby
require 'Atlas'

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
 "" => method(:acConnect),  # This key is the action label for a new connection.
 "Submit" => method(:acSubmit),
 "Clear" => method(:acClear),
}

Atlas.launch(callbacks)
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