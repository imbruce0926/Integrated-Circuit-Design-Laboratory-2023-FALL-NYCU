module CAD (
    //Input Port
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    mode,   
    matrix_size,
    matrix,
    matrix_idx,

    //Output Port
    out_valid,
    out_value
    );

input rst_n, clk, in_valid, in_valid2, mode;
input [3:0] matrix_idx;
input [1:0] matrix_size;
input signed [7:0] matrix;

output reg out_valid, out_value;

reg [14:0] addr_img;
reg [8:0] addr_kernel;
wire [7:0] out_img, out_kernel;
reg web_img, web_kernel, web_write;
reg web_read;
reg [10:0] addr_write, addr_read;
wire [19:0] DO_write, DO_read;
reg [19:0] DI_write;
reg [19:0] DI_read;
reg [10:0] deconv_size_spr;

parameter IDLE          = 4'd0;
parameter INPUT_IMG     = 4'd1;
parameter INPUT_KERNEL  = 4'd2;
parameter WAIT_INPUT2   = 4'd3;
parameter INPUT2_1        = 4'd4;
parameter INPUT2_2        = 4'd5;
parameter INIT            = 4'd6;
parameter CONV          = 4'd7;
parameter DE_CONV       = 4'd8;
integer i, j;

reg [3:0] c_state, n_state;
reg [1:0] matrix_size_reg;
reg [7:0] in_img;



New_Img_SRAM Img0 (.A0(addr_img[0]), .A1(addr_img[1]), .A2(addr_img[2]), .A3(addr_img[3]), .A4(addr_img[4]), .A5(addr_img[5]), .A6(addr_img[6]), .A7(addr_img[7]), .A8(addr_img[8]), .A9(addr_img[9]), .A10(addr_img[10]), .A11(addr_img[11]), .A12(addr_img[12]), .A13(addr_img[13]), .A14(addr_img[14]),
            .DO0(out_img[0]), .DO1(out_img[1]), .DO2(out_img[2]), .DO3(out_img[3]), .DO4(out_img[4]), .DO5(out_img[5]), .DO6(out_img[6]), .DO7(out_img[7]), 
            .DI0(in_img[0]), .DI1(in_img[1]), .DI2(in_img[2]), .DI3(in_img[3]), .DI4(in_img[4]), .DI5(in_img[5]), .DI6(in_img[6]), .DI7(in_img[7]), 
            .CK(clk), .WEB(web_img), .OE(1'b1), .CS(1'b1));

SRAM_Kernel Kernel0 (.A0(addr_kernel[0]), .A1(addr_kernel[1]), .A2(addr_kernel[2]), .A3(addr_kernel[3]), .A4(addr_kernel[4]), .A5(addr_kernel[5]), .A6(addr_kernel[6]), .A7(addr_kernel[7]), .A8(addr_kernel[8]), 
                    .DO0(out_kernel[0]), .DO1(out_kernel[1]), .DO2(out_kernel[2]), .DO3(out_kernel[3]), .DO4(out_kernel[4]), .DO5(out_kernel[5]), .DO6(out_kernel[6]), .DO7(out_kernel[7]), 
                    .DI0(matrix[0]), .DI1(matrix[1]), .DI2(matrix[2]), .DI3(matrix[3]), .DI4(matrix[4]), .DI5(matrix[5]), .DI6(matrix[6]), .DI7(matrix[7]), 
                    .CK(clk), .WEB(web_kernel), .OE(1'b1), .CS(1'b1));

