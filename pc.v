module pc(a,b,clk,reset);

input [31:0] a;
output reg [31:0] b;
input clk;
input reset;

always @(posedge clk) begin

    if(reset)
        b <= 32'b0;
    else
        b <= a;

end

endmodule
