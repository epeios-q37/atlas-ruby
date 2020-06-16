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

$viewModeElements = ["Pattern", "CreateButton", "DescriptionToggling", "ViewNotes"]

def readAsset(path)
	return Atlas::readAsset(path, "Notes")
end

def put(note, id, xml)
	xml.pushTag("Note")
	xml.putAttribute("id", id)

	note.each do |key,value|
		xml.putTagAndValue(key,value)
	end

	xml.popTag()
end

class Notes
	def initialize()
		@pattern=""
		@hideDescription = false
		@index = 0
		@notes = [
			{
				'title' => '',
				'description' => '',
			},
			{
				'title' => 'Improve design',
				'description' => "Tastes and colors… (aka «CSS aren't my cup of tea…»)",
			},
			{
				'title' => 'Fixing bugs',
				'description' => "There are bugs ? Really ?",
			},
			{
				'title' => 'Implement new functionalities',
				'description' => "Although it's almost perfect…, isn't it ?",
			},
		]
	end

	private def handleDescriptions(dom)
		if @hideDescriptions
			dom.disableElement("ViewDescriptions")
		else
			dom.enableElement("ViewDescriptions")
		end
	end

	private def displayList(dom)
		xml = Atlas.createXML("XDHTML")
		contents = {}

		xml.pushTag("Notes")

		index = 1

		while index < @notes.length()
			if @notes[index]['title'][0,@pattern.length()].downcase() == @pattern
				put(@notes[index], index, xml)
				contents["Description." + index.to_s()] = @notes[index]['description']
			end

			index += 1
		end

		dom.setLayoutXSL("Notes", xml, "Notes.xsl")
		dom.setContents(contents)
		dom.enableElements($viewModeElements)
	end

	private def view(dom)
		dom.enableElements($viewModeElements)
		dom.setContent("Edit." + @index.to_s(), "")
		@index = -1
	end

	def acConnect(dom, id)
		dom.setLayout("", readAsset("Main.html"))
		displayList(dom)
	end

	def acToggleDescriptions(dom, id)
		@hideDescriptions = dom.getContent(id) == "true"
		handleDescriptions(dom)
	end

	def acSearch(dom, id)
		@pattern = dom.getContent("Pattern").downcase()
		displayList(dom)
	end

	def acEdit(dom, id)
		index = dom.getContent(id)
		@index = index.to_i()
		note = @notes[@index]
		
		dom.setLayout("Edit." + index, readAsset( "Note.html") )
		dom.setContents({ "Title" => note['title'], "Description" => note['description'] })
		dom.disableElements($viewModeElements)
		dom.focus("Title")
	end	

	def acDelete(dom, id)
		if dom.confirm?("Are you sure you want to delete this entry ?")
			@notes.delete_at(dom.getContent(id).to_i())
			displayList(dom)	
		end
	end

	def acSubmit(dom, id)
		result = dom.getContents(["Title", "Description"])
		title = result["Title"].strip()
		description = result["Description"]
	
		if !title.empty?()
			@notes[@index] = { "title" => title, "description" => description }
	
			if @index == 0
				@notes.unshift( {'title' => '', 'description' => ''})
				displayList( dom )
			else
				dom.setContents( { "Title." + @index.to_s() => title, "Description." + @index.to_s() => description })
				view(dom)
			end
		else
			dom.alert("Title can not be empty !")
			dom.focus("Title")
		end
	end

	def acCancel(dom, id)
		note = @notes[@index]
	
		result = dom.getContents(["Title", "Description"])
		title = result["Title"].strip()
		description = result["Description"]
	
		if (title != note['title']) or (description != note['description'])
			if dom.confirm?("Are you sure you want to cancel your modifications ?")
				view( dom )
			end
		else
			view( dom )
		end
	end
end

callbacks = {
	"" => -> (notes, dom, id) {notes.acConnect(dom,id)},
	"ToggleDescriptions"  => -> (notes, dom, id) {notes.acToggleDescriptions(dom,id)},
	"Search" => -> (notes, dom, id) {notes.acSearch(dom,id)},
	"Edit" => -> (notes, dom, id) {notes.acEdit(dom,id)},
	"Delete" => -> (notes, dom, id) {notes.acDelete(dom,id)},
	"Submit" => -> (notes, dom, id) {notes.acSubmit(dom,id)},
	"Cancel" => -> (notes, dom, id) {notes.acCancel(dom,id)},
}

Atlas.launch(callbacks, -> () {Notes.new()}, readAsset("Head.html"), "Notes")
