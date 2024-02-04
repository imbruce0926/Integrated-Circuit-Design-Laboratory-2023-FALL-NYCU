module CC(
    //Input Port
    clk,
    rst_n,
	in_valid,
	mode,
    xi,
    yi,

    //Output Port
    out_valid,
	xo,
	yo
    );

input               clk, rst_n, in_valid;
input       [1:0]   mode;
input       [7:0]   xi, yi;  

output reg          out_valid;
output reg signed [7:0]   xo, yo;

//==============================================//
//             Parameter and Integer 0          //
//==============================================//

parameter IDLE_op_0 = 3'd0;
parameter OUT_op_0 = 3'd1;

parameter IDLE_cal_0 = 3'd0;
parameter FIND_cal_0 = 3'd1;

//==============================================//
//            FSM State Declaration 0           //
//==============================================//

reg cs_cal_0, cs_op_0, ns_cal_0, ns_op_0;

//==============================================//
//                 reg declaration 0            //
//==============================================//

reg signed [7:0] input_x[0:3], input_y[0:3];
reg [1:0] input_cnt;
reg [1:0] input_mode;
reg mode0_valid, mode1_valid, mode2_valid;
reg signed [7:0] y; 
reg signed [9:0] x_cnt, y_cnt;
reg signed [7:0] left, right;
reg signed [7:0] left_op, right_op;
reg signed [7:0] left_temp, right_temp;
reg signed [8:0] left_delta_x, right_delta_x, left_delta_y, right_delta_y;

reg signed [6:0] left_delta_x_1, right_delta_x_1, left_delta_y_1, right_delta_y_1; /* 8 */

reg signed [17:0] left_const, right_const; /*17*/

reg signed [11:0] left_const_1; /*17*/

reg signed [18:0] left_up, right_up;
reg left_p_n, right_p_n;
reg left_is_round, right_is_round;

//==============================================//
//             Current State Block 0            //
//==============================================//

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cs_cal_0 <= IDLE_cal_0;
        cs_op_0 <= IDLE_op_0;
    end
    else begin
        cs_cal_0 <= ns_cal_0;
        cs_op_0 <= ns_op_0;
    end
end


//==============================================//
//              Next State Block 0              //
//==============================================//

always @(*) begin: Next_State_Cal
    if(mode0_valid)  begin
        case(cs_cal_0)
            IDLE_cal_0: begin
                if((input_cnt == 3 || xo == right_op-1) && y <= input_y[0]) 
                    ns_cal_0 = FIND_cal_0;
                else if(/* cs_cal_0 == IDLE_cal_0 && */((right_op - left_op) == 1)) 
                    ns_cal_0 = FIND_cal_0;
                else begin
                    ns_cal_0 = IDLE_cal_0;
                end
            end
            FIND_cal_0: 
                ns_cal_0 = IDLE_cal_0;
        endcase
    end
    else
        ns_cal_0 = IDLE_cal_0;
end

always @(*) begin: Next_State_Op
    if(mode0_valid) begin
        case(cs_op_0)
            IDLE_op_0: begin
                case(cs_cal_0)
                    FIND_cal_0: ns_op_0 = OUT_op_0;
                    IDLE_cal_0: ns_op_0 = IDLE_cal_0;
                endcase       
            end
            OUT_op_0: 
                ns_op_0 = OUT_op_0;
        endcase
    end
    else
        ns_op_0 = IDLE_op_0;
end


//==============================================//
//              Calculation Block0              //
//==============================================//


always @(posedge clk or negedge rst_n) begin: Output_Coordinate
    if(!rst_n) begin
        left_op <= 0;
        right_op <= 0;
    end
    else if(mode0_valid) begin
        case(cs_cal_0)
            FIND_cal_0: begin
                left_op <= left;
                right_op <= right;
            end
        endcase
    end
    else if(!out_valid) begin
        left_op <= 0;
        right_op <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin: X_Cnt
    if(!rst_n) 
        x_cnt <= 1;
    else if(!out_valid) /* rst */
        x_cnt <= 1;
    else if(mode0_valid) begin
        if(cs_cal_0 == FIND_cal_0)
            x_cnt <= 1;
        else if(cs_op_0 == OUT_op_0)
            x_cnt <= x_cnt +1;
    end
        
