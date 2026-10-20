[:exit, :terminate, :raise].each do |name|
  t = [Thread.new { 7 }, 0][0]
  begin
    t.join
    value = case name
    when :exit then t.exit
    when :terminate then t.terminate
    when :raise then t.raise("x")
    end
    p [name, value.class, value.equal?(t)]
  rescue => error
    p [name, error.class, error.message]
  end
end
