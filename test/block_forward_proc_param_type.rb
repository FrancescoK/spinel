# spinel: share
def fwd_map(&b)  = ["a", "bb"].map(&b)
def fwd_sel(&b)  = ["a", "bb"].select(&b)
def fwd_sort(&b) = ["a", "bb"].sort_by(&b)
def fwd_min(&b)  = ["a", "bb"].min_by(&b)
def fwd_max(&b)  = ["a", "bb"].max_by(&b)
def fwd_grp(&b)  = ["a", "bb"].group_by(&b)
def fwd_cnt(&b)  = ["a", "bb"].count(&b)

len = ->(s) { s.length }
p fwd_map(&len)
p fwd_sort(&len)
p fwd_min(&len)
p fwd_max(&len)
p fwd_grp(&len)

long = ->(s) { s.length > 1 }
p fwd_sel(&long)
p fwd_cnt(&long)

def fwd_int(&b) = [1, 2].map(&b)
dbl = ->(x) { x * 2 }
p fwd_int(&dbl)

p(["a", "bb"].map(&len))
p(["a", "bb"].map { |s| s.length })