end

always @(*) begin: Y
    y = input_y[2] + y_cnt; 
end

always @(posedge clk or negedge rst_n) begin: Y_CNT
    if(!rst_n)
        y_cnt <= 0;
    else if(!out_valid) /* rst */
        y_cnt <= 0;
    else if(mode0_valid) begin
        if((input_cnt == 3  || xo == right_op-1) && y < input_y[0])
            y_cnt <= y_cnt + 1;
        else if(cs_cal_0 == IDLE_cal_0 && ((right_op - left_op) == 1))
            y_cnt <= y_cnt + 1;
    end
    
end

always @(*) begin: Calculate_Boundary 

    left_up = (left_const + left_delta_x * y);
    right_up = (right_const + right_delta_x * y);

    /* 1 is neg 0 is pos*/
    left_p_n = (left_up[18] ^ left_delta_y[8]); 
    right_p_n = (right_up[18] ^ right_delta_y[8]); 

    left_temp = left_up / left_delta_y;
    right_temp = right_up / right_delta_y;


    left_is_round = (left_delta_y * left_temp == left_up) ? 0 : 1;
    right_is_round = (right_delta_y * right_temp == right_up) ? 0 : 1;

    case({left_p_n, left_is_round})
        2'b11: left = left_temp - 1;
        default: left = left_temp;
    endcase

    case({right_p_n, right_is_round})
        2'b11: right = right_temp - 1;
        default: right = right_temp;
    endcase

end


always @(*) begin /* mode0 */
    left_delta_x = input_x[0] - input_x[2];
    left_delta_y = input_y[0] - input_y[2];
    right_delta_x = input_x[1] - input_x[3];
    right_delta_y = input_y[1] - input_y[3];

    left_const = left_delta_y * input_x[0] - left_delta_x * input_y[0];
    right_const = right_delta_y * input_x[1] - right_delta_x * input_y[1];
end

always @(*) begin /* mode1 */
    left_delta_x_1 = input_x[0] - input_x[1];
    left_delta_y_1 = input_y[0] - input_y[1];
    right_delta_x_1 = input_x[2] - input_x[3];
    right_delta_y_1 = input_y[2] - input_y[3];

    left_const_1 = left_delta_y_1 * input_x[0] - left_delta_x_1 * input_y[0];
end

//==============================================//
//              Calculation Block 1             //
//==============================================//

reg signed [24:0] line, radius; /* at least 24:0 */
reg signed [12:0] line_up;
reg [2:0] relation;


always @(*) begin
    line_up = (left_delta_y_1 * input_x[2] - left_delta_x_1 * input_y[2] - left_const_1);
    line = line_up * line_up;
    radius = ((right_delta_x_1 * right_delta_x_1) + (right_delta_y_1 * right_delta_y_1)) * ((left_delta_x_1 * left_delta_x_1) + (left_delta_y_1 * left_delta_y_1));
    
    if(line > radius)
        relation = 0;
    else if(line < radius)
        relation = 1;
    else
        relation = 2;
end


//==============================================//
//              Calculation Block 2             //
//==============================================//

reg [15:0] area;
reg signed [15:0] delta_0, delta_1, delta_2, delta_3, delta_4, delta_5, delta_6, delta_7;
reg signed [16:0] temp_temp, temp;

