`timescale 1ns/1ps
module tmr_top (
    input         clk,
    input         reset,
    input  [31:0] fault_inject,
    input         fault_enable,
    output reg [31:0] pc_out_debug,
    output        fault_detected
);
    // 3 copies of your RISC-V CPU
    wire [31:0] pc1, pc2, pc3;
    wire [31:0] pc2_actual;

    riscv_top CPU1 (
        .clk          (clk),
        .reset        (reset),
        .pc_out_debug (pc1)
    );
    riscv_top CPU2 (
        .clk          (clk),
        .reset        (reset),
        .pc_out_debug (pc2)
    );
    riscv_top CPU3 (
        .clk          (clk),
        .reset        (reset),
        .pc_out_debug (pc3)
    );

    // Fault injection mux
    assign pc2_actual = (fault_enable == 1'b1) ? fault_inject : pc2;

    // ML Voter
    wire [1:0] correct_cpu;
    wire       ml_fault_detected;

    ml_voter ML_VOTER (
        .clk           (clk),
        .reset         (reset),
        .cpu0_pc       (pc1),
        .cpu1_pc       (pc2_actual),
        .cpu2_pc       (pc3),
        .correct_cpu   (correct_cpu),
        .fault_detected(ml_fault_detected)
    );

    // Last known good PC
    reg [31:0] last_good_pc;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out_debug <= 32'd0;
            last_good_pc <= 32'd0;
        end else begin
            if (!ml_fault_detected) begin
                // No fault → output normally and save good PC
                case (correct_cpu)
                    2'd0: pc_out_debug <= pc1;
                    2'd1: pc_out_debug <= pc2_actual;
                    2'd2: pc_out_debug <= pc3;
                    default: pc_out_debug <= pc1;
                endcase
                last_good_pc <= pc_out_debug;
            end else begin
                // Fault detected → hold last good PC
                pc_out_debug <= last_good_pc;
            end
        end
    end

    assign fault_detected = ml_fault_detected;

endmodule