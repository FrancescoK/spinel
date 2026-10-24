# A conditional whose arms run code ahead of their value (each a call held
# for the interpolation), pushed into a String Array that holds handles: the
# branch form assigns either arm as the handle, in every representation.
module Helpers
  def self.url_encode(s)
    s.to_s.gsub(" ", "+")
  end

  def self.to_query_pairs(params, namespace)
    pairs = []
    params.each do |key, value|
      name = namespace.empty? ? key.to_s : "#{namespace}[#{key.to_s}]"
      pairs << (value.nil? ? "#{url_encode(name)}" : "#{url_encode(name)}=#{url_encode(value.to_s)}")
    end
    pairs.join("&")
  end
end
puts Helpers.to_query_pairs({ "a b" => "x y", "c" => nil }, "")
puts Helpers.to_query_pairs({ q: 1 }, "ns")
