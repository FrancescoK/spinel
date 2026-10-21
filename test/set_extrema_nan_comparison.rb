# spinel: share
require "set"

[Set[Float::NAN, 1.0], Set[1.0, Float::NAN]].each do |set|
  begin
    p set.min
  rescue => e
    p [e.class, e.message]
  end
  begin
    p set.max
  rescue => e
    p [e.class, e.message]
  end
  begin
    p set.min_by { |x| x }
  rescue => e
    p [e.class, e.message]
  end
  begin
    p set.max_by { |x| x }
  rescue => e
    p [e.class, e.message]
  end
end

[Set[Float::NAN, 1.0], "other"].each do |set|
  if set.is_a?(Set)
    begin
      p set.min
    rescue => e
      p [e.class, e.message]
    end
    begin
      p set.max
    rescue => e
      p [e.class, e.message]
    end
  end
end

begin
  p Set[Float::NAN, 1.0].min
rescue => e
  p [e.class, e.message]
end
begin
  p Set[1.0, Float::NAN].max
rescue => e
  p [e.class, e.message]
end
