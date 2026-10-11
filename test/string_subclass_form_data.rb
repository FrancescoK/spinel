# WEBrick::HTTPUtils::FormData as WEBrick 1.9.2 writes it: a String subclass
# whose [] and << fall back to String's through super, chained by an ivar.
CRLF = "\r\n"
module HTTPUtils
  def self.parse_header(raw); h = {}; raw.split(CRLF).each { |l| k, v = l.split(/:\s*/, 2); (h[k.downcase] ||= []) << v }; h; end
end
    class FormData < String
      EmptyRawHeader = [].freeze # :nodoc:
      EmptyHeader = {}.freeze # :nodoc:

      ##
      # The name of the form data part

      attr_accessor :name

      ##
      # The filename of the form data part

      attr_accessor :filename

      attr_accessor :next_data # :nodoc:
      protected :next_data

      ##
      # Creates a new FormData object.
      #
      # +args+ is an Array of form data entries.  One FormData will be created
      # for each entry.
      #
      # This is called by WEBrick::HTTPUtils.parse_form_data for you

      def initialize(*args)
        @name = @filename = @next_data = nil
        if args.empty?
          @raw_header = []
          @header = nil
          super("")
        else
          @raw_header = EmptyRawHeader
          @header = EmptyHeader
          super(args.shift)
          unless args.empty?
            @next_data = self.class.new(*args)
          end
        end
      end

      ##
      # Retrieves the header at the first entry in +key+

      def [](*key)
        begin
          @header[key[0].downcase].join(", ")
        rescue StandardError, NameError
          super
        end
      end

      ##
      # Adds +str+ to this FormData which may be the body, a header or a
      # header entry.
      #
      # This is called by WEBrick::HTTPUtils.parse_form_data for you

      def <<(str)
        if @header
          super
        elsif str == CRLF
          @header = HTTPUtils::parse_header(@raw_header.join)
          if cd = self['content-disposition']
            if /[ \t]+name="(.*?)"/ =~ cd then @name = $1 end
            if /[ \t]+filename="(.*?)"/ =~ cd then @filename = $1 end
          end
        else
          @raw_header << str
        end
        self
      end

      ##
      # Adds +data+ at the end of the chain of entries
      #
      # This is called by WEBrick::HTTPUtils.parse_form_data for you.

      def append_data(data)
        tmp = self
        while tmp
          unless tmp.next_data
            tmp.next_data = data
            break
          end
          tmp = tmp.next_data
        end
        self
      end

      ##
      # Yields each entry in this FormData

      def each_data
        tmp = self
        while tmp
          next_data = tmp.next_data
          yield(tmp)
          tmp = next_data
        end
      end

      ##
      # Returns all the FormData as an Array

      def list
        ret = []
        each_data{|data|
          ret << data.to_s
        }
        ret
      end

      ##
      # A FormData will behave like an Array

      alias :to_ary :list

      ##
      # This FormData's body

      def to_s
        String.new(self)
      end
    end
a = FormData.new("x", "y")
p a.list, a.to_ary
d = FormData.new
d << "Content-Disposition: form-data; name=\"f\"; filename=\"t.txt\"\r\n"
d << "Content-Type: text/plain\r\n"
d << CRLF
d << "hello"
d << " world"
p d, d.name, d.filename, d["content-type"], d[0], d[1, 3], d.to_s
b = FormData.new("v")
a.append_data(b)
p a.list
a.each_data { |x| puts x }
p a.frozen?, a.dup, a.dup.class, a.length, a + "!", a.sub("x", "z")
