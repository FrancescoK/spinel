class String::Helper
  def w = :sh
end
module M
  class Helper
    def w = :mh
  end
end
begin
  p Helper.new.w
rescue NameError => e
  p e.class
end
p String::Helper.new.w, M::Helper.new.w
