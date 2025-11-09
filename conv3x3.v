`timescale 1ns / 1ps

module conv3x3 #(
    parameter total_bits = 16, 
    parameter frac_bits  = 8,
    parameter max_rows   = 8,
    parameter max_cols   = 8
)(
    input clk,
    input rst,
    input  [3:0] rows, 
    input  [3:0] cols,
    input  [max_rows*max_cols*total_bits-1 : 0] matrix_data, // Flattened input image
    //kernel inputs
    input  signed [total_bits-1:0] K00, K01, K02,  
    input  signed [total_bits-1:0] K10, K11, K12,
    input  signed [total_bits-1:0] K20, K21, K22,
    output reg [(max_rows-2)*(max_cols-2)*total_bits-1 : 0] filtered_matrix,
    output reg done
);
    integer r, c;   //loop variables
    reg [3:0] row_cnt, col_cnt; //current coordinates of the pixel window
    reg signed [total_bits-1:0] I00, I01, I02;
    reg signed [total_bits-1:0] I10, I11, I12;
    reg signed [total_bits-1:0] I20, I21, I22;
    wire signed [total_bits-1:0] Y;
    //reg signed [total_bits-1:0] Y_reg;

    // Instantiate MAC
    mac_3x3 #(
        .total_bits(total_bits),
        .frac_bits(frac_bits)
    ) mac_unit (
        .I00(I00), .I01(I01), .I02(I02),
        .I10(I10), .I11(I11), .I12(I12),
        .I20(I20), .I21(I21), .I22(I22),
        .K00(K00), .K01(K01), .K02(K02),
        .K10(K10), .K11(K11), .K12(K12),
        .K20(K20), .K21(K21), .K22(K22),
        .Y(Y)
    );

    // Pixel extraction function
    function signed [total_bits-1:0] pixel;
        input integer row;
        input integer col;
        integer index;
        begin 
            index = (row*max_cols + col) * total_bits;  //index of the element in the flattened input 
            pixel = matrix_data[index +: total_bits];
        end
    endfunction
    
    // Add states for Finite state machine
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam COMPUTE = 2'b10;
    localparam STORE = 2'b11;
    
    reg [1:0] state;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin  //if reset is high, reset the pixel window coordinates, filtered matrix data (new test case)
            row_cnt <= 0;
            col_cnt <= 0;
            filtered_matrix <= 0;
            done <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (!done)
                        state <= LOAD; //next state is LOAD, loading the pixel values
                end

                LOAD: begin
                    I00 <= pixel(row_cnt,col_cnt);
                    I01 <= pixel(row_cnt,col_cnt + 1);
                    I02 <= pixel(row_cnt,col_cnt + 2);
                    I10 <= pixel(row_cnt+1,col_cnt);
                    I11 <= pixel(row_cnt+1,col_cnt + 1);
                    I12 <= pixel(row_cnt+1,col_cnt + 2);
                    I20 <= pixel(row_cnt+2,col_cnt);
                    I21 <= pixel(row_cnt+2,col_cnt + 1);
                    I22 <= pixel(row_cnt+2,col_cnt + 2);
                    state <= COMPUTE; //after loading the values compute the Y value
                end
                
                COMPUTE: begin
                    state <= STORE; //after computation store teh value in the filetered matrix
                end
                
                STORE: begin
                    filtered_matrix[(((row_cnt*(cols-2)) + col_cnt)*total_bits) +: total_bits] <= Y;
                    //update the pixel window coordinates
                    if (col_cnt < cols - 3) begin
                        col_cnt <= col_cnt + 1;
                        state <= LOAD;
                    end else if (row_cnt < rows - 3) begin
                        col_cnt <= 0;
                        row_cnt <= row_cnt + 1;
                        state <= LOAD;
                    end else begin
                        done <= 1;  //indicates completion of operation
                        state <= IDLE; //Sets back to IDLE state, to repeat the operation
                    end
                end
            endcase
        end
    end
endmodule
