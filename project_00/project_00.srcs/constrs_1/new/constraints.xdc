# Clock constraint
create_clock -period 10.000 -name clk [get_ports clk]

# Basys3 pin assignments
set_property PACKAGE_PIN W5   [get_ports clk]
set_property PACKAGE_PIN U18  [get_ports reset]

# IO Standards
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports {pc_out_debug[*]}]

# Bypass unassigned pins warning
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]