module register_file (
    input clk,
    input we,
    input [4:0] rs1, rs2, rd,
    input [31:0] wd,
    output [31:0] rd1, rd2
);

reg [31:0] regfile [31:0];

// Read operation (combinational)
assign rd1 = (rs1 == 5'b00000) ? 32'b0 : regfile[rs1];
assign rd2 = (rs2 == 5'b00000) ? 32'b0 : regfile[rs2];

// Write operation (sequential)
always @(posedge clk) begin

    if (we && (rd != 5'b00000)) begin
        regfile[rd] <= wd;
    end

end

endmodule
