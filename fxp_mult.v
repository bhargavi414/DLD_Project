module fxp_mult #(
parameter int_bits =8,// Number of integer bits
parameter frac_bits =8,// Number of fractional bits
parameter total_bits = int_bits+frac_bits 
)
(
input signed [total_bits-1:0] a, // 16 bit input a
input signed [total_bits-1:0] b, // 16 bit input b
output signed [total_bits-1:0] result // 16 bit output result

);
// wire to hold the full multiplication result
wire signed [2*total_bits-1:0] mult_full;
// multiply the q8.8 numbers gives a q16.16 result
assign mult_full = a*b;
// extracting the relevent bits for q8.8 result
// for q8.8 *q8.8 = q16.16 , we need to shift to right by frac_bits(8) to get back to q8.8
//to get the q8.8 format result
// we take bits [total_bits+frac_bits-1 : frac_bits
assign result = mult_full[total_bits+frac_bits-1 : frac_bits];
endmodule
