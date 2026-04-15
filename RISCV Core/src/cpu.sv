`include "cpu_param.svh"

module cpu (
    input  logic clk,
    input  logic rst,
    input  logic bp_enable,
    input  logic serial_in,
    output logic serial_out
);

    // =========================================================
    // BIOS Memory
    // =========================================================
    logic [BIOS_AWIDTH-1:0] bios_addra, bios_addrb;
    logic [DWIDTH-1:0]      bios_douta, bios_doutb;
    logic                   bios_ena, bios_enb;

    SYNC_ROM_DP #(
        .AWIDTH(BIOS_AWIDTH),
        .DWIDTH(DWIDTH),
        .MIF_HEX(BIOS_MIF_HEX)
    ) bios_mem (
        .q0    (bios_douta),
        .addr0 (bios_addra),
        .en0   (bios_ena),
        .q1    (bios_doutb),
        .addr1 (bios_addrb),
        .en1   (bios_enb),
        .clk   (clk)
    );

    // =========================================================
    // Data Memory
    // =========================================================
    logic [DMEM_AWIDTH-1:0] dmem_addra;
    logic [DWIDTH-1:0]      dmem_dina, dmem_douta;
    logic [BEWIDTH-1:0]     dmem_wbea;
    logic                   dmem_ena;

    SYNC_RAM_WBE #(
        .AWIDTH(DMEM_AWIDTH),
        .DWIDTH(DWIDTH)
    ) dmem (
        .q   (dmem_douta),
        .d   (dmem_dina),
        .addr(dmem_addra),
        .wbe (dmem_wbea),
        .en  (dmem_ena),
        .clk (clk)
    );

    // =========================================================
    // Instruction Memory
    // =========================================================
    logic [IMEM_AWIDTH-1:0] imem_addra, imem_addrb;
    logic [DWIDTH-1:0]      imem_douta, imem_doutb;
    logic [DWIDTH-1:0]      imem_dina, imem_dinb;
    logic [BEWIDTH-1:0]     imem_wbea, imem_wbeb;
    logic                   imem_ena, imem_enb;

    SYNC_RAM_DP_WBE #(
        .AWIDTH(IMEM_AWIDTH),
        .DWIDTH(DWIDTH)
    ) imem (
        .q0    (imem_douta),
        .d0    (imem_dina),
        .addr0 (imem_addra),
        .wbe0  (imem_wbea),
        .en0   (imem_ena),

        .q1    (imem_doutb),
        .d1    (imem_dinb),
        .addr1 (imem_addrb),
        .wbe1  (imem_wbeb),
        .en1   (imem_enb),

        .clk   (clk)
    );

    // =========================================================
    // Register File
    // =========================================================
    logic [RF_AWIDTH-1:0] wa, ra1, ra2;
    logic [DWIDTH-1:0]    wd, rd1, rd2;
    logic                 we;

    ASYNC_RAM_1W2R #(
        .AWIDTH(RF_AWIDTH),
        .DWIDTH(DWIDTH)
    ) rf (
        .addr0(wa),
        .d0   (wd),
        .we0  (we),

        .q1   (rd1),
        .addr1(ra1),

        .q2   (rd2),
        .addr2(ra2),

        .clk  (clk)
    );

    // =========================================================
    // On-chip UART
    // =========================================================

    logic [7:0] uart_rx_data_out;
    logic       uart_rx_data_out_valid;
    logic       uart_rx_data_out_ready;

    logic [7:0] uart_tx_data_in;
    logic       uart_tx_data_in_valid;
    logic       uart_tx_data_in_ready;

    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) on_chip_uart (
        .clk              (clk),
        .reset            (rst),

        .serial_in       (serial_in),
        .serial_out      (serial_out),

        .data_out        (uart_rx_data_out),
        .data_out_valid  (uart_rx_data_out_valid),
        .data_out_ready  (uart_rx_data_out_ready),

        .data_in         (uart_tx_data_in),
        .data_in_valid   (uart_tx_data_in_valid),
        .data_in_ready   (uart_tx_data_in_ready)
    );

    // =========================================================
    // CSR
    // =========================================================
    logic [DWIDTH-1:0] csr_dout, csr_din;
    logic              csr_we;

    REGISTER_R_CE #(
        .N(DWIDTH)
    ) csr (
        .q   (csr_dout),
        .d   (csr_din),
        .rst (rst),
        .ce  (csr_we),
        .clk (clk)
    );

    // =========================================================
    // TODO: CPU Core Logic
    // =========================================================

endmodule
