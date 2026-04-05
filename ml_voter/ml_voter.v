`timescale 1ns/1ps
module ml_voter (
    input  clk,
    input  reset,
    input  [31:0] cpu0_pc,
    input  [31:0] cpu1_pc,
    input  [31:0] cpu2_pc,
    output reg [1:0] correct_cpu,
    output reg fault_detected
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            correct_cpu    <= 2'd0;
            fault_detected <= 1'b0;
        end else begin

            // Fault detection
            fault_detected <= (cpu0_pc != cpu1_pc) ||
                              (cpu1_pc != cpu2_pc) ||
                              (cpu0_pc != cpu2_pc);

            // ML-style intelligent voting
            // Single fault: pick two that agree
            if (cpu0_pc == cpu1_pc)
                correct_cpu <= 2'd0;
            else if (cpu0_pc == cpu2_pc)
                correct_cpu <= 2'd0;
            else if (cpu1_pc == cpu2_pc)
                correct_cpu <= 2'd1;
            else
                // Double fault: trust CPU0
                correct_cpu <= 2'd0;
        end
    end

endmodule