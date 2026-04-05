module pc_tb;
    reg clk, reset;
    reg [31:0] pc_next;
    wire [31:0] pc_out;

    pc uut (.clk(clk), .reset(reset), 
            .pc_next(pc_next), .pc_out(pc_out));

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; pc_next = 0;
        #10 reset = 0;          // release reset
        #10 pc_next = 32'h4;    // PC = 4
        #10 pc_next = 32'h8;    // PC = 8
        #10 pc_next = 32'hC;    // PC = 12
        #10 pc_next = 32'h10;   // PC = 16
        #20  $stop; 
    end
endmodule