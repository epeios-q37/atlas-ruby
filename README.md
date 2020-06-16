# *Ruby* version of the *Atlas* toolkit

![For Ruby](https://q37.info/download/assets/Ruby.png "Ruby logo")

[![Run on Repl.it](https://repl.it/badge/github/epeios-q37/atlas-ruby)](https://q37.info/s/9thdtmjg)
[![Version 0.11](https://img.shields.io/static/v1.svg?&color=90b4ed&label=Version&message=0.11)](http://github.com/epeios-q37/atlas-ruby/)
[![Stars](https://img.shields.io/github/stars/epeios-q37/atlas-ruby.svg?style=social)](https://github.com/epeios-q37/atlas-ruby/stargazers)
[![license: MIT](https://img.shields.io/github/license/epeios-q37/atlas-ruby?color=yellow)](https://github.com/epeios-q37/atlas-ruby/blob/master/LICENSE)
[![Homepage](https://img.shields.io/static/v1?label=homepage&message=atlastk.org&color=ff69b4)](https://atlastk.org)




> *This toolkit is available for:*
> - *Java*: <http://github.com/epeios-q37/atlas-java>
> - *Node.js*: <http://github.com/epeios-q37/atlas-node>
> - *Perl*: <http://github.com/epeios-q37/atlas-perl>
> - *Python*: <http://github.com/epeios-q37/atlas-python>
> - *Ruby*: <http://github.com/epeios-q37/atlas-ruby>



---

## Straight to the point: the [*Hello, World!*](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) program

### Source code

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

### Result

[![Little demonstration](https://q37.info/download/assets/Hello.gif "A basic example")](https://q37.info/s/9thdtmjg)

### Try it yourself now

#### Online, with nothing to install

Thanks to [Replit](https://q37.info/s/mxmgq3qm), an [online IDE](https://q37.info/s/zzkzbdw7), you can write and run programs using the *Atlas* toolkit directly in your web browser, without having to install *Ruby* on your computer.

To see some examples, like the following [*TodoMVC*](http://todomvc.com/) application or the above [*Hello, World!*](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) program, simply:
-  go [here](https://q37.info/s/9thdtmjg) (or click on the [![Run on Repl.it](https://repl.it/badge/github/epeios-q37/atlas-ruby)](https://q37.info/s/9thdtmjg) badge at the top of this page),
-  click on the green `run` button,
-  select the demonstration you want to see,
-  click (or scan with your smartphone) the then displayed [QR code](https://q37.info/s/3pktvrj7).

[![TodoMVC](https://q37.info/download/TodoMVC.gif "The TodoMVC application made with the Atlas toolkit")](https://q37.info/s/9thdtmjg)

#### With *Ruby* on your computer

```
git clone https://github.com/epeios-q37/atlas-ruby
cd atlas-ruby/examples
ruby -I../atlastk Hello/Hello.rb
```

## Your turn

If you want to:

- take your code to the next level, from [CLI](https://q37.info/s/cnh9nrw9) to [GUI](https://q37.info/s/hw9n3pjs),
- teach your students to program a GUI, 
- impress your teacher with a blowing GUI,
- easily share your programs with all you family and friends,

then you found the right toolkit.

With the [*Atlas* toolkit](http://atlastk.org/), writing modern web applications ([*SPA*](https://q37.info/s/7sbmxd3j)) has never been this easy:
- no *JavaScript* to write; only *HTML* and *Ruby*,
- no [front and back end architecture](https://q37.info/s/px7hhztd) to bother with,
- no [web server](https://q37.info/s/n3hpwsht) (*Apache*, *Nginx*…) to install,
- no need to deploy your application on a remote server,
- no incoming port to open on your internet box.

The *Atlas* toolkit is written in pure *Ruby*, with no native code and no dependencies, allowing the *Atlas* toolkit to be used on all environments where *Ruby* is available. 

Simply by running them on a local computer with a simple internet connexion, applications using the *Atlas* toolkit will be accessible from the entire internet on laptops, smartphones, tablets…

## Content of the repository

The `Atlas` directory contains the *Ruby* source code of the *Atlas* toolkit, which is not needed to run the examples.

The `examples `directory contains some examples.

To run an example, launch, from the `examples` directory, `ruby -I../atlastk <Name>/main.rb`, where `<Name>` is the name of the example (`Blank`, `Chatroom`…).