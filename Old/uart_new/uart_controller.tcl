# TCL script for compiling and simulating UART controller in ModelSim

# Change to the working directory where your VHDL files are located
# cd "path/to/your/directory"

# Set the library
vlib work

# Compile the UART transmitter, receiver, and controller
vcom uart_tx.vhd
vcom uart_rx.vhd
vcom uart_controller.vhd

# Compile the testbench
vcom uart_controller_tb.vhd

# Load the simulation
vsim work.uart_controller_tb

# Add signals to the waveform
add wave sim:/uart_controller_tb/UUT/tx_ready_internal
add wave sim:/uart_controller_tb/UUT/tx_out
add wave sim:/uart_controller_tb/UUT/rx_ready_internal
add wave sim:/uart_controller_tb/UUT/rx_data
add wave sim:/uart_controller_tb/clk
add wave sim:/uart_controller_tb/rst_n
add wave sim:/uart_controller_tb/tx_data
add wave sim:/uart_controller_tb/tx_start
add wave sim:/uart_controller_tb/tx_ready
add wave sim:/uart_controller_tb/rx_in
add wave sim:/uart_controller_tb/rx_ready

# Run the simulation
run 450000 ns