SRAM_Output Output0 (.A0(addr_write[0]),.A1(addr_write[1]),.A2(addr_write[2]),.A3(addr_write[3]),.A4(addr_write[4]),.A5(addr_write[5]),.A6(addr_write[6]),.A7(addr_write[7]),.A8(addr_write[8]),.A9(addr_write[9]),.A10(addr_write[10]),
                .B0(addr_read[0]),.B1(addr_read[1]),.B2(addr_read[2]),.B3(addr_read[3]),.B4(addr_read[4]),.B5(addr_read[5]),.B6(addr_read[6]),.B7(addr_read[7]),.B8(addr_read[8]),.B9(addr_read[9]),.B10(addr_read[10]),
                .DOA0(DO_write[0]),.DOA1(DO_write[1]),.DOA2(DO_write[2]),.DOA3(DO_write[3]),.DOA4(DO_write[4]),.DOA5(DO_write[5]),.DOA6(DO_write[6]),.DOA7(DO_write[7]),.DOA8(DO_write[8]),.DOA9(DO_write[9]),.DOA10(DO_write[10]),.DOA11(DO_write[11]),.DOA12(DO_write[12]),.DOA13(DO_write[13]),.DOA14(DO_write[14]),.DOA15(DO_write[15]),.DOA16(DO_write[16]),.DOA17(DO_write[17]),.DOA18(DO_write[18]),.DOA19(DO_write[19]),
                .DOB0(DO_read[0]),.DOB1(DO_read[1]),.DOB2(DO_read[2]),.DOB3(DO_read[3]),.DOB4(DO_read[4]),.DOB5(DO_read[5]),.DOB6(DO_read[6]),.DOB7(DO_read[7]),.DOB8(DO_read[8]),.DOB9(DO_read[9]),.DOB10(DO_read[10]),.DOB11(DO_read[11]),.DOB12(DO_read[12]),.DOB13(DO_read[13]),.DOB14(DO_read[14]),.DOB15(DO_read[15]),.DOB16(DO_read[16]),.DOB17(DO_read[17]),.DOB18(DO_read[18]),.DOB19(DO_read[19]),
                .DIA0(DI_write[0]),.DIA1(DI_write[1]),.DIA2(DI_write[2]),.DIA3(DI_write[3]),.DIA4(DI_write[4]),.DIA5(DI_write[5]),.DIA6(DI_write[6]),.DIA7(DI_write[7]),.DIA8(DI_write[8]),.DIA9(DI_write[9]),.DIA10(DI_write[10]),.DIA11(DI_write[11]),.DIA12(DI_write[12]),.DIA13(DI_write[13]),.DIA14(DI_write[14]),.DIA15(DI_write[15]),.DIA16(DI_write[16]),.DIA17(DI_write[17]),.DIA18(DI_write[18]),.DIA19(DI_write[19]),
                .DIB0(DI_read[0]),.DIB1(DI_read[1]),.DIB2(DI_read[2]),.DIB3(DI_read[3]),.DIB4(DI_read[4]),.DIB5(DI_read[5]),.DIB6(DI_read[6]),.DIB7(DI_read[7]),.DIB8(DI_read[8]),.DIB9(DI_read[9]),.DIB10(DI_read[10]),.DIB11(DI_read[11]),.DIB12(DI_read[12]),.DIB13(DI_read[13]),.DIB14(DI_read[14]),.DIB15(DI_read[15]),.DIB16(DI_read[16]),.DIB17(DI_read[17]),.DIB18(DI_read[18]),.DIB19(DI_read[19]),
                .WEAN(web_write),.WEBN(web_read),.CKA(clk),.CKB(clk),.CSA(1'b1),.OEA(1'b1),.CSB(1'b1),.OEB(1'b1));


reg [13:0] input_cnt;
reg [4:0] row_cnt, col_cnt_d, row_cnt_d;
reg [5:0] col_cnt, down_cnt;
reg [3:0] img_cnt;
reg [5:0] size;
reg [8:0] kernel_cnt, kernel_cnt_d;
reg mode_reg;
reg [3:0] img_idx, kernel_idx;
reg signed [7:0] conv_reg [0:4][0:4], temp_conv_reg [0:3][0:4];
reg signed [7:0] temp_reg [0:4];
reg signed [7:0] kernel_reg [0:24];
reg [2:0] k_col_cnt, k_row_cnt;
reg signed [7:0] a_mult [0:4], b_mult [0:4];
reg signed [19:0] mult_5_add;
reg signed [19:0] conv_result;
reg [3:0] pooling_cnt;
reg do_cmp, do_pool;
reg signed [19:0] pooling_reg [0:13];
reg [7:0] out_CONV_cnt, out_addr_cnt_CONV;
reg [3:0] store_cnt;
reg [3:0] pooling_size;
reg [7:0] pooling_size_sqr;
reg [4:0] cnt_20;
reg [19:0] output_reg;
reg [10:0] out_DE_cnt;

// reg [4:0] cnt_20;
reg [10:0] out_addr_cnt_DE;

reg [3:0] cnt_16;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_16 <= 0;
    else begin
        if(n_state == INPUT2_1)
            cnt_16 <= cnt_16 + 1;
    end
end


///////////////////////////////////////////////////////////
//                        OUTPUT                         //
///////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        output_reg <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2)
            output_reg <= 0;
        else if(n_state == CONV) begin
            if(cnt_20 == 2)
                output_reg <= DO_read >> 1;
            else
                output_reg <= output_reg >> 1;
        end
        else if(n_state == DE_CONV) begin
            if(cnt_20 == 2 && out_addr_cnt_DE < deconv_size_spr+1) /* because output continue at cycle 400, +1*/ 
                output_reg <= DO_read >> 1;
            else
                output_reg <= output_reg >> 1;
        end
    end

