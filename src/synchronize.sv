`include "uart_params.svh"  // WIDTH defined here

module synchronizer (
    input  logic [WIDTH-1:0] async_signal,
    input  logic             clk,
    output logic [WIDTH-1:0] sync_signal
);


    logic [WIDTH-1:0] stage1, stage2;

    always_ff @(posedge clk) begin
        stage1 <= async_signal;
        stage2 <= stage1;
    end

    assign sync_signal = stage2;

endmodule
