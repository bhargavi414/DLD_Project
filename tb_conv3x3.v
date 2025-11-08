`timescale 1ns / 1ps

module tb_conv3x3;
  parameter total_bits = 16;
  parameter frac_bits  = 8;
  parameter max_rows   = 8;
  parameter max_cols   = 8;

  // Test inputs
  reg [3:0] rows, cols;
  reg signed [max_rows*max_cols*total_bits-1:0] matrix_data;
  reg signed [total_bits-1:0] K00, K01, K02, K10, K11, K12, K20, K21, K22;

  // Output
  wire signed [(max_rows-2)*(max_cols-2)*total_bits-1:0] filtered_matrix;

  // Instantiate DUT
  conv3x3 #(
    .total_bits(total_bits),
    .frac_bits(frac_bits),
    .max_rows(max_rows),
    .max_cols(max_cols)
  ) dut (
    .rows(rows),
    .cols(cols),
    .matrix_data(matrix_data),
    .K00(K00), .K01(K01), .K02(K02),
    .K10(K10), .K11(K11), .K12(K12),
    .K20(K20), .K21(K21), .K22(K22),
    .filtered_matrix(filtered_matrix)
  );

  integer r, c;
  reg signed [total_bits-1:0] temp;
  real temp_float;

  initial begin

  //Test case-1
    //image (4x4) in Q8.8
    // Original image: 4x4 stripes pattern
    //  1  0  1  0
    //  1  0  1  0
    //  1  0  1  0
    //  1  0  1  0
    rows = 4;
    cols = 4;
  //1 in Q8.8 is 256
    matrix_data = {
  16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,   // row 7
  16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,   // row 6
  16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,   // row 5
  16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,16'd0,   // row 4
  16'd0,16'd0,16'd0,16'd0,16'd256,16'd0,16'd256,16'd0, // row 3
  16'd0,16'd0,16'd0,16'd0,16'd256,16'd0,16'd256,16'd0, // row 2
  16'd0,16'd0,16'd0,16'd0,16'd256,16'd0,16'd256,16'd0, // row 1
  16'd0,16'd0,16'd0,16'd0,16'd256,16'd0,16'd256,16'd0  // row 0 (LSB)
    };

    //Edge detection kernel in Q8.8
    // Original kernel: Blur kernel(1/9 scaling)
    // 1 1 1
    // 1 1 1
    // 1 1 1 
  K00 = 16'd28; K01 = 16'd28; K02 = 16'd28;
  K10 = 16'd28; K11 = 16'd28; K12 = 16'd28;
  K20 = 16'd28; K21 = 16'd28; K22 = 16'd28;

    #10;

  $display("Filtered output:");
  for (r = 0; r < rows - 2; r = r + 1) begin
    for (c = 0; c < cols - 2; c = c + 1) begin
      temp = filtered_matrix[((r*(max_cols-2))+c)*total_bits +: total_bits];
      temp_float = $itor(temp) / 256.0; //convert back Q8.8 to float
      $write("%0.3f ", temp_float);
    end
    $write("\n");
  end

    #20

    //Test case-2
    rows=8;
    cols=8;

   //image (8x8) in Q8.8
  // Original image: 8x8 checkboard pattern
    matrix_data = {
  16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,   // row 7
  16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,   // row 6
  16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,   // row 5
  16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,     // row 4
  16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,  // row 3
  16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,   // row 2
  16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,  // row 1
  16'd0,16'd256,16'd0,16'd256,16'd0,16'd256,16'd0,16'd256   // row 0 (LSB)
  };

//Edge detection kernel in Q8.8
    // Original kernel: edge detection kernel(1/9 scaling)
    // -1 -1 -1
    // -1 8 -1
    // -1 -1 -1
  K00 = 16'd28; K01 = 16'd28; K02 = 16'd28;
  K10 = 16'd28; K11 = 16'd28; K12 = 16'd28;
  K20 = 16'd28; K21 = 16'd28; K22 = 16'd28;

    #10;

    $display("Filtered output:");
    //looping accross the matrix_data 
  for (r = 0; r < rows - 2; r = r + 1) begin
    for (c = 0; c < cols - 2; c = c + 1) begin
      temp = $signed(filtered_matrix[((r*(max_cols-2))+c)*total_bits +: total_bits]);
      temp_float = $itor(temp)/256.0; //convert back Q8.8 to float
      $write("%0.3f ", temp_float);
    end
    $write("\n");
  end

    $finish;
  end
endmodule
