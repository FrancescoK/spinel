#!/usr/bin/env ruby
# frozen_string_literal: true
# Check Spinel's "new String" claims under CRuby.
#
#   ruby tools/new_string_oracle.rb [--spinel BIN] [--claims FILE] [--max N]
#                                   [--jobs N] [--report FILE] [--json] PROG.rb...
#
# Under --share-strings the share facts claim that some values are new
# Strings: where the value is made, no name other than the one about to
# receive it can reach the object, so it may be copied, wrapped or changed
# without anyone seeing. This runs each program under CRuby (ruby
# --enable-frozen-string-literal) and checks the claims where they are made.
# A claim is disproved when the object is reachable from a name the program
# can still read: a live frame's local or self, a global, a constant, a
# class's own variables, and anything reachable from those.
#
# The claims come from the compiler: SPINEL_NEW_CLAIMS=FILE lists them
# (report-only, the generated C is unchanged), or --claims FILE reads a
# hand-written file for one program. A claims file has one claim per line,
# tab separated, blank lines and lines starting with # skipped:
#
#   kind  file  line  col  end_line  end_col  PrismKind  name  [key=value ...]
#
# The position is the claimed node's source range (columns are Prism's, 0
# based; a relative file is relative to a hand-written claims file's
# directory). The kind is only a label for the report. What is checked comes
# from the claim's check field, so a kind can be renamed, merged or added
# without this tool changing:
#
#   check=new       no name but the one receiving the value can reach the
#                   object (the default when a claim says nothing)
#   check=one-name  at most one name holds the object
#   check=elems     an Array: each String in it passes `new`, none is in
#                   it twice
#   check=param     (with param=NAME) a method answers parameter NAME's
#                   object, as passed, or one that passes `new`
#   check=unkept    (with param=NAME) the method keeps no reference to
#                   parameter NAME's String: once it returns, no name
#                   holds the object that did not hold it when it was
#                   called
#   check=unshared  the object is never changed in place while a second
#                   name can reach it (a lifetime claim: the plan copied
#                   the value because the share rule does not share its
#                   class, and the rule says no String of that class is
#                   changed while another name holds it)
#   check=frozen    the object is frozen (an ARGV or ENV String, which a
#                   copy cannot be told from)
#   check=none      listed, not checked
#
# A claim on a def node is about the method (its answers, its parameters),
# checked at its call and return (TracePoint); param and unkept only make
# sense there. Any other claim is about an expression, checked by
# wrapping it, `::SpOracle.v(id, (expr))`, in a rewritten copy of the program
# evaluated under the original path. A kind that states no check, or one this
# tool does not know, is reported and checked by the `new` rule.
#
# unshared is checked where the object is changed, not where it is made: the
# probe only records the objects the claimed expression answers (the first
# max evaluations per claim); a TracePoint on :c_call then watches the String
# methods that change the receiver in place (MUTATORS), and at each change of
# a recorded object (the first max per source line and method) searches for
# its holders by the same walk. The claim is disproved when two names hold it
# at that moment; the report gives both chains. Not names: a frame of the
# standard library, the `self` of a String method (the receiver the caller
# names), a Proc's capture of a variable a frame already names, and a local
# its method does not read again (a name is live if its next occurrence at or
# after the current line is a read; the caller of a call in progress needs a
# later line).
#
# unkept compares who can reach the argument at the call with who can at the
# return, by the same walk. A holder at the return that was not one at the
# call disproves the claim, whoever put the object there: the method, or a
# block it yielded to or called. (The claim is about the call. The share
# analysis itself counts a yield, a block call and any argument handed on as
# keeping, so a method it calls unkept gives the String to no block.) Not
# holders: the method's own frame, whose locals die with it; the caller's
# locals and every other holder that already held the object at the call; the
# return value, which no name holds yet. An argument that is nil, frozen or
# no String is not checked (no name can tell it from another).
#
# A run whose stdout or exit status differs from the plain run's is
# "perturbed" and its alarms are not counted. Exit status: 1 when a claim is
# disproved, 2 when a program could not be checked, else 0.

# (the program under test runs in the same process as the oracle's child, so
# the child loads only what it needs: json, for one, adds an ancestor to
# Object that a program may print. A run that still differs from the plain one
# is reported as perturbed.)
require "objspace"
require "prism"
require "rbconfig"

