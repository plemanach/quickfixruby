
module QuickFixRuby  
  module Fix
    class Buffer

      def initialize
        @buffer = ''
      end

      def add_to_stream data
          @buffer << data
      end

      def read_message

        if @buffer.length < 2
          return nil
        end

        pos = @buffer.index('8=')

        if pos == nil
          return nil
        end

        @buffer = @buffer[pos,@buffer.length - pos]


        res = extract_length

        if res[0] == false
          #We clean the buffer if the length is not correct
          @buffer = ''
          return nil
        end

        pos += res[1]

        if (@buffer.length < pos)
          return nil
        end

        pos = @buffer.index("\x01" + "10=", pos - 1)

        if (nil == pos)
            return nil
        end

        pos += 4

        pos = @buffer.index("\x01", pos);
        if (nil == pos)
            return nil
        end

        pos += 1;

        msg = @buffer[0, pos]
        @buffer = @buffer[pos, (@buffer.length - pos)]
        return msg

      end

      def extract_length
        length = 0
        pos = 0

        res =[false, length, pos]

        if @buffer.length < 1
          return res
        end

        startPos = @buffer.index("\x01" + "9=", 0)

        if startPos == nil
          return res
        end

        startPos += 3

        endPos = @buffer.index("\x01", startPos)

        if endPos == nil
          return res
        end

        strLength =  @buffer[startPos, (endPos - startPos)]

        length = strLength.to_i

        unless length <= 0
          pos = endPos + 1
          res[0] = true
          res[1] = length
          res[2] = pos
        end

        return res
       
      end

    end
  end
end