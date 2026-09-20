module control_tb;
    reg [6:0] opcode;
    wire branch, memread, memtoreg;
    wire memwrite, alusrc, regwrite;
    wire [1:0] aluop;

    control uut (
        .opcode(opcode),
        .branch(branch), .memread(memread),
        .memtoreg(memtoreg), .aluop(aluop),
        .memwrite(memwrite), .alusrc(alusrc),
        .regwrite(regwrite)
    );

    initial begin
        // R-type
        opcode = 7'b0110011; #10;
        // I-type
        opcode = 7'b0010011; #10;
        // Load
        opcode = 7'b0000011; #10;
        // Store
        opcode = 7'b0100011; #10;
        // Branch
        opcode = 7'b1100011; #10;
        $stop;
    end
endmodule