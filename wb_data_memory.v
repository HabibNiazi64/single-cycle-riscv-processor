module wb_data_memory(
    input  wire        clk,
    input  wire        reset,
    
    // Wishbone Slave Interface Ports
    input  wire [31:0] wb_adr_i,   // Address target input
    input  wire [31:0] wb_dat_i,   // Write data payload from master
    output reg  [31:0] wb_dat_o,   // Read data payload sent back to master
    input  wire        wb_we_i,    // Write Enable (1 = Write, 0 = Read)
    input  wire [2:0]  funct3,     // RISC-V structural size identifier (from CPU)
    input  wire        wb_stb_i,   // Strobe flag
    input  wire        wb_cyc_i,   // Cycle flag
    output reg         wb_ack_o    // Transfer Acknowledgment output
);

    // 32 words of 32-bit distributed data storage
    reg [31:0] mem [0:31];

    // Word selection routing logic 
    // We look at bits [6:2] to choose our 32-word array offsets
    wire [4:0] word_idx = wb_adr_i[6:2];
    wire [31:0] word    = mem[word_idx];

    // Valid transfer checker flag
    wire valid_cycle = wb_cyc_i && wb_stb_i;

    // ==================== WISHBONE WRITE CHANNEL ==================== //
    always @(posedge clk) begin
        if (valid_cycle && wb_we_i && !wb_ack_o) begin
            case(funct3)
                3'b000: begin // SB (Store Byte)
                    case(wb_adr_i[1:0])
                        2'b00: mem[word_idx][7:0]   <= wb_dat_i[7:0];
                        2'b01: mem[word_idx][15:8]  <= wb_dat_i[7:0];
                        2'b10: mem[word_idx][23:16] <= wb_dat_i[7:0];
                        2'b11: mem[word_idx][31:24] <= wb_dat_i[7:0];
                    endcase
                end

                3'b001: begin // SH (Store Half-Word)
                    if(wb_adr_i[1] == 1'b0)
                        mem[word_idx][15:0]  <= wb_dat_i[15:0];
                    else
                        mem[word_idx][31:16] <= wb_dat_i[15:0];
                end

                3'b010: begin // SW (Store Word)
                    mem[word_idx] <= wb_dat_i;
                end
            endcase
        end
    end

    // ==================== WISHBONE READ CHANNEL ==================== //
    always @(*) begin
        wb_dat_o = 32'b0;
        
        if (valid_cycle && !wb_we_i) begin
            case(funct3)
                3'b000: begin // LB (Load Byte, Signed Extended)
                    case(wb_adr_i[1:0])
                        2'b00: wb_dat_o = {{24{word[7]}},  word[7:0]};
                        2'b01: wb_dat_o = {{24{word[15]}}, word[15:8]};
                        2'b10: wb_dat_o = {{24{word[23]}}, word[23:16]};
                        2'b11: wb_dat_o = {{24{word[31]}}, word[31:24]};
                    endcase
                end

                3'b001: begin // LH (Load Half-Word, Signed Extended)
                    if(wb_adr_i[1] == 1'b0)
                        wb_dat_o = {{16{word[15]}}, word[15:0]};
                    else
                        wb_dat_o = {{16{word[31]}}, word[31:16]};
                end

                3'b010: begin // LW (Load Word)
                    wb_dat_o = word;
                end

                3'b100: begin // LBU (Load Byte, Unsigned Zero-Extended)
                    case(wb_adr_i[1:0])
                        2'b00: wb_dat_o = {24'b0, word[7:0]};
                        2'b01: wb_dat_o = {24'b0, word[15:8]};
                        2'b10: wb_dat_o = {24'b0, word[23:16]};
                        2'b11: wb_dat_o = {24'b0, word[31:24]};
                    endcase
                end

                3'b101: begin // LHU (Load Half-Word, Unsigned Zero-Extended)
                    if(wb_adr_i[1] == 1'b0)
                        wb_dat_o = {16'b0, word[15:0]};
                    else
                        wb_dat_o = {16'b0, word[31:16]};
                end
                
                default: wb_dat_o = 32'b0;
            endcase
        end
    end

    // ==================== ACKNOWLEDGMENT GENERATION ==================== //
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_ack_o <= 1'b0;
        end else begin
            if (valid_cycle && !wb_ack_o)
                wb_ack_o <= 1'b1;
            else
                wb_ack_o <= 1'b0;
        end
    end

endmodule
