module M
  class String::Helper
    def w = :string_helper
  end
  class Helper
    def w = :m_helper
  end
end
p String::Helper.new.w
p M::Helper.new.w
