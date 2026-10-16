class Duration
  def initialize(seconds)
    @seconds = seconds
  end
end

duration = Duration.new(60)

begin
  p 1.5 < duration
rescue ArgumentError => e
  puts e.message
end
begin
  p 1.5 > duration
rescue ArgumentError => e
  puts e.message
end
begin
  p 1.5 <= duration
rescue ArgumentError => e
  puts e.message
end
begin
  p 1.5 >= duration
rescue ArgumentError => e
  puts e.message
end

begin
  p 1 < duration
rescue ArgumentError => e
  puts e.message
end
begin
  p 1 > duration
rescue ArgumentError => e
  puts e.message
end
begin
  p 1 <= duration
rescue ArgumentError => e
  puts e.message
end
begin
  p 1 >= duration
rescue ArgumentError => e
  puts e.message
end
