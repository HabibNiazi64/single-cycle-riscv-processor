module branch_unit(

    input [2:0] funct3,
    input branch_ctrl,

    input [31:0] operandA,
    input [31:0] operandB,

    output reg branch_taken
);

always @(*) begin

    branch_taken = 1'b0;

    if(branch_ctrl) begin

        case(funct3)

            3'b000: branch_taken = (operandA == operandB); // BEQ

            3'b001: branch_taken = (operandA != operandB); // BNE

            3'b100: branch_taken =
                     ($signed(operandA) < $signed(operandB)); // BLT

            3'b101: branch_taken =
                     ($signed(operandA) >= $signed(operandB)); // BGE

            3'b110: branch_taken =
                     (operandA < operandB); // BLTU

            3'b111: branch_taken =
                     (operandA >= operandB); // BGEU

            default: branch_taken = 1'b0;

        endcase

    end

end

endmodule
