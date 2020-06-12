# *Ruby* version of the *Atlas* toolkit

![For Ruby](https://q37.info/download/assets/Ruby.png "Ruby logo")

[![Run on Repl.it](https://repl.it/badge/github/epeios-q37/atlas-)](https://q37.info/s/9thdtmjg)
[![Version 0.11](https://img.shields.io/static/v1.svg?&color=90b4ed&label=Version&message=0.11)](http://github.com/epeios-q37/atlas-ruby/)
[![Stars](https://img.shields.io/github/stars/epeios-q37/atlas-ruby.svg?style=social)](https://github.com/epeios-q37/atlas-ruby/stargazers)
[![license: MIT](https://img.shields.io/github/license/epeios-q37/atlas-ruby?color=yellow)](https://github.com/epeios-q37/atlas-ruby/blob/master/LICENSE)
[![Homepage](https://img.shields.io/static/v1?label=homepage&message=atlastk.org&color=ff69b4)](https://atlastk.org)


*NOTA*: this toolkit is also available for:

- *Java*: <https://github.com/epeios-q37/atlas-java>
- *Node.js*: <https://github.com/epeios-q37/atlas-node>
- *Perl*: <https://github.com/epeios-q37/atlas-perl>
- *Python*: <https://github.com/epeios-q37/atlas-python>

---

With the [*Atlas* toolkit](http://atlastk.org/), it has never been easier to create your own modern web application ([*SPA*](https://q37.info/s/7sbmxd3j)):
- no *Javascript* to write; only *HTML* and *Ruby*,
- no [front and back end architecture](https://q37.info/s/px7hhztd) to bother with,
- no [web server](https://q37.info/s/n3hpwsht) (*Apache*, *Nginx*…) to install,

and all this only with the help of a library of about 35 KB.

With the *Atlas* toolkit, your applications will be accessible from the entire internet on laptops, smartphones, tablets…, and this without having to deploy them on a remote server or to open an incoming port on your internet box. All you need is a local computer with a simple internet connection. 

The *Atlas* toolkit is also the fastest and easiest way to add a [graphical user interface](https://q37.info/s/hw9n3pjs) to all your programs.


## Live demonstrations

Before diving into source code, you can have a look on some live demonstrations, like this *Atlas* toolkit version of the [*TodoMVC*](http://todomvc.com/) application:

![TodoMVC](https://q37.info/download/TodoMVC.gif "The TodoMVC application made with the Atlas toolkit")

To see all the live demonstrations, simply go [here](https://q37.info/s/9thdtmjg), click on the green `run` button, select the demonstration you want to see, and then click (or scan with your smartphone) the then displayed [QR code](https://q37.info/s/3pktvrj7).


## *Hello, World!*

Here's how the [*Hello, World!*](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) program made with the *Atlas* toolkit looks like:

![Little demonstration](https://q37.info/download/assets/Hello.gif "A basic example")

This example is part of the live demonstrations above, but you can launch it on your computer:

- `git clone https://github.com/epeios-q37/atlas-ruby`
- `cd atlas-ruby`
- `ruby -IAtlas Hello/Hello.rb`

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

## Content of the repository

The `Atlas` directory contains the *Ruby* source code of the *Atlas* toolkit, which is not needed to run the examples.

All other directories are examples.

To run an example, launch `ruby -IAtlas <Name>/main.rb`, where `<Name>` is the name of the example (`Blank`, `Chatroom`…).

