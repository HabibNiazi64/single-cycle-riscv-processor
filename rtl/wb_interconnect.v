module wb_interconnect(
    // Master Interface (From CPU)
    input  wire [31:0] wbm_adr_i,
    input  wire [31:0] wbm_dat_i,
    output reg  [31:0] wbm_dat_o,
    input  wire        wbm_we_i,
    input  wire        wbm_sel_i,
    input  wire        wbm_stb_i,
    input  wire        wbm_cyc_i,
    output reg         wbm_ack_o,

    // Slave 0 Interface (Instruction Memory: 0x0000_0000)
    output wire [31:0] wbs0_adr_o,
    input  wire [31:0] wbs0_dat_i,
    output wire        wbs0_stb_o,
    output wire        wbs0_cyc_o,
    input  wire        wbs0_ack_i,

    // Slave 1 Interface (Data Memory: 0x1000_0000)
    output wire [31:0] wbs1_adr_o,
    output wire [31:0] wbs1_dat_o,
    input  wire [31:0] wbs1_dat_i,
    output wire        wbs1_we_o,
    output wire        wbs1_stb_o,
    output wire        wbs1_cyc_o,
    input  wire        wbs1_ack_i,

    // Slave 2 Interface (LED Peripheral: 0x4000_0000)
    output wire [31:0] wbs2_dat_o,
    output wire        wbs2_we_o,
    output wire        wbs2_stb_o,
    output wire        wbs2_cyc_o,
    input  wire        wbs2_ack_i
);

    // Address Decoding Logic
    wire sel_s0 = (wbm_adr_i[31:28] == 4'h0);    // Instruction Memory space
    wire sel_s1 = (wbm_adr_i[31:28] == 4'h1);    // Data Memory space
    wire sel_s2 = (wbm_adr_i == 32'h4000_0000);  // LED address

    // Route signals to Slaves
    assign wbs0_adr_o = wbm_adr_i;
    assign wbs0_stb_o = wbm_stb_i && sel_s0;
    assign wbs0_cyc_o = wbm_cyc_i && sel_s0;

    assign wbs1_adr_o = wbm_adr_i;
    assign wbs1_dat_o = wbm_dat_i;
    assign wbs1_we_o  = wbm_we_i;
    assign wbs1_stb_o = wbm_stb_i && sel_s1;
    assign wbs1_cyc_o = wbm_cyc_i && sel_s1;

    assign wbs2_dat_o = wbm_dat_i;
    assign wbs2_we_o  = wbm_we_i;
    assign wbs2_stb_o = wbm_stb_i && sel_s2;
    assign wbs2_cyc_o = wbm_cyc_i && sel_s2;

    // Multiplex Read Data and Acknowledgments back to Master
    always @(*) begin
        if (sel_s0) begin
            wbm_dat_o = wbs0_dat_i;
            wbm_ack_o = wbs0_ack_i;
        end else if (sel_s1) begin
            wbm_dat_o = wbs1_dat_i;
            wbm_ack_o = wbs1_ack_i;
        end else if (sel_s2) begin
            wbm_dat_o = 32'b0;
            wbm_ack_o = wbs2_ack_i;
        end else begin
            wbm_dat_o = 32'b0;
            wbm_ack_o = 1'b0;
        end
    end

endmodule

