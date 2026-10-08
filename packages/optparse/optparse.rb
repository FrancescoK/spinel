# Spinel package: optparse
#
# A statically typable subset of CRuby's OptionParser:
#   - OptionParser.new(banner, width, indent) { |opts| ... }
#   - on / on_tail with any number of switch names ("-nNAME" declares -n with
#     a value), any number of description lines and an optional Array type,
#     in any order
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
#   - OptionParser::InvalidOption, OptionParser::AmbiguousOption,
#     OptionParser::MissingArgument and OptionParser::NeedlessArgument, all
#     subclasses of OptionParser::ParseError
#
# Not supported: other value types than String and Array.

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

  # One entry of the help text: a switch, or a separator line (no names).
  class Switch
    attr_reader :shorts, :longs, :arg, :descriptions, :handler, :is_array

    def initialize(shorts, longs, arg, descriptions, handler, is_array)
      @shorts = shorts
      @longs = longs
      @arg = arg
      @descriptions = descriptions
      @handler = handler
      @is_array = is_array
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
    @entries.push(Switch.new([], [], "", [text], nil, false))
  end

  def on(*args, &block)
    @entries.push(build_switch(args, block))
  end

  def on_tail(*args, &block)
    @tail.push(build_switch(args, block))
  end

  # When a switch raises an error, argv keeps only the words after the
  # switch that failed, as in CRuby.
  def parse!(argv = ARGV)
    rest = []
    i = 0
    begin
      while i < argv.length
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
      rest = argv[(i + 1)..]
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
    is_array = false
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
      elsif a == Array
        is_array = true
      end
    end
    Switch.new(shorts, longs, arg_text, descriptions, block, is_array)
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

  def invoke(sw, value)
    handler = sw.handler
    return if handler.nil?
    if sw.is_array
      handler.call(value.nil? ? nil : value.split(","))
    else
      handler.call(value)
    end
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
    full = complete_long(name)
    raise InvalidOption.new("invalid option: " + name) if full.nil?
    sw = find_switch(full)
    is_enabled = !sw.negated?(full)
    if sw.takes_value && is_enabled
      attached = eq ? arg[(eq + 1)..] : nil
      value = attached || next_value(sw, argv, index, name)
      invoke(sw, value)
      index += 1 if attached.nil? && value
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
        invoke(sw, value)
        index += 1 if attached.nil? && value
        break
      end
      raise NeedlessArgument.new("needless argument: " + from_here) if arg[pos + 1] == "="
      invoke_flag(sw, true)
      pos += 1
    end
    index
  end
end
