# Spinel package: optparse
#
# A statically typable subset of CRuby's OptionParser:
#   - OptionParser.new(banner, width, indent) { |opts| ... }
#   - on / on_tail with any number of switch names ("-nNAME" declares -n with
#     a value), any number of description lines and an optional value type
#     (String, Array, Integer, Float, DecimalInteger, OctalInteger,
#     DecimalNumeric, TrueClass or FalseClass), in any order
#   - separator, banner=, summary_width, summary_indent, to_s (help text)
#   - parse! with --long=VALUE, --long VALUE, -s VALUE, -sVALUE, clustered
#     short switches (-vq, -vuNAME) and "--"
#   - --[no-]name switches: --name passes true, --no-name passes false;
#     with a required value, only the positive form reads that value
#   - optional values: "--name[=VALUE]" and "-n[VALUE]" take only an attached
#     value; "--name [VALUE]" also takes the next word unless it looks like a
#     switch. Without a value the block gets nil
#   - abbreviated long switches: "--verb" is "--verbose", each word may be
#     shortened ("--d-r" is "--dry-run") and case is ignored; a name two
#     switches share raises AmbiguousOption
#   - Integer reads 12, -3, 0x1f, 0b11, 010 and 1_000, and Float reads 1.5,
#     -.5 and 1e3; any other word raises OptionParser::InvalidArgument
#   - String refuses an empty value with OptionParser::InvalidArgument, and
#     Array passes nil for an empty item ("a,,b"); without a type an empty
#     value passes as it is
#   - OptionParser::InvalidOption, OptionParser::AmbiguousOption,
#     OptionParser::MissingArgument, OptionParser::NeedlessArgument and
#     OptionParser::InvalidArgument, all subclasses of OptionParser::ParseError
#
#   - DecimalInteger reads only decimal digits (010 is 10), OctalInteger
#     octal digits (10 is 8), and DecimalNumeric an Integer or, when a "." or
#     an exponent follows the digits, a Float
#   - TrueClass and FalseClass read yes, true and + as true and no, false, - and
#     nil as false, each cut short as far as it stays a prefix ("y", "fa");
#     case matters. Any other word raises InvalidArgument, an empty one
#     AmbiguousArgument (a subclass of it). Without a value ("--force[=YES]")
#     TrueClass passes true and FalseClass false
#   - an Array of String or Symbol names, an Array of [name, value] pairs or
#     a Hash accepts only those names, each word cut as far as it stays
#     unique ("d-r" is "dry-run"); case matters. A name passes itself, a
#     pair or a Hash entry its value. Any other word raises InvalidArgument,
#     one several names share AmbiguousArgument. A type after the enum
#     converts the word instead
#
# Not supported: other value types than String, Array, Integer, Float,
# DecimalInteger, OctalInteger, DecimalNumeric, TrueClass and FalseClass,
# and an Array of allowed values that are not names ([1, 2]).

