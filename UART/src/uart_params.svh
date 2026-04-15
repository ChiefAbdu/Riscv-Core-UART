`ifndef UART_PARAMS_SVH
`define UART_PARAMS_SVH

// Uart Params
parameter int CLOCK_FREQ      = 125_000_000;   // Hz
parameter int BAUD_RATE       = 115_200;

// Receiver/Transmitter LocalParams
localparam int SYMBOL_EDGE_TIME    = CLOCK_FREQ / BAUD_RATE;
localparam int CLOCK_COUNTER_WIDTH = $clog2(SYMBOL_EDGE_TIME);
localparam int SAMPLE_TIME           = SYMBOL_EDGE_TIME / 2;

`endif
