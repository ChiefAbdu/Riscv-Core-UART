`timescale 1ns/1ps
`include "uart_params.svh"

module uart_tb;

    // ---------------------------------------------------------------------
    // Parameters
    // ---------------------------------------------------------------------
    localparam int CLK_PERIOD = 10; // 100 MHz clock

    // ---------------------------------------------------------------------
    // DUT Signals
    // ---------------------------------------------------------------------
    logic clk;
    logic reset;

    // TX Path
    logic [7:0] data_in;
    logic       data_in_valid;
    logic       data_in_ready;

    // RX Path
    logic [7:0] data_out;
    logic       data_out_valid;
    logic       data_out_ready;

    // Serial Interface
    logic serial_in;
    logic serial_out;

    // Testbench variables
    int pass_count = 0;
    int fail_count = 0;

    // Queue to store expected values
    byte expected_queue[$];

    // ---------------------------------------------------------------------
    // Instantiate DUT
    // ---------------------------------------------------------------------
    uart dut (
        .clk            (clk),
        .reset          (reset),
        .data_in        (data_in),
        .data_in_valid  (data_in_valid),
        .data_in_ready  (data_in_ready),
        .data_out       (data_out),
        .data_out_valid (data_out_valid),
        .data_out_ready (data_out_ready),
        .serial_in      (serial_in),
        .serial_out     (serial_out)
    );

    // ---------------------------------------------------------------------
    // Clock Generation
    // ---------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ---------------------------------------------------------------------
    // UART Loopback Connection
    // ---------------------------------------------------------------------
    assign serial_in = serial_out;

    // Always ready to receive data
    initial data_out_ready = 1'b1;

    // ---------------------------------------------------------------------
    // Reset Task
    // ---------------------------------------------------------------------
    task automatic apply_reset();
        begin
            reset = 1'b1;
            data_in = 0;
            data_in_valid = 0;
            repeat (10) @(posedge clk);
            reset = 1'b0;
            repeat (5) @(posedge clk);
        end
    endtask

    // ---------------------------------------------------------------------
    // Transmit Byte Task
    // ---------------------------------------------------------------------
    task automatic send_byte(input byte tx_data);
        begin
            @(posedge clk);
            wait (data_in_ready);

            data_in       <= tx_data;
            data_in_valid <= 1'b1;
            expected_queue.push_back(tx_data);

            @(posedge clk);
            data_in_valid <= 1'b0;

            $display("[%0t] TX Sent: 0x%02h", $time, tx_data);
        end
    endtask

    // ---------------------------------------------------------------------
    // Scoreboard: Self-Checking Logic
    // ---------------------------------------------------------------------
    always @(posedge clk) begin
        if (data_out_valid && data_out_ready) begin
            if (expected_queue.size() == 0) begin
                $error("[%0t] Unexpected data received: 0x%02h",
                       $time, data_out);
                fail_count++;
            end
            else begin
                byte expected;
                expected = expected_queue.pop_front();

                if (data_out === expected) begin
                    $display("[%0t] RX Passed: 0x%02h",
                             $time, data_out);
                    pass_count++;
                end
                else begin
                    $error("[%0t] RX Failed: Expected=0x%02h, Got=0x%02h",
                           $time, expected, data_out);
                    fail_count++;
                end
            end
        end
    end

    // ---------------------------------------------------------------------
    // Test Sequence
    // ---------------------------------------------------------------------
    initial begin
        $display("\n==========================================");
        $display("        UART Self-Checking Testbench");
        $display("==========================================\n");

        apply_reset();

        // Directed Tests
        send_byte(8'h55);
        send_byte(8'hAA);
        send_byte(8'h00);
        send_byte(8'hFF);
        send_byte(8'hA5);

        // Random Tests
        repeat (20) begin
            send_byte($urandom_range(0, 255));
        end

        // Wait for all transmissions to complete
        wait (expected_queue.size() == 0);
        repeat (20) @(posedge clk);

        // -----------------------------------------------------------------
        // Test Summary
        // -----------------------------------------------------------------
        $display("\n==========================================");
        $display("              TEST SUMMARY");
        $display("==========================================");
        $display("Total Passed : %0d", pass_count);
        $display("Total Failed : %0d", fail_count);

        if (fail_count == 0)
            $display("STATUS : TEST PASSED ✅");
        else
            $display("STATUS : TEST FAILED ❌");

        $display("==========================================\n");

        $finish;
    end

    // ---------------------------------------------------------------------
    // Waveform Dump
    // ---------------------------------------------------------------------
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);
    end

endmodule
