module top #(
  parameter DATA_WIDTH = 32
)(
  input  logic clk_i,
  input  logic artsn_i,

  /// DATA PORTS ///
  input  logic signed [DATA_WIDTH - 1:0] a_i,
  input  logic signed [DATA_WIDTH - 1:0] b_i,
  input  logic signed [DATA_WIDTH - 1:0] c_i,
  input  logic signed [DATA_WIDTH - 1:0] d_i,
  output logic signed [DATA_WIDTH - 1:0] q_o,

  /// VALID PORTS /// 
  input  logic a_valid_i,
  input  logic b_valid_i,
  input  logic c_valid_i,
  input  logic d_valid_i,
  output logic q_valid_o
);

/// INPUT FFs ///

logic signed [DATA_WIDTH - 1:0] a_inp_ff;
logic signed [DATA_WIDTH - 1:0] b_inp_ff;
logic signed [DATA_WIDTH - 1:0] c_inp_ff;
logic signed [DATA_WIDTH - 1:0] d_inp_ff;

logic valid_inp_ff;

always_ff @( posedge clk_i or negedge artsn_i ) begin : input_flip_flops
  if ( ~artsn_i ) begin
    a_inp_ff <= DATA_WIDTH'(0);
    b_inp_ff <= DATA_WIDTH'(0);
    c_inp_ff <= DATA_WIDTH'(0);
    d_inp_ff <= DATA_WIDTH'(0);
    valid_inp_ff <= 1'b0;
  end

  else begin
    if ( a_valid_i ) a_inp_ff <= a_i;
    if ( b_valid_i ) b_inp_ff <= b_i;
    if ( b_valid_i ) c_inp_ff <= c_i;
    if ( b_valid_i ) d_inp_ff <= d_i;
    valid_inp_ff <= &{a_valid_i, b_valid_i, c_valid_i, d_valid_i};  // Объединение всех сигналов valid - все входные данные пришли и корректны
  end
end

/// PIPELINE FFs ///

/// Stage 1

logic [DATA_WIDTH - 1:0] ab_ff_st1;
logic [DATA_WIDTH - 1:0] c_ff_st1;
logic [DATA_WIDTH - 1:0] d_ff_st1;

logic signed [DATA_WIDTH - 1:0] c_multiplied;
logic signed [DATA_WIDTH - 1:0] c_incremented;
logic signed [DATA_WIDTH - 1:0] ab_summed;

logic valid_ff_st1;

always_ff @( posedge clk_i or negedge artsn_i ) begin : stage1_pipeline
  if ( ~artsn_i ) begin
    ab_ff_st1 <= DATA_WIDTH'(0);
    c_ff_st1  <= DATA_WIDTH'(0);
    d_ff_st1  <= DATA_WIDTH'(0);
    valid_ff_st1 <= 1'b0;
  end

  else begin
    ab_ff_st1 <= ab_summed;       // (a-b)
    c_ff_st1  <= c_incremented;   // 3*c + 1
    d_ff_st1  <= d_inp_ff << 2;   // 4*d
    valid_ff_st1 <= valid_inp_ff;
  end
end

/// Stage 2

logic [DATA_WIDTH - 1:0] abc_ff_st2;
logic [DATA_WIDTH - 1:0] d_ff_st2;

logic [DATA_WIDTH - 1:0] abc_mul;

logic valid_ff_st2;

always_ff @( posedge clk_i or negedge artsn_i ) begin : stage2_pipeline
  if ( ~artsn_i ) begin
    abc_ff_st2 <= DATA_WIDTH'(0);
    d_ff_st2   <= DATA_WIDTH'(0);
  end

  else begin
    abc_ff_st2 <= abc_mul;         // (a-b)*(3c+1)
    d_ff_st2   <= d_ff_st1;        // 4*d 
    valid_ff_st2 <= valid_ff_st1;
  end
end

/// INSTANCES ///

/// Stage 1 pipeline

multiplier # (
  .DATA_WIDTH( DATA_WIDTH )
)
multiplier_3c (
  .a_in   ( DATA_WIDTH'(3) ),
  .b_in   ( c_inp_ff ),
  .res_o  ( c_multiplied )
);

incrementer # (
  .DATA_WIDTH(DATA_WIDTH)
)
incrementer_3c (
  .data_i  ( c_multiplied  ),
  .data_o  ( c_incremented )
);

adder # (
  .DATA_WIDTH( DATA_WIDTH ) 
)
adder_ab (
  .a_in   ( a_inp_ff  ),
  .b_in   ( -b_inp_ff  ),
  .res_o  ( ab_summed )
);

/// Stage 2 pipeline 

multiplier # (
  .DATA_WIDTH( DATA_WIDTH )
)
multiplier_abc (
  .a_in   ( ab_ff_st1 ),
  .b_in   ( c_ff_st1  ),
  .res_o  ( abc_mul   )
);

/// Stage 3 pipeline

logic signed [DATA_WIDTH - 1:0] q_preresult;

adder # (
  .DATA_WIDTH( DATA_WIDTH )
)
adder_abcd (
  .a_in   ( abc_ff_st2  ),
  .b_in   ( -d_ff_st2  ),
  .res_o  ( q_preresult )
);

assign q_o = q_preresult >>> 1'b1;
assign q_valid_o = valid_ff_st2;

endmodule