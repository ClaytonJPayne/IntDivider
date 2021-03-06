`ifndef CLOCK_GEN
`define CLOCK_GEN

module ClockGen
    #(
        parameter PERIOD = 10;
    )
(
    output Clk
);
    localparam HALF_PERIOD = PERIOD / 2;
    logic ClkReg;
    assign Clk = ClkReg;
    initial begin
        ClkReg = 0;
    end
    always #HALF_PERIOD ClkReg = ~ClkReg;
endmodule : ClockGen

`endif // CLOCK_GEN
