`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Clayton Payne
// Create Date: 06/04/2021 04:00:56 PM
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module divider(dividend, divisor, quotient, remainder, err, clk, rst, start, ready);
    parameter width = 4;                // Width of datapath regs
    parameter s_idle = 0, s_divd = 1, s_remn = 2;
    
    input  start, clk, rst;
    input  [width-1:0] dividend, divisor;
    output [width-1:0] quotient, remainder;
    output err, ready;                  // err = division by zero
                                        // ready = division complete
    
    // Controller regs and nets
    reg    state, next_state;           // Controller states
    reg    load, divide;                // Control signals
    assign ready = (state == s_idle);
    
    // Datapath registers
    reg [width-1:0]  A, B, Q, I;
    reg [3:0]        counter;
    
    // Datapath combinational assignments 
    wire 	     cmp = (I >= B);
    wire [width-1:0] sub = I - cmp*B;   // If I is divisible by B, subtract B, if not, subtract 0
    wire   	     count_end;
    nor(count_end, counter[3], counter[2], counter[1], counter[0]);
    assign 	     quotient = Q;
    assign 	     remainder = I >> 1;
    assign 	     err = !B;
    
    // CONTROLLER //
    
    always @ (posedge clk, negedge rst)
        if (rst) state <= s_idle; 
        else state <= next_state;
    always @ (state, start, A, B, count_end) 
    begin
        // Blocking default assigments
        load = 0;
        divide = 0;
        // ASM
        case (state)
        s_idle: if (start) 
                begin 
                    next_state = s_divd;
                    load = 1;
                end
                else next_state = s_idle; 
        s_divd: begin
                    divide = 1;
                    if (!B || count_end) next_state = s_idle;
                    else next_state = s_divd;
                end
        default: next_state = s_idle; 
        endcase
    end
    
    // DATAPATH //
    
    always @ (posedge clk)
    begin
        if (load)
        begin
            A <= dividend;
            B <= divisor;
            I <= 0;
            Q <= 0;
            counter <= 4'b0100;
        end
        if (divide)
        begin
            I[0] <= A[3];
            A <= A << 1;
            I[width-1:1] <= sub[width-2:0];
            Q <= Q << 1;
            Q[0] <= cmp;
            if (!count_end) counter <= counter - 1;
            else counter <= 4'b0100;
        end
    end
endmodule