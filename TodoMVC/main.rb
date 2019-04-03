# encoding: UTF-8 
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
		xml.setAttribute("id", id)
		xml.setAttribute("completed", if todo['completed'] then "true" else "false" end)
		xml.setValue(todo['label'])
		xml.popTag()
	end

	private def displayCount(dom, count)
		text = ""

		if count == 1
			text = "1 item left"
		elsif count != 0
			text = count.to_s() + " items left"
		end

		dom.setContent("Count", text)
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

		dom.setLayoutXSL("Todos", xml, "Todos.xsl")
		handleCount(dom)
	end

	private def submitNew(dom)
		content = dom.getContent("Input").strip()
		dom.setContent("Input", "")

		if !content.empty?()
			@todos.unshift({'label' => content, 'completed' => false})
			displayTodos(dom)
		end
	end

	private def submitModification(dom)
		index = @index
		@index = -1

		content = dom.getContent("Input." + index.to_s()).strip()
		dom.setContent("Input." + index.to_s(), "")

		if !content.empty?()
			@todos[index]['label'] = content

			dom.setContent("Label." + index.to_s(), content)

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
		dom.setLayout("", readAsset("Main.html"))
		dom.focus("Input")
		displayTodos(dom)
		dom.disableElements(["HideActive", "HideCompleted"])
	end

	def acDestroy(dom, id)
		@todos.delete_at(dom.getContent(id).to_i())
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
		content = dom.getContent(id)
		@index = content.to_i()
	
		dom.addClasses({"View." + content => "hide", id => "editing"})
		dom.setContent("Input." + content, @todos[@index]['label'])
		dom.focus("Input." + content)
	end

	def acCancel(dom, id)
		index = @index.to_s()
		@index = -1
	
		dom.setContent("Input." + index, "")
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

Atlas.launch(callbacks, -> () {TodoMVC.new()}, readAsset("HeadDEMO.html"), "TodoMVC")
