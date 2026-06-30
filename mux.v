module mux(selc,mux_out,mux_in1,mux_in2);

input [31:0] mux_in1;
input [31:0] mux_in2;
output reg [31:0] mux_out;
input selc;

always @(*) begin

    if(selc)
        mux_out = mux_in2;
    else
        mux_out = mux_in1;

end

endmodule
