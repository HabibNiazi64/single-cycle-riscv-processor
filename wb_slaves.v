module wb_led_peripheral(
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] wb_dat_i,
    input  wire        wb_we_i,
    input  wire        wb_stb_i,
    input  wire        wb_cyc_i,
    output reg         wb_ack_o,
    output reg         led
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            led <= 1'b1; // Turn off (Active-low onboard Tang Nano)
            wb_ack_o <= 1'b0;
        end else begin
            wb_ack_o <= wb_stb_i && wb_cyc_i && !wb_ack_o;
            if (wb_stb_i && wb_cyc_i && wb_we_i) begin
                led <= (wb_dat_i[0] == 1'b1) ? 1'b0 : 1'b1;
            end
        end
    end
endmodule