end



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out_value <= 0;
    end
    else begin
        if(n_state == CONV || c_state == CONV) begin
            if((out_addr_cnt_CONV == pooling_size_sqr + 1 && cnt_20 == 2)) 
                out_valid <= 0;
            else if((out_addr_cnt_CONV == 1 && cnt_20 == 2)) 
                out_valid <= 1;

            if((out_addr_cnt_CONV == pooling_size_sqr + 1 && cnt_20 == 2)) 
                out_value <= 0;
            else if(cnt_20 == 2)
                out_value <= DO_read[0];
            else
                out_value <= output_reg[0];

        end
        else if(n_state == DE_CONV || c_state == DE_CONV) begin
            
            if((out_addr_cnt_DE == deconv_size_spr + 1 && cnt_20 == 2)) 
                out_valid <= 0;
            else if((out_addr_cnt_DE == 1 && cnt_20 == 2)) 
                out_valid <= 1;
                

            if((out_addr_cnt_DE == deconv_size_spr + 1 && cnt_20 == 2)) 
                out_value <= 0;
            else if(cnt_20 == 2 && out_addr_cnt_DE < deconv_size_spr+1)
                out_value <= DO_read[0];
            else
                out_value <= output_reg[0];
        end

    end

end

///////////////////////////////////////////////////////////
//                     OUTPUT OF CONV                    //
///////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_addr_cnt_CONV <= 0;
    else begin
        if(n_state == IDLE || n_state == INPUT2_1)
            out_addr_cnt_CONV <= 0;
        else if(n_state == CONV) begin
            if(cnt_20 == 1)
                out_addr_cnt_CONV <= out_addr_cnt_CONV +1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_20 <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2 || c_state == INPUT2_1)
            cnt_20 <= 0;
        else if(n_state == CONV) begin
            if(cnt_20 == 19)
                cnt_20 <= 0;
            else if(out_CONV_cnt >= 1)
                cnt_20 <= cnt_20 +1;
        end
        else if(n_state == DE_CONV) begin
            if(cnt_20 == 19)
                cnt_20 <= 0;
            else if(out_DE_cnt >= 1)
                cnt_20 <= cnt_20 + 1;
        end
    end
end

///////////////////////////////////////////////////////////
//                    OUTPUT OF DECONV                   //
///////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_addr_cnt_DE <= 0;
    else begin
        if(n_state == IDLE || n_state == INPUT2_1 || c_state == INPUT2_1)
            out_addr_cnt_DE <= 0;
        else if(n_state == DE_CONV) begin
            if(cnt_20 == 1)
                out_addr_cnt_DE <= out_addr_cnt_DE + 1;
        end
    end
end


///////////////////////////////////////////////////////////
//               OUTPUT SRAM CTRL SIGNAL                 //
///////////////////////////////////////////////////////////


always @(*) begin
    addr_read = 0;
    web_read = 1;
    DI_read = 0;
    if(n_state == CONV) begin
        if(cnt_20 == 1)
            addr_read = out_addr_cnt_CONV;
        else if(web_write == 0 && addr_write == 0) /* avoid read write same addr */
            addr_read = 1;
    end
    else if(n_state == DE_CONV) begin
        if(cnt_20 == 1 && out_addr_cnt_DE < deconv_size_spr)
            addr_read = out_addr_cnt_DE;
        else if(web_write == 0 && addr_write == 0) /* avoid read write same addr */
            addr_read = 1;
    end
end



always @(*) begin
    addr_write = 0;
    web_write = 1; //!!!!!!!!!!!!!!
    DI_write = 0;
    if(n_state == CONV) begin
        // if(store_cnt >= 0 && store_cnt < pooling_size && !(down_cnt == 0) && down_cnt[0] == 0 && (col_cnt == 6 || col_cnt == 7 || (col_cnt == 5 && row_cnt >= 3) || (col_cnt == 8 && row_cnt <= 1))) begin
        //     web_write = 0;
        //     addr_write = out_CONV_cnt;
        //     DI_write = pooling_reg[out_CONV_cnt % pooling_size];
        // end
        if( (row_cnt == 3) && (col_cnt >= 7) && (col_cnt <= size) && (col_cnt[0] == 1) && (down_cnt >= 1) && (down_cnt <= size - 4) && (down_cnt[0] == 1) || ((row_cnt == 3) && (col_cnt == 5) && (down_cnt >= 2) && (down_cnt <= size - 3) && (down_cnt[0] == 0)) ) begin
            web_write = 0;
            addr_write = out_CONV_cnt;
            DI_write = pooling_reg[out_CONV_cnt % pooling_size];
        end

    end
    else if(n_state == DE_CONV) begin
        
        DI_write = conv_result;
        if(!(col_cnt == 5 && row_cnt == 2 && down_cnt == 0) && row_cnt == 2 && out_DE_cnt < deconv_size_spr) begin
            web_write = 0;
            addr_write = out_DE_cnt;
        end
    end
        
end




