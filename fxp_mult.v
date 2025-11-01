
module decoder #(
    parameter N = 2
) (
    input  wire [N-1:0] sel,
    input wire  enable,
    output reg [(1<<N)-1:0] out
);
 integer i;
 always @(*) begin
if (enable) begin
out = { (1<<N){1'b0} }; 
out[sel] = 1'b1;  
end else begin
 out = { (1<<N){1'b0} };
end
end
endmodule 
