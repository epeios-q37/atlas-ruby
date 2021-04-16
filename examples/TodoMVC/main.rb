# encoding: UTF-8 
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

def readAsset(path)
	return Atlas::readAsset(path, "TodoMVC")
end

class TodoMVC
	def initialize()
		@exclude = nil
		@index = -1
		@todos = []

		if false	# Set to 'True' for testing purpose.
			@todos.push({"label" => "Todo 1", "completed" => true })
			@todos.push({"label" => "Todo 2", "completed" => false })
		end
	end

	private def itemsLeft()
		count = 0
		index = 0
		length = @todos.length()

		while index < length
			if not @todos[index]['completed']
				count += 1
			end

			index += 1
		end

		return count
	end

	private def push(todo, id, xml)
		xml.pushTag("Todo")
		xml.putAttribute("id", id)
		xml.putAttribute("completed", if todo['completed'] then "true" else "false" end)
		xml.putValue(todo['label'])
		xml.popTag()
	end

	private def displayCount(dom, count)
		text = ""

		if count == 1
			text = "1 item left"
		elsif count != 0
			text = count.to_s() + " items left"
		end

		dom.setValue("Count", text)
	end

	private def handleCount(dom)
		count = itemsLeft()

		if count != @todos.length()
			dom.disableElement("HideClearCompleted")
		else
			dom.enableElement("HideClearCompleted")
		end

		displayCount(dom, count)
	end

	private def displayTodos(dom)
		index = 0
		length = @todos.length()
		xml = Atlas.createXML("XDHTML")

		xml.pushTag("Todos")

		while index < length
			todo = @todos[index]

			if (@exclude == nil) or (todo['completed'] != @exclude)
				push(todo, index, xml)
			end

			index += 1
		end

		xml.popTag()

		dom.inner("Todos", xml, "Todos.xsl")
		handleCount(dom)
	end

	private def submitNew(dom)
		content = dom.getValue("Input").strip()
		dom.setValue("Input", "")

		if !content.empty?()
			@todos.unshift({'label' => content, 'completed' => false})
			displayTodos(dom)
		end
	end

	private def submitModification(dom)
		index = @index
		@index = -1

		content = dom.getValue("Input." + index.to_s()).strip()
		dom.setValue("Input." + index.to_s(), "")

		if !content.empty?()
			@todos[index]['label'] = content

			dom.setValue("Label." + index.to_s(), content)

			dom.removeClasses({"View." + index.to_s() => "hide", "Todo." + index.to_s() => "editing"})
		else
			todos.pop(index)
			displayTodos(dom)
		end
	end

	def submit(dom, id)
		if @index == -1
			submitNew(dom)
		else
			submitModification(dom)
		end
	end

	def acConnect(dom, id)
		dom.inner("", readAsset("Main.html"))
		dom.focus("Input")
		displayTodos(dom)
		dom.disableElements(["HideActive", "HideCompleted"])
	end

	def acDestroy(dom, id)
		@todos.delete_at(dom.getMark(id).to_i())
		displayTodos(dom)
	end

	def acToggle(dom, id)
		index = id.to_i()
		@todos[index]['completed'] = !@todos[index]['completed']
	
		dom.toggleClass("Todo." + id, "completed")
		dom.toggleClass("Todo." + id, "active")
	
		handleCount(dom)
	end

	def acAll(dom, id)
		@exclude = nil
	
		dom.addClass("All", "selected")
		dom.removeClasses({"Active" => "selected", "Completed" => "selected"})
		dom.disableElements(["HideActive", "HideCompleted"])
	end
	
	def acActive(dom, id)
		@exclude = true
	
		dom.addClass("Active", "selected")
		dom.removeClasses({"All" => "selected", "Completed" => "selected"})
		dom.disableElement("HideActive")
		dom.enableElement("HideCompleted")
	end
	
	def acCompleted(dom, id)
		@exclude = false
	
		dom.addClass("Completed", "selected")
		dom.removeClasses({"All" => "selected", "Active" => "selected"})
		dom.disableElement("HideCompleted")
		dom.enableElement("HideActive")
	end

	def acClear(dom, id)
		index = @todos.length()
	
		while index != 0
			index -= 1
	
			if @todos[index]['completed']
				@todos.delete_at(index)
			end
		end
	
		displayTodos(dom)
	end

	def acEdit(dom, id)
		content = dom.getMark(id)
		@index = content.to_i()
	
		dom.addClasses({"View." + content => "hide", id => "editing"})
		dom.setValue("Input." + content, @todos[@index]['label'])
		dom.focus("Input." + content)
	end

	def acCancel(dom, id)
		index = @index.to_s()
		@index = -1
	
		dom.setValue("Input." + index, "")
		dom.removeClasses({"View." + index => "hide", "Todo." + index => "editing"})
	end
end

callbacks = {
	"" => -> (notes, dom, id) {notes.acConnect(dom,id)},
	"Submit" => -> (notes, dom, id) {notes.submit(dom,id)},
	"Destroy" => -> (notes, dom, id) {notes.acDestroy(dom,id)},
	"Toggle" => -> (notes, dom, id) {notes.acToggle(dom,id)},
	"All" => -> (notes, dom, id) {notes.acAll(dom,id)},
	"Active" => -> (notes, dom, id) {notes.acActive(dom,id)},
	"Completed" => -> (notes, dom, id) {notes.acCompleted(dom,id)},
	"Clear" => -> (notes, dom, id) {notes.acClear(dom,id)},
	"Edit" => -> (notes, dom, id) {notes.acEdit(dom,id)},
	"Cancel" => -> (notes, dom, id) {notes.acCancel(dom,id)},
}

Atlas.launch(callbacks, -> () {TodoMVC.new()}, readAsset("HeadFaaS.html"), "TodoMVC")
