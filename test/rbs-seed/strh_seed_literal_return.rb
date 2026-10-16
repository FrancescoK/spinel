# A method whose return an --rbs signature gives Array[String], answering a
# literal of Strings that are changed in place by whoever reads them: under
# --share-strings the literal was typed as the Array of String handles, then
# refused that form (the return's C type is the seed's), leaving a general
# Array returned from a function declared as the typed one. A seeded return
# is not where the form is given.
module SeedStatements
  def self.all
    [+"CREATE TABLE a", +"CREATE TABLE b", +"CREATE INDEX c"]
  end

  def self.shared
    one = +"shared"
    [one, one]
  end

  def self.early(flag)
    return [+"early"] if flag
    [+"late", +"later"]
  end
end

last = nil
SeedStatements.all.each { |sql| last = sql }
last << ";"
puts last

SeedStatements.shared.each { |s| s << "!" }
puts SeedStatements.shared.join(",")

p SeedStatements.early(true)
p SeedStatements.early(false)
sql = SeedStatements.all
sql[0] << ";"
p sql

# The literal reaches the return through the arms of an `if`, `unless` and
# `case`, a begin's body, rescues and else, a def's own rescue, and a
# `return` that is the method's only statement or one of several.
module SeedArms
  def self.cond(flag)
    if flag == 0
      [+"if"]
    elsif flag == 1
      [+"elsif", +"two"]
    else
      [+"else", +"two", +"three"]
    end
  end

  def self.neg(flag)
    unless flag
      [+"unless"]
    else
      [+"unless-else"]
    end
  end

  def self.kase(n)
    case n
    when 0 then [+"zero"]
    when 1 then [+"one", +"uno"]
    else [+"many"]
    end
  end

  def self.guarded(flag)
    begin
      raise "x" if flag == 0
      [+"ok", +"fine"]
    rescue
      [+"rescued"]
    else
      [+"else-arm"]
    ensure
      flag
    end
  end

  def self.own_rescue(flag)
    raise "y" if flag
    [+"fine"]
  rescue
    [+"own-rescue"]
  end

  def self.chain(f)
    if f == 0 then [+"c0"]
    elsif f == 1 then [+"c1"]
    elsif f == 2 then [+"c2"]
    elsif f == 3 then [+"c3"]
    elsif f == 4 then [+"c4"]
    elsif f == 5 then [+"c5"]
    elsif f == 6 then [+"c6"]
    elsif f == 7 then [+"c7"]
    elsif f == 8 then [+"c8"]
    elsif f == 9 then [+"c9"]
    elsif f == 10 then [+"c10"]
    elsif f == 11 then [+"c11"]
    elsif f == 12 then [+"c12"]
    else [+"else", +"e"]
    end
  end

  def self.nested(f, g)
    begin
      unless f == 0
        if g == 0
          case f
          when 1 then [+"deep1"]
          else
            if g == 1
              [+"deep2", +"x"]
            else
              [+"deep3"]
            end
          end
        else
          [+"shallow"]
        end
      else
        [+"zero"]
      end
    rescue
      [+"never"]
    end
  end

  def self.only_return(flag)
    return [+"ret", +"x"]
  end

  def self.some_returns(flag)
    return [+"early", +"x"] if flag == 0
    return [+"mid"] if flag == 1
    [+"tail"]
  end
end

def last_bang(list)
  last = nil
  list.each { |x| last = x }
  last << "!"
  last
end

[0, 1, 2].each { |f| puts last_bang(SeedArms.cond(f)) }
[true, false].each { |f| puts last_bang(SeedArms.neg(f)) }
[0, 1, 2].each { |n| puts last_bang(SeedArms.kase(n)) }
[0, 1].each { |f| puts last_bang(SeedArms.guarded(f)) }
[true, false].each { |f| puts last_bang(SeedArms.own_rescue(f)) }
[0, 5, 12, 50].each { |f| puts last_bang(SeedArms.chain(f)) }
[[0, 0], [1, 0], [2, 0], [2, 1], [2, 2], [3, 1]].each { |f, g| puts last_bang(SeedArms.nested(f, g)) }
puts last_bang(SeedArms.only_return(1))
[0, 1, 2].each { |f| puts last_bang(SeedArms.some_returns(f)) }
