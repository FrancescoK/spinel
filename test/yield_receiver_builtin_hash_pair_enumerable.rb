# min/max/uniq on a Hash site beside an Array one, and dig/fetch's own-key
# forms on a Hash site beside an Array one -- part of K-029's "other names
# likely follow the same pattern" leftover (kilau K-033). min/max/uniq
# already answer correctly on a direct (non-yield) Hash call, by treating
# the materialized [key, value] pairs as a Poly Array (hash_enum_redispatch,
# analyze_infer.c); the per-site yield table just never consulted that
# answer. minmax stays unfixed here on purpose -- a Hash site beside an
# Array one hits a separate, pre-existing boxing gap in the method's own
# compiled body, found and left documented rather than papered over.
def t_min = yield.min
p t_min { { a: 1, b: 2 } }
p t_min { [3, 1, 2] }

def t_max = yield.max
p t_max { { a: 1, b: 2 } }
p t_max { [3, 1, 2] }

def t_uniq = yield.uniq
p t_uniq { { a: 1, b: 2 } }
p t_uniq { [3, 1, 2, 1] }

def t_dig = yield.dig(2)
p t_dig { { a: 1, b: 2 } }
p t_dig { [10, 20, 30] }

def t_fetch = yield.fetch(:z, 99)
p t_fetch { { a: 1, b: 2 } }

def t_fetch_array = yield.fetch(0, 99)
p t_fetch_array { [10, 20, 30] }
