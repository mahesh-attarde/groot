# Linux Perf Tools
# Originally from https://www.brendangregg.com/perf.html  but tailored only for hardware events on CPU
# Useful only for micro-arch
# https://perfwiki.github.io/main/tutorial/
# RECORD
# STATS REPORT
## FE stats
perf stat -e uops_issued.any,idq.dsb_uops,idq.mite_uops,dsb2mite_switches.penalty_cycles  ./test --benchmark_filter=test_foo
## Annotate
# Disassemble and annotate instructions with percentages (needs some debuginfo): stdio optional
perf annotate --stdio
# Use Wrapper on perf, toplev
# https://github.com/aayasin/perf-tools
