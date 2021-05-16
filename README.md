# *Ruby* version of the *Atlas* toolkit

[![Run on Repl.it](https://q37.info/s/kpm7xhfm.png)](https://q37.info/s/9thdtmjg)  [![About online demonstrations](https://img.shields.io/badge/about-online%20demonstrations-informational)](https://q37.info/s/sssznrb4)

[![Version 0.12](https://img.shields.io/static/v1.svg?&color=90b4ed&label=Version&message=0.12&style=for-the-badge)](http://github.com/epeios-q37/atlas-ruby/)
[![license: MIT](https://img.shields.io/github/license/epeios-q37/atlas-ruby?color=yellow&style=for-the-badge)](https://github.com/epeios-q37/atlas-ruby/blob/master/LICENSE)
[![Documentation](https://img.shields.io/static/v1?label=documentation&message=atlastk.org&color=ff69b4&style=for-the-badge)](https://atlastk.org)  



> The [*Atlas* toolkit](https://atlastk.org) is available for:
> 
> | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Language | [*Git*](https://en.wikipedia.org/wiki/Git) repositories | Online démonstrations
> |-|-|-|:-:|
> | ![Java](https://q37.info/s/sgb9nq7x.svg) | [*Java*](https://q37.info/s/qtnkp9w4)  | [*Framagit*](https://framagit.org/epeios-q37/atlas-java) [*GitHub*](https://github.com/epeios-q37/atlas-java) | [![Run on Replit](https://q37.info/s/kpm7xhfm.png)](https://q37.info/s/3vwk3h3n) |
> | ![Node.js](https://q37.info/s/b9ctj4bb.svg) | [*Node.js*](https://q37.info/s/3d7hr733) | [*Framagit*](https://framagit.org/epeios-q37/atlas-node) [*GitHub*](https://github.com/epeios-q37/atlas-node) | [![Run on Replit](https://q37.info/s/kpm7xhfm.png)](https://q37.info/s/st7gccd4) |
> | ![Perl](https://q37.info/s/v9qkzvhk.svg) | [*Perl*](https://q37.info/s/4nvmwjgg)  | [*Framagit*](https://framagit.org/epeios-q37/atlas-perl) [*GitHub*](https://github.com/epeios-q37/atlas-perl) | [![Run on Replit](https://q37.info/s/kpm7xhfm.png)](https://q37.info/s/h3h34zgq) |
> | ![Python](https://q37.info/s/t4s3p4rk.svg) | [*Python*](https://q37.info/s/pd7j9k4r)  | [*Framagit*](https://framagit.org/epeios-q37/atlas-python) [*GitHub*](https://github.com/epeios-q37/atlas-python) | [![Run on Replit](https://q37.info/s/kpm7xhfm.png)](https://q37.info/s/vwpsw73v) |
> | ![Ruby](https://q37.info/s/ngxztq4t.svg) | [*Ruby*](https://q37.info/s/gkfj3zpz)  | [*Framagit*](https://framagit.org/epeios-q37/atlas-ruby) [*GitHub*](https://github.com/epeios-q37/atlas-ruby) | [![Run on Replit](https://q37.info/s/kpm7xhfm.png)](https://q37.info/s/9thdtmjg) |




---

## A GUI with *Ruby* in a couple of minutes

Click the animation to see a screencast of programming this ["Hello, World!"](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program) with *Ruby* in a matter of minutes:

[![Building a GUI in with *Ruby* in less then 10 minutes](https://q37.info/s/qp4z37pg.gif)](https://q37.info/s/zgb4d9v3)

Same video on [*Peertube*](https://en.wikipedia.org/wiki/PeerTube): <https://q37.info/s/fj3trgds>.

Source code:

```ruby
require 'Atlas'
 
$BODY =
<<~HEREDOC
<fieldset>
 <input id="Input" data-xdh-onevent="Submit" value="World"/>
 <button data-xdh-onevent="Submit">Hello</button>
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

### See for yourself right now - it's quick and easy!

#### Online, with nothing to install

To run above "Hello, World!" program directly in your browser, as seen in corresponding video, follow this link: <https://replit.com/@AtlasTK/hello-ruby>.

Thanks to [*Replit*](https://q37.info/s/mxmgq3qm), an [online IDE](https://q37.info/s/zzkzbdw7), you can write and run programs using the *Atlas* toolkit directly in your web browser, without having to install *Ruby* on your computer [![About online demonstrations](https://img.shields.io/badge/about-online%20demonstrations-informational)](https://q37.info/s/sssznrb4).

To see more examples, like the following [*TodoMVC*](http://todomvc.com/), simply:
- go [here](https://q37.info/s/9thdtmjg) (also accessible with the [![Run on Repl.it](https://q37.info/s/kpm7xhfm.png)](https://q37.info/s/9thdtmjg) button at the top of this page),
- click on the green `run` button,
- choose the demonstration to launch,
- open the then displayed URL in a browser (should be clickable), 
- … and, as you wish, run your own tests directly in your browser, by modifying the code of the examples or by writing your own code.

[![TodoMVC](https://q37.info/download/TodoMVC.gif "The TodoMVC application made with the Atlas toolkit")](https://q37.info/s/9thdtmjg)

#### With *Ruby* on your computer

```shell
# You can replace 'github.com' with 'framagit.org'.
# DON'T copy/paste this and above line!
git clone https://github.com/epeios-q37/atlas-ruby
cd atlas-ruby/examples
ruby -I../atlastk Hello/Hello.rb
```



## Your turn

If you want to take your code to the next level, from [CLI](https://q37.info/s/cnh9nrw9) to [GUI](https://q37.info/s/hw9n3pjs), then you found the right toolkit.

With the [*Atlas* toolkit](http://atlastk.org/), you transform your programs in modern web applications ([*SPA*](https://q37.info/s/7sbmxd3j)) without the usual hassles:
- no *JavaScript* to write; only *HTML*(/*CSS*) and *Ruby*,
- no [front and back end architecture](https://q37.info/s/px7hhztd) to bother with,
- no [web server](https://q37.info/s/n3hpwsht) (*Apache*, *Nginx*…) to install,
- no need to deploy your application on a remote server,
- no incoming port to open on your internet box or routeur.

The *Atlas* toolkit is written in pure *Ruby*, with no native code and no dependencies, allowing the *Atlas* toolkit to be used on all environments where *Ruby* is available. 

And simply by running them on a local computer connected to internet, applications using the *Atlas* toolkit will be accessible from the entire internet on laptops, smartphones, tablets…

## Content of the repository

The `Atlas` directory contains the *Ruby* source code of the *Atlas* toolkit, which is not needed to run the examples.

The `examples `directory contains some examples.

To run an example, launch, from the `examples` directory, `ruby -I../atlastk <Name>/main.rb`, where `<Name>` is the name of the example (`Blank`, `Chatroom`…).
