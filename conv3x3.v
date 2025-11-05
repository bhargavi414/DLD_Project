module conv3x3 #(
    parameter total_bits=16, 
    parameter frac_bits=8,
    parameter max_rows=8,
    parameter max_cols=8

    //input can be taken by making rest of the bits 0 if rows/cols are less than 8
    )
    (
    //following are given through test bench
    //enter the number of rows and columns in your input image
    input [3:0] rows, 
    input[3:0] cols,
    input[max_rows*max_cols*total_bits-1 : 0] matrix_data, //take the input of flattened image matrix
    //input of 3x3 kernel weights 
    input  signed [total_bits-1:0] K00, K01, K02,  
    input  signed [total_bits-1:0] K10, K11, K12,
    input  signed [total_bits-1:0] K20, K21, K22,
    //In filtered matrix->#Rows=(R-K+1) #Columns=(C-K+1)
    output reg [(max_rows-2)*(max_cols-2)*total_bits-1 : 0] filtered_matrix
);

//declaring local variables to use in mac unit 
//loop variables
integer r,c;
reg signed[total_bits-1:0] I00,I01,I02;
reg signed[total_bits-1:0] I10,I11,I12;
reg signed[total_bits-1:0] I20,I21,I22;
wire signed[total_bits-1:0] Y; //output of the convolution

//instantiating mac unit 
mac_3x3 #(
    .total_bits(total_bits),
    .frac_bits(frac_bits)
)mac_unit(
    .I00(I00), .I01(I01), .I02(I02),
    .I10(I10), .I11(I11), .I12(I12),
    .I20(I20), .I21(I21), .I22(I22),
    .K00(K00), .K01(K01), .K02(K02),
    .K10(K10), .K11(K11), .K12(K12),
    .K20(K20), .K21(K21), .K22(K22),
    .Y(Y)
);

//function for extracting the require image pixel from the flattened bus input 
function signed[total_bits-1:0] pixel;
    input integer row;
    input integer col;
    integer index; 
    begin 
        index=(row*max_cols+col)*total_bits;        //pixel in flattened bus->r*c+c
        pixel=matrix_data[index+:total_bits];       //extract the required data slice
    end
endfunction


//sliding window convolution of image
always @(*) begin
    filtered_matrix=0;

    for(r=0; r<rows-2;r=r+1) begin
        for(c=0;c<cols-2;c=c+1) begin

            //3x3 sub-matrix from input image matrix
            I00=pixel(r,c);
            I01=pixel(r,c+1);
            I02=pixel(r,c+2);
            I10=pixel(r+1,c);
            I11=pixel(r+1,c+1);
            I12=pixel(r+1,c+2);
            I20=pixel(r+2,c);
            I21=pixel(r+2,c+1);
            I22=pixel(r+2,c+2);

            //Convolution of the submatrix and kernel matrix will result in Y-should be stored in output matrix
            filtered_matrix[(((r*(max_cols-2))+c)*total_bits)+:total_bits]=Y;
            end
        end
    end
endmodule
