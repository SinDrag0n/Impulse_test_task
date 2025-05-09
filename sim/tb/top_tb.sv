module top_tb();

  // Parameters
  localparam  DATA_WIDTH   = 32;
  localparam  TEST_AMMOUNT = 1000;

  //Ports
  logic clk_i;
  logic artsn_i;
  logic [DATA_WIDTH - 1:0] a_i;
  logic [DATA_WIDTH - 1:0] b_i;
  logic [DATA_WIDTH - 1:0] c_i;
  logic [DATA_WIDTH - 1:0] d_i;
  logic [DATA_WIDTH - 1:0] q_o;
  logic a_valid_i;
  logic b_valid_i;
  logic c_valid_i;
  logic d_valid_i;
  logic q_valid_o;

  logic [DATA_WIDTH - 1:0] a_queue [$];
  logic [DATA_WIDTH - 1:0] b_queue [$];
  logic [DATA_WIDTH - 1:0] c_queue [$];
  logic [DATA_WIDTH - 1:0] d_queue [$];

  logic [DATA_WIDTH - 1:0] q_expected;

  top # (
    .DATA_WIDTH(DATA_WIDTH)
  )
  top_inst (
    .clk_i(clk_i),
    .artsn_i(artsn_i),
    .a_i(a_i),
    .b_i(b_i),
    .c_i(c_i),
    .d_i(d_i),
    .q_o(q_o),
    .a_valid_i(a_valid_i),
    .b_valid_i(b_valid_i),
    .c_valid_i(c_valid_i),
    .d_valid_i(d_valid_i),
    .q_valid_o(q_valid_o)
  );

always #5  clk_i = ! clk_i ;

task reset();
  clk_i     <= 1'b0;
  artsn_i   <= 1'b1;
  a_i       <= DATA_WIDTH'(0);
  b_i       <= DATA_WIDTH'(0);
  c_i       <= DATA_WIDTH'(0);
  d_i       <= DATA_WIDTH'(0);
  a_valid_i <= 1'b0;
  b_valid_i <= 1'b0;
  c_valid_i <= 1'b0;
  d_valid_i <= 1'b0;
  #10;
  artsn_i <= 1'b0;
  #100;
  artsn_i <= 1'b1;  
endtask

task driver();
  repeat ( TEST_AMMOUNT ) begin
    @( negedge clk_i );
    if ( $urandom % 2 ) begin
      generate_data();
    end

    else begin
      no_test();// No input data
    end
  end
endtask

task generate_data();
  a_i = $urandom_range(99, 0);
  b_i = $urandom_range(99, 0);
  c_i = $urandom_range(99, 0);
  d_i = $urandom_range(99, 0);

  a_valid_i <= 1'b1;
  b_valid_i <= 1'b1;
  c_valid_i <= 1'b1;
  d_valid_i <= 1'b1;

  a_queue.push_front( a_i );
  b_queue.push_front( b_i );
  c_queue.push_front( c_i );
  d_queue.push_front( d_i );
endtask

task no_test();

  a_valid_i <= 1'b0;
  b_valid_i <= 1'b0;
  c_valid_i <= 1'b0;
  d_valid_i <= 1'b0;

endtask

task monitor();
  repeat ( TEST_AMMOUNT ) begin
    @( negedge clk_i );
      if ( q_valid_o )
      q_expected = ( ( a_queue.pop_back() - b_queue.pop_back() ) * ( 1 + 3 * c_queue.pop_back() ) - 4 * d_queue.pop_back() ) / 2;

      if ( q_expected != q_o ) begin
        $error("Wrong output data, expected %d, got %d at moment: %t", q_expected, q_o, $time());
      end
  end
endtask

initial begin
  reset();
  fork
  driver();
  monitor();
  join
  $finish();
end

endmodule