module alu_tb;
  reg  [31:0] a, b;
  reg  [3:0]  alu_ctrl;
  wire [31:0] result;
  wire zero;
  alu uut (.a(a), .b(b), .alu_ctrl(alu_ctrl),
           .result(result), .zero(zero));
  initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars(0, alu_tb);
    // Test ADD: 5+3=8
    a=32'd5; b=32'd3; alu_ctrl=4'b0000; #10;
    $display("ADD: %d + %d = %d", a, b, result);
    // Test SUB: 10-4=6
    a=32'd10; b=32'd4; alu_ctrl=4'b0001; #10;
    $display("SUB: %d - %d = %d", a, b, result);
    // Test AND
    a=32'hFF; b=32'h0F; alu_ctrl=4'b0010; #10;
    $display("AND: %h & %h = %h", a, b, result);
    $finish;
  end
endmodule
