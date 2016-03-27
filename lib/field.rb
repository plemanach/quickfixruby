module QuickFixRuby
  module Fix
    class Field
      
      def initialize tag, value
        @tag = tag
        @value = value
      end

      def value
        @value
      end

      def tag
        @tag
      end

    end
  end
end