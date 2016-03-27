require 'date'

module QuickFixRuby
  module Fix
    class FixMessage

      def initialize fields
        @fields = fields
      end

      def get_as_string tag
        field = lookup_field tag
        if field
          field.value
        end
      end

      def get_as_datetime tag
        field = lookup_field tag
        if field
          DateTime.parse(field.value)
        end
      end
       
      def lookup_field tag
        field = @fields.select {|f| f.tag == tag}.first
      end

    end
  end
end