`include "uart_params.svh"

module debouncer #(
    parameter int WIDTH         = 1,
    parameter int SAMPLE_CNT_MAX = DEBOUNCE_SAMPLES,   // cycles input must be stable
    parameter int PULSE_CNT_MAX  = PULSE_SAMPLES        // min pulse width to accept
)(
    input  logic             clk,
    input  logic [WIDTH-1:0] glitchy_signal,
    output logic [WIDTH-1:0] debounced_signal
);

    localparam int SAMPLE_CTR_WIDTH = $clog2(SAMPLE_CNT_MAX);
    localparam int PULSE_CTR_WIDTH  = $clog2(PULSE_CNT_MAX);

    logic [WIDTH-1:0]           signal_stable;
    logic [SAMPLE_CTR_WIDTH-1:0] sample_counter;
    logic [PULSE_CTR_WIDTH-1:0]  pulse_counter;
    logic                        sample_saturated, pulse_saturated;

    assign sample_saturated = (sample_counter == SAMPLE_CTR_WIDTH'(SAMPLE_CNT_MAX - 1));
    assign pulse_saturated  = (pulse_counter  == PULSE_CTR_WIDTH'(PULSE_CNT_MAX  - 1));

    // -------------------------------------------------------------------------
    // Stage snapshot — track last seen value
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        signal_stable <= glitchy_signal;
    end

    // -------------------------------------------------------------------------
    // Sample counter — resets on any input change, counts up while stable
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (glitchy_signal != signal_stable)
            sample_counter <= '0;
        else if (!sample_saturated)
            sample_counter <= sample_counter + 1'b1;
    end

    // -------------------------------------------------------------------------
    // Pulse counter — only starts once sample window is satisfied
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!sample_saturated)
            pulse_counter <= '0;
        else if (!pulse_saturated)
            pulse_counter <= pulse_counter + 1'b1;
    end

    // -------------------------------------------------------------------------
    // Output — only commits once both windows are satisfied
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (sample_saturated & pulse_saturated)
            debounced_signal <= glitchy_signal;
    end

endmodule
