require 'rubygems'
require 'awesome_print'
require 'json'
require 'pastel'

desc "Create the JSON file"
task :go do 
    files = %w{m4se/template.tex po/template.tex pollen/template.tex safety_line/safety_line.tex sediment/template.tex sivibirpp/template.tex}
    ruby format("tex_to_json.rb %s",files.join(" "))
end

desc "Copy the sheets for creating the website"
task :copy_sheets do 
    data=JSON::parse(File.read("stories.json"))
    files=data.keys.map {|f| f.ext(".pdf")} # change the extension of the key
    files=data.to_a.inject([]) do |obj,e|
	# e.first is the key, which contains the name of the file
	# e.last contains the data
	obj << {:src =>e.first.ext(".pdf"),:to=> e.last["metadata"]["identifier"].ext(".pdf")} 
    end
    colorize=Pastel.new
    files.each do |f|
	puts format "Copy %s to www/source/sheets/%s",colorize.blue.bold(f[:src]),colorize.blue.bold(f[:to])
	FileUtils.cp(f[:src],format("www/source/sheets/%s",f[:to]))
    end
end
