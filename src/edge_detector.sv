`include "uart_params.svh"

module edge_detector (
    input  logic             clk,
    input  logic [WIDTH-1:0] signal_in,
    output logic [WIDTH-1:0] edge_detect_pulse
);

    logic [WIDTH-1:0] signal_prev;

    always_ff @(posedge clk) begin
        signal_prev <= signal_in;
    end

    // Pulse when current is HIGH and previous was LOW (rising edge)
    assign edge_detect_pulse = signal_in & ~signal_prev;

endmodule
