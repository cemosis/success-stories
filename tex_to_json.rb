require 'rubygems'
require 'json'
require 'fast_blank'
require 'pry'
require 'awesome_print'

class String
    def compact_spaces!
	gsub!(/\n+/," ")
	gsub!(/\s+/," ")
	return self
    end

    def remove_surrounding_brackets!
	sub!(/\A{/,"")
	sub!(/}\Z/,"")
	strip!
	return self
    end

    def to_blank_if_nil
	return self
    end
end

class NilClass
    def to_blank_if_nil
	return ""
    end
end


# Class that contains the text to analyze
class Text

    # content contains the text
    attr_reader :content
    # pos contains the pointer's position
    attr_accessor :pos
    # frozen if the content is allows to change or not
    attr_accessor :frozen
    # data containts the parsed data
    attr_accessor :data
    # contains the last match (nil or [MatchData])
    attr_accessor :last_match

    def initialize(content)
	raise ArgumentError,"Expect a string" unless content.kind_of?(String)
	@content=content
	@pos=0
	@frozen=false
	@data={}
	@last_match=nil
    end

    def [](value)
	@content[value]
    end

    def from_pos
	@content[@pos..-1]
    end

    def blank_from_pos?
	@content[@pos..-1].nil? || @content[@pos..-1].blank?
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
	if regexp === content.from_pos then 
	    content.last_match=m=Regexp.last_match # store the match
	    content.pos+=m.end(0) # update the pointer position at the end of the string
	    return true
	else 
	    return false
	end
    end
end


# Parser for the metadata
class MetaDataParser < ObjectParser

    Regexp_md=/\\MetaData{/

    def self.parse(content)
	# detect a Metadata
	return false unless super(content,Regexp_md)
	content.pos-=1 # inject the {
	start=content.pos
	if GroupParser.parse(content) then 
	    content.data[:metadata]=content[start..content.pos].compact_spaces!.remove_surrounding_brackets! # push the content, exclude nesting brackets
	    return true
	else
	    raise "Non nested parenthesis while parsing MetaData."
	end
    end
end

# There could be several Setup variables
class SetupParser < ObjectParser
    Regexp_setup=/\\(Setup(\p{Lu}\p{L}*)?){/

    def self.parse(content)
	# detect a Setup
	return false unless super(content,Regexp_setup)
	key=content.last_match[1].downcase.to_sym # create the key, a symbol in lowercase
	content.pos-=1 # inject the {
	start=content.pos
	if GroupParser.parse(content) then 
	    content.data[key]=[] unless content.data.has_key?(key) # create a new key if it does not exists
	    keysvalues=content[start..content.pos].compact_spaces!.remove_surrounding_brackets! # push the content, exclude nesting brackets
	    obj={}
	    KeysValuesParser.parse(TeXText.new(keysvalues),obj)
	    content.data[key] << obj
	    return true
	else
	    raise "Non nested brackets while parsing Setup."
	end
    end
end

# Detection of change of directory
class KeyValueParser < ObjectParser
    def self.parse(content,object={})
	ap content[content.pos..-1]
	if %r{\s*(\w*?)\s*=\s*} === content[content.pos..-1] then 
	    m=Regexp.last_match # store the match
	    key=m[1] # get the key
	    content.pos+=m.end(0) # update the pointer position after the end of the match
	    i=start=content.pos
	    while true do 
		if content[i].nil? then # at end of the string
		    object[key]=content[start..i].to_blank_if_nil.remove_surrounding_brackets! # this may be an empty string
		    content.pos=i
		    return true
		elsif content[i]=="," then
		    object[key]=content[start...i].remove_surrounding_brackets! # extract the value, do not include the comma
		    content.pos=i+1 # skip the comma
		    return true
		elsif content[i]=="{" then 
		    start=content.pos=i
		    GroupParser.parse(content) # find balanced brackets
		    i=content.pos # after the paired bracket
		else
		    i+=1 # increase the pointer
		    ap content[i]
		end
	    end
	else
	    return false
	end
    end
end

# Detection of change of directory
class KeysValuesParser < ObjectParser
    def self.parse(content,object={})
	while KeyValueParser.parse(content,object) do end
	raise "Unexpected content while parsing keys-values: %s" %[content[content.pos..-1]] unless content.blank_from_pos?
	return true
    end
end

# Parser for detecting balanced groups
class GroupParser < ObjectParser
    # see https://stackoverflow.com/questions/6331065/matching-balanced-parenthesis-in-ruby-using-recursive-regular-expressions-like-p
    Regexp_group = %r{
  (?<re>
   \s*{
      (?:
        (?> [^{}]+ )
        |
        \g<re>
      )*
  }
  )
}x
    
    def self.parse(content)
	super(content,Regexp_group)
    end

end

content=TeXText.new(File.read("m4se/template.tex")).uncomment!








MetaDataParser.parse(content)
content.pos=0
while SetupParser.parse(content) do end

#ap obj




binding.pry
