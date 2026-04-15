`include "uart_params.svh"  // CLOCK_FREQ, BAUD_RATE defined here

module uart_transmitter (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] data_in,
    input  logic       data_in_valid,
    output logic       data_in_ready,
    output logic       serial_out
);

    // -------------------------------------------------------------------------
    // Parameters & Localparams
    // -------------------------------------------------------------------------
    localparam int SYMBOL_EDGE_TIME    = CLOCK_FREQ / BAUD_RATE;
    localparam int CLOCK_COUNTER_WIDTH = $clog2(SYMBOL_EDGE_TIME);

    // -------------------------------------------------------------------------
    // Internal signals
    // -------------------------------------------------------------------------
    logic [9:0]                     tx_shift_value, tx_shift_next;
    logic                           tx_shift_ce, tx_shift_load;

    logic [3:0]                     bit_counter_value, bit_counter_next;
    logic                           bit_counter_ce, bit_counter_rst;

    logic [CLOCK_COUNTER_WIDTH-1:0] clock_counter_value, clock_counter_next;
    logic                           clock_counter_ce, clock_counter_rst;

    logic                           sending, done;

    // -------------------------------------------------------------------------
    // Derived control signals
    // -------------------------------------------------------------------------
    logic data_in_fire, symbol_edge;

    assign data_in_fire = data_in_valid & data_in_ready;
    assign symbol_edge  = (clock_counter_value == CLOCK_COUNTER_WIDTH'(SYMBOL_EDGE_TIME - 1));
    assign done         = (bit_counter_value == 4'd9) & symbol_edge;

    // -------------------------------------------------------------------------
    // TX shift register
    // Frame format: {stop_bit=1, data[7:0], start_bit=0} — transmitted LSB first
    // On load:  capture {1, data_in[7:0], 0}
    // On shift: shift right, feeding 1s into MSB (idle/stop level)
    // serial_out is always the LSB of the shift register
    // -------------------------------------------------------------------------
    assign tx_shift_next = tx_shift_load ? {1'b1, data_in, 1'b0}          // parallel load
                                         : {1'b1, tx_shift_value[9:1]};   // shift right, fill 1

    assign tx_shift_ce   = data_in_fire | (symbol_edge & sending);  // load or shift each symbol

    always_ff @(posedge clk) begin
        if (tx_shift_ce)
            tx_shift_value <= tx_shift_next;
    end

    // tx_shift_load is high on the very first cycle (data_in_fire), low during shifting
    assign tx_shift_load = data_in_fire;

    // -------------------------------------------------------------------------
    // Bit counter — counts 0..9 (start + 8 data + stop)
    // -------------------------------------------------------------------------
    assign bit_counter_next = bit_counter_value + 4'd1;
    assign bit_counter_ce   = symbol_edge & sending;
    assign bit_counter_rst  = done | reset;

    always_ff @(posedge clk) begin
        if (bit_counter_rst)
            bit_counter_value <= 4'd0;
        else if (bit_counter_ce)
            bit_counter_value <= bit_counter_next;
    end

    // -------------------------------------------------------------------------
    // Clock counter — runs while 'sending', resets on each symbol edge
    // -------------------------------------------------------------------------
    assign clock_counter_next = clock_counter_value + 1'b1;
    assign clock_counter_ce   = sending;
    assign clock_counter_rst  = symbol_edge | done | reset;

    always_ff @(posedge clk) begin
        if (clock_counter_rst)
            clock_counter_value <= '0;
        else if (clock_counter_ce)
            clock_counter_value <= clock_counter_next;
    end

    // -------------------------------------------------------------------------
    // 'sending' — asserted when a frame is in progress
    // Set on data_in_fire, cleared when the stop bit has been fully transmitted
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset | done)
            sending <= 1'b0;
        else if (data_in_fire)
            sending <= 1'b1;
    end

    // -------------------------------------------------------------------------
    // Outputs
    // ready when not currently sending (single-entry, no FIFO)
    // serial_out idles HIGH (mark), transmits LSB of shift register
    // -------------------------------------------------------------------------
    assign data_in_ready = ~sending;
    assign serial_out    = sending ? tx_shift_value[0] : 1'b1;  // idle = HIGH

endmodule
