`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Clayton Payne
// 
// Create Date: 06/05/2021 12:04:16 AM
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb;
    parameter        width = 4;
    integer 	     i = 0, j = 0;
    reg  [width-1:0] dividend, divisor;
    reg 	     start, clk, rst;
    wire [width-1:0] quotient, remainder;
    wire 	     ready, err;

    divider div (dividend, divisor, quotient, remainder, err, clk, rst, start, ready);
    always #5 clk = !clk;
    initial 
    begin 
        rst = 1; clk = 0; dividend = 0; divisor = 0; start = 0; #100;
        rst = 0; #100;
        repeat (16)
        begin
        dividend = i;
            repeat (16)
            begin
                divisor = j; start = 1; #10;
                start = 0; #90;
                j = j+1;
            end
        i = i+1;
        end
    end 
endmodule
