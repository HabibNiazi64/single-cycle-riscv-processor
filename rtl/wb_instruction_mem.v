module wb_instruction_mem(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] wb_adr_i, 
    output wire [31:0] wb_dat_o, 
    input  wire        wb_stb_i, 
    input  wire        wb_cyc_i, 
    output wire        wb_ack_o  
);

    reg [31:0] mem [0:127];
    integer i;

    initial begin
        // Pre-fill the entire instruction space with safe NOP values
        for (i = 0; i < 128; i = i + 1) begin
            mem[i] = 32'h00000013; 
        end
        // Load whatever exists in your hex file without restricting a fixed array end-index range
        $readmemh("program.hex", mem);
    end

    // Safeguard the index bounds check using a 7-bit wide mask
    wire [6:0] word_addr = wb_adr_i[8:2];
    
    // Drive data over the interconnect fabric transparently
    assign wb_dat_o = (wb_cyc_i && wb_stb_i) ? mem[word_addr] : 32'h00000013;

    // Direct acknowledgment response back to single-cycle master bus configurations
    assign wb_ack_o = wb_cyc_i && wb_stb_i;

endmodule
