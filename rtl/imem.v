module imem (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:255];

    initial begin
        mem[0] = 32'h00500093;
        mem[1] = 32'h00A00113;
        mem[2] = 32'h002081B3;
        mem[3] = 32'h401181B3;
        mem[4] = 32'h0040A233;
        mem[5] = 32'h00000013;
    end

    assign instr = mem[addr[9:2]];

endmodule