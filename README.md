<div align="center">

The *Atlas* toolkit is available for:

[![Java](https://s.q37.info/jrnv4mj4.svg)](https://github.com/epeios-q37/atlas-java) [![Node.js](https://s.q37.info/fh7v7kn9.svg)](https://github.com/epeios-q37/atlas-node) [![Perl](https://s.q37.info/hgnwnnn3.svg)](https://github.com/epeios-q37/atlas-perl) [![Python](https://s.q37.info/94937nbb.svg)](https://github.com/epeios-q37/atlas-python) [![Ruby](https://s.q37.info/zn4qrx9j.svg)](https://github.com/epeios-q37/atlas-ruby)

To see the *Atlas* toolkit in action:

[![Version 0.13](https://img.shields.io/static/v1.svg?&color=blue&labelColor=red&label=online&message=demonstrations&style=for-the-badge)](https://s.q37.info/sssznrb4)

</div>



# *Ruby* version of the *Atlas* toolkit

<div align="center">

[![Version 0.13](https://img.shields.io/static/v1.svg?&color=90b4ed&label=Version&message=0.13&style=for-the-badge)](http://github.com/epeios-q37/atlas-ruby/) [![license: MIT](https://img.shields.io/github/license/epeios-q37/atlas-ruby?color=yellow&style=for-the-badge)](https://github.com/epeios-q37/atlas-ruby/blob/master/LICENSE) [![Documentation](https://img.shields.io/static/v1?label=documentation&message=atlastk.org&color=ff69b4&style=for-the-badge)](https://atlastk.org) 

</div>



## A GUI with *Ruby* in a couple of minutes

Click the animation to see a screencast of programming this ["Hello, World!" program](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) with *Ruby* in a matter of minutes:

<div align="center">

[![Building a GUI in with *Ruby* in less then 10 minutes](https://s.q37.info/qp4z37pg.gif)](https://s.q37.info/zgb4d9v3)

</div>

Same video on [*Peertube*](https://en.wikipedia.org/wiki/PeerTube): <https://s.q37.info/fj3trgds>.

<details>
<summary>Click to see the corresponding source code</summary>

```ruby
require 'Atlas'
 
$BODY =
<<~HEREDOC
<fieldset>
 <input id="Input" xdh:onevent="Submit" value="World"/>
 <button xdh:onevent="Submit">Hello</button>
 <hr/>
 <fieldset>
  <output id="Output">Greetings displayed here!</output>
 </fieldset>
</fieldset>
HEREDOC
 
def acConnect(userObject, dom, id)
 dom.inner("", $BODY)
 dom.focus("Input")
end
 
def acSubmit(userObject, dom, id)
 name = dom.getValue("Input")
 dom.begin("Output", "<div>Hello, " + name + "!</div>")
 dom.setValue("Input", "")
 dom.focus("Input")
end
 
CALLBACKS = {
 "" => method(:acConnect),
 "Submit" => method(:acSubmit)
}
 
Atlas.launch(CALLBACKS)
```

</details>

### See for yourself right now - it's quick and easy!

```shell
# You can replace 'github.com' with 'framagit.org'.
# DON'T copy/paste this and above line!
git clone https://github.com/epeios-q37/atlas-ruby
cd atlas-ruby/examples
ruby -I../atlastk Hello/Hello.rb
```



## Your turn

If you want to take your code to the next level, from [CLI](https://s.q37.info/cnh9nrw9) to [GUI](https://s.q37.info/hw9n3pjs), then you found the right toolkit.

With the [*Atlas* toolkit](http://atlastk.org/), you transform your programs in modern web applications ([*SPA*](https://s.q37.info/7sbmxd3j)) without the usual hassles:
- no *JavaScript* to write; only *HTML*(/*CSS*) and *Ruby*,
- no [front and back end architecture](https://s.q37.info/px7hhztd) to bother with,
- no [web server](https://s.q37.info/n3hpwsht) (*Apache*, *Nginx*…) to install,
- no need to deploy your application on a remote server,
- no incoming port to open on your internet box or routeur.

The *Atlas* toolkit is written in pure *Ruby*, with no native code and no dependencies, allowing the *Atlas* toolkit to be used on all environments where *Ruby* is available. 

And simply by running them on a local computer connected to internet, applications using the *Atlas* toolkit will be accessible from the entire internet on laptops, smartphones, tablets…

## Content of the repository

The `Atlas` directory contains the *Ruby* source code of the *Atlas* toolkit, which is not needed to run the examples.

The `examples `directory contains some examples.

To run an example, launch, from the `examples` directory, `ruby -I../atlastk <Name>/main.rb`, where `<Name>` is the name of the example (`Blank`, `Chatroom`…).