module SpOracle
  ORACLE_FILE = File.expand_path(__FILE__)
  CHECKS = %w[new one-name elems param unkept unshared frozen none].freeze
  METHOD_CHECKS = %w[param unkept].freeze
  # The String methods that change the receiver in place (unshared)
  MUTATORS = %i[
    << concat replace insert prepend []= slice! clear force_encoding setbyte append_as_bytes bytesplice
    encode! unicode_normalize! scrub! succ! next! reverse! upcase! downcase! capitalize! swapcase!
    strip! lstrip! rstrip! chomp! chop! squeeze! delete! delete_prefix! delete_suffix! sub! gsub!
    tr! tr_s! initialize_copy initialize
  ].to_h { |m| [m, true] }.freeze
  # (the standard library's frames, default gems among them, hold Strings only while they run)
  MODULE_NAME = Module.instance_method(:name)
  STD_PATHS = [RbConfig::CONFIG["rubylibprefix"], "<internal:"].freeze

  # ---- the run (child process) ----
  class Runner
    # sites: site id => [claim id]; claims: claim id => {check, param}
    def initialize(sites, claims, max)
      @sites = sites
      @claims = claims
      @rets = {}                  # [path, line, name] => [claim id]
      @max = max
      @seen = Hash.new(0)
      @results = Hash.new { |h, k| h[k] = { "checked" => 0, "disproved" => 0, "witness" => nil, "mutations" => 0 } }
      @recorded = {}.compare_by_identity  # unshared: object => [claim id]
      @mut_seen = Hash.new(0)             # [path, line, method] => changes checked
      @prog_path = nil
      @stacks = {}.compare_by_identity  # Fiber => [frame]
      @busy = false
      @serial = 0
      @boot_modules = {}.compare_by_identity
      ObjectSpace.each_object(Module) { |m| @boot_modules[m] = true }
      @touched = {}.compare_by_identity
      @touched[Object] = true
    end
    attr_reader :results
    attr_writer :prog_path

    def add_ret(path, line, name, ids) = (@rets[[path, line, name]] = ids)

    def stack = (@stacks[Fiber.current] ||= [])

    # pending: [[claim id, the parameter's object at the call, who held that
    # object at the call (unkept only)]]; serial tells two frames of one
    # method apart
    Frame = Struct.new(:binding, :pending, :label, :names, :serial, :kind, :path, :lineno, :meth, :std)
    # who refers to an object: root names (key => chain) and objects
    # (identity => chain); a chain runs from a root name through the objects
    # between it and the holder
    Holders = Struct.new(:names, :objs)

    # The local names a block (or lambda) starting at path:line reads or
    # writes, its parameters among them: the names of its environment it can
    # observe. nil (follow them all) where the source is unknown or the block
    # asks for a binding or evals.
    def block_names(path, line)
      @block_names ||= {}
      key = [path, line]
      return @block_names[key] if @block_names.key?(key)
      @block_names[key] = begin
        @parsed ||= {}
        tree = (@parsed[path] ||= (Prism.parse_file(path).value rescue nil))
        blocks = []
        find = lambda do |n|
          return unless n
          blocks << n if (n.is_a?(Prism::BlockNode) || n.is_a?(Prism::LambdaNode)) && n.location.start_line == line
          n.compact_child_nodes.each { |ch| find.(ch) }
        end
        find.(tree)
        if blocks.empty?
          nil
        else
          names = {}
          open = false
          walk = lambda do |n|
            return unless n
            # (a program that reopens Array or Integer must not be asked of its own: no split, no last)
            k = n.type
            names[n.name] = true if (k.start_with?("local_variable") || k.end_with?("parameter_node")) && n.respond_to?(:name) && n.name
            open = true if n.is_a?(Prism::CallNode) && %i[binding eval local_variables].include?(n.name)
            n.compact_child_nodes.each { |ch| walk.(ch) }
          end
          blocks.each { |b| walk.(b) }
          open ? nil : names
        end
      end
    end

    def trace
      tp = TracePoint.new(:call, :b_call, :class, :return, :b_return, :end) do |t|
        next if @busy || t.path == ORACLE_FILE
        case t.event
        when :call, :b_call, :class
          b = (t.binding rescue nil)
          pending = []
          if t.event == :call && (ids = @rets[[t.path, t.lineno, t.method_id.name]])
            @busy = true
            begin
              ids.each do |id|
                pn = @claims[id]["param"]
                arg = pn && b ? (b.local_variable_get(pn.to_sym) rescue nil) : nil
                pending << [id, arg, @claims[id]["check"] == "unkept" ? holders_at_call(id, arg) : nil]
              end
            rescue StandardError => e
              @results["oracle-error"]["witness"] ||= "#{e.class}: #{e.message}"
            ensure
              @busy = false
            end
          end
          @busy = true
          @touched[t.self] = true if t.event == :class
          @busy = false
          names = t.event == :b_call ? block_names(t.path, t.lineno) : nil
          path = t.path || ""
          stack << Frame.new(b, pending, "#{t.event} #{t.method_id || "block"} #{File.basename(path)}:#{t.lineno}", names, @serial += 1,
                             t.event, path, t.lineno, t.method_id, STD_PATHS.any? { |d| path.start_with?(d) })
        else
          fr = stack.pop
          if fr && !fr.pending.empty? && t.event == :return
            @busy = true
            begin
              fr.pending.each { |id, arg, before| check_ret(id, fr, arg, t.return_value, before) }
            rescue StandardError => e
              @results["oracle-error"]["witness"] ||= "#{e.class}: #{e.message}"
            ensure
              @busy = false
            end
          end
        end
      end
      tp.enable
      mutation_trace if @claims.values.any? { |c| c["check"] == "unshared" }
      tp
    end

    # ---- unshared: a recorded object is changed in place ----
    def mutation_trace
      tp = TracePoint.new(:c_call) do |t|
        next if @busy || !MUTATORS[t.method_id]
        o = t.self
        next unless String === o
        ids = @recorded[o]
        next unless ids
        next if (@mut_seen[[t.path, t.lineno, t.method_id]] += 1) > @max
        @busy = true
        begin
          w = mutation_witness(o, t)
          ids.each do |id|
            r = @results[id]
            r["mutations"] += 1
            next unless w
            r["disproved"] += 1
            r["witness"] ||= w
          end
        rescue StandardError => e
          @results["oracle-error"]["witness"] ||= "#{e.class}: #{e.message}"
        ensure
          @busy = false
        end
      end
      tp.enable
      tp
    end

    # nil when at most one name holds o as it is changed; else both chains
    def mutation_witness(o, t)
      lines = frame_lines
      frames = {}
      @stacks.each_value { |st| st.each { |fr| frames[fr.serial] = fr } }
      keep = lambda do |key|
        if key.is_a?(Array)
          fr = frames[key[0]]
          # (a frame's `self` is kept: its String is dropped below)
          next false if fr.nil? || fr.std
          next true if key[1] == :self
          next local_live?(fr.path, fr.kind, fr.lineno, key[1], lines[fr.serial], !lines[:below].key?(fr.serial))
        end
        next true unless key.is_a?(String) && key.start_with?("toplevel local ")
        local_live?(@prog_path, :program, 0, key.delete_prefix("toplevel local ").to_sym, lines[:main], !lines[:below].key?(:main))
      end
      h = holders(o, nil, keep)
      names = h.names.reject { |k, _| k.is_a?(Array) && k[1] == :self }
      objs = h.objs.reject { |x, _| (Proc === x || Binding === x) && captured_by_a_frame?(x, o) }
      refs = names.values + objs.values
      return nil if refs.size < 2
      "#{o.inspect[0, 40]} changed by String##{t.method_id} at #{File.basename(t.path || "")}:#{t.lineno} while held by #{refs.size} names: " \
        "#{refs[0, 3].join("; ")}#{refs.size > 3 ? "; ..." : ""}"
    end

    # frame serial (or :main for the program's toplevel) => the line it is at
    # now, by matching the stack to the backtrace; :below holds the frames
    # that are waiting on a call (their line is the call's, so a read on it
    # is not a later one). Other fibers' frames have no line.
    def frame_lines
      bt = (Thread.current.backtrace_locations || []).reject { |l| l.absolute_path == ORACLE_FILE }
      lines = { below: {} }
      ptr = 0
      stack.reverse.each_with_index do |fr, depth|
        i = (ptr...bt.size).find { |k| frame_matches?(fr, bt[k]) }
        next unless i
        lines[fr.serial] = bt[i].lineno
        lines[:below][fr.serial] = true if depth > 0
        ptr = i + 1
      end
      m = (ptr...bt.size).find { |k| bt[k].label == "<main>" }
      if m
        lines[:main] = bt[m].lineno
        lines[:below][:main] = true unless stack.empty?
      end
      lines
    end

    def frame_matches?(fr, loc)
      return false unless loc.path == fr.path
      case fr.kind
      when :call then loc.base_label == fr.meth.name && !loc.label.start_with?("block ")
      when :b_call then loc.label.start_with?("block ")
      else loc.label.start_with?("<class:", "<module:", "singleton class")
      end
    end

    # Does the local v still matter to its scope? Its next occurrence at or
    # after the current line (after it, for a frame waiting on a call) is a
    # read. nil lines (a frame we cannot place) and unknown scopes: not a name.
    def local_live?(path, kind, line, v, cur, inclusive)
      return false unless cur
      occ = []
      scope_nodes(path, kind, line).each { |n| local_occurrences(n, v, occ, true) }
      occ.sort_by! { |l, c, _| [l, c] }
      nxt = occ.find { |l, _, _| inclusive ? l >= cur : l > cur }
      nxt ? nxt[2] : false
    end

    def scope_nodes(path, kind, line)
      @scopes ||= {}
      @scopes[[path, kind, line]] ||= begin
        @parsed ||= {}
        tree = (@parsed[path] ||= (Prism.parse_file(path).value rescue nil))
        out = []
        if tree && kind == :program
          out << tree
        elsif tree
          want = case kind
                 when :call then [Prism::DefNode]
                 when :b_call then [Prism::BlockNode, Prism::LambdaNode]
                 else [Prism::ClassNode, Prism::ModuleNode, Prism::SingletonClassNode]
                 end
          find = lambda do |n|
            return unless n
            out << n if want.any? { |k| n.is_a?(k) } && n.location.start_line == line
            n.compact_child_nodes.each { |ch| find.(ch) }
          end
          find.(tree)
        end
        out
      end
    end

    # [line, column, read?] of every occurrence of local v in node n, not
    # entering a nested def or class (its locals are its own). A parameter
    # is no occurrence: it is bound before the body, whatever line it is on.
    def local_occurrences(n, v, occ, root)
      return unless n
      unless root
        return if n.is_a?(Prism::DefNode) || n.is_a?(Prism::ClassNode) || n.is_a?(Prism::ModuleNode) || n.is_a?(Prism::SingletonClassNode)
      end
      if n.respond_to?(:name) && n.name == v
        loc = n.location
        case n
        when Prism::LocalVariableReadNode, Prism::LocalVariableOperatorWriteNode, Prism::LocalVariableOrWriteNode,
             Prism::LocalVariableAndWriteNode
          occ << [loc.start_line, loc.start_column, true]
        when Prism::LocalVariableWriteNode, Prism::LocalVariableTargetNode
          occ << [loc.start_line, loc.start_column, false]
        end
      end
      n.compact_child_nodes.each { |ch| local_occurrences(ch, v, occ, false) }
    end

    # A Proc or Binding that holds o through a variable some live frame also
    # names holds the same name, not a second one.
    def captured_by_a_frame?(x, o)
      b = Binding === x ? x : (x.binding rescue nil)
      return false unless b
      vars = b.local_variables.select { |v| (b.local_variable_get(v) rescue nil).equal?(o) }
      bindings = [TOPLEVEL_BINDING] + @stacks.values.flat_map { |st| st.filter_map(&:binding) }
      vars.any? { |v| bindings.any? { |b2| !b2.equal?(b) && b2.local_variable_defined?(v) && same_variable?(b2, b, v, o) } }
    end

    # A probe: an expression claim's value has just been made.
    def probe(site, val)
      return val if @busy
      ids = @sites[site]
      return val unless ids
      @busy = true
      begin
        ids.each do |id|
          next if @seen[id] >= @max
          @seen[id] += 1
          if @claims[id]["check"] == "unshared"
            record(id, val)
          else
            tally(id, check_value(@claims[id], val, nil, nil))
          end
        end
      rescue StandardError => e
        # (the oracle's own failure never changes the program's run)
        @results["oracle-error"]["witness"] ||= "#{e.class}: #{e.message}"
      ensure
        @busy = false
      end
      val
    end

    def check_ret(id, frame, arg, val, before)
      if @claims[id]["check"] == "unkept"
        # (counted, and skipped when the argument is no one's concern, at the call)
        tally(id, unkept_witness(@claims[id], arg, frame, before)) if before
        return
      end
      return if @seen[id] >= @max
      @seen[id] += 1
      return record(id, val) if @claims[id]["check"] == "unshared"
      tally(id, check_value(@claims[id], val, frame, arg))
    end

    # The argument of an unkept claim at the method's call: who holds it, or
    # nil where there is nothing to check (nil, frozen, no String, or the
    # claim's evaluations are used up). The method's own frame is not on the
    # stack yet.
    def holders_at_call(id, arg)
      return nil unless String === arg && !arg.frozen? && @seen[id] < @max
      @seen[id] += 1
      holders(arg, nil)
    end

    # nil when no name holds the argument that did not at the call; else the
    # first new holder's chain
    def unkept_witness(claim, arg, frame, before)
      after = holders(arg, frame)
      fresh = after.names.reject { |k, _| before.names.key?(k) }.values +
              after.objs.reject { |k, _| before.objs.key?(k) }.values
      fresh.empty? ? nil : "#{arg.inspect[0, 40]} (parameter #{claim["param"]}) kept, reachable: #{fresh[0]}"
    end

    # unshared: the object is checked where it is changed (mutation_trace)
    def record(id, val)
      @results[id]["checked"] += 1
      (Array === val ? val : [val]).each do |e|
        (@recorded[e] ||= []) << id if String === e && !e.frozen?
      end
    end

    def tally(id, witness)
      r = @results[id]
      r["checked"] += 1
      return unless witness
      r["disproved"] += 1
      r["witness"] ||= witness
    end

    # What a claim says holds of object o, by its check field; nil when it
    # does, else a description of what breaks it. A check this tool does not
    # know is the `new` rule.
    def check_value(claim, o, exclude_frame, arg)
      case claim["check"]
      when "one-name" then one_name_witness(o, exclude_frame)
      when "elems" then elems_witness(o, exclude_frame)
      when "frozen" then String === o && !o.frozen? ? "#{o.inspect[0, 40]} is not frozen" : nil
      when "param" then claim["param"] && o.equal?(arg) ? nil : witness(o, exclude_frame)
      else witness(o, exclude_frame)
      end
    end

    # nil when object o is a new String no other name holds (or no String,
    # nil, or frozen); else a description of the name that reaches it.
    def witness(o, exclude_frame)
      return nil unless String === o && !o.frozen?
      path = holder_path(o, exclude_frame)
      path && "#{o.inspect[0, 40]} reachable: #{path}"
    end

    # at most one name holds o (the holder the value is read from, or none)
    def one_name_witness(o, exclude_frame)
      return nil unless String === o && !o.frozen?
      h = holders(o, exclude_frame)
      refs = h.names.values + h.objs.values
      refs.size > 1 ? "#{o.inspect[0, 40]} held by #{refs.size} names: #{refs[0, 3].join("; ")}" : nil
    end

    def elems_witness(a, exclude_frame)
      return nil unless Array === a
      ids = {}.compare_by_identity
      a.each_with_index do |e, i|
        next unless String === e && !e.frozen?
        return "element #{i} #{e.inspect[0, 40]} appears twice" if ids[e]
        ids[e] = true
        w = witness(e, exclude_frame)
        return "element #{i}: #{w}" if w
      end
      nil
    end

    # ---- reachability from the program's names ----
    def roots(exclude_frame)
      verbose = $VERBOSE
      $VERBOSE = nil
      roots_of(exclude_frame)
    ensure
      $VERBOSE = verbose
    end

    def roots_of(exclude_frame)
      out = []
      listed = Hash.new { |h, k| h[k] = [] }  # local name => [[binding, value]] listed
      out << ["TOPLEVEL self", TOPLEVEL_BINDING.receiver, "TOPLEVEL self"]
      TOPLEVEL_BINDING.local_variables.each do |v|
        val = TOPLEVEL_BINDING.local_variable_get(v)
        listed[v] << [TOPLEVEL_BINDING, val]
        out << ["toplevel local #{v}", val, "toplevel local #{v}"]
      end
      @stacks.each_value do |st|
        st.each do |fr|
          next if fr.equal?(exclude_frame) || fr.binding.nil?
          b = fr.binding
          out << ["self of #{fr.label}", b.receiver, [fr.serial, :self]]
          b.local_variables.each do |v|
            next if fr.names && !fr.names[v]
            val = (b.local_variable_get(v) rescue nil)
            # (a block's binding shows the locals of the frames around it: one
            # variable is one name)
            next if fr.label.start_with?("b_call") && listed[v].any? { |b2, val2| val2.equal?(val) && same_variable?(b, b2, v, val) }
            listed[v] << [b, val]
            out << ["local #{v} of #{fr.label}", val, [fr.serial, v]]
          end
        end
      end
      global_variables.each do |g|
        next if g == :$_ || g == :$~ || g == :$! || g == :$@ || g.start_with?("$SpOracle")
        val = (eval(g.to_s) rescue nil) # rubocop:disable Security/Eval
        out << [g.to_s, val, g.to_s]
      end
      mods = []
      ObjectSpace.each_object(Module) { |m| mods << m if !@boot_modules[m] || @touched[m] }
      saved = Warning[:deprecated]
      Warning[:deprecated] = false
      mods.each do |m|
        # (a module may redefine its own `name`)
        nm = MODULE_NAME.bind_call(m)
        next if m == SpOracle || (nm && nm.start_with?("SpOracle"))
        m.constants(false).each do |k|
          next if m.autoload?(k)
          val = (m.const_get(k, false) rescue nil)
          # (TOPLEVEL_BINDING's locals are the toplevel locals, roots above)
          out << ["constant #{m}::#{k}", val, "constant #{m}::#{k}"] unless val.is_a?(Module) || val.equal?(TOPLEVEL_BINDING)
        end
        m.instance_variables.each { |iv| out << ["#{m} #{iv}", m.instance_variable_get(iv), "#{m} #{iv}"] }
        (m.class_variables(false) rescue []).each { |cv| out << ["#{m} #{cv}", (m.class_variable_get(cv) rescue nil), "#{m} #{cv}"] }
      end
      Warning[:deprecated] = saved
      out
    end

    # (no method of the program's objects is called on the way: `==` and
    # `is_a?` may be theirs, and a `==` that reads its argument's ivars
    # raises on `true`)
    # Do bindings b and b2 name one variable by v? Set it through b and read
    # it through b2, then put it back.
    def same_variable?(b, b2, v, val)
      mark = Object.new
      b.local_variable_set(v, mark)
      b2.local_variable_get(v).equal?(mark)
    rescue NameError
      false
    ensure
      b.local_variable_set(v, val)
    end

    def leaf?(x)
      case x
      when NilClass, TrueClass, FalseClass, Symbol, Numeric, String, Module, ObjectSpace::InternalObjectWrapper,
           Thread, Fiber, TracePoint, Runner, Frame
        true
      else
        false
      end
    end

    def edges(x)
      case x
      when Proc
        b = (x.binding rescue nil)
        return [] unless b
        sl = x.source_location
        names = sl ? block_names(sl[0], sl[1]) : nil
        [b.receiver] + b.local_variables.filter_map { |v| (b.local_variable_get(v) rescue nil) if !names || names[v] }
      when Binding
        [x.receiver] + x.local_variables.map { |v| x.local_variable_get(v) rescue nil }
      else
        ObjectSpace.reachable_objects_from(x) || []
      end
    end

    # every name and reachable object that refers to o directly, each with
    # the chain from the name that reaches it
    def holders(o, exclude_frame, keep = nil)
      seen = {}.compare_by_identity   # object => [name or class, parent]
      queue = []
      names = {}
      objs = {}.compare_by_identity
      roots(exclude_frame).each do |label, v, key|
        next if keep && !keep.(key)
        names[key] ||= label if v.equal?(o)
        next if leaf?(v) || seen[v]
        seen[v] = [label, nil]
        queue << v
      end
      until queue.empty?
        x = queue.shift
        edges(x).each do |y|
          objs[x] ||= chain_of(seen, x) if y.equal?(o)
          next if leaf?(y) || seen[y]
          seen[y] = ["#{y.class}", x]
          queue << y
        end
      end
      Holders.new(names, objs)
    end

    def chain_of(seen, x)
      chain = []
      while x
        lab, par = seen[x]
        chain.unshift(lab || x.class.to_s)
        x = par
      end
      chain.join(" -> ")
    end

    def holder_path(o, exclude_frame)
      seen = {}.compare_by_identity
      queue = []
      roots(exclude_frame).each do |label, v, _|
        return label if v.equal?(o)
        next if leaf?(v) || seen[v]
        seen[v] = [label, nil]
        queue << v
      end
      until queue.empty?
        x = queue.shift
        edges(x).each do |y|
          return chain_of(seen, x) if y.equal?(o)
          next if leaf?(y) || seen[y]
          seen[y] = ["#{y.class}", x]
          queue << y
        end
      end
      nil
    end
  end

  def self.v(id, val) = (@runner ? @runner.probe(id, val) : val)
  def self.runner=(r)
    @runner = r
  end
