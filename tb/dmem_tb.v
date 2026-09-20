module dmem_tb;
    reg clk, we;
    reg  [31:0] addr, wd;
    wire [31:0] rd;

    dmem uut (.clk(clk), .we(we),
              .addr(addr), .wd(wd), .rd(rd));

    always #5 clk = ~clk;

    initial begin
        clk=0; we=0; addr=0; wd=0;

        // Write 100 to address 0
        we=1; addr=32'h00; wd=32'd100; #10;

        // Write 200 to address 4
        addr=32'h04; wd=32'd200; #10;

        // Read address 0
        we=0; addr=32'h00; #10;

        // Read address 4
        addr=32'h04; #10;
        #20;
        $stop;
    end
endmodule