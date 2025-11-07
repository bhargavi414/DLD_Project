// mac_3x3.v
// This module performs a 3x3 multiply-and-accumulate (MAC) operation.
// It takes 9 image pixels and 9 kernel weights (Q8.8 fixed-point format)
// and produces a single convolution output value
// Basically, this block is responsible for doing:
// output=sum(pixel(i,j)*kernel(i,j)) for i,j in {0,1,2}
// The module uses the fxp_mult module and fxp_add module

module mac_3x3#(
    parameter int_bits = 8, //  Number of integer bits
    parameter frac_bits = 8,   // Number of fractional bits
    parameter total_bits=16  // Bit-width of inputs and output (Q8.8 -> 16 bits total)
 )
(
    // 3x3 input image window
    input  signed [total_bits-1:0] I00, I01, I02,
    input  signed [total_bits-1:0] I10, I11, I12,
    input  signed [total_bits-1:0] I20, I21, I22,
    // 3x3 kernel weights
    input  signed [total_bits-1:0] K00, K01, K02,
    input  signed [total_bits-1:0] K10, K11, K12,
    input  signed [total_bits-1:0] K20, K21, K22,
    // Convolution result
    output signed [total_bits-1:0] Y
);
    wire signed [total_bits-1:0] m00,m01,m02,m10,m11,m12,m20,m21,m22; //multiplication results
    wire signed [total_bits-1:0] s1,s2,s3,s4,s5,s6,s7,s8; //sum results 

    // Multiply
    fxp_mult #(int_bits, frac_bits) M00(I00,K00,m00);       //(a->I00, b->K00, result->m00)
    fxp_mult #(int_bits, frac_bits) M01(I01,K01,m01);
    fxp_mult #(int_bits, frac_bits) M02(I02,K02,m02);
    fxp_mult #(int_bits, frac_bits) M10(I10,K10,m10);
    fxp_mult #(int_bits, frac_bits) M11(I11,K11,m11);
    fxp_mult #(int_bits, frac_bits) M12(I12,K12,m12);
    fxp_mult #(int_bits, frac_bits) M20(I20,K20,m20);
    fxp_mult #(int_bits, frac_bits) M21(I21,K21,m21);
    fxp_mult #(int_bits, frac_bits) M22(I22,K22,m22);

    //Add up all nine multiplication results.
    fxp_add #(total_bits) A1(m00, m01, s1);
    fxp_add #(total_bits) A2(s1, m02, s2);
    fxp_add #(total_bits) A3(s2, m10, s3);
    fxp_add #(total_bits) A4(s3, m11, s4);
    fxp_add #(total_bits) A5(s4, m12, s5);
    fxp_add #(total_bits) A6(s5, m20, s6);
    fxp_add #(total_bits) A7(s6, m21, s7);
    fxp_add #(total_bits) A8(s7, m22, Y); // final output

endmodule