always @(*) begin
    if(n_state == WAIT_INPUT2 || c_state == WAIT_INPUT2)
        in_img = 0;
    else if(n_state == INPUT_IMG || c_state == INPUT_IMG)
        in_img = matrix;
    else
        in_img = 0;
end

always @(*) begin
    case(matrix_size_reg)
        0: deconv_size_spr = 144;
        1: deconv_size_spr = 400;
        2: deconv_size_spr = 1296;
        default: deconv_size_spr = 0;
    endcase
end



///////////////////////////////////////////////////////////
//                       POOLING                         //
///////////////////////////////////////////////////////////

always @(*) begin
    case(matrix_size_reg)
        0: pooling_size = 2;
        1: pooling_size = 6;
        2: pooling_size = 14;
        default: pooling_size = 0;
    endcase
end

always @(*) begin
    case(matrix_size_reg)
        0: pooling_size_sqr = 4;
        1: pooling_size_sqr = 36;
        2: pooling_size_sqr = 196;
        default: pooling_size_sqr = 0;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) store_cnt <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2)
            store_cnt <= 0;
        else if(n_state == CONV) begin
            if(col_cnt == 5 && row_cnt == 2)
                store_cnt <= 0;
            else 
                store_cnt <= store_cnt + 1;
        end
    end
end



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) out_CONV_cnt <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2)
            out_CONV_cnt <= 0;
        else if(n_state == CONV) begin
            // if(store_cnt >= 0 && store_cnt < pooling_size && !(down_cnt == 0) && down_cnt[0] == 0 && (col_cnt == 6 || col_cnt == 7 || (col_cnt == 5 && row_cnt >= 3) || (col_cnt == 8 && row_cnt <= 1)))
            //     out_CONV_cnt <= out_CONV_cnt + 1;
            if( (row_cnt == 3) && (col_cnt >= 7) && (col_cnt <= size) && (col_cnt[0] == 1) && (down_cnt >= 1) && (down_cnt <= size - 4) && (down_cnt[0] == 1) || ((row_cnt == 3) && (col_cnt == 5) && (down_cnt >= 2) && (down_cnt <= size - 3) && (down_cnt[0] == 0)) )
                out_CONV_cnt <= out_CONV_cnt + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) do_pool <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2)
            do_pool <= 0;
        else if(n_state == CONV) begin
            if(col_cnt == 5 && row_cnt == 2 && down_cnt >= 1 && down_cnt <= size-1)
                do_pool <= do_pool + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 14; i = i + 1)
            pooling_reg[i] <= 0;
    end
    else begin
        if(n_state == CONV) begin
            if(!(col_cnt == 5 && row_cnt == 2 && down_cnt == 0) && row_cnt == 2) begin
                if(do_pool == 0) begin
                    if(do_cmp == 0)
                        pooling_reg[pooling_cnt] <= conv_result;
                    else begin
                        if(conv_result > pooling_reg[pooling_cnt])
                            pooling_reg[pooling_cnt] <= conv_result;
                    end
                end
                else begin
                    if(conv_result > pooling_reg[pooling_cnt])
                        pooling_reg[pooling_cnt] <= conv_result;
                end
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_DE_cnt <= 0;
    else if(n_state == INPUT2_1)
        out_DE_cnt <= 0;
    else if(n_state == DE_CONV) begin
        if(!(col_cnt == 5 && row_cnt == 2 && down_cnt == 0) && row_cnt == 2 && out_DE_cnt < deconv_size_spr)
            out_DE_cnt <= out_DE_cnt + 1;  /* CONV maybe need revised */
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) pooling_cnt <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2)
            pooling_cnt <= 0;
        else if(n_state == CONV) begin
            if(pooling_cnt == pooling_size-1 && do_cmp == 1 && (col_cnt == 5 && row_cnt == 2))
                pooling_cnt <= 0;
            else if((row_cnt == 2 && down_cnt <= size-1 && do_cmp == 1) && !(col_cnt == 5 && row_cnt == 2 && down_cnt == 0))
                pooling_cnt <= pooling_cnt + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) do_cmp <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2)
            do_cmp <= 0;
        else if(n_state == CONV) begin
            if((row_cnt == 2 && down_cnt <= size-1) && !(col_cnt == 5 && row_cnt == 2 && down_cnt == 0))
                do_cmp <= do_cmp + 1;
        end
    end
end




///////////////////////////////////////////////////////////
//                       HARDWARE                        //
///////////////////////////////////////////////////////////

always @(*) begin
    mult_5_add = a_mult[0] * b_mult[0] + a_mult[1] * b_mult[1] + a_mult[2] * b_mult[2] + a_mult[3] * b_mult[3] + a_mult[4] * b_mult[4];
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        conv_result <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2)
            conv_result <= 0;
        else if(n_state == CONV || n_state == DE_CONV) begin                // !!!!!!!!!!!!!!!!
            if(row_cnt == 2)
                conv_result <= mult_5_add;
            else
                conv_result <= conv_result + mult_5_add;
        end
    end
