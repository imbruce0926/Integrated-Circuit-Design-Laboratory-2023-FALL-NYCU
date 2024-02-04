
module SMC(
  // Input signals
    mode,
    W_0, V_GS_0, V_DS_0,
    W_1, V_GS_1, V_DS_1,
    W_2, V_GS_2, V_DS_2,
    W_3, V_GS_3, V_DS_3,
    W_4, V_GS_4, V_DS_4,
    W_5, V_GS_5, V_DS_5,   
  // Output signals
    out_n
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
output [7:0] out_n; 							

wire [7:0] sort_result[0:5];
wire [7:0] cal_result[0:5];

reg [7:0] n0, n1, n2;



//================================================================
//    DESIGN
//================================================================

/*Calculate Id or gm*/

cal_Id_gm U0 (.W(W_0), .V_GS(V_GS_0), .V_DS(V_DS_0), .mode_0(mode[0]), .out(cal_result[0]));
cal_Id_gm U1 (.W(W_1), .V_GS(V_GS_1), .V_DS(V_DS_1), .mode_0(mode[0]), .out(cal_result[1]));
cal_Id_gm U2 (.W(W_2), .V_GS(V_GS_2), .V_DS(V_DS_2), .mode_0(mode[0]), .out(cal_result[2]));
cal_Id_gm U3 (.W(W_3), .V_GS(V_GS_3), .V_DS(V_DS_3), .mode_0(mode[0]), .out(cal_result[3]));
cal_Id_gm U4 (.W(W_4), .V_GS(V_GS_4), .V_DS(V_DS_4), .mode_0(mode[0]), .out(cal_result[4]));
cal_Id_gm U5 (.W(W_5), .V_GS(V_GS_5), .V_DS(V_DS_5), .mode_0(mode[0]), .out(cal_result[5]));

/*Sort*/

sorting Sort0 (.data0(cal_result[0]), .data1(cal_result[1]), .data2(cal_result[2]), .data3(cal_result[3]), .data4(cal_result[4]), .data5(cal_result[5]), 
                .out0(sort_result[0]), .out1(sort_result[1]), .out2(sort_result[2]), .out3(sort_result[3]), .out4(sort_result[4]), .out5(sort_result[5]));

/*Select according to mode*/  

always @(*)begin

  case(mode[1])
  1'b0: begin
    n0 = sort_result[3];
    n1 = sort_result[4];
    n2 = sort_result[5];
  end
  1'b1: begin
    n0 = sort_result[0];
    n1 = sort_result[1];
    n2 = sort_result[2];
  end
  endcase

end

/*Output*/

cal_ave Cal0 (.mode_0(mode[0]), .out_0(n0), .out_1(n1), .out_2(n2), .out_n(out_n));

endmodule

//================================================================
//   SUB MODULE
//================================================================

module cal_ave(mode_0, out_0, out_1, out_2, out_n);

input [7:0] out_0, out_1, out_2;
input mode_0;
output [7:0] out_n;

wire [6:0] out_0_temp, out_1_temp, out_2_temp;
reg [7:0] out_temp;
wire [6:0] out_temp2;

divide_3_8b D0(out_0, out_0_temp);
divide_3_8b D1(out_1, out_1_temp);
divide_3_8b D2(out_2, out_2_temp);

always @(*) begin
  case(mode_0)
    1'b0:
      out_temp = (out_0_temp + out_1_temp + out_2_temp);
    1'b1:
      out_temp = (3*out_0_temp + 4*out_1_temp + 5*out_2_temp) / 4;
    default:
      out_temp = 8'bxxxx_xxxx;
  endcase
end

divide_3_8b D3(out_temp, out_temp2);

assign out_n = out_temp2;

endmodule


module cal_Id_gm (W, V_GS, V_DS, mode_0, out);

input [2:0] W, V_GS, V_DS;
input mode_0;
output [7:0] out;

reg [2:0] V_OV;
wire opmode;
wire [1:0]formula;
reg [5:0] part;

assign opmode = (V_OV > V_DS) ? 1'b0 : 1'b1;
assign formula = {opmode, mode_0};


always @(*) begin
  case(V_GS)
    3'd0: V_OV = 0;
    3'd1: V_OV = 0;
    3'd2: V_OV = 1; 
    3'd3: V_OV = 2;
    3'd4: V_OV = 3;
    3'd5: V_OV = 4;
    3'd6: V_OV = 5;
    3'd7: V_OV = 6;
    default : V_OV = 3'bxxx;
  endcase
end

always @(*) begin
  case(formula)
    2'b00: begin
      case(V_DS)
        3'd0: part = 0;
        3'd1: part = 2;
        3'd2: part = 4;
        3'd3: part = 6;
        3'd4: part = 8;
        3'd5: part = 10;
        3'd6: part = 12;
        3'd7: part = 14;
        default: part = 6'bxxxxxx;
      endcase
    end
    2'b01: begin
      case(V_OV)
        3'd0: begin
          case(V_DS)
            3'd0: part = 0;
            3'd1: part = 0;
            3'd2: part = 0;
            3'd3: part = 0;
            3'd4: part = 0;
            3'd5: part = 0;
            3'd6: part = 0;
            3'd7: part = 0;
            default : part = 6'bxxxxxx;
          endcase
        end
        3'd1: begin
          case(V_DS)
            3'd0: part = 0;
            3'd1: part = 0;
            3'd2: part = 0;
            3'd3: part = 0;
            3'd4: part = 0;
            3'd5: part = 0;
            3'd6: part = 0;
            3'd7: part = 0;
            default : part = 6'bxxxxxx;
          endcase
        end
        3'd2: begin
          case(V_DS)
            3'd0: part = 0;
            3'd1: part = 3;
            3'd2: part = 0;
            3'd3: part = 0;
            3'd4: part = 0;
            3'd5: part = 0;
            3'd6: part = 0;
            3'd7: part = 0;
            default : part = 6'bxxxxxx;
          endcase
        end
        3'd3: begin
          case(V_DS)
            3'd0: part = 0;
            3'd1: part = 5;
            3'd2: part = 8;
            3'd3: part = 0;
            3'd4: part = 0;
            3'd5: part = 0;
            3'd6: part = 0;
            3'd7: part = 0;
            default : part = 6'bxxxxxx;
          endcase
        end
        3'd4: begin
          case(V_DS)
            3'd0: part = 0;
            3'd1: part = 7;
            3'd2: part = 12;
            3'd3: part = 15;
            3'd4: part = 0;
            3'd5: part = 0;
            3'd6: part = 0;
            3'd7: part = 0;
            default : part = 6'bxxxxxx;
          endcase
        end
        3'd5: begin
          case(V_DS)
            3'd0: part = 0;
            3'd1: part = 9;
            3'd2: part = 16;
            3'd3: part = 21;
            3'd4: part = 24;
            3'd5: part = 0;
            3'd6: part = 0;
            3'd7: part = 0;
            default : part = 6'bxxxxxx;
          endcase
        end
        3'd6: begin
          case(V_DS)
            3'd0: part = 0;
            3'd1: part = 11;
            3'd2: part = 20;
            3'd3: part = 27;
            3'd4: part = 32;
            3'd5: part = 35;
            3'd6: part = 0;
            3'd7: part = 0;
            default : part = 6'bxxxxxx;
          endcase
        end
        3'd7: part = 0;
        default: part = 6'bxxxxxx;
      endcase
    end
    2'b10: begin
      case(V_OV)
        3'd0: part = 0;
        3'd1: part = 2;
        3'd2: part = 4;
        3'd3: part = 6;
        3'd4: part = 8;
        3'd5: part = 10;
        3'd6: part = 12;
        3'd7: part = 0;
        default: part = 6'bxxxxxx;
      endcase
    end
    2'b11: begin
      case(V_OV)
        3'd0: part = 0;
        3'd1: part = 1;
        3'd2: part = 4;
        3'd3: part = 9;
        3'd4: part = 16;
        3'd5: part = 25;
        3'd6: part = 36;
        3'd7: part = 0;
        default: part = 6'bxxxxxx;
      endcase
    end
    default: part = 6'bxxxxxx;
  endcase

end

assign out = part * W;


endmodule


module sorting (data0, data1, data2, data3, data4, data5, out0, out1, out2, out3, out4, out5);

input [7:0] data0, data1, data2, data3, data4, data5;
output [7:0] out0, out1, out2, out3, out4, out5;

wire [7:0] L1_larger_1, L1_smaller_1;
wire [7:0] L1_larger_2, L1_smaller_2;
wire [7:0] L1_larger_3, L1_smaller_3;

wire [7:0] L2_larger_1, L2_smaller_1;
wire [7:0] L2_larger_2, L2_smaller_2;
wire [7:0] L2_larger_3, L2_smaller_3;

wire [7:0] L3_larger_1, L3_smaller_1;
wire [7:0] L3_larger_2, L3_smaller_2;
wire [7:0] L3_larger_3, L3_smaller_3;

wire [7:0] L4_larger_1, L4_smaller_1;
wire [7:0] L4_larger_2, L4_smaller_2;

wire [7:0] L5_larger_1, L5_smaller_1;

compartor C0 (data0, data1, L1_larger_1, L1_smaller_1);
compartor C1 (data2, data3, L1_larger_2, L1_smaller_2);
compartor C2 (data4, data5, L1_larger_3, L1_smaller_3);

compartor C3 (L1_larger_1, L1_larger_2, L2_larger_1, L2_smaller_1);
compartor C4 (L1_smaller_1, L1_larger_3, L2_larger_2, L2_smaller_2);
compartor C5 (L1_smaller_2, L1_smaller_3, L2_larger_3, L2_smaller_3);

compartor C6 (L2_larger_1, L2_larger_2, L3_larger_1, L3_smaller_1);
compartor C7 (L2_smaller_1, L2_larger_3, L3_larger_2, L3_smaller_2);
compartor C8 (L2_smaller_2, L2_smaller_3, L3_larger_3, L3_smaller_3);

compartor C9 (L3_smaller_1, L3_larger_2, L4_larger_1, L4_smaller_1);
compartor C10 (L3_smaller_2, L3_larger_3, L4_larger_2, L4_smaller_2);

compartor C11 (L4_smaller_1, L4_larger_2, L5_larger_1, L5_smaller_1);


assign out0 = L3_larger_1;
assign out1 = L4_larger_1;
assign out2 = L5_larger_1;
assign out3 = L5_smaller_1;
assign out4 = L4_smaller_2;
assign out5 = L3_smaller_3;


endmodule

module compartor(a, b, A, B);
input [7:0] a, b;
output [7:0] A, B;

assign A = (a>=b) ? a : b;
assign B = (a>=b) ? b : a;

endmodule

module divide_3_8b (in, out);

input [7:0] in;
output reg [6:0] out;

always @(*) begin
  case(in)
    8'd0 : out = 0;
    8'd1 : out = 0;
    8'd2 : out = 0;
    8'd3 : out = 1;
    8'd4 : out = 1;
    8'd5 : out = 1;
    8'd6 : out = 2;
    8'd7 : out = 2;
    8'd8 : out = 2;
    8'd9 : out = 3;
    8'd10 : out = 3;
    8'd11 : out = 3;
    8'd12 : out = 4;
    8'd13 : out = 4;
    8'd14 : out = 4;
    8'd15 : out = 5;
    8'd16 : out = 5;
    8'd17 : out = 5;
    8'd18 : out = 6;
    8'd19 : out = 6;
    8'd20 : out = 6;
    8'd21 : out = 7;
    8'd22 : out = 7;
    8'd23 : out = 7;
    8'd24 : out = 8;
    8'd25 : out = 8;
    8'd26 : out = 8;
    8'd27 : out = 9;
    8'd28 : out = 9;
    8'd29 : out = 9;
    8'd30 : out = 10;
    8'd31 : out = 10;
    8'd32 : out = 10;
    8'd33 : out = 11;
    8'd34 : out = 11;
    8'd35 : out = 11;
    8'd36 : out = 12;
    8'd37 : out = 12;
    8'd38 : out = 12;
    8'd39 : out = 13;
    8'd40 : out = 13;
    8'd41 : out = 13;
    8'd42 : out = 14;
    8'd43 : out = 14;
    8'd44 : out = 14;
    8'd45 : out = 15;
    8'd46 : out = 15;
    8'd47 : out = 15;
    8'd48 : out = 16;
    8'd49 : out = 16;
    8'd50 : out = 16;
    8'd51 : out = 17;
    8'd52 : out = 17;
    8'd53 : out = 17;
    8'd54 : out = 18;
    8'd55 : out = 18;
    8'd56 : out = 18;
    8'd57 : out = 19;
    8'd58 : out = 19;
    8'd59 : out = 19;
    8'd60 : out = 20;
    8'd61 : out = 20;
    8'd62 : out = 20;
    8'd63 : out = 21;
    8'd64 : out = 21;
    8'd65 : out = 21;
    8'd66 : out = 22;
    8'd67 : out = 22;
    8'd68 : out = 22;
    8'd69 : out = 23;
    8'd70 : out = 23;
    8'd71 : out = 23;
    8'd72 : out = 24;
    8'd73 : out = 24;
    8'd74 : out = 24;
    8'd75 : out = 25;
    8'd76 : out = 25;
    8'd77 : out = 25;
    8'd78 : out = 26;
    8'd79 : out = 26;
    8'd80 : out = 26;
    8'd81 : out = 27;
    8'd82 : out = 27;
    8'd83 : out = 27;
    8'd84 : out = 28;
    8'd85 : out = 28;
    8'd86 : out = 28;
    8'd87 : out = 29;
    8'd88 : out = 29;
    8'd89 : out = 29;
    8'd90 : out = 30;
    8'd91 : out = 30;
    8'd92 : out = 30;
    8'd93 : out = 31;
    8'd94 : out = 31;
    8'd95 : out = 31;
    8'd96 : out = 32;
    8'd97 : out = 32;
    8'd98 : out = 32;
    8'd99 : out = 33;
    8'd100 : out = 33;
    8'd101 : out = 33;
    8'd102 : out = 34;
    8'd103 : out = 34;
    8'd104 : out = 34;
    8'd105 : out = 35;
    8'd106 : out = 35;
    8'd107 : out = 35;
    8'd108 : out = 36;
    8'd109 : out = 36;
    8'd110 : out = 36;
    8'd111 : out = 37;
    8'd112 : out = 37;
    8'd113 : out = 37;
    8'd114 : out = 38;
    8'd115 : out = 38;
    8'd116 : out = 38;
    8'd117 : out = 39;
    8'd118 : out = 39;
    8'd119 : out = 39;
    8'd120 : out = 40;
    8'd121 : out = 40;
    8'd122 : out = 40;
    8'd123 : out = 41;
    8'd124 : out = 41;
    8'd125 : out = 41;
    8'd126 : out = 42;
    8'd127 : out = 42;
    8'd128 : out = 42;
    8'd129 : out = 43;
    8'd130 : out = 43;
    8'd131 : out = 43;
    8'd132 : out = 44;
    8'd133 : out = 44;
    8'd134 : out = 44;
    8'd135 : out = 45;
    8'd136 : out = 45;
    8'd137 : out = 45;
    8'd138 : out = 46;
    8'd139 : out = 46;
    8'd140 : out = 46;
    8'd141 : out = 47;
    8'd142 : out = 47;
    8'd143 : out = 47;
    8'd144 : out = 48;
    8'd145 : out = 48;
    8'd146 : out = 48;
    8'd147 : out = 49;
    8'd148 : out = 49;
    8'd149 : out = 49;
    8'd150 : out = 50;
    8'd151 : out = 50;
    8'd152 : out = 50;
    8'd153 : out = 51;
    8'd154 : out = 51;
    8'd155 : out = 51;
    8'd156 : out = 52;
    8'd157 : out = 52;
    8'd158 : out = 52;
    8'd159 : out = 53;
    8'd160 : out = 53;
    8'd161 : out = 53;
    8'd162 : out = 54;
    8'd163 : out = 54;
    8'd164 : out = 54;
    8'd165 : out = 55;
    8'd166 : out = 55;
    8'd167 : out = 55;
    8'd168 : out = 56;
    8'd169 : out = 56;
    8'd170 : out = 56;
    8'd171 : out = 57;
    8'd172 : out = 57;
    8'd173 : out = 57;
    8'd174 : out = 58;
    8'd175 : out = 58;
    8'd176 : out = 58;
    8'd177 : out = 59;
    8'd178 : out = 59;
    8'd179 : out = 59;
    8'd180 : out = 60;
    8'd181 : out = 60;
    8'd182 : out = 60;
    8'd183 : out = 61;
    8'd184 : out = 61;
    8'd185 : out = 61;
    8'd186 : out = 62;
    8'd187 : out = 62;
    8'd188 : out = 62;
    8'd189 : out = 63;
    8'd190 : out = 63;
    8'd191 : out = 63;
    8'd192 : out = 64;
    8'd193 : out = 64;
    8'd194 : out = 64;
    8'd195 : out = 65;
    8'd196 : out = 65;
    8'd197 : out = 65;
    8'd198 : out = 66;
    8'd199 : out = 66;
    8'd200 : out = 66;
    8'd201 : out = 67;
    8'd202 : out = 67;
    8'd203 : out = 67;
    8'd204 : out = 68;
    8'd205 : out = 68;
    8'd206 : out = 68;
    8'd207 : out = 69;
    8'd208 : out = 69;
    8'd209 : out = 69;
    8'd210 : out = 70;
    8'd211 : out = 70;
    8'd212 : out = 70;
    8'd213 : out = 71;
    8'd214 : out = 71;
    8'd215 : out = 71;
    8'd216 : out = 72;
    8'd217 : out = 72;
    8'd218 : out = 72;
    8'd219 : out = 73;
    8'd220 : out = 73;
    8'd221 : out = 73;
    8'd222 : out = 74;
    8'd223 : out = 74;
    8'd224 : out = 74;
    8'd225 : out = 75;
    8'd226 : out = 75;
    8'd227 : out = 75;
    8'd228 : out = 76;
    8'd229 : out = 76;
    8'd230 : out = 76;
    8'd231 : out = 77;
    8'd232 : out = 77;
    8'd233 : out = 77;
    8'd234 : out = 78;
    8'd235 : out = 78;
    8'd236 : out = 78;
    8'd237 : out = 79;
    8'd238 : out = 79;
    8'd239 : out = 79;
    8'd240 : out = 80;
    8'd241 : out = 80;
    8'd242 : out = 80;
    8'd243 : out = 81;
    8'd244 : out = 81;
    8'd245 : out = 81;
    8'd246 : out = 82;
    8'd247 : out = 82;
    8'd248 : out = 82;
    8'd249 : out = 83;
    8'd250 : out = 83;
    8'd251 : out = 83;
    8'd252 : out = 84;
    8'd253 : out = 84;
    8'd254 : out = 84;
    8'd255 : out = 85;
    default : out = 7'bxxxxxxx;
  endcase
end
endmodule
