# An advisory `-> String?` seed pins the return to a bare `const char *`, and
# the implicit nil arm of a valueless `if` then returned the EMPTY STRING --
# the slot's default -- rather than NULL. `.nil?` answered false and `compact`
# kept the slot, so a page rendered `class="sidebar admin "` where Rails
# rendered `class="sidebar admin"` (#4250). An advisory seed must never remove
# the nil arm: `String?` says may be nil.
# spinel: rbs-seed-check
class Helper
  def self.guard_if(flag)
    "yes" if flag
  end

  def self.explicit_nil(flag)
    return nil unless flag
    "yes"
  end

  def self.case_nil(n)
    case n
    when 1 then "one"
    end
  end

  def self.count(flag)
    3 if flag
  end
end

puts Helper.guard_if(false).nil?
puts Helper.guard_if(true)
puts Helper.explicit_nil(false).nil?
puts Helper.explicit_nil(true)
puts Helper.case_nil(2).nil?
puts Helper.case_nil(1)
puts Helper.count(false).nil?
puts Helper.count(true)
puts [ "a", Helper.guard_if(false), Helper.case_nil(2) ].compact.length
puts [ "a", Helper.guard_if(true) ].compact.join(" ")
