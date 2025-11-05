
// Adding two Numbers in the Q8.8 Format 8--> INTEGER PART & 8-->FRactional Part
// Each number is represented as a 16-bit signed integer
// By Usingf the Adder
module add(a, b, sum);
 
  input [15:0] a; // Q8.8 format 1st number
   
   input [15:0] b; 
  // Q8.8 format 2nd number  
   
    output [15:0] sum; 
  // Q8.8 format sum of a and b

    assign sum = a + b; 
  // Simple addition of two signed numbers and assigning the values
endmodule
