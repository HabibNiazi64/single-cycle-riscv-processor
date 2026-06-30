module main_control(
    input [6:0] opcode,

    output reg ALUSrc,
    output reg MemtoReg,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output wire Jump,       // Changed to wire to allow explicit OR gate driving
    output reg [1:0] ALUOp
);

    // Hardware internal decode signals for the OR merge
    reg is_jal;
    reg is_jalr;

    // Explicit Parallel OR Gate Logic for Jump Merging
    assign Jump = is_jal | is_jalr;

    always @(*) begin
        // Default internal decode initializations to prevent unintended latches
        is_jal  = 1'b0;
        is_jalr = 1'b0;

        case(opcode)

            // R-TYPE
            7'b0110011: begin
                ALUSrc   = 0;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 0;
                ALUOp    = 2'b10;
            end

            // I-ALU
            7'b0010011: begin
                ALUSrc   = 1;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 0;
                ALUOp    = 2'b00;
            end

            // LOAD
            7'b0000011: begin
                ALUSrc   = 1;
                MemtoReg = 1;
                RegWrite = 1;
                MemRead  = 1;
                MemWrite = 0;
                Branch   = 0;
                ALUOp    = 2'b00;
            end

            // STORE
            7'b0100011: begin
                ALUSrc   = 1;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead  = 0;
                MemWrite = 1;
                Branch   = 0;
                ALUOp    = 2'b00;
            end

            // BRANCH
            7'b1100011: begin
                ALUSrc   = 0;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 1;
                ALUOp    = 2'b01;
            end

            // JAL (Jump and Link)
            7'b1101111: begin
                ALUSrc   = 0;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 0;
                ALUOp    = 2'b00;
                is_jal   = 1'b1;  // Triggers the OR gate
            end

            // JALR (Jump and Link Register)
            7'b1100111: begin
                ALUSrc   = 1;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 0;
                ALUOp    = 2'b00;
                is_jalr  = 1'b1;  // Triggers the OR gate
            end

            // LUI (Load Upper Immediate)
            7'b0110111: begin
                ALUSrc   = 1;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 0;
                ALUOp    = 2'b00;
            end

            // AUIPC (Add Upper Immediate to PC)
            7'b0010111: begin
                ALUSrc   = 1;
                MemtoReg = 0;
                RegWrite = 1;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 0;
                ALUOp    = 2'b00;
            end

            // DEFAULT / ILLEGAL OPCODE SAFEGUARD
            default: begin
                ALUSrc   = 0;
                MemtoReg = 0;
                RegWrite = 0;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 0;
                ALUOp    = 2'b00;
            end

        endcase
    end

endmodule
