require "json"

class MergeCandidate
  def merge(options) = self
end

def receiver(hash)
  hash ? JSON.parse('{"source":1}') : MergeCandidate.new
end

def merge_keywords(value)
  value.merge(
    entry_00: "value-00",
    entry_01: "value-01",
    entry_02: "value-02",
    entry_03: "value-03",
    entry_04: "value-04",
    entry_05: "value-05",
    entry_06: "value-06",
    entry_07: "value-07",
    entry_08: "value-08",
    entry_09: "value-09",
    entry_10: "value-10",
    entry_11: "value-11",
    entry_12: "value-12",
    entry_13: "value-13",
    entry_14: "value-14",
    entry_15: "value-15",
    entry_16: "value-16",
    entry_17: "value-17",
    entry_18: "value-18",
    entry_19: "value-19",
    entry_20: "value-20",
    entry_21: "value-21",
    entry_22: "value-22",
    entry_23: "value-23",
    entry_24: "value-24",
    entry_25: "value-25",
    entry_26: "value-26",
    entry_27: "value-27",
    entry_28: "value-28",
    entry_29: "value-29",
    entry_30: "value-30",
    entry_31: "value-31",
    entry_32: "value-32",
    entry_33: "value-33",
    entry_34: "value-34",
    entry_35: "value-35",
  )
end

original = receiver(true)
merged = merge_keywords(original)
p [merged.size, merged["source"], merged[:entry_00], merged[:entry_17], merged[:entry_35]]
p [original.size, original["source"]]
candidate = receiver(false)
p merge_keywords(candidate) == candidate
