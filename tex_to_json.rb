require 'rubygems'
require 'json'
require 'fast_blank'
require 'pry'
require 'awesome_print'

class String
    # Transform newlines and spaces into a single space
    def compact_spaces!
	gsub!(/\n+/," ")
	gsub!(/\s+/," ")
	return self
    end

    # Remove the surrounding brackets
    def remove_surrounding_brackets!
	sub!(/\A\s*{\s*/,"")
	sub!(/\s*}\s*\Z/,"")
	return self
    end
end



# Class that contains the text to analyze.
# Stores a string together with a pointer.
class Text

    extend Forwardable

    def_delegator :@content,:[]

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

    # Takes a string.
    def initialize(content)
	raise ArgumentError,"Expect a string" unless content.kind_of?(String)
	@content=content
	@pos=0
	@frozen=false
	@data={}
	@last_match=nil
    end

    def from_pos
	@content[@pos..-1]
    end

    # Check if what is after the pointer's position is blank
    def blank_from_pos?
	# The string @content[@pos..-1] may be nil, which justify the #to_s
	@content[@pos..-1].to_s.blank?
    end
end


# Class that contains text with the TeX format (inherits from Text)
class TeXText < Text

    TexLineComment=/\A%/ # the whole line is commented
    TeXComment=/(?<!\\)%/

    # remove the comments of the tex file
    def uncomment! 
	raise "Cannot change a frozen text." if @frozen
	@content=@content.each_line.each_with_object([]) do |line,new_content|
	    line.chomp! # remove the newline if any
	    m=line.match(TexLineComment) # check if the whole line is commented
	    next unless m.nil? # read the next line if the whole line is commented
	    m=line.match(TeXComment) # match comment if any
	    new_content << (m.nil? ? line : m.pre_match)  # keep only the pre-match
	end.join("\n")
	return self
    end

    # Parse a success story
    # It proceed in two passes: first the metadata, then the setup.
    def parse
	@pos=0 # rewind
	MetaDataParser.parse(self)
	@pos=0 # rewind
	while SetupParser.parse(self) do end
	return self
    end

end

# Generic class for parsing a part of a text
class ObjectParser 

    def self.parse(content,regexp)
	if regexp === content.from_pos then 
	    content.last_match=m=Regexp.last_match # store the match
	    content.pos+=m.end(0) # update the pointer position at the end of the matched string
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
	    # push the content, exclude nesting brackets
	    keysvalues=content[start..content.pos].compact_spaces!.remove_surrounding_brackets!
	    content.data[:metadata]={}
	    # parse the key-values pairs
	    KeysValuesParser.parse(TeXText.new(keysvalues),content.data[:metadata]) 
	    return true
	else
	    raise "Non nested parenthesis while parsing MetaData."
	end
    end
end

# There could be several Setup variables
class SetupParser < ObjectParser

    # Regular expression to detect \SetupXyz
    Regexp_setup=/\\(Setup(\p{Lu}\p{L}*)?){/

    def self.parse(content)
	# Detect a Setup. Unlike metadata, this command may be used
	# several times.
	return false unless super(content,Regexp_setup)
	# create the key (the name of a setup), a symbol in lowercase.
	key=content.last_match[1].downcase.to_sym 
	content.pos-=1 # inject the {
	start=content.pos
	if GroupParser.parse(content) then 
	    # create a new key if it does not exists
	    content.data[key]={} unless content.data.has_key?(key) 
	    # push the content, exclude nesting brackets
	    keysvalues=content[start...content.pos].compact_spaces!.remove_surrounding_brackets! 
	    obj={}
	    KeysValuesParser.parse(TeXText.new(keysvalues),obj)
	    content.data[key].merge!(obj) # merge with the values already found 
	    return true
	else
	    raise "Non nested brackets while parsing Setup."
	end
    end
end

# Detection of change of directory
class KeyValueParser < ObjectParser
    # @param [TeXText] content
    # @param [Hash] object for storing keys/values
    def self.parse(content,object={})
	if %r{\s*(\w*?)\s*=\s*} === content.from_pos then 
	    m=Regexp.last_match # store the match
	    key=m[1].to_sym # get the key as a symbol
	    content.pos+=m.end(0) # update the pointer position after the end of the match
	    i=start=content.pos # store the pointer's position
	    # Iterate over the characters to check for end of string, a comma or an opening bracket
	    while true do 
		if content[i].nil? then # at end of the string, return the whole content
		    # this may be an empty string,
		    # the #to_s is for transforming a nil into an empty string
		    object[key]=content[start..i].to_s.remove_surrounding_brackets! 
		    content.pos=i # set the new position
		    return true
		elsif content[i]=="," then
		    # extract the value, do not include the comma
		    object[key]=content[start...i].remove_surrounding_brackets! 
		    content.pos=i+1 # skip the comma
		    return true
		elsif content[i]=="{" then 
		    content.pos=i
		    # find balanced brackets, the pointer position is advanced.
		    GroupParser.parse(content) 
		    i=content.pos # after the paired bracket
		else
		    i+=1 # increase the pointer
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
	raise "Unexpected content while parsing keys-values: %s" %[content.from_pos] unless content.blank_from_pos?
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

# Read the content of the files
data={}
filename=nil
ARGF.each_line do |line|
    if filename!=ARGF.filename then 
      filename=ARGF.filename 
      data[filename]=""
    end
    data[filename] << line
end

# Deal with each file
data.each_pair do |k,v|
    data[k]=TeXText.new(v).uncomment!.parse
end

result={}
data.each_key do |key|
    result[key] = data[key].data
    #result[key][:setup]=result[key][:setup].inject({},&:merge) # merge all the hash
end


File.open("stories.json","w") do |file|
    file.puts result.to_json
end

# https://stackoverflow.com/questions/9647997/converting-a-nested-hash-into-a-flat-hash
def flat_hash(h,f=[],g={})
   return g.update({ f=>h }) unless h.is_a? Hash
   h.each { |k,r| flat_hash(r,f+[k],g) }
   g
end

# Flatten the hash for table generation
table=result.to_a.inject([]) do |obj,h| # h contains an array with 2 elements. The first is the key
    h= flat_hash({:id=>h[0]}.merge(h[1])) # add the key as id and merge with the hash
    # Transform the keys from arrays to string
    obj << h.to_a.inject({}) do |obj,content|
	obj.update(content.first.join("_")=>content.last)
    end
end

table={records:table} # embedd into a table, for adding metadata if needed

File.open("stories_table.json","w") do |file|
    file.puts table.to_json
end



#binding.pry