always @(*) begin /* not change */
    delta_0 = (input_x[0] * input_y[1]);
    delta_1 = (input_x[1] * input_y[0]);
    delta_2 = (input_x[1] * input_y[2]);
    delta_3 = (input_x[2] * input_y[1]);

    delta_4 = (input_x[2] * input_y[3]);
    delta_5 = (input_x[3] * input_y[2]);
    delta_6 = (input_x[3] * input_y[0]);
    delta_7 = (input_x[0] * input_y[3]);

    temp = (delta_0 - delta_1) + (delta_2 - delta_3) + (delta_4 - delta_5) + (delta_6 - delta_7);

    if(temp < 0)
        temp_temp = -temp;
    else
         temp_temp = temp;

    area = (temp_temp) / 2;

end

//==============================================//
//                Output Block                  //
//==============================================//

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        xo <= 0;
    else begin
        case(input_mode)
            2'd0: begin
                if(!mode0_valid)
                    xo <= 0;
                else if(cs_cal_0 == FIND_cal_0)
                    xo <= left;
                else
                    xo <= left_op + x_cnt;
            end
            2'd1: 
                xo <= 0;
            2'd2: 
                xo <= area[15:8];
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        yo <= 0;
    else begin
        case(input_mode)
            2'd0: begin
                if(!mode0_valid)
                    yo <= 0;
                else if(cs_cal_0 == FIND_cal_0)
                    yo <= y;
                else if(!out_valid) /* rst */
                    yo <= 0;
            end
            2'd1: begin
                if(mode1_valid) begin
                    case(relation)
                        2'd0: yo <= 0;
                        2'd1: yo <= 1;
                        2'd2: yo <= 2;
                    endcase
                end
            end
            2'd2: 
                yo <= area[7:0];
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin: Out_Valid
    if(!rst_n) 
        out_valid <= 0;
    else begin
        case(input_mode)
            2'd0: begin
                if(xo == input_x[1] && yo == input_y[1])
                    out_valid <= 0;
                else if(cs_cal_0 == FIND_cal_0)
                    out_valid <= 1;
            end
            2'd1: begin
                if(mode1_valid) begin
                    if(!out_valid)
                        out_valid <= 1;
                    else
                        out_valid <= 0;
                end
            end
            2'd2: begin
                if(mode2_valid) begin
                    if(!out_valid)
                        out_valid <= 1;
                    else
                        out_valid <= 0;
                end
            end
            default: begin
            end
        endcase
    end


    
end

//==============================================//
//                  Input Block                 //
//==============================================//

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        input_cnt <= 0;
    else if(in_valid) 
        input_cnt <= input_cnt + 1;
    else if(!out_valid) /* rst */
        input_cnt <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        input_x[0] <= 0;
        input_y[0] <= 0;
        input_x[1] <= 0;
        input_y[1] <= 0;
        input_x[2] <= 0;
        input_y[2] <= 0;
        input_x[3] <= 0;
        input_y[3] <= 0;
    end
    else if(in_valid) begin
        input_x[input_cnt] <= xi;
        input_y[input_cnt] <= yi;
    end

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        input_mode <= 0;
    else if(in_valid) 
        input_mode <= mode;
end

//==============================================//
//                  Select Mode                 //
//==============================================//

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mode0_valid <= 0;
    else if(in_valid && input_cnt == 1) begin
        case(input_mode)
            2'd0: mode0_valid <= 1;
            2'd1: mode0_valid <= 0;
            2'd2: mode0_valid <= 0;
        endcase
    end
    else if(xo == input_x[1] && yo == input_y[1])
        mode0_valid <= 0;
end
        
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mode1_valid <= 0;
    else if(in_valid && input_cnt == 3) begin
        case(input_mode)
            2'd0: mode1_valid <= 0;
            2'd1: mode1_valid <= 1;
            2'd2: mode1_valid <= 0;
        endcase
    end
    else if(out_valid)
        mode1_valid <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        mode2_valid <= 0;
    else if(in_valid && input_cnt == 3) begin
        case(input_mode)
            2'd0: mode2_valid <= 0;
            2'd1: mode2_valid <= 0;
            2'd2: mode2_valid <= 1;
        endcase
    end
    else if(out_valid)
        mode2_valid <= 0;
end

endmodule 