# The corpus writes PASS, FAIL or ERR to each .ok. Only recorded failures
# may remain red with String sharing; a newly passing entry can be removed.
FILENAME == ARGV[1] {
    sub(/#.*/, "")
    if (NF == 1) known[$1] = 1
    else if (NF) {
        print "gate-test-shared: invalid entry: " $0
        bad++
    }
    next
}
{
    name = FILENAME
    sub(/^.*\//, "", name)
    sub(/\.ok$/, "", name)
    if ($0 == "PASS") {
        pass++
        if (name in known)
            print "gate-test-shared: " name " passes; remove it from the list"
    }
    else if ($0 == "FAIL" || $0 == "ERR") {
        if (name in known) {
            expected++
            print "gate-test-shared: known " $0 ": " name
        }
        else {
            bad++
            print "gate-test-shared: " $0 ": " name " (not in known-failures.txt)"
            for (i = 0; i < 40 && (getline line < (FILENAME ".diff")) > 0; i++)
                print line
            close(FILENAME ".diff")
        }
    }
    else {
        bad++
        print "gate-test-shared: invalid result: " FILENAME
    }
}
END {
    printf "gate-test-shared: %d pass, %d known failures, %d new failures\n", pass, expected, bad
    exit (bad != 0)
}