end

always @(*) begin
    case(row_cnt)
        0: begin
            a_mult[0] = conv_reg[3][0];
            a_mult[1] = conv_reg[3][1];
            a_mult[2] = conv_reg[3][2];
            a_mult[3] = conv_reg[3][3];
            a_mult[4] = conv_reg[3][4];
        end
        1: begin
            a_mult[0] = conv_reg[4][0];
            a_mult[1] = conv_reg[4][1];
            a_mult[2] = conv_reg[4][2];
            a_mult[3] = conv_reg[4][3];
            a_mult[4] = conv_reg[4][4];
        end
        2: begin
            a_mult[0] = conv_reg[0][0];
            a_mult[1] = conv_reg[0][1];
            a_mult[2] = conv_reg[0][2];
            a_mult[3] = conv_reg[0][3];
            a_mult[4] = conv_reg[0][4];
        end
        3: begin
            a_mult[0] = conv_reg[1][0];
            a_mult[1] = conv_reg[1][1];
            a_mult[2] = conv_reg[1][2];
            a_mult[3] = conv_reg[1][3];
            a_mult[4] = conv_reg[1][4];
        end
        4: begin
            a_mult[0] = conv_reg[2][0];
            a_mult[1] = conv_reg[2][1];
            a_mult[2] = conv_reg[2][2];
            a_mult[3] = conv_reg[2][3];
            a_mult[4] = conv_reg[2][4];
        end
        default : begin
            a_mult[0] = 0;
            a_mult[1] = 0;
            a_mult[2] = 0;
            a_mult[3] = 0;
            a_mult[4] = 0;
        end
    endcase

    case(row_cnt)
        0: begin
            b_mult[0] = kernel_reg[15];
            b_mult[1] = kernel_reg[16];
            b_mult[2] = kernel_reg[17];
            b_mult[3] = kernel_reg[18];
            b_mult[4] = kernel_reg[19];
        end
        1: begin
            b_mult[0] = kernel_reg[20];
            b_mult[1] = kernel_reg[21];
            b_mult[2] = kernel_reg[22];
            b_mult[3] = kernel_reg[23];
            b_mult[4] = kernel_reg[24];
        end
        2: begin
            b_mult[0] = kernel_reg[0];
            b_mult[1] = kernel_reg[1];
            b_mult[2] = kernel_reg[2];
            b_mult[3] = kernel_reg[3];
            b_mult[4] = kernel_reg[4];
        end
        3: begin
            b_mult[0] = kernel_reg[5];
            b_mult[1] = kernel_reg[6];
            b_mult[2] = kernel_reg[7];
            b_mult[3] = kernel_reg[8];
            b_mult[4] = kernel_reg[9];        
        end
        4: begin
            b_mult[0] = kernel_reg[10];
            b_mult[1] = kernel_reg[11];
            b_mult[2] = kernel_reg[12];
            b_mult[3] = kernel_reg[13];
            b_mult[4] = kernel_reg[14];
        end
        default : begin
            b_mult[0] = 0;
            b_mult[1] = 0;
            b_mult[2] = 0;
            b_mult[3] = 0;
            b_mult[4] = 0;
        end
    endcase

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 5; i = i + 1) begin
            for(j = 0; j < 4; j = j + 1) begin
                temp_conv_reg[j][i] <= 0 ;
            end
        end
    end
    else begin
        if(c_state == CONV || c_state == DE_CONV) begin                                    // !!!!!!!!!!!!!!!!!!
            if(col_cnt == 5 && row_cnt == 2) begin
                for(i = 0; i < 5; i = i + 1) begin
                    for(j = 1; j < 5; j = j + 1) 
                        temp_conv_reg[j-1][i] <= conv_reg[j][i];
                end
            end
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 5; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1) begin
                conv_reg[i][j] <= 0 ;
            end
        end
    end
    else begin
        if((n_state == INIT || c_state == INIT) && mode_reg == 0) begin
            conv_reg[row_cnt_d][col_cnt_d] <= out_img;
        end
        else if((n_state == INIT || c_state == INIT) && mode_reg == 1) begin
            for(i = 0; i < 4; i = i + 1) begin
                for(j = 0; j < 5; j = j + 1) begin
                    conv_reg[i][j] <= 0;
                end
            end
            conv_reg[4][0] <= 0;
            conv_reg[4][1] <= 0;
            conv_reg[4][2] <= 0;
            conv_reg[4][3] <= 0;
            if(row_cnt_d == 0 && col_cnt_d == 0)
                conv_reg[4][4] <= out_img;
        end
        else if(c_state == CONV || c_state == DE_CONV) begin                        // !!!!!!!!!!!!!!!!!
            if(col_cnt == 5 && row_cnt == 1 && down_cnt != 0) begin
                for(i = 0; i < 5; i = i + 1) begin
                    for(j = 0; j < 4; j = j + 1) begin
                        conv_reg[j][i] <= temp_conv_reg[j][i];
                    end
                end
                for(i = 0; i < 5; i = i + 1) begin
                    conv_reg[4][i] <= temp_reg[i];
                end
            end
            else if(!(row_cnt == 1 && col_cnt == 5 && down_cnt == 0)) begin
                case(row_cnt)
                    0: begin
                        for(i = 1; i < 5; i = i + 1) 
                            conv_reg[3][i-1] <= conv_reg[3][i];

                        conv_reg[3][4] <= temp_reg[3];
                    end
                    1: begin
                        for(i = 1; i < 5; i = i + 1) 
                            conv_reg[4][i-1] <= conv_reg[4][i];
                        conv_reg[4][4] <= temp_reg[4];
                    end
                    2: begin
                        for(i = 1; i < 5; i = i + 1) 
                            conv_reg[0][i-1] <= conv_reg[0][i];

                        conv_reg[0][4] <= temp_reg[0];
                    end
                    3: begin
                        for(i = 1; i < 5; i = i + 1) 
                            conv_reg[1][i-1] <= conv_reg[1][i];

                        conv_reg[1][4] <= temp_reg[1];
                    end
                    4: begin
                        for(i = 1; i < 5; i = i + 1) 
                            conv_reg[2][i-1] <= conv_reg[2][i];

                        conv_reg[2][4] <= temp_reg[2];
                    end
                endcase
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        temp_reg[0] <= 0;
        temp_reg[1] <= 0;
        temp_reg[2] <= 0;
        temp_reg[3] <= 0;
        temp_reg[4] <= 0;
    end
    else begin
        if(n_state == CONV) begin
            case(row_cnt)
                0: temp_reg[4] <= out_img ;
                1: temp_reg[0] <= out_img ;
                2: temp_reg[1] <= out_img ;
                3: temp_reg[2] <= out_img ;
                4: temp_reg[3] <= out_img ;
            endcase
        end
        else if(n_state == INPUT2_1) begin
            temp_reg[0] <= 0;
            temp_reg[1] <= 0;
            temp_reg[2] <= 0;
            temp_reg[3] <= 0;
            temp_reg[4] <= 0;
        end
        else if(n_state == DE_CONV) begin
            if(!(col_cnt == 5 && (/*row_cnt == 2 || */ row_cnt == 1 || row_cnt == 0) && down_cnt == 0)) begin
                case(row_cnt)
                    0: temp_reg[4] <= out_img ;
                    1: temp_reg[0] <= out_img ;
                    2: temp_reg[1] <= out_img ;
                    3: temp_reg[2] <= out_img ;
                    4: temp_reg[3] <= out_img ;
                endcase
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 25; i = i + 1) begin
            kernel_reg[i] <= 0;
        end
    end
    else begin
        if((n_state == INIT || c_state == INIT) && mode_reg == 0) begin
            if(kernel_cnt_d < 25)
                kernel_reg[kernel_cnt_d] <= out_kernel;
        end
        else if((n_state == INIT || c_state == INIT) && mode_reg == 1) begin
            if(kernel_cnt_d < 25)
                kernel_reg[24 - kernel_cnt_d] <= out_kernel;
        end
        
    end
