`include "uart_params.svh"

module button_parser (
    input  logic             clk,
    input  logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] out
);

    logic [WIDTH-1:0] synchronized_signals;
    logic [WIDTH-1:0] debounced_signals;

    // -------------------------------------------------------------------------
    // Stage 1: Synchroniser — resolves metastability on async button inputs
    // -------------------------------------------------------------------------
    synchronizer #(
        .WIDTH (WIDTH)
    ) u_sync (
        .clk        (clk),
        .async_signal (in),
        .sync_signal  (synchronized_signals)
    );

    // -------------------------------------------------------------------------
    // Stage 2: Debouncer — filters mechanical contact bounce
    // -------------------------------------------------------------------------
    debouncer #(
        .WIDTH        (WIDTH),
        .SAMPLE_CNT_MAX (SAMPLE_CNT_MAX),
        .PULSE_CNT_MAX  (PULSE_CNT_MAX)
    ) u_debounce (
        .clk            (clk),
        .glitchy_signal  (synchronized_signals),
        .debounced_signal (debounced_signals)
    );

    // -------------------------------------------------------------------------
    // Stage 3: Edge detector — produces a clean 1-cycle pulse per press
    // -------------------------------------------------------------------------
    edge_detector #(
        .WIDTH (WIDTH)
    ) u_edge (
        .clk              (clk),
        .signal_in        (debounced_signals),
        .edge_detect_pulse (out)
    );

endmodule
