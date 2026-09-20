module regfile_tb;
    reg clk, reset, we;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] wd;
    wire [31:0] rd1, rd2;

    regfile uut (.clk(clk), .reset(reset), .we(we),
                 .rs1(rs1), .rs2(rs2), .rd(rd),
                 .wd(wd), .rd1(rd1), .rd2(rd2));

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; we = 0;
        rs1 = 0; rs2 = 0; rd = 0; wd = 0;
        #10 reset = 0;

        // Write 100 into x1
        we = 1; rd = 5'd1; wd = 32'd100;
        #10;

        // Write 200 into x2
        rd = 5'd2; wd = 32'd200;
        #10;

        // Read x1 and x2
        we = 0; rs1 = 5'd1; rs2 = 5'd2;
        #10;

        // Try writing to x0 (should stay 0)
        we = 1; rd = 5'd0; wd = 32'd999;
        #10;
        rs1 = 5'd0;
        #20;
        $stop;
    end
endmodule