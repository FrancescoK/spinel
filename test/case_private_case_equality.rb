matcher_class = Class.new do
  def ===(_value)
    true
  end
  private :===
end

result = case 1
         when matcher_class.new then :called
         else :missed
         end
p result

case 1
when matcher_class.new
  p :statement_called
else
  p :statement_missed
end
