module imem_tb;
    reg  [31:0] addr;
    wire [31:0] instr;

    imem uut (.addr(addr), .instr(instr));

    initial begin
        addr = 32'h00; #10;
        addr = 32'h04; #10;
        addr = 32'h08; #10;
        addr = 32'h0C; #10;
        $stop;
    end
endmodule
