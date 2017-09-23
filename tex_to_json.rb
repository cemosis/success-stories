require 'rubygems'
require 'json'
require 'fast_blank'
require 'pry'
require 'awesome_print'


# Class that contains the text to analyze
class Text

    # content contains the text
    attr_reader :content
    # pos contains the pointer's position
    attr_accessor :pos
    # frozen if the content is allows to change or not
    attr_accessor :frozen

    def initialize(content)
	raise ArgumentError,"Expect a string" unless content.kind_of?(String)
	@content=content
	@pos=0
	@frozen=false
    end

    def [](value)
	@content[value]
    end
end


# Class that contains text with the TeX format (inherits from Text)
class TeXText < Text

    TexLineComment=/\A%/ # the whole line is commented
    TeXComment=/(?<!\\)%/

    # remove the comments
    def uncomment! 
	raise "Cannot change a frozen text" if @freeze
	new_content=[] # will accumulate the new lines
	@content.each_line do |line|
	    line.chomp! # remove the newline if any
	    m=line.match(TexLineComment) # check if the whole line is commented
	    next unless m.nil? # read the next line if the whole line is commented
	    m=line.match(TeXComment) # match comment if any
	    new_content << (m.nil? ? line : line.pre_match)  # keep only the pre-match
	end
	@content=new_content.join("\n") # write the new content
	return self
    end
end

# Generic class for parsing a part of a text
class ObjectParser 

    def self.parse(content,regexp)
	if regexp === content.content[content.pos..-1] then 
	    m=Regexp.last_match # store the match
	    content.pos+=m.end(0) # update the pointer position at the end of the string
	    return true
	else 
	    return false
	end
    end
end

class MetaData < ObjectParser

    Regexp_md=/\\MetaData{/

    def self.parse(content)
	super(content,Regexp_md)
    end
end

class Group < ObjectParser
    Regexp_group = %r{
  (?<re>
    \(
      (?:
        (?> [^()]+ )
        |
        \g<re>
      )*
    \)
  )
}x
    
    def self.parse(content)
	super(content,Regexp_group)
    end

    def self.re
	Regexp_group
    end
end

content=TeXText.new(File.read("m4se/template.tex")).uncomment!

#MetaData.parse(content)



binding.pry
