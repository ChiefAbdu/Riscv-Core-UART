`ifndef UART_PARAMS_SVH
`define UART_PARAMS_SVH

localparam int CLOCK_FREQ      = 125_000_000;   // Hz
localparam int BAUD_RATE       = 115_200;

localparam int WIDTH           = 1;              // button bus width

localparam int DEBOUNCE_SAMPLES  = CLOCK_FREQ / 1_000;   // 1ms stability window
localparam int PULSE_SAMPLES     = CLOCK_FREQ / 10_000;  // 0.1ms min pulse width

localparam int SAMPLE_CNT_MAX  = DEBOUNCE_SAMPLES;
localparam int PULSE_CNT_MAX   = PULSE_SAMPLES;

`endif
