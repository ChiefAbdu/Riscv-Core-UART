`include "uart_params.svh"  // CLOCK_FREQ, BAUD_RATE defined here

module uart (
    input  logic       clk,
    input  logic       reset,

    // TX path
    input  logic [7:0] data_in,
    input  logic       data_in_valid,
    output logic       data_in_ready,

    // RX path
    output logic [7:0] data_out,
    output logic       data_out_valid,
    input  logic       data_out_ready,

    // Serial interface
    input  logic       serial_in,
    output logic       serial_out
);

    logic serial_in_reg;
    logic serial_out_reg;
    logic serial_out_tx;        // combinational output from transmitter

    always_ff @(posedge clk) begin
        serial_out_reg <= reset ? 1'b1 : serial_out_tx;
        serial_in_reg  <= reset ? 1'b1 : serial_in;
    end

    assign serial_out = serial_out_reg;

    // -------------------------------------------------------------------------
    // UART Transmitter
    // -------------------------------------------------------------------------
    uart_transmitter u_tx (
        .clk            (clk),
        .reset          (reset),
        .data_in        (data_in),
        .data_in_valid  (data_in_valid),
        .data_in_ready  (data_in_ready),
        .serial_out     (serial_out_tx)
    );

    // -------------------------------------------------------------------------
    // UART Receiver
    // -------------------------------------------------------------------------
    uart_receiver u_rx (
        .clk            (clk),
        .reset          (reset),
        .data_out       (data_out),
        .data_out_valid (data_out_valid),
        .data_out_ready (data_out_ready),
        .serial_in      (serial_in_reg)
    );

endmodule
