[-> { ("A"..).step([]) { } }, -> { ("A"...).step({}) { } }, -> { ("a".."e").step([]) { } },
 -> { (1.0..2.0).step([]) { } }, -> { (1..3).step({}) { } }].each do |f|
  begin
    f.call
  rescue TypeError => e
    p e.message
  end
end
