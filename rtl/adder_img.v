module adder_img(pc,img,sum_out);

input [31:0] pc,img;
output reg [31:0] sum_out;

always @(*) begin

    sum_out = pc + img;

end

endmodule
