

`timescale 1ns/1ps

module tmr_tb;

    // ---- Signals ----
    reg         clk;
    reg         reset;
    reg  [31:0] fault_inject;
    reg         fault_enable;
    wire [31:0] pc_out_debug;
    wire        fault_detected;

    // ---- Instantiate TMR top ----
    tmr_top uut (
        .clk           (clk),
        .reset         (reset),
        .fault_inject  (fault_inject),
        .fault_enable  (fault_enable),
        .pc_out_debug  (pc_out_debug),
        .fault_detected(fault_detected)
    );

    // ---- 100MHz clock ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Test sequence ----
    initial begin
        $dumpfile("tmr_tb.vcd");
        $dumpvars(0, tmr_tb);

        // Initialize all signals safely
        fault_enable = 1'b0;
        fault_inject = 32'h00000000;
        reset        = 1'b1;

        $display("=================================");
        $display("   TMR Fault Tolerance Testbench ");
        $display("=================================");

        // ---- Phase 1: Normal Operation ----
        $display("\n[PHASE 1] Normal Operation");
        #20;
        reset = 1'b0;
        #100;
        $display("  PC           = %h", pc_out_debug);
        $display("  Fault Detect = %b (expect 0)", fault_detected);

        if (fault_detected == 0)
            $display("  PASS: No fault in normal operation");
        else
            $display("  FAIL: False fault detected!");

        // ---- Phase 2: Inject Fault into CPU2 ----
        $display("\n[PHASE 2] Injecting Fault into CPU2");
        fault_enable = 1'b1;
        fault_inject = 32'hDEADBEEF;
        #100;
        $display("  PC           = %h (should NOT be DEADBEEF)", pc_out_debug);
        $display("  Fault Detect = %b (expect 1)", fault_detected);

        if (fault_detected == 1)
            $display("  PASS: Fault correctly detected!");
        else
            $display("  FAIL: Fault not detected!");

        if (pc_out_debug != 32'hDEADBEEF)
            $display("  PASS: Voter corrected output!");
        else
            $display("  FAIL: Corrupted value passed through!");

        // ---- Phase 3: Recovery ----
        $display("\n[PHASE 3] Removing Fault - Recovery");
        fault_enable = 1'b0;
        fault_inject = 32'h00000000;
        #100;
        $display("  PC           = %h", pc_out_debug);
        $display("  Fault Detect = %b (expect 0)", fault_detected);

        if (fault_detected == 0)
            $display("  PASS: System recovered successfully!");
        else
            $display("  FAIL: Fault still showing after removal!");

        // ---- Summary ----
        $display("\n=================================");
        $display("  TMR SIMULATION COMPLETE!");
        $display("  System mimics ISRO space-grade");
        $display("  fault tolerant processor design");
        $display("=================================");

        $finish;
    end

    // ---- Monitor every clock cycle ----
    always @(posedge clk) begin
        if (!reset)
            $display("  t=%0t | PC=%h | fault=%b",
                      $time, pc_out_debug, fault_detected);
    end

endmodule