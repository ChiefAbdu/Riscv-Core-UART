`ifndef UART_PARAMS_SVH
`define UART_PARAMS_SVH


// UART Trasnmitter/Receiver params
    parameter CLOCK_FREQ = 125_000_000;
    parameter BAUD_RATE = 115_200;

// Synchronize/Edge-Detection params
    parameter WIDTH = 1

// Debounce/Button-Parser params

    //parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 25000,
    parameter PULSE_CNT_MAX      = 150,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX) + 1,
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1

