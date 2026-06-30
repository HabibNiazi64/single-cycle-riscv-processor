module adder(add_in, add_out);

input [31:0] add_in;
output [31:0] add_out;

assign add_out = add_in + 4;

endmodule
