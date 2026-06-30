module top(
    input sys_clk,   // Matches CST configuration pin 52
    input sys_rst_n, // Matches CST configuration pin 4 (Active-Low button)
    output wire led  // Matches CST configuration pin 10
);

//==================== PHYSICAL HARDWARE INTERFACE LOGIC ====================//
// Invert the active-low physical button to create the active-high reset signal
wire reset = !sys_rst_n;
wire clk   = sys_clk;

wire [31:0] pc_current;
wire [31:0] pc_next;
wire [31:0] pc_plus4;
wire [31:0] branch_addr;
wire [31:0] jalr_addr;
wire [31:0] instruction;
wire [6:0]  opcode;

wire ALUSrc;
wire MemtoReg;
wire RegWrite;
wire MemRead;
wire MemWrite;
wire Branch;
wire Jump;

wire [1:0] ALUOp;

wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;

wire [31:0] imm_out;

wire [31:0] rd1;
wire [31:0] rd2;

wire [2:0] func3;
wire [6:0] func7;

wire [3:0] alu_control;

reg  [31:0] write_data; // Target writeback selection registry register 
reg  [31:0] alu_in1;    // Selection mux for LUI / AUIPC / Standard
wire [31:0] alu_in2;

wire [31:0] alu_result;
wire zero;
wire [31:0] read_data;
wire branch_taken;

//==================== WISHBONE INTERNAL BUS ROUTING WIRES ====================//
wire [31:0] wbm_dat_o; // Data incoming to the CPU Master from Interconnect
wire        wbm_ack_i; // Master handshake completion flag

// Slave 0 Signals (Wishbone Instruction Memory - Unused on bus now, kept for interconnect wire stability)
wire [31:0] s0_adr;
wire [31:0] s0_dat_r;
wire        s0_stb, s0_cyc, s0_ack;

// Slave 1 Signals (Wishbone Data Memory)
wire [31:0] s1_adr;
wire [31:0] s1_dat_w, s1_dat_r;
wire        s1_we, s1_stb, s1_cyc, s1_ack;

// Slave 2 Signals (Wishbone LED Peripheral)
wire [31:0] s2_dat_w;
wire        s2_we, s2_stb, s2_cyc, s2_ack;

//==================== STRUCTURAL ASSIGNS ====================//
assign rs1    = instruction[19:15];
assign rs2    = instruction[24:20];
assign rd     = instruction[11:7];
assign opcode = instruction[6:0];
assign func3  = instruction[14:12];
assign func7  = instruction[31:25];

//==================== PC REGISTER ====================//
pc pc1 (
    .clk(clk),
    .reset(reset),
    .a(pc_next),
    .b(pc_current)
);

//==================== PC + 4 ADDER ====================//
adder add1(
    .add_in(pc_current),
    .add_out(pc_plus4)
);

//==================== BRANCH & JAL ADDER ====================//
adder_img branch_add(
    .pc(pc_current),
    .img(imm_out),
    .sum_out(branch_addr)
);

//==================== JALR TARGET ADDER ====================//
assign jalr_addr = (rd1 + imm_out) & 32'hFFFF_FFFE;

//==================== ADVANCED BRANCH DECISION UNIT ====================//
branch_unit bu1 (
    .funct3(func3),
    .branch_ctrl(Branch),
    .operandA(rd1),
    .operandB(rd2),
    .branch_taken(branch_taken)
);

