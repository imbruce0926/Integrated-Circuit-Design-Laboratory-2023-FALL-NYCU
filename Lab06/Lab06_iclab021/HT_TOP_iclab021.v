//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : HT_TOP.v
//   	Module Name : HT_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

// synopsys translate_off
`include "SORT_IP.v"
// synopsys translate_on


module HT_TOP(
    // Input signals
    clk,
	rst_n,
	in_valid,
    in_weight, 
	out_mode,
    // Output signals
    out_valid, 
	out_code
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid, out_mode;
input [2:0] in_weight;

output reg out_valid, out_code;

// ===============================================================
// Parameter
// ===============================================================

parameter IDLE = 0;
parameter INPUT = 1;
parameter CAL = 2;
parameter DELAY = 3;
parameter A = 4;
parameter B = 5;
parameter C = 6;
parameter E = 7;
parameter I = 8;
parameter L = 9;
parameter O = 10;
parameter V = 11;

// ===============================================================
// Reg & Wire Declaration
// ===============================================================

reg [31:0] IN_character, OUT_character, sort_result;
reg [39:0] IN_weight;

reg [3:0] c_state, n_state;
reg [3:0] input_cnt;
reg mode_reg;

reg [4:0] weight_reg [15:0];
reg children [1:6] [7:14]; // !! HERE
reg [2:0] length [7:14]; 
reg [6:0] code [7:14];
reg [2:0] cnt_7;

reg [2:0] out_cnt;

wire [3:0] bigger, smaller;

integer i, j;
// ===============================================================
// Design
// ===============================================================

SORT_IP #(8) S0 (.IN_character(IN_character), .IN_weight(IN_weight), .OUT_character(OUT_character));

assign bigger = OUT_character[7:4];
assign smaller = OUT_character[3:0];


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 7; i <= 14; i = i + 1) begin
            length[i] <= 0;
        end
    end
    else if(c_state == IDLE) begin
        for(i = 7; i <= 14; i = i + 1) begin
            length[i] <= 0;
        end
    end
    else if(n_state == CAL || c_state == CAL) begin
        if((bigger >= 7 && bigger <= 14) && (smaller >= 7 && smaller <= 14)) begin
            length[bigger] <= length[bigger] + 1;
            length[smaller] <= length[smaller] + 1;
        end
        else if((bigger >= 7 && bigger <= 14) && !(smaller >= 7 && smaller <= 14)) begin
            
            if(bigger != 7)
                length[7] <= (children[smaller][7] == 1) ? length[7] + 1 : length[7] ;
            else
                length[7] <= length[7] + 1;

            if(bigger != 8)
                length[8] <= (children[smaller][8] == 1) ? length[8] + 1 : length[8] ;
            else
                length[8] <= length[8] + 1;

            if(bigger != 9)
                length[9] <= (children[smaller][9] == 1) ? length[9] + 1 : length[9] ;
            else
                length[9] <= length[9] + 1;

            if(bigger != 10)
                length[10] <= (children[smaller][10] == 1) ? length[10] + 1 : length[10] ;
            else
                length[10] <= length[10] + 1;

            if(bigger != 11)
                length[11] <= (children[smaller][11] == 1) ? length[11] + 1 : length[11] ;
            else
                length[11] <= length[11] + 1;

            if(bigger != 12)
                length[12] <= (children[smaller][12] == 1) ? length[12] + 1 : length[12] ;
            else
                length[12] <= length[12] + 1;

            if(bigger != 13)
                length[13] <= (children[smaller][13] == 1) ? length[13] + 1 : length[13] ;
            else
                length[13] <= length[13] + 1;

            if(bigger != 14)
                length[14] <= (children[smaller][14] == 1) ? length[14] + 1 : length[14] ;
            else
                length[14] <= length[14] + 1;

        end
        else if(!(bigger >= 7 && bigger <= 14) && (smaller >= 7 && smaller <= 14)) begin

            if(smaller != 7)
                length[7] <= (children[bigger][7] == 1) ? length[7] + 1 : length[7] ;
            else
                length[7] <= length[7] + 1;

            if(smaller != 8)
                length[8] <= (children[bigger][8] == 1) ? length[8] + 1 : length[8] ;
            else
                length[8] <= length[8] + 1;

            if(smaller != 9)
                length[9] <= (children[bigger][9] == 1) ? length[9] + 1 : length[9] ;
            else
                length[9] <= length[9] + 1;

            if(smaller != 10)
                length[10] <= (children[bigger][10] == 1) ? length[10] + 1 : length[10] ;
            else
                length[10] <= length[10] + 1;

            if(smaller != 11)
                length[11] <= (children[bigger][11] == 1) ? length[11] + 1 : length[11] ;
            else
                length[11] <= length[11] + 1;

            if(smaller != 12)
                length[12] <= (children[bigger][12] == 1) ? length[12] + 1 : length[12] ;
            else
                length[12] <= length[12] + 1;

            if(smaller != 13)
                length[13] <= (children[bigger][13] == 1) ? length[13] + 1 : length[13] ;
            else
                length[13] <= length[13] + 1;

            if(smaller != 14)
                length[14] <= (children[bigger][14] == 1) ? length[14] + 1 : length[14] ;
            else
                length[14] <= length[14] + 1;
        end
        else begin
            if(children[bigger][7] == 1 || children[smaller][7] == 1)
                length[7] <= length[7] + 1;
            
            if(children[bigger][8] == 1 || children[smaller][8] == 1)
                length[8] <= length[8] + 1;
            
            if(children[bigger][9] == 1 || children[smaller][9] == 1)
                length[9] <= length[9] + 1;

            if(children[bigger][10] == 1 || children[smaller][10] == 1)
                length[10] <= length[10] + 1;

            if(children[bigger][11] == 1 || children[smaller][11] == 1)
                length[11] <= length[11] + 1;

            if(children[bigger][12] == 1 || children[smaller][12] == 1)
                length[12] <= length[12] + 1;

            if(children[bigger][13] == 1 || children[smaller][13] == 1)
                length[13] <= length[13] + 1;

            if(children[bigger][14] == 1 || children[smaller][14] == 1)
                length[14] <= length[14] + 1;
            
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 7; i <= 14; i = i + 1) begin
            code[i] <= 0;
        end
    end
    else if(c_state == IDLE) begin
        for(i = 7; i <= 14; i = i + 1) begin
            code[i] <= 0;
        end
    end
    else if(n_state == CAL || c_state == CAL) begin
        if((bigger >= 7 && bigger <= 14) && (smaller >= 7 && smaller <= 14)) begin
            code[bigger] <= {code[bigger][5:0], 1'b0};
            code[smaller] <= {code[smaller][5:0], 1'b1};
        end
        else if((bigger >= 7 && bigger <= 14) && !(smaller >= 7 && smaller <= 14)) begin
            
            if(bigger != 7)
                code[7] <= (children[smaller][7] == 1) ? {code[7][5:0], 1'b1} : code[7] ;
            else
                code[7] <= {code[7][5:0], 1'b0};

            if(bigger != 8)
                code[8] <= (children[smaller][8] == 1) ? {code[8][5:0], 1'b1} : code[8] ;
            else
                code[8] <= {code[8][5:0], 1'b0};

            if(bigger != 9)
                code[9] <= (children[smaller][9] == 1) ? {code[9][5:0], 1'b1} : code[9] ;
            else
                code[9] <= {code[9][5:0], 1'b0};

            if(bigger != 10)
                code[10] <= (children[smaller][10] == 1) ? {code[10][5:0], 1'b1} : code[10] ;
            else
                code[10] <= {code[10][5:0], 1'b0};

            if(bigger != 11)
                code[11] <= (children[smaller][11] == 1) ? {code[11][5:0], 1'b1} : code[11] ;
            else
                code[11] <= {code[11][5:0], 1'b0};

            if(bigger != 12)
                code[12] <= (children[smaller][12] == 1) ? {code[12][5:0], 1'b1} : code[12] ;
            else
                code[12] <= {code[12][5:0], 1'b0};

            if(bigger != 13)
                code[13] <= (children[smaller][13] == 1) ? {code[13][5:0], 1'b1} : code[13] ;
            else
                code[13] <= {code[13][5:0], 1'b0};

            if(bigger != 14)
                code[14] <= (children[smaller][14] == 1) ? {code[14][5:0], 1'b1} : code[14] ;
            else
                code[14] <= {code[14][5:0], 1'b0};

        end
        else if(!(bigger >= 7 && bigger <= 14) && (smaller >= 7 && smaller <= 14)) begin

            if(smaller != 7)
                code[7] <= (children[bigger][7] == 1) ? {code[7][5:0], 1'b0} : code[7] ;
            else
                code[7] <= {code[7][5:0], 1'b1};

            if(smaller != 8)
                code[8] <= (children[bigger][8] == 1) ? {code[8][5:0], 1'b0} : code[8] ;
            else
                code[8] <= {code[8][5:0], 1'b1};

            if(smaller != 9)
                code[9] <= (children[bigger][9] == 1) ? {code[9][5:0], 1'b0} : code[9] ;
            else
                code[9] <= {code[9][5:0], 1'b1};

            if(smaller != 10)
                code[10] <= (children[bigger][10] == 1) ? {code[10][5:0], 1'b0} : code[10] ;
            else
                code[10] <= {code[10][5:0], 1'b1};

            if(smaller != 11)
                code[11] <= (children[bigger][11] == 1) ? {code[11][5:0], 1'b0} : code[11] ;
            else
                code[11] <= {code[11][5:0], 1'b1};

            if(smaller != 12)
                code[12] <= (children[bigger][12] == 1) ? {code[12][5:0], 1'b0} : code[12] ;
            else
                code[12] <= {code[12][5:0], 1'b1};

            if(smaller != 13)
                code[13] <= (children[bigger][13] == 1) ? {code[13][5:0], 1'b0} : code[13] ;
            else
                code[13] <= {code[13][5:0], 1'b1};

            if(smaller != 14)
                code[14] <= (children[bigger][14] == 1) ? {code[14][5:0], 1'b0} : code[14] ;
            else
                code[14] <= {code[14][5:0], 1'b1};
        end
        else begin
            if(children[bigger][7] == 0 && children[smaller][7] == 1)
                code[7] <= {code[7][5:0], 1'b1};
            else if(children[bigger][7] == 1 && children[smaller][7] == 0)
                code[7] <= {code[7][5:0], 1'b0};
            
            if(children[bigger][8] == 0 && children[smaller][8] == 1)
                code[8] <= {code[8][5:0], 1'b1};
            else if(children[bigger][8] == 1 && children[smaller][8] == 0)
                code[8] <= {code[8][5:0], 1'b0};

            if(children[bigger][9] == 0 && children[smaller][9] == 1)
                code[9] <= {code[9][5:0], 1'b1};
            else if(children[bigger][9] == 1 && children[smaller][9] == 0)
                code[9] <= {code[9][5:0], 1'b0};

            if(children[bigger][10] == 0 && children[smaller][10] == 1)
                code[10] <= {code[10][5:0], 1'b1};
            else if(children[bigger][10] == 1 && children[smaller][10] == 0)
                code[10] <= {code[10][5:0], 1'b0};

            if(children[bigger][11] == 0 && children[smaller][11] == 1)
                code[11] <= {code[11][5:0], 1'b1};
            else if(children[bigger][11] == 1 && children[smaller][11] == 0)
                code[11] <= {code[11][5:0], 1'b0};

            if(children[bigger][12] == 0 && children[smaller][12] == 1)
                code[12] <= {code[12][5:0], 1'b1};
            else if(children[bigger][12] == 1 && children[smaller][12] == 0)
                code[12] <= {code[12][5:0], 1'b0};

            if(children[bigger][13] == 0 && children[smaller][13] == 1)
                code[13] <= {code[13][5:0], 1'b1};
            else if(children[bigger][13] == 1 && children[smaller][13] == 0)
                code[13] <= {code[13][5:0], 1'b0};

            if(children[bigger][14] == 0 && children[smaller][14] == 1)
                code[14] <= {code[14][5:0], 1'b1};
            else if(children[bigger][14] == 1 && children[smaller][14] == 0)
                code[14] <= {code[14][5:0], 1'b0};
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 1; i <= 6; i = i + 1) begin
            for(j = 7; j <= 14; j = j + 1) begin
                children[i][j] <= 0;
            end
        end
    end
    else if(n_state == IDLE) begin
        for(i = 1; i <= 6; i = i + 1) begin
            for(j = 7; j <= 14; j = j + 1) begin
                children[i][j] <= 0;
            end
        end
    end
    else if(n_state == CAL || c_state == CAL) begin
        if(cnt_7 >= 1) begin // !! if add this line will reduce area
            if((bigger >= 7 && bigger <= 14) && (smaller >= 7 && smaller <= 14)) begin
                children[cnt_7][bigger] <= 1;
                children[cnt_7][smaller] <= 1;
            end
            else if((bigger >= 7 && bigger <= 14) && !(smaller >= 7 && smaller <= 14)) begin
                case(bigger)
                    7: begin
                        children[cnt_7][7] <= 1;

                        children[cnt_7][8] <= children[smaller][8];
                        children[cnt_7][9] <= children[smaller][9];
                        children[cnt_7][10] <= children[smaller][10];
                        children[cnt_7][11] <= children[smaller][11];
                        children[cnt_7][12] <= children[smaller][12];
                        children[cnt_7][13] <= children[smaller][13];
                        children[cnt_7][14] <= children[smaller][14];

                    end
                    8: begin
                        children[cnt_7][8] <= 1;

                        children[cnt_7][7] <= children[smaller][7];
                        children[cnt_7][9] <= children[smaller][9];
                        children[cnt_7][10] <= children[smaller][10];
                        children[cnt_7][11] <= children[smaller][11];
                        children[cnt_7][12] <= children[smaller][12];
                        children[cnt_7][13] <= children[smaller][13];
                        children[cnt_7][14] <= children[smaller][14];
                    end
                    9: begin
                        children[cnt_7][9] <= 1;

                        children[cnt_7][7] <= children[smaller][7];
                        children[cnt_7][8] <= children[smaller][8];
                        children[cnt_7][10] <= children[smaller][10];
                        children[cnt_7][11] <= children[smaller][11];
                        children[cnt_7][12] <= children[smaller][12];
                        children[cnt_7][13] <= children[smaller][13];
                        children[cnt_7][14] <= children[smaller][14];
                    end
                    10: begin
                        children[cnt_7][10] <= 1;

                        children[cnt_7][7] <= children[smaller][7];
                        children[cnt_7][8] <= children[smaller][8];
                        children[cnt_7][9] <= children[smaller][9];
                        children[cnt_7][11] <= children[smaller][11];
                        children[cnt_7][12] <= children[smaller][12];
                        children[cnt_7][13] <= children[smaller][13];
                        children[cnt_7][14] <= children[smaller][14];
                    end
                    11: begin
                        children[cnt_7][11] <= 1;

                        children[cnt_7][7] <= children[smaller][7];
                        children[cnt_7][8] <= children[smaller][8];
                        children[cnt_7][9] <= children[smaller][9];
                        children[cnt_7][10] <= children[smaller][10];
                        children[cnt_7][12] <= children[smaller][12];
                        children[cnt_7][13] <= children[smaller][13];
                        children[cnt_7][14] <= children[smaller][14];
                    end
                    12: begin
                        children[cnt_7][12] <= 1;

                        children[cnt_7][7] <= children[smaller][7];
                        children[cnt_7][8] <= children[smaller][8];
                        children[cnt_7][9] <= children[smaller][9];
                        children[cnt_7][10] <= children[smaller][10];
                        children[cnt_7][11] <= children[smaller][11];
                        children[cnt_7][13] <= children[smaller][13];
                        children[cnt_7][14] <= children[smaller][14];
                    end
                    13: begin
                        children[cnt_7][13] <= 1;

                        children[cnt_7][7] <= children[smaller][7];
                        children[cnt_7][8] <= children[smaller][8];
                        children[cnt_7][9] <= children[smaller][9];
                        children[cnt_7][10] <= children[smaller][10];
                        children[cnt_7][11] <= children[smaller][11];
                        children[cnt_7][12] <= children[smaller][12];
                        children[cnt_7][14] <= children[smaller][14];
                    end
                    14: begin
                        children[cnt_7][14] <= 1;

                        children[cnt_7][7] <= children[smaller][7];
                        children[cnt_7][8] <= children[smaller][8];
                        children[cnt_7][9] <= children[smaller][9];
                        children[cnt_7][10] <= children[smaller][10];
                        children[cnt_7][11] <= children[smaller][11];
                        children[cnt_7][12] <= children[smaller][12];
                        children[cnt_7][13] <= children[smaller][13];
                    end
                endcase
            end
            else if(!(bigger >= 7 && bigger <= 14) && (smaller >= 7 && smaller <= 14)) begin
                case(smaller)
                    7: begin
                        children[cnt_7][7] <= 1;

                        children[cnt_7][8] <= children[bigger][8];
                        children[cnt_7][9] <= children[bigger][9];
                        children[cnt_7][10] <= children[bigger][10];
                        children[cnt_7][11] <= children[bigger][11];
                        children[cnt_7][12] <= children[bigger][12];
                        children[cnt_7][13] <= children[bigger][13];
                        children[cnt_7][14] <= children[bigger][14];

                    end
                    8: begin
                        children[cnt_7][8] <= 1;

                        children[cnt_7][7] <= children[bigger][7];
                        children[cnt_7][9] <= children[bigger][9];
                        children[cnt_7][10] <= children[bigger][10];
                        children[cnt_7][11] <= children[bigger][11];
                        children[cnt_7][12] <= children[bigger][12];
                        children[cnt_7][13] <= children[bigger][13];
                        children[cnt_7][14] <= children[bigger][14];
                    end
                    9: begin
                        children[cnt_7][9] <= 1;

                        children[cnt_7][7] <= children[bigger][7];
                        children[cnt_7][8] <= children[bigger][8];
                        children[cnt_7][10] <= children[bigger][10];
                        children[cnt_7][11] <= children[bigger][11];
                        children[cnt_7][12] <= children[bigger][12];
                        children[cnt_7][13] <= children[bigger][13];
                        children[cnt_7][14] <= children[bigger][14];
                    end
                    10: begin
                        children[cnt_7][10] <= 1;

                        children[cnt_7][7] <= children[bigger][7];
                        children[cnt_7][8] <= children[bigger][8];
                        children[cnt_7][9] <= children[bigger][9];
                        children[cnt_7][11] <= children[bigger][11];
                        children[cnt_7][12] <= children[bigger][12];
                        children[cnt_7][13] <= children[bigger][13];
                        children[cnt_7][14] <= children[bigger][14];
                    end
                    11: begin
                        children[cnt_7][11] <= 1;

                        children[cnt_7][7] <= children[bigger][7];
                        children[cnt_7][8] <= children[bigger][8];
                        children[cnt_7][9] <= children[bigger][9];
                        children[cnt_7][10] <= children[bigger][10];
                        children[cnt_7][12] <= children[bigger][12];
                        children[cnt_7][13] <= children[bigger][13];
                        children[cnt_7][14] <= children[bigger][14];
                    end
                    12: begin
                        children[cnt_7][12] <= 1;

                        children[cnt_7][7] <= children[bigger][7];
                        children[cnt_7][8] <= children[bigger][8];
                        children[cnt_7][9] <= children[bigger][9];
                        children[cnt_7][10] <= children[bigger][10];
                        children[cnt_7][11] <= children[bigger][11];
                        children[cnt_7][13] <= children[bigger][13];
                        children[cnt_7][14] <= children[bigger][14];
                    end
                    13: begin
                        children[cnt_7][13] <= 1;

                        children[cnt_7][7] <= children[bigger][7];
                        children[cnt_7][8] <= children[bigger][8];
                        children[cnt_7][9] <= children[bigger][9];
                        children[cnt_7][10] <= children[bigger][10];
                        children[cnt_7][11] <= children[bigger][11];
                        children[cnt_7][12] <= children[bigger][12];
                        children[cnt_7][14] <= children[bigger][14];
                    end
                    14: begin
                        children[cnt_7][14] <= 1;

                        children[cnt_7][7] <= children[bigger][7];
                        children[cnt_7][8] <= children[bigger][8];
                        children[cnt_7][9] <= children[bigger][9];
                        children[cnt_7][10] <= children[bigger][10];
                        children[cnt_7][11] <= children[bigger][11];
                        children[cnt_7][12] <= children[bigger][12];
                        children[cnt_7][13] <= children[bigger][13];
                    end
                endcase
            end
            else begin
                children[cnt_7][7] <= children[bigger][7] | children[smaller][7];
                children[cnt_7][8] <= children[bigger][8] | children[smaller][8];
                children[cnt_7][9] <= children[bigger][9] | children[smaller][9];
                children[cnt_7][10] <= children[bigger][10] | children[smaller][10];
                children[cnt_7][11] <= children[bigger][11] | children[smaller][11];
                children[cnt_7][12] <= children[bigger][12] | children[smaller][12];
                children[cnt_7][13] <= children[bigger][13] | children[smaller][13];
                children[cnt_7][14] <= children[bigger][14] | children[smaller][14];
            end
        end // !HERE
    end
        
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_7 <= 6;
    else if(n_state == IDLE)
        cnt_7 <= 6;
    else if(n_state == CAL || c_state == CAL) begin
        if(cnt_7 > 0)
            cnt_7 <= cnt_7 - 1;
        else 
            cnt_7 <= cnt_7;
    end
end


//////////////////////////////////////////////////////////////////////////
//                                 SORT                                 //
//////////////////////////////////////////////////////////////////////////

always @(*) begin
    IN_character = 0;
    case(cnt_7)
        6: IN_character = {4'd14, 4'd13, 4'd12, 4'd11, 4'd10, 4'd9, 4'd8, 4'd7};
        5: IN_character = sort_result;
        4: IN_character = sort_result;
        3: IN_character = sort_result;
        2: IN_character = sort_result;
        1: IN_character = sort_result;
        0: IN_character = sort_result;
    endcase
end

always @(*) begin
    IN_weight = 0;
    
    case(cnt_7)
        6: IN_weight = {weight_reg[14], weight_reg[13], weight_reg[12], weight_reg[11], weight_reg[10], weight_reg[9], weight_reg[8], weight_reg[7]};
        default :IN_weight = {weight_reg[sort_result[31:28]], weight_reg[sort_result[27:24]], weight_reg[sort_result[23:20]], weight_reg[sort_result[19:16]], 
                                weight_reg[sort_result[15:12]], weight_reg[sort_result[11:8]], weight_reg[sort_result[7:4]], weight_reg[sort_result[3:0]]};
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        sort_result <= 0;

    else if(n_state == CAL || c_state == CAL) begin
        case(cnt_7)
            6: sort_result <= {OUT_character[31:8], 4'd6, 4'd15};
            5: sort_result <= {OUT_character[27:8], 4'd5, 4'd15, 4'd15};
            4: sort_result <= {OUT_character[23:8], 4'd4, 4'd15, 4'd15, 4'd15};
            3: sort_result <= {OUT_character[19:8], 4'd3, 4'd15, 4'd15, 4'd15, 4'd15};
            2: sort_result <= {OUT_character[15:8], 4'd2, 4'd15, 4'd15, 4'd15, 4'd15, 4'd15};
            1: sort_result <= {OUT_character[11:8], 4'd1, 4'd15, 4'd15, 4'd15, 4'd15, 4'd15, 4'd15};
        endcase
    end
        
end

//////////////////////////////////////////////////////////////////////////
//                                 INPUT                                //
//////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        input_cnt <= 14;
    else if(n_state == IDLE)
        input_cnt <= 14;
    else if(n_state == INPUT)
        input_cnt <= input_cnt - 1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        weight_reg[15] <= 31;
        for(i = 0; i <= 14; i = i + 1)
            weight_reg[i] <= 0;
    end
    else if(n_state == INPUT)
        weight_reg[input_cnt] <= in_weight;
    else if(n_state == CAL || c_state == CAL) 
        weight_reg[cnt_7] <= weight_reg[bigger] + weight_reg[smaller];
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        mode_reg <= 0;
    else if(n_state == INPUT && c_state == IDLE)
        mode_reg <= out_mode;
end

//////////////////////////////////////////////////////////////////////////
//                                 STATE                                //
//////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) c_state <= IDLE;
    else c_state <= n_state;
end

always @(*) begin

    n_state = IDLE;

    case(c_state) 
        IDLE: begin
            if(in_valid)
                n_state = INPUT;
            else
                n_state = c_state;
        end
        INPUT: begin
            if(input_cnt == 6)
                n_state = CAL;
            else
                n_state = c_state;
        end
        CAL: begin
            if(cnt_7 == 0)
                n_state = I;
            else
                n_state = c_state;
        end
        // DELAY: begin
        //     n_state = I;
        // end
        I: begin
            if(out_cnt == length[10]-1) begin
                if(mode_reg == 1)
                    n_state = C;
                else
                    n_state = L;
            end
            else
                n_state = c_state;
        end
        C: begin
            if(out_cnt == length[12]-1)
                n_state = L;
            else
                n_state = c_state;
        end
        L: begin
            if(out_cnt == length[9]-1) begin
                if(mode_reg == 1)
                    n_state = A;
                else
                    n_state = O;
            end
            else
                n_state = c_state;
        end
        A: begin
            if(out_cnt == length[14]-1)
                n_state = B;
            else
                n_state = c_state;
        end
        B: begin
            if(out_cnt == length[13]-1)
                n_state = IDLE;
            else
                n_state = c_state;
        end

        O: begin
            if(out_cnt == length[8]-1)
                n_state = V;
            else
                n_state = c_state;
        end
        V: begin
            if(out_cnt == length[7]-1)
                n_state = E;
            else
                n_state = c_state;
        end
        E: begin
            if(out_cnt == length[11]-1)
                n_state = IDLE;
            else
                n_state = c_state;
        end
    endcase
end


//////////////////////////////////////////////////////////////////////////
//                                OUTPUT                                //
//////////////////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        out_cnt <= 0;
    else if(c_state == IDLE)
        out_cnt <= 0;
    else if(c_state == I) begin
        if(out_cnt == length[10] - 1)
            out_cnt <= 0;
        else
            out_cnt <= out_cnt + 1;
    end
    else if(c_state == C) begin
        if(out_cnt == length[12] - 1)
            out_cnt <= 0;
        else
            out_cnt <= out_cnt + 1;
    end
    else if(c_state == L) begin
        if(out_cnt == length[9] - 1)
            out_cnt <= 0;
        else
            out_cnt <= out_cnt + 1;
    end
    else if(c_state == A) begin
        if(out_cnt == length[14] - 1)
            out_cnt <= 0;
        else
            out_cnt <= out_cnt + 1;
    end
    else if(c_state == B) begin
        if(out_cnt == length[13] - 1)
            out_cnt <= 0;
        else
            out_cnt <= out_cnt + 1;
    end
    else if(c_state == O) begin
        if(out_cnt == length[8] - 1)
            out_cnt <= 0;
        else
            out_cnt <= out_cnt + 1;
    end
    else if(c_state == V) begin
        if(out_cnt == length[7] - 1)
            out_cnt <= 0;
        else
            out_cnt <= out_cnt + 1;
    end
    else if(c_state == E) begin
        if(out_cnt == length[11] - 1)
            out_cnt <= 0;
        else
            out_cnt <= out_cnt + 1;
    end

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_valid <= 0;
    else if(c_state == IDLE)
        out_valid <= 0;
    else if(c_state == I)
        out_valid <= 1;
    // else if((c_state == B && out_cnt == length[13]-1) || (c_state == E && out_cnt == length[11]-1))
    //     out_valid <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_code <= 0;
    else if(c_state == IDLE)
        out_code <= 0;
    else if(c_state == I)
        out_code <= code[10][out_cnt];
    else if(c_state == C)
        out_code <= code[12][out_cnt];
    else if(c_state == L)
        out_code <= code[9][out_cnt];
    else if(c_state == A)
        out_code <= code[14][out_cnt];
    else if(c_state == B) 
        out_code <= code[13][out_cnt];
    else if(c_state == O)
        out_code <= code[8][out_cnt];
    else if(c_state == V)
        out_code <= code[7][out_cnt];
    else if(c_state == E) 
        out_code <= code[11][out_cnt];
end

endmodule