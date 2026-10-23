# When an_settle_seed_boxes drops a parameter seed (here `combo_codes_train`'s,
# handed `@codes_tr[fa]` from a table an empty block fills with nil), the local
# pins it clears are the ones narrowed under that seed: the method's own. It
# cleared every local's pin in the program, and the re-run did not give back
# `SdkDataset.load`'s `columns` and `SdkBases.build`'s `raw_train`/`raw_test`
# (Array[Array[Float]]): `train.columns[k]` read a box, `SdkColumnSet#add`'s
# parameters, which carry no signature, took it, and stayed boxed.
# spinel: rbs-seed-check
class SdkDataset
  attr_reader :columns

  def initialize(columns)
    @columns = columns
  end

  def self.load(n, rows)
    columns = Array.new(n) { Array.new(0, 0.0) }
    i = 0
    while i < rows
      k = 0
      while k < columns.length
        columns[k] << (i + k) * 0.5
        k += 1
      end
      i += 1
    end
    new(columns)
  end
end

class SdkPermutations
  def initialize
    @tables = Array.new(0) { Array.new(0, 0) }
  end

  def add(perm)
    @tables << perm
    @tables.length
  end
end

class SdkPairPlan

  def setup(n_features)
    @codes_tr = Array.new(n_features) { }
  end

  def build(fa, fb, mult, n)
    SdkPipeline.combo_codes_train(@codes_tr[fa], @codes_tr[fb], mult, n)
  end
end

class SdkColumnSet
  attr_reader :n

  def initialize
    @n = 0
  end

  def add(col_tr, col_te, max_bins)
    @n += col_tr.length + col_te.length + max_bins
  end
end

class SdkSharedEncoding
  attr_reader :cols

  def initialize(train, tst, max_bins)
    @cols = SdkColumnSet.new
    k = 0
    while k < train.columns.length
      @cols.add(train.columns[k], tst.columns[k], max_bins)
      k += 1
    end
  end
end

module SdkPipeline
  def self.combo_codes_train(ci, cj, mult, n)
    out = Array.new(n, 0)
    i = 0
    while i < n
      out[i] = ci[i] * mult + cj[i]
      i += 1
    end
    out
  end

  def self.encode_target(plan)
    perms = SdkPermutations.new
    plan.setup(2)
    perms.add([1, 0])
  end
end

class SdkBases

  def initialize(raw_train, raw_test)
    @raw_train = raw_train
    @raw_test = raw_test
  end

  def width
    @raw_train.length + @raw_test.length
  end

  def self.build(train, tst)
    num_idx = []
    k = 0
    while k < tst.columns.length
      num_idx << k
      k += 1
    end
    raw_train = num_idx.map { |kk| train.columns[kk] }
    raw_test = num_idx.map { |kk| tst.columns[kk] }
    SdkBases.new(raw_train, raw_test)
  end
end

train = SdkDataset.load(2, 3)
tst = SdkDataset.load(2, 3)
bases = SdkBases.build(train, tst)
sh = SdkSharedEncoding.new(train, tst, 255)
p bases.width + sh.cols.n
p SdkPipeline.encode_target(SdkPairPlan.new)
