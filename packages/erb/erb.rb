# Spinel lib: erb
#
# The part of ERB an AOT program can run: a template whose Ruby is only
# `<%= name %>`, rendered by result_with_hash from the Hash it is handed,
# as CRuby's ERB renders it (the name is a local the Hash binds). Comment
# tags (`<%# %>`), empty tags, the literal `<%%`, and trim_mode "-" (`<%-`
# strips the indentation before a tag that starts its line, `-%>` the
# newline after it) are handled. Any other code in a tag needs eval, which
# a compiled program does not have: it raises NotImplementedError naming
# the tag, where the placeholder this replaces answered the template
# unrendered. So does a trim_mode other than "-". A template with no tag
# is its own result, through result and run too, and ERB::Util's escapes
# need no eval and answer as CRuby's.
class ERB
  def initialize(input, trim_mode: nil, eoutvar: "_erbout")
    @input = input
    # Only "-" is supported; "<>", ">" and "%" change the output in
    # ways this renderer does not reproduce.
    unless trim_mode.nil? || trim_mode == "-"
      raise NotImplementedError, "ERB trim_mode #{trim_mode.inspect}: only \"-\" is supported"
    end
    @trim = trim_mode == "-"
    @filename = ""
    @lineno = 0
  end

  attr_reader :filename
  attr_accessor :lineno

  def filename=(name)
    @filename = name
  end

  def src
    raise NotImplementedError, "ERB#src: a compiled program has no Ruby source to show"
  end

  def result(_binding = nil)
    raise NotImplementedError, "ERB#result needs eval; render with result_with_hash" if @input.include?("<%")
    @input
  end

  def run(b = nil)
    print result(b)
    nil
  end

  def result_with_hash(vars)
    out = +""
    s = @input
    i = 0
    n = s.length
    while i < n
      open = s.index("<%", i)
      if open.nil?
        out << s[i, n - i]
        break
      end
      # `<%%` is a literal `<%`
      if s[open + 2] == "%"
        out << s[i, open - i] << "<%"
        i = open + 3
        next
      end
      text = s[i, open - i]
      inner_start = open + 2
      strip_left = @trim && s[inner_start] == "-"
      inner_start += 1 if strip_left
      # `<%-`: the indentation before the tag goes, when only
      # indentation precedes it on its line
      if strip_left
        line_start = text.rindex("\n")
        indent = line_start.nil? ? text : text[line_start + 1, text.length - line_start - 1]
        if indent.match?(/\A[ \t]*\z/) && (line_start || i == 0 || s[i - 1] == "\n")
          text = text[0, text.length - indent.length]
        end
      end
      out << text
      close = s.index("%>", inner_start)
      raise SyntaxError, "#{@filename}: unterminated ERB tag" if close.nil?
      body = s[inner_start, close - inner_start]
      i = close + 2
      # `-%>`: the newline after the tag goes
      if @trim && body.end_with?("-")
        body = body[0, body.length - 1]
        if s[i, 2] == "\r\n"
          i += 2
        elsif s[i] == "\n"
          i += 1
        end
      end
      if body.strip.empty?
        next
      elsif strip_left && body.start_with?("=")
        raise SyntaxError, "ERB tag <%-#{body}%>: `<%-=` is not a tag"
      elsif strip_left && body.start_with?("#")
        # CRuby compiles `<%-#` as a Ruby comment, which can swallow the
        # text after the tag
        raise NotImplementedError, "ERB tag <%-#{body}%> is Ruby code, not a comment tag"
      elsif body.start_with?("#")
        next
      elsif body.start_with?("=")
        name = body[1, body.length - 1].strip
        unless name.match?(/\A[a-z_][a-zA-Z0-9_]*\z/)
          raise NotImplementedError, "ERB tag <%#{body}%> needs eval; a compiled program renders <%= name %> from result_with_hash only"
        end
        if vars.key?(name.to_sym)
          out << vars[name.to_sym].to_s
        elsif vars.key?(name)
          out << vars[name].to_s
        else
          raise NameError, "undefined local variable or method '#{name}' for an instance of ERB"
        end
      else
        raise NotImplementedError, "ERB tag <%#{body}%> needs eval; a compiled program renders <%= name %> from result_with_hash only"
      end
    end
    out
  end

  module Util
    HTML_ESCAPE = { "&" => "&amp;", "<" => "&lt;", ">" => "&gt;", "\"" => "&quot;", "'" => "&#39;" }

    def html_escape(s)
      s.to_s.gsub(/[&<>"']/) { |c| HTML_ESCAPE[c] }
    end

    def url_encode(s)
      out = +""
      s.to_s.each_byte do |b|
        if (b >= 48 && b <= 57) || (b >= 65 && b <= 90) || (b >= 97 && b <= 122) ||
           b == 95 || b == 45 || b == 46 || b == 126
          out << b.chr
        else
          out << format("%%%02X", b)
        end
      end
      out
    end

    alias h html_escape
    alias u url_encode
    module_function :h, :html_escape, :u, :url_encode
  end
end
