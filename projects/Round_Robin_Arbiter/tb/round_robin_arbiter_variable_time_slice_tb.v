

// simple Tb
module Arbiter_test;
  reg clk;
  reg rst_n;
  reg [3:0] REQ;
  wire [3:0] GNT;
  
  //Instantiate Design Under Test
  
  round_robin_arbiter_variable_time_slice DUT(.clk(clk), .rst_n(rst_n), .REQ(REQ), .GNT(GNT));
  
  //Generate a 10 ns  Time Period Clock 
  always #5 clk = ~clk;
  
  //Drive the DUT or Generate stimuli for the DUT
  
  initial begin
    clk = 0;
    rst_n = 1;
    REQ = 4'b0;
    //Deassert the Reset
    #3 rst_n = 0;
    #6 rst_n = 1;
    
    @(posedge clk) REQ = 4'b0001;    
    
    @(posedge clk) REQ = 4'b0000;
    
    @(posedge clk) REQ = 4'b0011;
    
    @(posedge clk) REQ = 4'b0110;
    
    @(posedge clk) REQ = 4'b1110;
    
    @(posedge clk) REQ = 4'b1111;
    
    @(posedge clk) REQ = 4'b0100;
    
    @(posedge clk) REQ = 4'b0100;
    
    @(posedge clk) REQ = 4'b0001;
    
    @(posedge clk) REQ = 4'b0010;
    
    @(posedge clk) REQ = 4'b0010;
    
    @(posedge clk) REQ = 4'b0010;
    
    #5 rst_n = 0;
    
    #100 $finish;
  end
  
   initial begin
    // below two lines are used to show waveform
    $dumpfile("dump.vcd");
     $dumpvars();
  end
  
endmodule
    
    
    
    
    