end



///////////////////////////////////////////////////////////
//                         INPUT                         //
///////////////////////////////////////////////////////////



always @(*) begin /* can be merged img_cnt <= img_idx */
    addr_img = 0;
    if(n_state == WAIT_INPUT2/* || c_state == IDLE*/)
        addr_img = 16384;
    else if(n_state == INPUT_IMG || c_state == INPUT_IMG) begin
        case(matrix_size_reg)
            2'd0: addr_img = {img_cnt, row_cnt[2:0], col_cnt[2:0]};
            2'd1: addr_img = {img_cnt, row_cnt[3:0], col_cnt[3:0]};
            2'd2: addr_img = {img_cnt, row_cnt[4:0], col_cnt[4:0]};
        endcase
    end
    else if((n_state == INIT || c_state == INIT)) begin
        case(matrix_size_reg)
            2'd0: addr_img = {img_idx, row_cnt[2:0], col_cnt[2:0]};
            2'd1: addr_img = {img_idx, row_cnt[3:0], col_cnt[3:0]};
            2'd2: addr_img = {img_idx, row_cnt[4:0], col_cnt[4:0]};
        endcase
    end
    else if((n_state == CONV || c_state == CONV)) begin
        case(matrix_size_reg)
            2'd0: addr_img = (col_cnt == 4) ? {img_idx, down_cnt[2:0] + col_cnt[2:0], row_cnt[2:0]} : {img_idx, down_cnt[2:0] + row_cnt[2:0], col_cnt[2:0]};
            2'd1: addr_img = (col_cnt == 4) ? {img_idx, down_cnt[3:0] + col_cnt[3:0], row_cnt[3:0]} : {img_idx, down_cnt[3:0] + row_cnt[3:0], col_cnt[3:0]};
            2'd2: addr_img = (col_cnt == 4) ? {img_idx, down_cnt[4:0] + col_cnt[4:0], row_cnt[4:0]} : {img_idx, down_cnt[4:0] + row_cnt[4:0], col_cnt[4:0]};
        endcase
    end
    else if((n_state == DE_CONV || c_state == DE_CONV)) begin

        if(col_cnt == 4) begin /* get horizontal line */
            if(row_cnt < 4 || down_cnt + col_cnt < 4 || row_cnt > size + 4 || down_cnt + col_cnt > size + 4) begin
                addr_img = 16384;
            end
            else begin
                case(matrix_size_reg)
                    2'd0: addr_img = {img_idx, down_cnt[2:0] + col_cnt[2:0] - 3'd4, row_cnt[2:0] - 3'd4};
                    2'd1: addr_img = {img_idx, down_cnt[3:0] + col_cnt[3:0] - 3'd4, row_cnt[3:0] - 3'd4};
                    2'd2: addr_img = {img_idx, down_cnt[4:0] + col_cnt[4:0] - 3'd4, row_cnt[4:0] - 3'd4};
                endcase
            end
        end
        else begin
            if(down_cnt + row_cnt < 4 || col_cnt < 4 || down_cnt + row_cnt > size + 4 || col_cnt > size + 4) begin
                addr_img = 16384;
            end
            else begin
                case(matrix_size_reg)
                    2'd0: addr_img = {img_idx, down_cnt[2:0] + row_cnt[2:0] - 3'd4, col_cnt[2:0] - 3'd4};
                    2'd1: addr_img = {img_idx, down_cnt[3:0] + row_cnt[3:0] - 3'd4, col_cnt[3:0] - 3'd4};
                    2'd2: addr_img = {img_idx, down_cnt[4:0] + row_cnt[4:0] - 3'd4, col_cnt[4:0] - 3'd4};
                endcase
            end
        end

    end
