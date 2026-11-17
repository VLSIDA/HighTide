# Preserve the original CTS repair and full global-route repair sequence.
# Extraction moved worst hold from -1.46827 ps at global route to -54.8109 ps
# (294 violations). Add margin at the routed repair stage, without changing
# clock/I/O constraints or running placement-based hold repair differently.
set ::env(HOLD_SLACK_MARGIN) 80
