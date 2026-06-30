module alu_32bit(
    input [3:0] opcode,
    input [31:0] OperandA, OperandB,
    output reg [31:0] result,
    output reg zero
);

always @(*) begin
    // Default values
    result = 32'd0;
    zero = 1'b0;

    case(opcode)
        // Arithmetic & Logic
        4'b0000: result = OperandA + OperandB;
        4'b0001: result = OperandA - OperandB;
        4'b0010: result = OperandA ^ OperandB;
        4'b0011: result = OperandA | OperandB;
        4'b0100: result = OperandA & OperandB;
        4'b0101: result = OperandA << OperandB[4:0];
        4'b0110: result = OperandA >> OperandB[4:0];
        4'b0111: result = $signed(OperandA) >>> OperandB[4:0];

        // Signed Comparison (SLT)
        4'b1000: result = ($signed(OperandA) < $signed(OperandB)) ? 32'd1 : 32'd0;

        // Unsigned Comparison
        4'b1001: result = (OperandA < OperandB) ? 32'd1 : 32'd0;

        // Equality Check (Used for BEQ)
        4'b1010: result = (OperandA == OperandB) ? 32'd1 : 32'd0;

        // Inequality Check (Used for BNE)
        4'b1011: result = (OperandA != OperandB) ? 32'd1 : 32'd0;

        // Additional Signed Comparisons
        4'b1100: result = ($signed(OperandA) < $signed(OperandB)) ? 32'd1 : 32'd0;
        4'b1101: result = ($signed(OperandA) >= $signed(OperandB)) ? 32'd1 : 32'd0;

        // Additional Unsigned Comparisons
        4'b1110: result = (OperandA < OperandB) ? 32'd1 : 32'd0;
        4'b1111: result = (OperandA >= OperandB) ? 32'd1 : 32'd0;

        default: result = 32'd0;
    endcase

    // CRITICAL FIX: The Zero flag for Branching
    // For BEQ, pcsrc = Branch & zero. 
    // We want zero to be HIGH only if OperandA and OperandB are actually equal.
    zero = (OperandA == OperandB);

end

endmodule
