`ifndef INT_DIVIDER
`define INT_DIVIDER

module IntDivider 
    # (
        parameter WIDTH = 8,
        parameter LOGWIDTH = $clog2(WIDTH)
    )
(
    input  logic                 CLK,
    input  logic                 RST,
    input  logic                 DataVal,
    input  logic [WIDTH-1:0]     Dividend,
    input  logic [WIDTH-1:0]     Divisor,
    output logic [WIDTH-1:0]     Quotient,
    output logic [WIDTH-1:0]     Remainder,
    output logic                 DivdByZeroExc,
    output logic                 ResultVal
);
    // Controller
    logic                        DivdState;
    logic                        DivdStateD;
    logic                        DivdEn;
    logic                        LoadABEn;
    logic                        LoadEn;
    logic                        DivdByZeroExcEn;
    logic                        ResultValEn;
    logic                        RemainderIsZero;

    // Datapath
    logic [WIDTH-1:0]            DividendD;
    logic [WIDTH-1:0]            DividendQ;
    logic [WIDTH-1:0]            DivisorQ;
    logic [WIDTH-1:0]            TwosCompDivisor;
    logic [WIDTH-1:0]            QuotientD;
    logic [WIDTH-1:0]            RemainderD;
    logic [WIDTH-1:0]            RemainderQ;
    logic                        DivdByZeroExcD;
    logic                        ResultValD;
    logic                        DivsGTRem;
    logic                        DivsGTERem;
    logic                        SubResult;
    logic [LOGWIDTH-1:0]         CntD;
    logic [LOGWIDTH-1:0]         CntQ;

    // Controller
    rflop #(1)       I_DivdState    (.Q(DivdState     ), .D(DivdStateD    ), .Clk(CLK), .En(1'b1       ), .Rst(RST));
    rflop #(1)       I_ResultVal    (.Q(ResultVal     ), .D(ResultValD    ), .Clk(CLK), .En(ResultValEn), .Rst(RST));

    assign LoadABEn              = ~DivdState       & DataVal;
    assign DivdByZeroExcEn       = LoadABEn;
    assign DivdStateD            = (LoadABEn        & ~DivdByZeroExcD     ) |
                                   (DivdState       & RemainderIsZero     ) ;
    assign DivdEn                = DivdState;
    assign LoadEn                = LoadABEn         | DivdEn;
    assign ResultValD            = DivdState        | DivdByZeroExcD;
    assign ResultValEn           = (DivdByZeroExcEn & DivdByZeroExcD      ) |
                                   (DivdState       & RemainderIsZero     ) ;

    // Datapath
    flop #(WIDTH)    I_Dividend     (.Q(DividendQ     ), .D(DividendD     ), .Clk(CLK), .En(LoadEn         ));
    flop #(WIDTH)    I_Divisor      (.Q(DivisorQ      ), .D(Divisor       ), .Clk(CLK), .En(LoadEn         ));
    flop #(WIDTH)    I_Quotient     (.Q(Quotient      ), .D(QuotientD     ), .Clk(CLK), .En(LoadEn         ));
    flop #(WIDTH)    I_Remainder    (.Q(RemainderQ    ), .D(RemainderD    ), .Clk(CLK), .En(LoadEn         ));
    flop #(1)        I_DivByZeroExc (.Q(DivByZeroExc  ), .D(DivdByZeroExcD), .Clk(CLK), .En(LoadABEn       ));
    flop #(LOGWIDTH) I_Cnt          (.Q(CntQ          ), .D(CntD          ), .Clk(CLK), .En(LoadEn         ));

    assign Quotient              = QuotientQ << CntQ;
    assign DivsGTERem            = DivsGTRem | (DividendQ == RemainderQ);
    assign TwosCompDivisor       = ~DivisorQ + 1'b1;
    assign SubResult             = {WIDTH{DivsGTERem}} & (RemainderQ + TwosCompDivisor);
    assign Remainder             = RemainderD[WIDTH-1:1];
    assign RemainderIsZero       = (RemainderD == '0);
    assign DivdbyZeroExcD        = (Divisor    == '0);

    Comparator #(WIDTH) Comparator 
    (
        .A      (DivisorQ       ),
        .B      (RemainderQ     ),
        .AGTB   (DivsGTRem      )
    );

    always_comb begin
        DividendD      = '0;
        RemainderD     = '0;
        QuotientD      = '0;
        CntD           = '0;
        unique case (1'b1) inside
            LoadABEn    :  begin
                DividendD      = Dividend;
                CntD           = {LOGWIDTH{1'b1}};
            end
            DivdEn      :  begin
                DividendD      = {DividendQ[WIDTH-2:0], 1'b0};
                RemainderD     = {SubResult[WIDTH-2:0], DividendQ[WIDTH-1]};
                QuotientD      = {Quotient[WIDTH-2:0], DivsGTERem};
                CntD           = CntQ + {LOGWIDTH{1'b1}};
            end
        endcase
    end

endmodule : IntDivider

`endif // INT_DIVIDER