require_relative 'cxl_sample'
threads = Array.new(4) do |index|
  Thread.new do
    20.times do
      data = CxlData.new
      raise 'serialized result' unless CxlSample.serialized == 1
      raise 'native result' unless CxlSample.unlocked == 2
      result = CxlSample.callback do |n|
        Thread.pass
        GC.start
        CxlSample.serialized + n
      end
      raise 'callback result' unless result == 4
      message = "error-#{index}"
      caught = CxlSample.protected_callback do |step|
        raise message if step == 1
        Thread.pass
        GC.start
        0
      end
      raise 'cross-thread errinfo' unless caught == true
      GC.start
      raise 'TypedData result' unless data.touch == 1
    end
    20
  end
end
total = threads.map(&:value).sum
threads = nil
GC.start
raise 'TypedData callbacks did not run' unless CxlSample.gc_callbacks
puts total
