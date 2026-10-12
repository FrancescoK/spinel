# spinel: rbs-seed-contradicted-return
# A Time (or a Range) is a struct passed by value; no conversion makes one an
# object pointer. A method seeded to return an object that answers a Time
# (activesupport's Time.current, declared `-> TimeWithZone`, answers
# Time.now when no zone is set) reached the C compiler as an sp_Time
# returned from an sp_<Class> * function.
class SeedRetStruct
  def now = Time.now
end

p SeedRetStruct.new.now.class