end



always @(*) begin
    addr_kernel = 0;
    
    if(c_state == INPUT_KERNEL) begin
        addr_kernel = kernel_cnt;
    end
    else if(n_state == INIT) begin
        addr_kernel = kernel_idx * 25 + kernel_cnt;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) kernel_cnt <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2)
            kernel_cnt <= 0;
        else if(c_state == INPUT_KERNEL) begin
            if(kernel_cnt == 399)
                kernel_cnt <= 0;
            else
                kernel_cnt <= kernel_cnt +1;
        end
        else if(n_state == INIT || c_state == INIT) begin
            if(kernel_cnt == 25)
                kernel_cnt <= 0;
            else
                kernel_cnt <= kernel_cnt + 1;
        end

    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        down_cnt <= 0;
    else begin
        if(n_state == IDLE || n_state == INPUT2_1)
            down_cnt <= 0;
        else if(n_state == CONV) begin
            if(row_cnt == 4 && col_cnt == size)
                down_cnt <= down_cnt + 1;
        end
        else if(n_state == DE_CONV) begin
            if(row_cnt == 4 && col_cnt == size + 8)
                down_cnt <= down_cnt + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        col_cnt <= 0;
    else begin
        if(n_state == IDLE || n_state == INPUT2_1) 
            col_cnt <= 0;
        else if(n_state == INPUT_IMG || c_state == INPUT_IMG)  begin
            if(col_cnt == size) 
                col_cnt <= 0;
            else 
                col_cnt <= col_cnt + 1;
        end
        else if(n_state == INIT /*|| c_state == INIT*/) begin
            if(row_cnt == 4) 
                col_cnt <= col_cnt + 1;
        end
        else if(n_state == CONV /*|| c_state == INIT*/) begin
            if(col_cnt == size && row_cnt == 4) 
                col_cnt <= 4;
            else if(row_cnt == 4) 
                col_cnt <= col_cnt + 1;
        end
        else if(n_state == DE_CONV /*|| c_state == INIT*/) begin
            if(col_cnt == size + 8 && row_cnt == 4) 
                col_cnt <= 4;
            else if(row_cnt == 4) 
                col_cnt <= col_cnt + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        row_cnt <= 0;
    else begin
        if(n_state == IDLE || n_state == INPUT2_1) 
            row_cnt <= 0;
        else if(n_state == INPUT_IMG || c_state == INPUT_IMG) begin
            if(col_cnt == size && row_cnt == size) 
                row_cnt <= 0;
            else if(col_cnt == size) 
                row_cnt <= row_cnt + 1;
        end
        else if(n_state == INIT /*|| c_state == INIT*/) begin
            if(row_cnt == 4) 
                row_cnt <= 0;
            else
                row_cnt <= row_cnt + 1;
        end
        else if(n_state == CONV /*|| c_state == INIT*/) begin
            if(row_cnt == 4) 
                row_cnt <= 0;
            else
                row_cnt <= row_cnt + 1;
        end
        else if(n_state == DE_CONV /*|| c_state == INIT*/) begin
            if(row_cnt == 4) 
                row_cnt <= 0;
            else
                row_cnt <= row_cnt + 1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        img_cnt <= 0;
    else begin
        if(n_state == IDLE || n_state == WAIT_INPUT2) 
            img_cnt <= 0;
        else if(n_state == INPUT_IMG || c_state == INPUT_IMG) begin
            if(col_cnt == size && row_cnt == size && img_cnt == 15) 
                img_cnt <= 0;
            else if(col_cnt == size && row_cnt == size) 
                img_cnt <= img_cnt + 1;
        end
    end
