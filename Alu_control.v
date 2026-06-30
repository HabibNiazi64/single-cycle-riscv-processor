module ALU_Control (
    input [1:0] alu_op,
    input [6:0] func7,
    input [2:0] func3,
    output reg [3:0] alu_control
);

always @(*) begin

    alu_control = 4'b0000;

    case (alu_op)

        2'b10: begin

            case ({func7, func3})

                10'b0000000_000: alu_control = 4'b0000;
                10'b0100000_000: alu_control = 4'b0001;
                10'b0000000_100: alu_control = 4'b0010;
                10'b0000000_110: alu_control = 4'b0011;
                10'b0000000_111: alu_control = 4'b0100;
                10'b0000000_001: alu_control = 4'b0101;
                10'b0000000_101: alu_control = 4'b0110;
                10'b0100000_101: alu_control = 4'b0111;
                10'b0000000_010: alu_control = 4'b1000;
                10'b0000000_011: alu_control = 4'b1001;

                default: alu_control = 4'b0000;

            endcase

        end

        2'b01: begin

            case (func3)

                3'b000: alu_control = 4'b1010;
                3'b001: alu_control = 4'b1011;
                3'b100: alu_control = 4'b1100;
                3'b101: alu_control = 4'b1101;
                3'b110: alu_control = 4'b1110;
                3'b111: alu_control = 4'b1111;

                default: alu_control = 4'b0000;

            endcase

        end

        default: alu_control = 4'b0000;

    endcase

end

endmodule
