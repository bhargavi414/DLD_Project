
// Adding two Numbers in the Q8.8 Format 8--> INTEGER PART & 8-->FRactional Part
// Each number is represented as a 16-bit signed integer
// By Usingf the Adder
module fxp_add #(parameter total_bits = 16)

(   input  signed  [total_bits-1:0] a, // Q8.8 format 1st number
    input  signed  [total_bits-1:0] b,  // Q8.8 format 2nd number 
    output signed  [total_bits-1:0] y   // Q8.8 format sum of a and b
);
    assign y = a + b; // Simple addition of two signed numbers and assigning the values
endmodule