end

always @(*) begin
    if(n_state == INPUT_IMG || c_state == INPUT_IMG || n_state == WAIT_INPUT2/* || c_state == WAIT_INPUT2*/) 
        web_img = 0;
    else 
        web_img = 1;
end

always @(*) begin
    if(c_state == INPUT_KERNEL) 
        web_kernel = 0;
    else
        web_kernel = 1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mode_reg <= 0;
    else if(n_state == INPUT2_1)
        mode_reg <= mode;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        img_idx <= 0;
    else if(n_state == INPUT2_1)
        img_idx <= matrix_idx;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        kernel_idx <= 0;
    else if(n_state == INPUT2_2)
        kernel_idx <= matrix_idx;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) matrix_size_reg <= 0;
    else if(in_valid) begin
        if(n_state == INPUT_IMG && col_cnt == 0 && row_cnt == 0 && img_cnt == 0) 
            matrix_size_reg <= matrix_size;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        col_cnt_d <= 0;
        row_cnt_d <= 0;
        kernel_cnt_d <= 0;
    end
    else begin
        col_cnt_d <= col_cnt;
        row_cnt_d <= row_cnt;
        kernel_cnt_d <= kernel_cnt;
    end
end

always @(*) begin
    case(matrix_size_reg)
        2'd0: size = 7;
        2'd1: size = 15;
        2'd2: size = 31;
        default: size = 0;
    endcase
end

///////////////////////////////////////////////////////////
//                         STATE                         //
///////////////////////////////////////////////////////////

always @(*) begin
    n_state = c_state;
    case(c_state)
        IDLE: begin
            if(in_valid) n_state = INPUT_IMG;
            else n_state = c_state;
        end
        INPUT_IMG: begin
            if(col_cnt == size && row_cnt == size && img_cnt == 15)
                n_state = INPUT_KERNEL;
            else
                n_state = c_state;
        end   
        INPUT_KERNEL: begin
            if(kernel_cnt == 399)
                n_state = WAIT_INPUT2;
            else
                n_state = c_state;
        end  
        WAIT_INPUT2: begin
            if(in_valid2)
                n_state = INPUT2_1;
            else
                n_state = c_state;
        end
        INPUT2_1: 
            n_state = INPUT2_2;
        INPUT2_2: 
            n_state = INIT;
        INIT: begin
            if(kernel_cnt == 25) begin
                case(mode_reg)
                    1'b0: n_state = CONV;
                    1'b1: n_state = DE_CONV;
                endcase
            end
        end
        CONV: begin
            if(out_addr_cnt_CONV == pooling_size_sqr + 1 && cnt_20 == 2 && cnt_16 != 0)
                n_state = WAIT_INPUT2;
            else if(out_addr_cnt_CONV == pooling_size_sqr + 1 && cnt_20 == 2 && cnt_16 == 0)
                n_state = IDLE;
            else
                n_state = c_state;
        end
        DE_CONV: begin
            if((out_addr_cnt_DE == (size+5)*(size+5) + 1 && cnt_20 == 2) && cnt_16 != 0)
                n_state = WAIT_INPUT2;
            else if((out_addr_cnt_DE == (size+5)*(size+5) + 1 && cnt_20 == 2) && cnt_16 == 0)
                n_state = IDLE;
            else
                n_state = c_state;   
        end
        default: n_state = c_state;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) c_state <= IDLE;
    else c_state <= n_state;
end

endmodule

