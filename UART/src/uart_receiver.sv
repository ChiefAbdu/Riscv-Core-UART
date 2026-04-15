`include "uart_params.svh"  // CLOCK_FREQ, BAUD_RATE defined here

module uart_receiver (
    input  logic       clk,
    input  logic       reset,
    output logic [7:0] data_out,
    output logic       data_out_valid,
    input  logic       data_out_ready,
    input  logic       serial_in
);


    // -------------------------------------------------------------------------
    // Internal signals
    // -------------------------------------------------------------------------
    logic [9:0]                     rx_shift_value, rx_shift_next;
    logic                           rx_shift_ce;

    logic [3:0]                     bit_counter_value, bit_counter_next;
    logic                           bit_counter_ce, bit_counter_rst;

    logic [CLOCK_COUNTER_WIDTH-1:0] clock_counter_value, clock_counter_next;
    logic                           clock_counter_ce, clock_counter_rst;

    logic                           has_byte, start;

    // -------------------------------------------------------------------------
    // Derived control signals
    // -------------------------------------------------------------------------
    logic data_out_fire, symbol_edge, sample_time_pulse, done;

    assign data_out_fire  = data_out_valid & data_out_ready;
    assign symbol_edge    = (clock_counter_value == CLOCK_COUNTER_WIDTH'(SYMBOL_EDGE_TIME - 1));
    assign sample_time_pulse = (clock_counter_value == CLOCK_COUNTER_WIDTH'(SAMPLE_TIME - 1));
    assign done           = (bit_counter_value == 4'd9) & sample_time_pulse;

    // -------------------------------------------------------------------------
    // RX shift register — serial_in shifts in MSB, data captured LSB-first
    // Shift right: first received bit (LSB) walks down to rx_shift_value[1]
    // data_out = rx_shift_value[8:1] recovers the correct byte
    // -------------------------------------------------------------------------
    assign rx_shift_next = {serial_in, rx_shift_value[9:1]};
    assign rx_shift_ce   = sample_time_pulse & start;   // only sample during active frame

    always_ff @(posedge clk) begin
        if (rx_shift_ce)
            rx_shift_value <= rx_shift_next;
    end

    // -------------------------------------------------------------------------
    // Bit counter — counts 0..9 (start + 8 data + stop)
    // -------------------------------------------------------------------------
    assign bit_counter_next = bit_counter_value + 4'd1;
    assign bit_counter_ce   = symbol_edge & start;      // FIX: gate on start
    assign bit_counter_rst  = done | reset;

    always_ff @(posedge clk) begin
        if (bit_counter_rst)
            bit_counter_value <= 4'd0;
        else if (bit_counter_ce)
            bit_counter_value <= bit_counter_next;
    end

    // -------------------------------------------------------------------------
    // Clock counter — free-runs while 'start' is asserted
    // Resets on symbol edge (to re-align), on done, or on reset
    // -------------------------------------------------------------------------
    assign clock_counter_next = clock_counter_value + 1'b1;
    assign clock_counter_ce   = start;
    assign clock_counter_rst  = symbol_edge | done | reset;

    always_ff @(posedge clk) begin
        if (clock_counter_rst)
            clock_counter_value <= '0;
        else if (clock_counter_ce)
            clock_counter_value <= clock_counter_next;
    end

    // -------------------------------------------------------------------------
    // 'has_byte' — asserted once all 10 bits are sampled, cleared on handshake
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset | data_out_fire)
            has_byte <= 1'b0;
        else if (done)
            has_byte <= 1'b1;
    end

    // -------------------------------------------------------------------------
    // 'start' — asserted on start-bit detection, cleared when frame is done
    // FIX: added '& ~start' to prevent re-triggering mid-frame
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset | done)
            start <= 1'b0;
        else if ((serial_in == 1'b0) && (bit_counter_value == 4'd0) && !start)
            start <= 1'b1;     // FIX: ~start guards against spurious re-latching
    end

    // -------------------------------------------------------------------------
    // Outputs
    // -------------------------------------------------------------------------
    assign data_out       = rx_shift_value[8:1];
    assign data_out_valid = has_byte;

endmodule
