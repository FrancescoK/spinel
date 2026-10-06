# callgrind runs

Instruction counts (valgrind callgrind, "Ir") for optcarrot (checksum 59662)
and selected benchmarks, comparing two spinel commits. Edit `callgrind.conf`
(BASE, HEAD, BENCHES, LABEL) and push this branch; the summary is on the run
page and in the `callgrind-<LABEL>` artifact.

Optional keys: `BASE_ENV` / `HEAD_ENV` (space-separated `NAME=value` pairs
the spinel compiles of that side run with, e.g. `HEAD_ENV=SPINEL_SHARE_STRINGS=1`
with `BASE` = `HEAD` to compare one sha with itself under a compile-time
switch) and `FPS_PAIRS` (optcarrot fps from N alternating base/head pairs,
ABBA order, after the Ir runs). A key left out is empty / 0; whoever stages
the next run removes these lines so they do not carry over.
