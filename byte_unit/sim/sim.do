run 0ns
log -r /byte_unit_tb/*
do waves_all.do;
run -all; wave zoom full;
simstats; quit