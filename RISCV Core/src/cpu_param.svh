`ifndef CPU_PARAM_SVH
`define CPU_PARAM_SVH

    // =========================================================
    // Global parameters
    // =========================================================
    parameter int CPU_CLOCK_FREQ = 50_000_000;
    parameter int RESET_PC       = 32'h4000_0000;
    parameter int BAUD_RATE      = 115200;
    parameter string BIOS_MIF_HEX = "";


    // =========================================================
    // Local parameters
    // =========================================================
    localparam int DWIDTH     = 32;
    localparam int BEWIDTH    = DWIDTH / 8;
    localparam int BIOS_AWIDTH = 12;
    localparam int DMEM_AWIDTH = 14;
    localparam int IMEM_AWIDTH = 14;
    localparam int RF_AWIDTH   = 5;

`endif
