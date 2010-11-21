require 'eventmachine'
require 'em/protocols/header_and_content'

class String
  alias :each :each_line
end

module Librevox
  class Response
    attr_accessor :headers, :content, :raw_content

    def initialize headers="", content=""
      self.headers = headers
      self.content = content
    end

    def headers= headers
      @headers = headers_2_hash(headers)
      @headers.each {|k,v| v.chomp! if v.is_a?(String)}
    end

    def content= content
      @raw_content = content
      @content = content.match(/:/) ? headers_2_hash(content) : content
      @content.each {|k,v| v.chomp! if v.is_a?(String)}
    end
    
    # If raw_content is a newline separated string with "+OK" as the last line, parse the lines into an array
    # of hashes [ {"column1" => value1, "col2" => value2 }, {...}, ...]
    def content_from_db
      lines = @raw_content.split("\n")
      result = []
      if lines.pop == "+OK" && lines.count > 0
        keys = lines.delete_at(0).split("|")
        lines.each do |line|
          hash = Hash.new
          values = line.split("|")
          keys.each do |key|
            hash.store(key.to_sym,values.delete_at(0))
          end
          result << hash
        end
      end
      result
    end

    def event?
      @content.is_a?(Hash) && @content.include?(:event_name)
    end

    def event
      @content[:event_name] if event?
    end

    def api_response?
      @headers[:content_type] == "api/response"
    end

    def command_reply?
      @headers[:content_type] == "command/reply"
    end

    private
    def headers_2_hash *args
      EM::Protocols::HeaderAndContentProtocol.headers_2_hash *args
    end
  end
end
