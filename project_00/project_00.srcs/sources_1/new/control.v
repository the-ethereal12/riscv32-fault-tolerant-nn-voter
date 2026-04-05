module control (
    input  [6:0] opcode,
    output reg       branch,
    output reg       memread,
    output reg       memtoreg,
    output reg [1:0] aluop,
    output reg       memwrite,
    output reg       alusrc,
    output reg       regwrite
);
    always @(*) begin
        case(opcode)
            7'b0110011: begin // R-type
                branch=0; memread=0; memtoreg=0;
                aluop=2'b10; memwrite=0; alusrc=0; regwrite=1;
            end
            7'b0010011: begin // I-type (ADDI)
                branch=0; memread=0; memtoreg=0;
                aluop=2'b10; memwrite=0; alusrc=1; regwrite=1;
            end
            7'b0000011: begin // Load (LW)
                branch=0; memread=1; memtoreg=1;
                aluop=2'b00; memwrite=0; alusrc=1; regwrite=1;
            end
            7'b0100011: begin // Store (SW)
                branch=0; memread=0; memtoreg=0;
                aluop=2'b00; memwrite=1; alusrc=1; regwrite=0;
            end
            7'b1100011: begin // Branch (BEQ)
                branch=1; memread=0; memtoreg=0;
                aluop=2'b01; memwrite=0; alusrc=0; regwrite=0;
            end
            default: begin
                branch=0; memread=0; memtoreg=0;
                aluop=2'b00; memwrite=0; alusrc=0; regwrite=0;
            end
        endcase
    end
endmodule