end

# ---- the driver ----
module SpOracleDriver
  module_function

  CHECKS_SET = SpOracle::CHECKS

  Claim = Struct.new(:kind, :path, :sl, :sc, :el, :ec, :nk, :name, :fields, keyword_init: true) do
    def check = fields["check"]
    def method_claim? = nk == "DefNode"
  end

  # The claims in a file: [claims, the lines that are no claim].
  def read_claims(file, base)
    bad = []
    claims = File.readlines(file, chomp: true, encoding: "UTF-8").filter_map do |l|
      next if l.strip.empty? || l.start_with?("#")
      k, f, sl, sc, el, ec, nk, nm, *rest = l.split("\t")
      unless nm && [sl, sc, el, ec].all? { |x| x.match?(/\A\d+\z/) }
        bad << l
        next
      end
      fields = rest.to_h { |kv| kv.split("=", 2) }
      Claim.new(kind: k, path: File.expand_path(f, base), sl: sl.to_i, sc: sc.to_i, el: el.to_i, ec: ec.to_i,
                nk: nk, name: nm, fields: fields)
    end
    [claims, bad]
  end

  # stdout, stderr, status and whether the time ran out
  def capture(cmd, env: {}, chdir: nil, stdin: File::NULL, timeout: 120)
    ro, wo = IO.pipe
    re, we = IO.pipe
    opts = { in: stdin, out: wo, err: we, pgroup: true }
    opts[:chdir] = chdir if chdir
    pid = Process.spawn(env, *cmd, **opts)
    wo.close
    we.close
    out = Thread.new { ro.binmode.read }
    err = Thread.new { re.binmode.read }
    waiter = Process.detach(pid)
    expired = !waiter.join(timeout)
    if expired
      Process.kill("KILL", -pid) rescue nil
      waiter.join
    end
    [out.value, err.value, waiter.value, expired]
  end

  def compiler_claims(spinel, prog, dir)
    out = File.join(dir, "claims.tsv")
    env = { "SPINEL_NEW_CLAIMS" => out, "SP_COLLECT_ERRORS" => "1" }
    _o, e, st, expired = capture([spinel, "--share-strings", prog, "-S"], env: env)
    refused = !st.success? || e.match?(/^spinel: .*(under --share-strings|refus)/)
    [File.exist?(out) ? out : nil, refused, expired ? "the compiler timed out" : e]
  end

  def prism_index(src)
    idx = {}
    walk = lambda do |n|
      return unless n
      loc = n.location
      key = [loc.start_line, loc.start_column, loc.end_line, loc.end_column, n.class.name.split("::").last]
      idx[key] ||= n
      n.compact_child_nodes.each { |ch| walk.(ch) }
    end
    walk.(Prism.parse(src).value)
    idx
  end

  # wraps: [[start_offset, end_offset, id]]
  def rewrite(src, wraps)
    ins = Hash.new { |h, k| h[k] = [] }
    wraps.each do |s, e, id|
      ins[s] << [1, -e, "::SpOracle.v(#{id}, ("]
      ins[e] << [0, -s, "))"]
    end
    bytes = src.b
    out = +""
    last = 0
    ins.keys.sort.each do |off|
      out << bytes[last...off]
      # at one offset: closers first (innermost first), then openers (outermost first)
      ins[off].sort_by { |kind, ord, _| [kind, ord] }.each { |_, _, t| out << t }
      last = off
    end
    out << bytes[last..]
    out.force_encoding(src.encoding)
  end

  # The expression whose value a claimed node answers: a statement list, an
  # else clause or parentheses answer their last statement. nil where there is
  # none: a next, break or return is no value (the walk never gives it an
  # identity, so a claim on it, or on a list ending in it, says nothing; the
  # value it passes on is its argument's own node).
  def value_node(n)
    loop do
      case n
      when Prism::ElseNode then n = n.statements
      when Prism::ParenthesesNode then n = n.body
      when Prism::StatementsNode then n = n.body.last
      when Prism::NextNode, Prism::BreakNode, Prism::ReturnNode, Prism::RedoNode, Prism::RetryNode then return nil
      else return n
      end
      return nil unless n
    end
  end

  def not_cruby?(prog)
    File.foreach(prog, encoding: "BINARY").first(12).any? { |l| l.match?(/\A#\s*spinel:\s*not-cruby\b/) }
  end

  # Check one program. Returns a report hash: "status" is "checked", "skipped"
  # or "error"; "claims" lists every claim with its outcome.
  def check_program(prog, opts)
    prog = File.expand_path(prog)
    rep = { "program" => prog, "status" => "checked", "refused" => false, "unprobed" => [], "notes" => [], "claims" => [],
            "perturbed" => nil, "oracle_error" => nil }
    return rep.merge("status" => "skipped", "notes" => ["not-cruby"]) if not_cruby?(prog)
    Dir.mktmpdir("nso") do |d|
      if opts[:claims]
        file = opts[:claims]
        base = File.dirname(File.expand_path(file))
        err = ""
      else
        file, rep["refused"], err = compiler_claims(opts[:spinel], prog, d)
        base = Dir.pwd
        unless file
          first = err.lines.grep(/^spinel:/).first
          return rep.merge("status" => first ? "skipped" : "error", "notes" => ["no claims: #{(first || err.lines.first || "no output").strip}"])
        end
      end
      claims, bad = read_claims(file, base)
      bad.each { |l| rep["notes"] << "claims file: not a claim: #{l[0, 60].inspect}" }
      src = File.read(prog, encoding: "UTF-8")
      idx = prism_index(src)

      # the checks to run: expression sites (wrapped) and method answers
      ids = claims.each_index.to_a
      sites = {}      # [start, end] => [claim index]
      rets = {}       # [path, line, name] => [claim index]
      out = claims.map { |c| { "kind" => c.kind, "check" => c.check || "new", "stated" => !c.check.nil?, "site" => nil, "reached" => false,
                               "checked" => 0, "disproved" => 0, "witness" => nil, "mutations" => 0, "param" => c.fields["param"] } }
      ids.each do |i|
        c = claims[i]
        o = out[i]
        o["site"] = "#{File.basename(c.path)}:#{c.sl}:#{c.sc} #{c.nk} #{c.name}"
        unless CHECKS_SET.include?(o["check"])
          rep["notes"] << "claim kind #{c.kind}: unknown check #{o["check"].inspect}, checked as new"
          o["check"] = "new"
        end
        next if o["check"] == "none"
        if c.method_claim?
          rets[[c.path, c.sl, c.name]] = (rets[[c.path, c.sl, c.name]] || []) << i
          next
        end
        if SpOracle::METHOD_CHECKS.include?(o["check"])
          rep["unprobed"] << [i, "#{o["check"]} claim on no method"]
          next
        end
        if c.path != prog
          rep["unprobed"] << [i, "other file"]
          next
        end
        n = idx[[c.sl, c.sc, c.el, c.ec, c.nk]]
        unless n
          rep["unprobed"] << [i, "no Prism node"]
          next
        end
        n = value_node(n)
        # (the Strings of `*list` are the elements of the list: an unshared
        # claim on the splat is recorded on each)
        n = n.expression if n.is_a?(Prism::SplatNode) && o["check"] == "unshared" && n.expression
        if n.nil?
          rep["unprobed"] << [i, "no value (jump or empty)"]
          next
        end
        if n.is_a?(Prism::StringNode) && n.opening_loc.nil?
          rep["unprobed"] << [i, "string part"]
          next
        end
        (sites[[n.location.start_offset, n.location.end_offset]] ||= []) << i
      end
      wraps = sites.keys.each_with_index.map { |(s, e), k| [s, e, k] }
      site_claims = sites.values
      # drop a wrap that makes the copy fail to parse
      rewritten = rewrite(src, wraps)
      unless Prism.parse(rewritten).success?
        keep = wraps.select { |w| Prism.parse(rewrite(src, [w])).success? }
        (wraps - keep).each { |w| site_claims[w[2]].each { |i| rep["unprobed"] << [i, "wrap does not parse"] } }
        wraps = keep
        rewritten = rewrite(src, wraps)
      end
      cfg = { "sites" => wraps.to_h { |s, e, k| [k.to_s, site_claims[k]] },
              "claims" => ids.to_h { |i| [i.to_s, { "check" => out[i]["check"], "param" => out[i]["param"] }] },
              "rets" => rets.map { |(path, line, name), v| { "path" => path, "line" => line, "name" => name, "ids" => v } },
              "max" => opts[:max], "path" => prog }
      File.write(File.join(d, "prog.rb"), rewritten)
      File.binwrite(File.join(d, "claims"), Marshal.dump(cfg))
      args = File.exist?("#{prog}.args") ? Shellwords.split(File.read("#{prog}.args")) : []
      stdin = File.exist?("#{prog}.stdin") ? "#{prog}.stdin" : File::NULL
      ruby = RbConfig.ruby
      plain_out, _pe, pst, pexp = capture([ruby, "--enable-frozen-string-literal", prog, *args], stdin: stdin, timeout: opts[:timeout])
      return rep.merge("status" => "skipped", "notes" => rep["notes"] + ["the plain CRuby run timed out"]) if pexp
      o_out, o_err, ost, oexp = capture([ruby, "--enable-frozen-string-literal", SpOracle::ORACLE_FILE, "--child", *args],
                                        env: { "SP_ORACLE_DIR" => d }, stdin: stdin, timeout: opts[:timeout] * 3)
      res_file = File.join(d, "results")
      if oexp || !File.exist?(res_file)
        # (a program that execs never runs the oracle's at_exit: nothing to read)
        why = oexp ? "the oracle run timed out" : "the oracle run wrote no results: #{o_err.lines.last&.strip}"
        return rep.merge("status" => oexp || o_err.empty? ? "skipped" : "error", "notes" => rep["notes"] + [why])
      end
      res = Marshal.load(File.binread(res_file))
      if plain_out != o_out || pst.exitstatus != ost.exitstatus
        pl = plain_out.lines
        ol = o_out.lines
        i = (0...[pl.size, ol.size].max).find { |k| pl[k] != ol[k] }.to_i
        rep["perturbed"] = "line #{i + 1}: CRuby #{pl[i].inspect} oracle #{ol[i].inspect}, exit #{pst.exitstatus}/#{ost.exitstatus}"
      end
      rep["oracle_error"] = res["oracle-error"]&.fetch("witness")
      ids.each do |i|
        r = res[i]
        next unless r
        out[i].merge!("reached" => r["checked"] > 0, "checked" => r["checked"], "disproved" => r["disproved"], "witness" => r["witness"],
                      "mutations" => r["mutations"])
      end
      rep["claims"] = out
      rep["child_stderr"] = o_err.empty? ? nil : (o_err[-2000..] || o_err)
      rep
    end
  end

  def disproved(rep) = rep["perturbed"] ? [] : rep["claims"].select { |c| c["disproved"] > 0 }

  def summary(reps)
    done = reps.select { |r| r["status"] == "checked" }
    kinds = Hash.new { |h, k| h[k] = { "check" => nil, "listed" => 0, "unstated" => 0, "sites" => 0, "reached" => 0, "disproved" => 0 } }
    done.each do |r|
      r["claims"].each do |c|
        k = kinds[c["kind"]]
        k["check"] = k["check"] && k["check"] != c["check"] ? "mixed" : c["check"]
        k["listed"] += 1
        k["unstated"] += 1 unless c["stated"]
        next if c["check"] == "none"
        k["sites"] += 1
        k["reached"] += 1 if c["reached"]
        k["disproved"] += 1 if c["disproved"] > 0 && !r["perturbed"]
      end
    end
    kinds
  end

  def report_text(reps, opts)
    done = reps.select { |r| r["status"] == "checked" }
    kinds = summary(reps)
    lines = []
    bad = done.sum { |r| disproved(r).size }
    lines << "new-string-oracle: #{reps.size} programs, #{done.size} checked, #{reps.count { |r| r["status"] == "skipped" }} skipped, " \
             "#{reps.count { |r| r["status"] == "error" }} errors, #{done.count { |r| r["perturbed"] }} perturbed, #{bad} claims disproved"
    lines << format("  %-16s %-9s %8s %8s %8s %9s", "kind", "check", "listed", "checkable", "reached", "disproved")
    kinds.sort_by { |k, _| k }.each do |k, v|
      lines << format("  %-16s %-9s %8d %8d %8d %9d", k, v["check"], v["listed"], v["sites"], v["reached"], v["disproved"])
    end
    uns = done.flat_map { |r| r["claims"].select { |c| c["check"] == "unshared" && c["reached"] } }
    lines << "  unshared: #{uns.size} claims recorded an object, #{uns.count { |c| c["mutations"] > 0 }} had one changed in place " \
             "(#{uns.sum { |c| c["mutations"] }} changes checked)" unless uns.empty?
    unstated = kinds.select { |_, v| v["unstated"] > 0 }.keys
    lines << "  kinds with no stated check (checked as new): #{unstated.sort.join(", ")}" unless unstated.empty?
    un = done.flat_map { |r| r["unprobed"].map { |_, why| why } }.tally
    lines << "  unprobed: #{un.map { |w, n| "#{n} #{w}" }.join(", ")}" unless un.empty?
    reps.each do |r|
      name = r["program"].sub(/\A#{Regexp.escape(Dir.pwd)}\//, "")
      disproved(r).each do |c|
        lines << "DISPROVED #{name}: #{c["kind"]} #{c["site"]} (#{c["disproved"]}/#{c["checked"]}): #{c["witness"]}"
      end
      lines << "PERTURBED #{name}: #{r["perturbed"]}" if r["perturbed"]
      lines << "ORACLE-ERROR #{name}: #{r["oracle_error"]}" if r["oracle_error"]
      r["notes"].each { |n| lines << "#{r["status"] == "error" ? "ERROR" : "note"} #{name}: #{n}" unless n == "not-cruby" }
    end
    lines.join("\n") + "\n"
  end

  def run(argv)
    %w[json optparse rbconfig shellwords tmpdir].each { |lib| require lib }
    opts = { spinel: File.expand_path("../bin/spinel", __dir__), max: 20, jobs: 2, timeout: 60 }
    json = false
    report = nil
    OptionParser.new do |o|
      o.banner = "Usage: ruby tools/new_string_oracle.rb [options] PROG.rb..."
      o.on("--spinel BIN") { |v| opts[:spinel] = File.expand_path(v) }
      o.on("--claims FILE", "Read these claims (one program) instead of asking the compiler") { |v| opts[:claims] = v }
      o.on("--max N", Integer, "Evaluations checked per claim (default 20)") { |v| opts[:max] = v }
      o.on("--jobs N", Integer, "Programs checked at once (default 2)") { |v| opts[:jobs] = v }
      o.on("--timeout S", Integer, "Seconds a CRuby run may take (the oracle's gets three times)") { |v| opts[:timeout] = v }
      o.on("--report FILE", "Also write the report to FILE") { |v| report = v }
      o.on("--json", "Print the reports as JSON") { json = true }
    end.parse!(argv)
    abort "new_string_oracle: no programs" if argv.empty?
    abort "new_string_oracle: --claims names the claims of one program" if opts[:claims] && argv.size != 1
    abort "new_string_oracle: no compiler at #{opts[:spinel]} (build it, or pass --spinel)" unless opts[:claims] || File.executable?(opts[:spinel])
    queue = Queue.new
    argv.each_with_index { |p, i| queue << [i, p] }
    reps = Array.new(argv.size)
    workers = [opts[:jobs], argv.size].min.times.map do
      Thread.new do
        loop do
          i, prog = queue.pop(true)
          reps[i] = begin
            check_program(prog, opts)
          rescue StandardError => e
            { "program" => File.expand_path(prog), "status" => "error", "claims" => [], "unprobed" => [], "notes" => ["#{e.class}: #{e.message}"] }
          end
        end
      rescue ThreadError
        nil
      end
    end
    workers.each(&:join)
    text = report_text(reps, opts)
    if json
      puts JSON.pretty_generate(reps)
    else
      print text
    end
    File.write(report, text) if report
    exit(reps.any? { |r| disproved(r).any? } ? 1 : reps.any? { |r| r["status"] == "error" } ? 2 : 0)
  end
end

# (in a method: the program's top-level locals are TOPLEVEL_BINDING's, and
# the oracle's must not be among them)
def SpOracle.child_main
  dir = ENV.fetch("SP_ORACLE_DIR")
  cfg = Marshal.load(File.binread(File.join(dir, "claims")))
  runner = SpOracle::Runner.new(cfg["sites"].transform_keys(&:to_i), cfg["claims"].transform_keys(&:to_i), cfg["max"])
  runner.prog_path = cfg["path"]
  cfg["rets"].each { |c| runner.add_ret(c["path"], c["line"], c["name"], c["ids"]) }
  SpOracle.runner = runner
  src = File.read(File.join(dir, "prog.rb"), encoding: "UTF-8")
  path = cfg["path"]
  $0 = path
  # (Marshal, not JSON: a program may reopen String#to_s, which JSON calls)
  at_exit { File.binwrite(File.join(dir, "results"), Marshal.dump(runner.results.to_a.to_h)) }
  runner.trace
  TOPLEVEL_BINDING.eval(src, path, 1)
end

if ARGV.first == "--child"
  ARGV.shift
  SpOracle.child_main
else
  SpOracleDriver.run(ARGV.dup)
end
