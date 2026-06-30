`timescale 1ns / 1ps

module top_tb;

    //==================== TESTBENCH SIGNALS ====================//
    reg clk;
    reg reset;
    wire led;

    //==================== UNIT UNDER TEST (UUT) ====================//
    top uut (
        .sys_clk   (clk),     // Connects testbench 'clk' to 'sys_clk'
        .sys_rst_n (~reset),  // Inverts active-high testbench reset to match active-low 'sys_rst_n'
        .led       (led)
    );

    //==================== CLOCK GENERATION ====================//
    // Generates a 50MHz clock cycle (20ns period)
    always begin
        #10 clk = ~clk;
    end

    //==================== INITIAL STIMULUS ====================//
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1; // Asserting reset (which sends 0 to sys_rst_n)

        // Hold reset high for 40 nanoseconds to clear registers
        #40;
        reset = 0; // De-asserting reset (which sends 1 to sys_rst_n to run)
        
        $display("======= SIMULATION STARTED =======");
        $display("Time\t\tPC\t\tInstruction\tLED State");
        $display("---------------------------------------------------------");

        // Run the simulation for 2000ns (Enough time to execute a lightweight delay loop)
        #2000;
        
        $display("======= SIMULATION FINISHED =======");
        $finish;
    end

    //==================== WAVEFORM DUMPING (GTKWave) ====================//
    initial begin
        $dumpfile("dump.vcd"); // Name of the VCD file generated
        $dumpvars(0, top_tb);  // Dumps all signals in the testbench and submodules
    end

    //==================== RUNTIME MONITOR ====================//
    // Prints status to terminal on every clock edge to watch execution flow
    always @(posedge clk) begin
        if (!reset) begin
            $display("%0t ns\t0x%h\t0x%h\t%s", 
                     $time, 
                     uut.pc_current, 
                     uut.instruction, 
                     (led == 1'b0) ? "ON (Low)" : "OFF (High)");
        end
    end

endmodule
