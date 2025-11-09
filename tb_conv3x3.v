`timescale 1ns / 1ps

module tb_conv3x3;

  parameter total_bits = 16;
  parameter frac_bits  = 8;
  parameter max_rows   = 8;
  parameter max_cols   = 8;

  reg clk;
  reg rst;
  reg [3:0] rows, cols;
  reg signed [max_rows*max_cols*total_bits-1:0] matrix_data;
  reg signed [total_bits-1:0] K00, K01, K02, K10, K11, K12, K20, K21, K22;

  wire signed [(max_rows-2)*(max_cols-2)*total_bits-1:0] filtered_matrix;
  wire done;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Instantiate DUT
  conv3x3 #(
    .total_bits(total_bits),
    .frac_bits(frac_bits),
    .max_rows(max_rows),
    .max_cols(max_cols)
  ) dut (
    .clk(clk),
    .rst(rst),
    .rows(rows),
    .cols(cols),
    .matrix_data(matrix_data),
    .K00(K00), .K01(K01), .K02(K02),
    .K10(K10), .K11(K11), .K12(K12),
    .K20(K20), .K21(K21), .K22(K22),
    .filtered_matrix(filtered_matrix),
    .done(done)
  );

  integer r, c;
  reg signed [total_bits-1:0] temp;
  real temp_float;

  initial begin
    // Reset DUT
    rst = 1; 
    #15;
    rst = 0;

    // Test Case 1
    rows = 4;
    cols = 4;
    //vertical stripes input image matrix
    matrix_data = {
      16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,
      16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,
      16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,
      16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,
      16'd0,16'd0,16'd0,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd0,16'd0,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd0,16'd0,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd0,16'd0,16'd0,16'd256,16'd0,16'd256,16'd0
    };
  //scaled 3x3 blur kernel
    K00 = 16'd28; K01 = 16'd28; K02 = 16'd28;
    K10 = 16'd28; K11 = 16'd28; K12 = 16'd28;
    K20 = 16'd28; K21 = 16'd28; K22 = 16'd28;

    wait(done); //wait until done==1 (until operation is complete)
    #10;

    $display("Filtered output for 4x4 stripes:");
    for (r = 0; r < rows-2; r = r + 1) begin
      for (c = 0; c < cols-2; c = c + 1) begin
          temp = filtered_matrix[((r*(cols-2)) + c)*total_bits +: total_bits];
          temp_float = $itor(temp) / 256.0; //obtaining decimal form from Q8.8
          $write("%0.3f ", temp_float);
      end
      $write("\n");
    end

    // Reset for next test case
    rst = 1;
    #10;
    rst = 0;

    //Test Case 2
    rows = 8;
    cols = 8;
    //8x8 checkboard input image matrix
    matrix_data = {
      16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,
      16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,
      16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,
      16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256
    };
  //3x3 scaled blur kernel
    K00 = 16'd28; K01 = 16'd28; K02 = 16'd28;
    K10 = 16'd28; K11 = 16'd28; K12 = 16'd28;
    K20 = 16'd28; K21 = 16'd28; K22 = 16'd28;

    wait(done);
    #10;

    $display("Filtered output for 8x8 checkerboard with blur kernel:");
    for (r = 0; r < rows-2; r = r + 1) begin
      for (c = 0; c < cols-2; c = c + 1) begin
        temp = filtered_matrix[((r*(cols-2)) + c)*total_bits +: total_bits];
        temp_float = $itor(temp) / 256.0;
        $write("%0.3f ", temp_float);
      end
      $write("\n");
    end

    rst = 1;
    #10;
    rst = 0;

    //Test Case 3
    rows = 8;
    cols = 8;
    //8x8 checkboard matrix
    matrix_data = {
      16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,
      16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,
      16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,
      16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,
      16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256
    };
  //3x3 edge detection matrix
    K00 = -16'd256; K01 = -16'd256; K02 = -16'd256;
    K10 = -16'd256; K11 = 16'd2048; K12 = -16'd256;
    K20 = -16'd256; K21 = -16'd256; K22 = -16'd256;

    wait(done);
    #10;

    $display("Filtered output for 8x8 checkerboard with edge detection kernel:");
    for (r = 0; r < rows-2; r = r + 1) begin
      for (c = 0; c < cols-2; c = c + 1) begin
        temp = filtered_matrix[((r*(cols-2)) + c)*total_bits +: total_bits];
        temp_float = $itor(temp) / 256.0;
        $write("%0.3f ", temp_float);
      end
      $write("\n");
    end

    $finish;
  end

endmodule