class OptionParser
  class ParseError < StandardError
  end

  class InvalidOption < ParseError
  end

  class AmbiguousOption < ParseError
  end

  class MissingArgument < ParseError
  end

  class NeedlessArgument < ParseError
  end

  class InvalidArgument < ParseError
  end

  class AmbiguousArgument < InvalidArgument
  end

  # The words an Integer or a Float switch accepts. radix is a leading 0
  # with an octal, binary (0b) or hexadecimal (0x) number. The lookahead
  # group captures what follows the leading digits: DecimalNumeric reads
  # the word as a Float when it is there, and as an Integer when not.
  digits = '\d+(?:_\d+)*'
  binary = 'b[01]+(?:_[01]+)*'
  hex = 'x[\da-f]+(?:_[\da-f]+)*'
  radix = "0(?:[0-7]+(?:_[0-7]+)*|#{binary}|#{hex})?"
  INTEGER_VALUE = /\A[-+]?(?:#{radix}|#{digits})\z/io
  FLOAT_VALUE = /\A[-+]?(?:#{digits}(?=(.)?)(?:\.(?:#{digits})?)?|\.#{digits})
                 (?:E[-+]?#{digits})?\z/iox

  # The value types CRuby names by their pattern, as it defines them.
  DecimalInteger = /\A[-+]?#{digits}\z/io
  OctalInteger = /\A[-+]?(?:[0-7]+(?:_[0-7]+)*|0(?:#{binary}|#{hex}))\z/io
  DecimalNumeric = FLOAT_VALUE

  # One name an enum switch accepts and the value it passes.
  class Choice
    attr_reader :name, :value, :string_key

    def initialize(name, value, string_key)
      @name = name
      @value = value
      @string_key = string_key
    end
  end

  # One entry of the help text: a switch, or a separator line (no names).
  class Switch
    attr_reader :shorts, :longs, :arg, :descriptions, :handler, :type,
                :choices, :choice_value

    def initialize(shorts, longs, arg, descriptions, handler, type, choices = nil, choice_value = true)
      @shorts = shorts
      @longs = longs
      @arg = arg
      @descriptions = descriptions
      @handler = handler
      @type = type
      @choices = choices
      @choice_value = choice_value
    end

    def takes_value
      @arg != ""
    end

    # "[=VALUE]", "=[VALUE]" or "[VALUE]": only an attached value.
    def optional_value?
      @arg.start_with?("[") || @arg.start_with?("=[")
    end

    # " [VALUE]": an attached value, or else the next word.
    def placed_value?
      @arg.start_with?(" ") && @arg.lstrip.start_with?("[")
    end

    def separator?
      @shorts.empty? && @longs.empty?
    end

    def matches?(name)
      @shorts.include?(name) || @longs.any? { |long| accepts?(long, name) }
    end

    # A --[no-]name declaration accepts --name and --no-name; any other long
    # declaration accepts only itself.
    def accepts?(long, name)
      return long == name unless long.start_with?("--[no-]")

      base = long.delete_prefix("--[no-]")
      name == "--" + base || name == "--no-" + base
    end

    def negated?(name)
      @longs.any? do |long|
        long.start_with?("--[no-]") &&
          "--no-" + long.delete_prefix("--[no-]") == name
      end
    end
  end

  attr_accessor :banner, :summary_width, :summary_indent

  def initialize(banner = nil, width = 32, indent = "    ", &block)
    @banner = banner || "Usage: " + File.basename($0) + " [options]"
    @summary_width = width
    @summary_indent = indent
    @entries = []
    @tail = []
    block.call(self) if block
  end

  def separator(text)
    @entries.push(Switch.new([], [], "", [text], nil, Object))
  end

  def on(*args, &block)
    @entries.push(build_switch(args, block))
  end

  def on_tail(*args, &block)
    @tail.push(build_switch(args, block))
  end

  # When a switch raises an error, argv keeps only the words after the
  # switch that failed and the value it read, as in CRuby.
  def parse!(argv = ARGV)
    rest = []
    i = 0
    begin
      while i < argv.length
        @used = i
        arg = argv[i]
        if arg == "--"
          rest.concat(argv[(i + 1)..])
          break
        end
        if arg.length > 2 && arg[0] == "-" && arg[1] == "-"
          i = parse_long(argv, i)
        elsif arg.length > 1 && arg[0] == "-"
          i = parse_short(argv, i)
        else
          rest.push(arg)
        end
        i += 1
      end
    rescue ParseError
      rest = argv[(@used + 1)..]
      argv.clear
      argv.concat(rest)
      raise
    end
    argv.clear
    argv.concat(rest)
    argv
  end

  def parse(argv)
    parse!(argv.dup)
  end

  def to_s
    out = @banner + "\n"
    (@entries + @tail).each { |e| out += help_line(e) }
    out
  end

  alias help to_s

  private

  def build_switch(args, block)
    shorts = []
    longs = []
    arg_text = ""
    descriptions = []
    type = Object
    choices = nil
    choice_value = true
    args.each do |a|
      if a.is_a?(String) && a.length > 1 && a[0] == "-"
        # a "[" opens an optional value ("--name[=VALUE]"), but the "[no-]" of
        # a negatable long switch is part of its name
        from = a.start_with?("--[no-]") ? 7 : 1
        cut = a.index(/[=\[ ]/, from) || (a[1] == "-" ? a.length : 2)
        text = a[cut..]
        arg_text = text unless text.empty?
        (a[1] == "-" ? longs : shorts).push(a[0, cut])
      elsif a.is_a?(String)
        descriptions.push(a)
      elsif a == String || a == Array || a == Integer || a == Float || a == TrueClass || a == FalseClass ||
            a == DecimalInteger || a == OctalInteger || a == DecimalNumeric
        type = a
        choice_value = false
      elsif enum?(a)
        # only the first enum takes the conversion back from a type
        choice_value = true if choices.nil?
        choices ||= []
        add_choices(choices, a)
      elsif a.is_a?(Module) && a != Object && a != NilClass && a != Numeric && a != Regexp
        # CRuby has no converter for it either. Numeric and Regexp are
        # CRuby value types that still pass the word as it is.
        raise ArgumentError, "unsupported argument type: #{a}"
      end
    end
    # A boolean type after the enum still passes the enum's value, as in
    # CRuby, where its converter keeps the value the Hash matched.
    choice_value = true if type == TrueClass || type == FalseClass
    Switch.new(shorts, longs, arg_text, descriptions, block, type, choices, choice_value)
  end

  def enum?(a)
    return true if a.is_a?(Hash)
    return false unless a.is_a?(Array) && !a.empty?
    a.all? do |item|
      first = item.is_a?(Array) ? item[0] : item
      first.is_a?(String) || first.is_a?(Symbol)
    end
  end

  # An Array value passes its first item, as CRuby splats it.
  def add_choices(choices, enum)
    enum.each do |item|
      if enum.is_a?(Hash)
        name, value = item
      elsif item.is_a?(Array)
        name = item[0]
        value = item.length > 1 ? item[1] : name
      else
        name = item
        value = item
      end
      value = value[0] if value.is_a?(Array)
      if name.is_a?(String)
        choices.push(Choice.new(name, value, true))
      elsif name.is_a?(Symbol)
        choices.push(Choice.new(name.to_s, value, false))
      end
    end
  end

  def help_line(sw)
    return sw.descriptions[0] + "\n" if sw.separator?
    names = (sw.shorts + sw.longs).join(", ") + sw.arg
    names = "    " + names if sw.shorts.empty?
    descriptions = sw.descriptions
    return @summary_indent + names + "\n" if descriptions.empty?
    gap = @summary_indent + " " * (@summary_width + 1)
    out = @summary_indent + names.ljust(@summary_width) + " "
    out = @summary_indent + names + "\n" + gap if names.length > @summary_width
    out += descriptions[0] + "\n"
    descriptions[1..].each { |d| out += gap + d + "\n" }
    out
  end

  def find_switch(name)
    (@entries + @tail).find { |e| e.matches?(name) }
  end

  # Passes the value to the block in the switch's type. An empty String or
  # a word that is not an Integer or a Float raises InvalidArgument naming
  # it as given (shown). Object is the type of a switch declared without one.
  def invoke(sw, value, shown)
    handler = sw.handler
    type = sw.type
    choices = sw.choices
    if choices && !value.nil?
      choice = choose(choices, value, shown)
      if sw.choice_value
        handler.call(choice.value) if handler
        return
      end
    end
    if value.nil? && (type == TrueClass || type == FalseClass)
      handler.call(type == TrueClass) if handler
    elsif value.nil? || type == Object
      handler.call(value) if handler
    elsif type == TrueClass || type == FalseClass
      handler.call(boolean_value(value, shown)) if handler
    elsif type == String
      raise invalid_argument(shown) if value.empty?
      handler.call(value) if handler
    elsif type == Array
      handler.call(value.split(",").map { |item| item.empty? ? nil : item }) if handler
    elsif type == Integer
      raise invalid_argument(shown) unless value.match?(INTEGER_VALUE)
      begin
        number = Integer(value)
      rescue ArgumentError
        raise invalid_argument(shown)
      end
      handler.call(number) if handler
    elsif type == DecimalInteger || type == OctalInteger
      raise invalid_argument(shown) unless value.match?(type)
      begin
        number = Integer(value, type == DecimalInteger ? 10 : 8)
      rescue ArgumentError
        raise invalid_argument(shown)
      end
      handler.call(number) if handler
    elsif type == DecimalNumeric
      match = DecimalNumeric.match(value)
      raise invalid_argument(shown) unless match
      begin
        number = match[1] ? Float(value) : Integer(value)
      rescue ArgumentError
        raise invalid_argument(shown)
      end
      handler.call(number) if handler
    else
      raise invalid_argument(shown) unless value.match?(FLOAT_VALUE)
      handler.call(value.to_f) if handler
    end
  end

  # The words a TrueClass or FalseClass switch reads: true for a prefix of
  # "yes" or "true" or "+", false for a prefix of "no", "false" or "nil" or
  # "-". An empty word is ambiguous, any other invalid.
  def boolean_value(word, shown)
    raise AmbiguousArgument.new("ambiguous argument: " + shown) if word.empty?
    return true if word == "+" || "yes".start_with?(word) || "true".start_with?(word)
    return false if word == "-" || "no".start_with?(word) || "false".start_with?(word) || "nil".start_with?(word)
    raise invalid_argument(shown)
  end

  # Completes the word as complete_long does, but case matters and two
  # names with the same value are not ambiguous. Only a String key matches
  # the word exactly, as CRuby's Hash#fetch does.
  def choose(choices, word, shown)
    exact = choices.find { |c| c.string_key && c.name == word }
    return exact if exact
    words = Regexp.quote(word).gsub(/\w+\b/, "\\&\\w*")
    pattern = Regexp.new("\\A" + words)
    found = choices.select { |c| c.name.match?(pattern) }.sort_by { |c| c.name.length }
    raise invalid_argument(shown) if found.empty?
    best = found[0]
    found[1..].each do |c|
      next if c.value == best.value
      if c.name == best.name
        best = c
        next
      end
      next if c.name.start_with?(best.name)
      raise AmbiguousArgument.new("ambiguous argument: " + shown)
    end
    best
  end

  def invalid_argument(shown)
    InvalidArgument.new("invalid argument: " + shown)
  end

  def invoke_flag(sw, value)
    handler = sw.handler
    handler.call(value) if handler
  end

  # Returns the next word as the value of a switch with no attached value.
  # An optional value is nil instead: "[=VALUE]" never takes the next word,
  # and " [VALUE]" leaves it when it looks like a switch, as in CRuby.
  # Raises MissingArgument when a required value has no next word.
  def next_value(sw, argv, index, name)
    return nil if sw.optional_value?
    word = index + 1 < argv.length ? argv[index + 1] : nil
    if sw.placed_value?
      return nil if word.nil? || word.match?(/\A-./)
      return word
    end
    raise MissingArgument.new("missing argument: " + name) if word.nil?
    word
  end

  # Returns the full name of a long switch from a shortened one. Each word
  # may be cut ("--d-r" is "--dry-run") and case is ignored; an exact name
  # wins. When names of several switches match, the shortest wins if it
  # starts all the others ("--lis" is "--list" beside "--listen"), else
  # raises AmbiguousOption. Switches from on come before on_tail ones, and
  # a bare "--" matches nothing.
  def complete_long(name)
    return name if find_switch(name)
    return nil if name == "--"
    words = Regexp.quote(name[2..]).gsub(/\w+\b/, "\\&\\w*")
    pattern = Regexp.new("\\A" + words, Regexp::IGNORECASE)
    complete_in(@entries, name, pattern) || complete_in(@tail, name, pattern)
  end

  # complete_long within one list; nil when nothing matches.
  def complete_in(entries, name, pattern)
    found = []
    entries.each do |sw|
      sw.longs.each do |long|
        if long.start_with?("--[no-]")
          base = long.delete_prefix("--[no-]")
          found.push(["--" + base, sw]) if base.match?(pattern)
          found.push(["--no-" + base, sw]) if ("no-" + base).match?(pattern)
        elsif long[2..].match?(pattern)
          found.push([long, sw])
        end
      end
    end
    return nil if found.empty?
    found = found.sort_by { |pair| pair[0].length }
    best, best_sw = found[0]
    found.each do |full, sw|
      next if sw == best_sw || full.start_with?(best)
      raise AmbiguousOption.new("ambiguous option: " + name)
    end
    best
  end

  # Returns the index of the last word used, so parse! skips a value word.
  def parse_long(argv, index)
    arg = argv[index]
    eq = arg.index("=")
    name = eq ? arg[0, eq] : arg
    begin
      full = complete_long(name)
    rescue AmbiguousOption
      raise AmbiguousOption.new("ambiguous option: " + arg)
    end
    raise InvalidOption.new("invalid option: " + arg) if full.nil?
    sw = find_switch(full)
    is_enabled = !sw.negated?(full)
    if sw.takes_value && is_enabled
      attached = eq ? arg[(eq + 1)..] : nil
      value = attached || next_value(sw, argv, index, name)
      index += 1 if attached.nil? && value
      @used = index
      invoke(sw, value, attached ? arg : name + " " + value.to_s)
    else
      raise NeedlessArgument.new("needless argument: " + arg) if eq
      invoke_flag(sw, is_enabled)
    end
    index
  end

  # Reads each letter after the dash as one switch. A switch that takes a
  # value uses the rest of the word. Errors name the word from the failing
  # letter on, as in CRuby.
  # Returns the index of the last word used, so parse! skips a value word.
  def parse_short(argv, index)
    arg = argv[index]
    pos = 1
    while pos < arg.length
      name = "-" + arg[pos]
      from_here = "-" + arg[pos..]
      sw = find_switch(name)
      raise InvalidOption.new("invalid option: " + from_here) if sw.nil?
      if sw.takes_value
        attached = pos + 1 < arg.length ? arg[(pos + 1)..] : nil
        value = attached || next_value(sw, argv, index, name)
        index += 1 if attached.nil? && value
        @used = index
        invoke(sw, value, attached ? from_here : name + " " + value.to_s)
        break
      end
      raise NeedlessArgument.new("needless argument: " + from_here) if arg[pos + 1] == "="
      invoke_flag(sw, true)
      pos += 1
    end
    index
  end
end