//==================== PROGRAM COUNTER MUX ====================//
reg [31:0] pc_next_mux;
always @(*) begin
    if (Jump) begin
        if (opcode == 7'b1100111) // JALR
            pc_next_mux = jalr_addr;
        else                      // JAL
            pc_next_mux = branch_addr; 
    end else if (branch_taken) begin
        pc_next_mux = branch_addr;
    end else begin
        pc_next_mux = pc_plus4;
    end
end
assign pc_next = pc_next_mux;

//==================== MAIN CONTROL UNIT ====================//
main_control Cu (
    .opcode(opcode),
    .ALUSrc(ALUSrc),
    .MemtoReg(MemtoReg),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .Jump(Jump),
    .ALUOp(ALUOp)
);

//==================== REGISTER FILE ====================//
register_file rf1(
    .clk(clk),
    .we(RegWrite),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wd(write_data),
    .rd1(rd1),
    .rd2(rd2)
);

//==================== IMMEDIATE GENERATOR ====================//
imm_gen ig1(
    .instr(instruction),
    .imm_out(imm_out)  
);

//==================== ALU OPERAND A SELECT MUX ====================//
always @(*) begin
    case(opcode)
        7'b0110111: alu_in1 = 32'b0;        // LUI
        7'b0010111: alu_in1 = pc_current;   // AUIPC
        default:    alu_in1 = rd1;          // Standard
    endcase
end

//==================== ALU OPERAND B SELECT MUX ====================//
mux mux1(
    .selc(ALUSrc),
    .mux_in1(rd2),
    .mux_in2(imm_out),
    .mux_out(alu_in2)
);

//==================== ALU CONTROL ====================//
ALU_Control aluctrl1(  
    .alu_op(ALUOp),
    .func7(func7),
    .func3(func3),
    .alu_control(alu_control)
);

//==================== ALU ====================//
alu_32bit alu1(              
    .opcode(alu_control),
    .OperandA(alu_in1), 
    .OperandB(alu_in2),
    .result(alu_result),
    .zero(zero)
);

//==================== WISHBONE MASTER INTERFACE LOGIC ====================//
wire [31:0] cpu_bus_addr = alu_result;

//==================== WISHBONE BUS INTERCONNECT ====================//
wb_interconnect bus_manager (
    // CPU Master Ports
    .wbm_adr_i(cpu_bus_addr),
    .wbm_dat_i(rd2),
    .wbm_dat_o(wbm_dat_o),
    .wbm_we_i(MemWrite),
    .wbm_sel_i(1'b1),
    .wbm_stb_i(MemRead || MemWrite), 
    .wbm_cyc_i(MemRead || MemWrite),
    .wbm_ack_o(wbm_ack_i),

    // Slave 0 Ports (Instruction Memory ROM)
    .wbs0_adr_o(s0_adr), 
    .wbs0_dat_i(s0_dat_r),
    .wbs0_stb_o(s0_stb), 
    .wbs0_cyc_o(s0_cyc), 
    .wbs0_ack_i(s0_ack),

    // Slave 1 Ports (Data Memory RAM)
    .wbs1_adr_o(s1_adr), 
    .wbs1_dat_o(s1_dat_w), 
    .wbs1_dat_i(s1_dat_r),
    .wbs1_we_o(s1_we), 
    .wbs1_stb_o(s1_stb), 
    .wbs1_cyc_o(s1_cyc), 
    .wbs1_ack_i(s1_ack),

    // Slave 2 Ports (LED Controller Register)
    .wbs2_dat_o(s2_dat_w), 
    .wbs2_we_o(s2_we),
    .wbs2_stb_o(s2_stb), 
    .wbs2_cyc_o(s2_cyc), 
    .wbs2_ack_i(s2_ack)
);

//==================== SLAVE INSTANTIATIONS ====================//

// Slave 0: Wishbone Instruction Memory (ROM Dedicated Direct Routing)
wb_instruction_mem s0_rom (
    .clk(clk), 
    .reset(reset),
    .wb_adr_i(pc_current), 
    .wb_stb_i(1'b1),       
    .wb_cyc_i(1'b1),       
    .wb_dat_o(s0_dat_r),
    .wb_ack_o(s0_ack)
);

assign instruction = s0_dat_r;

// Slave 1: Native Wishbone Data Memory (RAM)
wb_data_memory s1_ram (
    .clk(clk),
    .reset(reset),
    .wb_adr_i(s1_adr),
    .wb_dat_i(s1_dat_w),
    .wb_dat_o(s1_dat_r),
    .wb_we_i(s1_we),
    .funct3(func3),
    .wb_stb_i(s1_stb),
    .wb_cyc_i(s1_cyc),
    .wb_ack_o(s1_ack)
);

// Disconnect the CPU peripheral from the direct top-level pin
wire cpu_led_wire;

// Slave 2: Wishbone Memory-Mapped LED Peripheral Register (MMIO)
wb_led_peripheral s2_io (
    .clk(clk),
    .reset(reset),
    .wb_dat_i(s2_dat_w),
    .wb_we_i(s2_we),
    .wb_stb_i(s2_stb),
    .wb_cyc_i(s2_cyc),
    .wb_ack_o(s2_ack),
    .led(cpu_led_wire) // Routed to dummy wire
);

//==================== REG-FILE WRITE BACK SELECTION MUX ====================//
always @(*) begin
    if (Jump) begin
        write_data = pc_plus4;
    end else if (MemtoReg) begin
        write_data = wbm_dat_o; 
    end else begin
        write_data = alu_result;
    end
end

//==================== DIAGNOSTIC BLINKY GENERATOR ====================//
reg [24:0] hardware_speed_counter;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        hardware_speed_counter <= 25'b0;
    end else begin
        hardware_speed_counter <= hardware_speed_counter + 1'b1;
    end
end

// CRITICAL FIX: Combines the hardware counter and the CPU wire.
// This forces the synthesizer to preserve the entire CPU design!
assign led = (~hardware_speed_counter[24]) && cpu_led_wire;

endmodule
