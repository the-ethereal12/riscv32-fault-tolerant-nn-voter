module riscv_top (
    input  clk,
    input  reset,
    output [31:0] pc_out_debug
);
    // Wires connecting all modules
    wire [31:0] pc_out, pc_next, instr;
    wire [31:0] rd1, rd2, wd, alu_result;
    wire [31:0] imm, alu_b, dmem_rd;
    wire        zero, branch, memread;
    wire        memtoreg, memwrite;
    wire        alusrc, regwrite;
    wire [1:0]  aluop;
    wire [3:0]  alu_ctrl;
    wire        pcsrc;

    // Debug output
    assign pc_out_debug = pc_out;

    // PC next logic
    assign pc_next = (pcsrc) ? 
                     (pc_out + (imm << 1)) : 
                     (pc_out + 4);
    assign pcsrc = branch & zero;

    // Immediate generation
    assign imm = {{20{instr[31]}}, instr[31:20]};

    // ALU control
    assign alu_ctrl = (aluop == 2'b00) ? 4'b0000 :
                      (aluop == 2'b01) ? 4'b0001 :
                      (instr[14:12] == 3'b000) ? 4'b0000 :
                      (instr[14:12] == 3'b111) ? 4'b0010 :
                      (instr[14:12] == 3'b110) ? 4'b0011 :
                      4'b0000;

    // ALU B input mux
    assign alu_b = alusrc ? imm : rd2;

    // Writeback mux
    assign wd = memtoreg ? dmem_rd : alu_result;

    // Module instantiations
    pc PC (
        .clk(clk), .reset(reset),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    imem IMEM (
        .addr(pc_out),
        .instr(instr)
    );

    control CTRL (
        .opcode(instr[6:0]),
        .branch(branch), .memread(memread),
        .memtoreg(memtoreg), .aluop(aluop),
        .memwrite(memwrite), .alusrc(alusrc),
        .regwrite(regwrite)
    );

    regfile RF (
        .clk(clk), .reset(reset),
        .we(regwrite),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .wd(wd),
        .rd1(rd1), .rd2(rd2)
    );

    alu ALU (
        .a(rd1), .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    dmem DMEM (
        .clk(clk), .we(memwrite),
        .addr(alu_result),
        .wd(rd2),
        .rd(dmem_rd)
    );

endmodule