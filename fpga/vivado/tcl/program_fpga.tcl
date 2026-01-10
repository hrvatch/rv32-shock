# Program FPGA bitstream via JTAG
# Usage: vivado -mode batch -source program_fpga.tcl -tclargs <bitstream_path>

# Check if bitstream path is provided
if { $argc > 0 } {
    set bitstream_file [lindex $argv 0]
} else {
    puts "ERROR: No bitstream file specified"
    puts "Usage: vivado -mode batch -source program_fpga.tcl -tclargs <bitstream_path>"
    exit 1
}

# Check if bitstream file exists
if { ![file exists $bitstream_file] } {
    puts "ERROR: Bitstream file not found: $bitstream_file"
    exit 1
}

puts "=========================================="
puts "Programming FPGA with bitstream:"
puts "  $bitstream_file"
puts "=========================================="

# Open hardware manager
open_hw_manager

# Connect to local hardware server
puts "Connecting to hardware server..."
connect_hw_server -allow_non_jtag

# Open and refresh the target
puts "Opening hardware target..."
open_hw_target

# Get the first device (should be the XC7A200T on Nexys Video)
set device [lindex [get_hw_devices] 0]
puts "Target device: $device"

# Set the device as current
current_hw_device $device

# Refresh the device
refresh_hw_device $device

# Set the bitstream file
set_property PROGRAM.FILE $bitstream_file $device

# Program the device
puts "Programming device..."
program_hw_devices $device

# Verify programming was successful
if { [get_property REGISTER.IR.BIT5_DONE [lindex [get_hw_devices] 0]] } {
    puts "=========================================="
    puts "SUCCESS: FPGA programmed successfully!"
    puts "=========================================="
} else {
    puts "=========================================="
    puts "ERROR: Programming failed!"
    puts "=========================================="
    exit 1
}

# Cleanup
close_hw_target
disconnect_hw_server
close_hw_manager

exit
