require 'parsefailure'
require 'fixmessage'
require 'field'

include QuickFixRuby::Fix

module QuickFixRuby  
  module Fix
    class Parser

   
      def parse str

      	errors    = []
        msg_type  = str.match(/^8\=[^\x01]+\x019\=[^\x01]+\x0135\=([^\x01]+)\x01/)

        unless str.match(/^8\=[^\x01]+\x019\=[^\x01]+\x0135\=[^\x01]+\x01.+10\=[^\x01]+\x01/)
          ParseFailure.new("Malformed message <#{str}>")
        else
   
          fields = []

          str.split("\x01").each{ 
           |field| 
           fiedArray = field.split('=')
           fields << Field.new(fiedArray[0].to_i, fiedArray[1])
          }

          #klass = MessageClassMapping.get(msg_type[1])

          #unless klass
          #  errors << "Unknown message type <#{msg_type[1]}>"
          #end

          # Check message length
          length = str.gsub(/10\=[^\x01]+\x01$/, '').gsub(/^8\=[^\x01]+\x019\=([^\x01]+)\x01/, '').length
          if length != $1.to_i
            errors << "Incorrect body length"
          end

          # Check checksum
          checksum = str.match(/10\=([^\x01]+)\x01/)[1]

          total = 0
          str.gsub(/10\=[^\x01]+\x01/, '').each_char do |i| total += i.ord end

          expected = ('%03d' % (total % 256))
          if checksum != expected
            errors << "Incorrect checksum, expected <#{expected}>, got <#{checksum}>"
          end

          if errors.empty?
            msg = FixMessage.new(fields)
          else
            ParseFailure.new(errors)
          end
        end 
      end
        
    end
  end
end