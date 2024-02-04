//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Siamese Neural Network 
//   Author     		: Jia-Yu Lee (maggie8905121@gmail.com)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SNN.v
//   Module Name : SNN
//   Release version : V1.0 (Release Date: 2023-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SNN(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
    );


//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point parameter
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;
parameter round = 3'b000;

input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel, Weight;
input [1:0] Opt;

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

genvar i, j, k;
integer n, m, r;


wire [7:0] status_mac1, status_mac2, status_mac3, status_mac4;
wire [7:0] status_add1, status_add2, status_add3, status_add4;
reg [inst_sig_width+inst_exp_width:0] a_mac1, b_mac1, c_mac1, a_mac2, b_mac2, c_mac2;
reg [inst_sig_width+inst_exp_width:0] a_mac3, b_mac3, c_mac3, a_mac4, b_mac4, c_mac4;
reg [inst_sig_width+inst_exp_width:0] z_mac1, z_mac2, z_mac3, z_mac4;
reg [inst_sig_width+inst_exp_width:0] a_add1, b_add1, a_add2, b_add2;
reg [inst_sig_width+inst_exp_width:0] a_add3, b_add3, a_add4, b_add4;
reg [inst_sig_width+inst_exp_width:0] z_add1, z_add2, z_add3, z_add4;
reg [inst_sig_width+inst_exp_width:0] a_cmp1, b_cmp1, a_cmp2, b_cmp2;
reg aeqb_cmp1, altb_cmp1, unordered_cmp1, agtb_cmp1, aeqb_cmp2, altb_cmp2, unordered_cmp2, agtb_cmp2;
reg [inst_sig_width+inst_exp_width:0] Max1, Min1, Max2, Min2;
reg [7:0] status0_cmp1, status1_cmp1, status0_cmp2, status1_cmp2;
reg [inst_sig_width+inst_exp_width:0] a_div1, a_div2, a_div3, a_div4;
reg [inst_sig_width+inst_exp_width:0] b_div1, b_div2, b_div3, b_div4;
reg [inst_sig_width+inst_exp_width:0] z_div1, z_div2, z_div3, z_div4;
reg [7:0] status_div1, status_div2, status_div3, status_div4;
reg [inst_sig_width+inst_exp_width:0] a_exp1, a_exp2, a_exp3, a_exp4;
reg [inst_sig_width+inst_exp_width:0] z_exp1, z_exp2, z_exp3, z_exp4;
wire [7:0] status_exp1, status_exp2, status_exp3, status_exp4;

reg [1:0] Opt_reg;
reg [inst_sig_width+inst_exp_width:0] Img_reg [0:95];
reg [inst_sig_width+inst_exp_width:0] Kernel_reg [0:26];
reg [inst_sig_width+inst_exp_width:0] Weight_reg [0:3];
reg [inst_sig_width+inst_exp_width:0] Image_group [0:5] [0:5] [0:5];
reg [inst_sig_width+inst_exp_width:0] Kernel_group [0:2] [0:2] [0:2];
reg [7:0] input_cnt;
reg [3:0] conv_cnt;
reg [1:0] nine_cycle_cnt;
reg [2:0] img_cnt;
reg [inst_sig_width+inst_exp_width:0] Kernel_sel [0:8];
reg [inst_sig_width+inst_exp_width:0] feture_map [0:3] [0:3];
reg [inst_sig_width+inst_exp_width:0] result1, result2, result3, result4;
reg [inst_sig_width+inst_exp_width:0] pooling [0:1] [0:1] [0:1];


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out <= 0;
		out_valid <= 0;
	end
	else begin
		case(Opt_reg[1])
			0: begin
				if(input_cnt == 246) begin
					out_valid <= 1;
					out <= z_add1;
				end
				else begin
					out_valid <= 0;
					out <= 0;
				end

			end
			1: begin
				if(input_cnt == 248) begin
					out_valid <= 1;
					out <= z_add1;
				end
				else begin
					out_valid <= 0;
					out <= 0;
				end
			end
		endcase
	end
end


//////////////////////////////////////////////////////////
//                           exp                        //
//////////////////////////////////////////////////////////

always @(*) begin
	if(input_cnt == 237) begin
		a_exp1 = feture_map[0][0];
		a_exp2 = feture_map[1][0];
		a_exp3 = feture_map[2][0];
		a_exp4 = feture_map[3][0];
	end
	else if(input_cnt == 238) begin
		a_exp1 = {~feture_map[0][0][31], feture_map[0][0][30:0]};
		a_exp2 = {~feture_map[1][0][31], feture_map[1][0][30:0]};
		a_exp3 = {~feture_map[2][0][31], feture_map[2][0][30:0]};
		a_exp4 = {~feture_map[3][0][31], feture_map[3][0][30:0]};
	end
	else if(input_cnt == 239) begin
		a_exp1 = feture_map[0][1];
		a_exp2 = feture_map[1][1];
		a_exp3 = feture_map[2][1];
		a_exp4 = feture_map[3][1];
	end
	else if(input_cnt == 240) begin
		a_exp1 = {~feture_map[0][1][31], feture_map[0][1][30:0]};
		a_exp2 = {~feture_map[1][1][31], feture_map[1][1][30:0]};
		a_exp3 = {~feture_map[2][1][31], feture_map[2][1][30:0]};
		a_exp4 = {~feture_map[3][1][31], feture_map[3][1][30:0]};
	end
	else begin
		a_exp1 = feture_map[0][1];
		a_exp2 = feture_map[1][1];
		a_exp3 = feture_map[2][1];
		a_exp4 = feture_map[3][1];
	end
end



//////////////////////////////////////////////////////////
//                       Reciprocol                     //
//////////////////////////////////////////////////////////

always @(*) begin
	if(input_cnt == 235) begin
		b_div1 = feture_map[0][3];
		b_div2 = feture_map[0][3];
		b_div3 = feture_map[0][3];
		b_div4 = feture_map[0][3];
	end
	else if(input_cnt == 236) begin
		b_div1 = feture_map[2][3];
		b_div2 = feture_map[2][3];
		b_div3 = feture_map[2][3];
		b_div4 = feture_map[2][3];
	end
	else if(input_cnt == 242 && !Opt_reg[1]) begin
		b_div1 = Img_reg[0];
		b_div2 = Img_reg[1];
		b_div3 = Img_reg[2];
		b_div4 = Img_reg[3];
	end
	else if(input_cnt == 243 && !Opt_reg[1]) begin
		b_div1 = Img_reg[4];
		b_div2 = Img_reg[5];
		b_div3 = Img_reg[6];
		b_div4 = Img_reg[7];
	end
	else if(input_cnt == 243 && Opt_reg[1]) begin
		b_div1 = Img_reg[0];
		b_div2 = Img_reg[1];
		b_div3 = Img_reg[2];
		b_div4 = Img_reg[3];
	end
	else if(input_cnt == 245 && Opt_reg[1]) begin
		b_div1 = Img_reg[8];
		b_div2 = Img_reg[9];
		b_div3 = Img_reg[10];
		b_div4 = Img_reg[11];
	end
	else begin
		b_div1 = 0;
		b_div2 = 0;
		b_div3 = 0;
		b_div4 = 0;
	end
end

always @(*) begin
	if(input_cnt == 235) begin
		a_div1 = feture_map[0][0];
		a_div2 = feture_map[1][0];
		a_div3 = feture_map[2][0];
		a_div4 = feture_map[3][0];
	end
	else if(input_cnt == 236) begin
		a_div1 = feture_map[0][1];
		a_div2 = feture_map[1][1];
		a_div3 = feture_map[2][1];
		a_div4 = feture_map[3][1];
	end
	else if(input_cnt == 242 && !Opt_reg[1]) begin
		a_div1 = 32'b00111111100000000000000000000000;;
		a_div2 = 32'b00111111100000000000000000000000;;
		a_div3 = 32'b00111111100000000000000000000000;;
		a_div4 = 32'b00111111100000000000000000000000;;
	end
	else if(input_cnt == 243 && !Opt_reg[1]) begin
		a_div1 = 32'b00111111100000000000000000000000;;
		a_div2 = 32'b00111111100000000000000000000000;;
		a_div3 = 32'b00111111100000000000000000000000;;
		a_div4 = 32'b00111111100000000000000000000000;;
	end
	else if(input_cnt == 243 && Opt_reg[1]) begin
		a_div1 = Img_reg[4];
		a_div2 = Img_reg[5];
		a_div3 = Img_reg[6];
		a_div4 = Img_reg[7];
	end
	else if(input_cnt == 245 && Opt_reg[1]) begin
		a_div1 = Img_reg[12];
		a_div2 = Img_reg[13];
		a_div3 = Img_reg[14];
		a_div4 = Img_reg[15];
	end
	else begin
		a_div1 = 0;
		a_div2 = 0;
		a_div3 = 0;
		a_div4 = 0;
	end
end



//////////////////////////////////////////////////////////
//                        Pooling                       //
//////////////////////////////////////////////////////////

always @(*) begin

	case(input_cnt)
		85, 193: begin
			a_cmp1 = feture_map[0][0];
			b_cmp1 = feture_map[0][1];
		end
		86, 194: begin
			a_cmp1 = feture_map[0][2];
			b_cmp1 = feture_map[0][3];
		end
		94, 202: begin
			a_cmp1 = result1;
			b_cmp1 = feture_map[1][0];
		end
		95, 203: begin
			a_cmp1 = result1;
			b_cmp1 = feture_map[1][1];
		end
		96, 204: begin
			a_cmp1 = result2;
			b_cmp1 = feture_map[1][2];
		end
		97, 205: begin
			a_cmp1 = result2;
			b_cmp1 = feture_map[1][3];
		end


		103, 211: begin
			a_cmp1 = feture_map[2][0];
			b_cmp1 = feture_map[2][1];
		end
		104, 212: begin
			a_cmp1 = feture_map[2][2];
			b_cmp1 = feture_map[2][3];
		end
		112, 220: begin
			a_cmp1 = result1;
			b_cmp1 = feture_map[3][0];
		end
		113, 221: begin
			a_cmp1 = result1;
			b_cmp1 = feture_map[3][1];
		end
		114, 222: begin
			a_cmp1 = result2;
			b_cmp1 = feture_map[3][2];
		end
		115, 223: begin
			a_cmp1 = result2;
			b_cmp1 = feture_map[3][3];
		end

		225: begin
			a_cmp1 = feture_map[0][0];
			b_cmp1 = feture_map[1][0];
		end
		226: begin
			a_cmp1 = result1;
			b_cmp1 = result3;
		end
		228: begin
			a_cmp1 = feture_map[0][1];
			b_cmp1 = feture_map[1][1];
		end
		229: begin
			a_cmp1 = result1;
			b_cmp1 = result3;
		end

		default: begin
			a_cmp1 = 0;
			b_cmp1 = 0;
		end

	endcase

end

always @(*) begin

	case(input_cnt)

		225: begin
			a_cmp2 = feture_map[2][0];
			b_cmp2 = feture_map[3][0];
		end
		226: begin
			a_cmp2 = result2;
			b_cmp2 = result4;
		end
		228: begin
			a_cmp2 = feture_map[2][1];
			b_cmp2 = feture_map[3][1];
		end
		229: begin
			a_cmp2 = result2;
			b_cmp2 = result4;
		end

		default: begin
			a_cmp2 = 0;
			b_cmp2 = 0;
		end

	endcase

end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		result1 <= 0;
		result2 <= 0;
		result3 <= 0;
		result4 <= 0;
	end
	else begin
		case(input_cnt)
			85, 193: result1 <= Max1;
			86, 194: result2 <= Max1;
			94, 202: result1 <= Max1;
			95, 203: result1 <= Max1;
			96, 204: result2 <= Max1;
			97, 205: result2 <= Max1;

			103, 211: result1 <= Max1;
			104, 212: result2 <= Max1;
			112, 220: result1 <= Max1;
			113, 221: result1 <= Max1;
			114, 222: result2 <= Max1;
			115, 223: result2 <= Max1;

			225: begin
				result1 <= Max1;
				result2 <= Min1;
				result3 <= Max2;
				result4 <= Min2;
			end
			226: begin
				result1 <= Max1; /* Find x_max of first map */
				result2 <= Min2; /* Find x_min of first map */
			end
			228: begin
				result1 <= Max1;
				result2 <= Min1;
				result3 <= Max2;
				result4 <= Min2;
			end
			229: begin
				result1 <= Max1; /* Find x_max of second map */
				result2 <= Min2; /* Find x_min of second map */
			end

		endcase
	end

end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(n = 0; n < 4; n = n + 1) begin
			for(m = 0; m < 4; m = m + 1) begin
				pooling[0][n][m] <= 0;
				pooling[1][n][m] <= 0;
			end
		end
	end
	else begin
	case(input_cnt)

		96: pooling[0][0][0] <= result1;
		98: pooling[0][0][1] <= result2;
		114: pooling[0][1][0] <= result1;
		116: pooling[0][1][1] <= result2;
		
		204: pooling[1][0][0] <= result1;
		206: pooling[1][0][1] <= result2;
		222: pooling[1][1][0] <= result1;
		224: pooling[1][1][1] <= result2;
		
	endcase
	end
end

//////////////////////////////////////////////////////////
//                     Convolution                      //
//////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(n = 0; n < 5; n = n + 1) begin
			for(m = 0; m < 5; m = m + 1) begin
				feture_map[n][m] <= 0;
			end
		end
	end
	else begin
		if(input_cnt < 220) begin
			if(conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) begin
				if(nine_cycle_cnt == 1 /*&& img_cnt == 0*/) begin
					feture_map[0][0] <= z_add1;
					feture_map[0][1] <= z_add2;
					feture_map[0][2] <= z_add3;
					feture_map[0][3] <= z_add4;
				end
				else if(nine_cycle_cnt == 2 /*&& img_cnt == 0*/) begin
					feture_map[1][0] <= z_add1;
					feture_map[1][1] <= z_add2;
					feture_map[1][2] <= z_add3;
					feture_map[1][3] <= z_add4;
				end
				else if(nine_cycle_cnt == 3 /*&& img_cnt == 0*/) begin
					feture_map[2][0] <= z_add1;
					feture_map[2][1] <= z_add2;
					feture_map[2][2] <= z_add3;
					feture_map[2][3] <= z_add4;
				end
				else if(nine_cycle_cnt == 0 /*&& img_cnt == 1*/) begin
					feture_map[3][0] <= z_add1;
					feture_map[3][1] <= z_add2;
					feture_map[3][2] <= z_add3;
					feture_map[3][3] <= z_add4;
				end
			end
			else if(img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) begin
				for(n = 0; n < 5; n = n + 1) begin
					for(m = 0; m < 5; m = m + 1) begin
						feture_map[n][m] <= 0;
					end
				end
			end
		end
		else if(input_cnt == 222) begin
			feture_map[0][0] <= z_mac1;
			feture_map[1][0] <= z_mac2;
			feture_map[2][0] <= z_mac3;
			feture_map[3][0] <= z_mac4; /* flatten map1 after matrix mult */
		end
		else if(input_cnt == 227) begin
			feture_map[0][1] <= z_mac1;
			feture_map[1][1] <= z_mac2;
			feture_map[2][1] <= z_mac3;
			feture_map[3][1] <= z_mac4; /* flatten map2 after matrix mult */

			feture_map[0][2] <= result1; /* x_max of map 1 */
			feture_map[1][2] <= {~result2[31], result2[30:0]}; /* x_min of map 1 */
		end
		else if(input_cnt == 230) begin
			feture_map[2][2] <= result1; /* x_max of map 2 */
			feture_map[3][2] <= {~result2[31], result2[30:0]}; /* x_min of map 2 */
		end
		else if(input_cnt == 228) begin
			feture_map[0][0] <= z_add1;
			feture_map[1][0] <= z_add2;
			feture_map[2][0] <= z_add3;
			feture_map[3][0] <= z_add4; /* 分子 of map1 */
		end
		else if(input_cnt == 231) begin
			feture_map[0][1] <= z_add1;
			feture_map[1][1] <= z_add2;
			feture_map[2][1] <= z_add3;
			feture_map[3][1] <= z_add4; /* 分子 of map2 */
		end	
		else if(input_cnt == 232) begin
			feture_map[0][3] <= z_add1; /* 分母 of map1 */
			feture_map[2][3] <= z_add2; /* 分母 of map2 */
		end
		// else if(input_cnt == 233) begin
		// 	feture_map[0][3] <= z_recip1;
		// 	feture_map[2][3] <= z_recip2;
		// end
		else if(input_cnt == 235) begin
			feture_map[0][0] <= z_div1;
			feture_map[1][0] <= z_div2;
			feture_map[2][0] <= z_div3;
			feture_map[3][0] <= z_div4;
		end
		else if(input_cnt == 236) begin
			feture_map[0][1] <= z_div1;
			feture_map[1][1] <= z_div2;
			feture_map[2][1] <= z_div3;
			feture_map[3][1] <= z_div4;
		end
		else if(input_cnt == 237) begin
			feture_map[0][2] <= z_exp1;
			feture_map[1][2] <= z_exp2;
			feture_map[2][2] <= z_exp3;
			feture_map[3][2] <= z_exp4;
		end
		else if(input_cnt == 238) begin
			feture_map[0][3] <= z_exp1;
			feture_map[1][3] <= z_exp2;
			feture_map[2][3] <= z_exp3;
			feture_map[3][3] <= z_exp4;
		end
		else if(input_cnt == 239) begin
			feture_map[0][0] <= z_exp1;
			feture_map[1][0] <= z_exp2;
			feture_map[2][0] <= z_exp3;
			feture_map[3][0] <= z_exp4;
		end
		else if(input_cnt == 240) begin
			feture_map[0][1] <= z_exp1;
			feture_map[1][1] <= z_exp2;
			feture_map[2][1] <= z_exp3;
			feture_map[3][1] <= z_exp4;
		end
		else if(!Opt_reg[1] && input_cnt == 246 || Opt_reg[1] && input_cnt == 248) begin
			for(n = 0; n < 5; n = n + 1) begin
				for(m = 0; m < 5; m = m + 1) begin
					feture_map[n][m] <= 0;
			end
		end
		end

	end
end

always @(*) begin
	if(input_cnt < 220) begin
		a_add1 = z_mac1;
		a_add2 = z_mac2;
		a_add3 = z_mac3;
		a_add4 = z_mac4;
	end
	else if(input_cnt == 228) begin
		a_add1 = feture_map[0][0];
		a_add2 = feture_map[1][0];
		a_add3 = feture_map[2][0];
		a_add4 = feture_map[3][0];
	end
	else if(input_cnt == 231) begin
		a_add1 = feture_map[0][1];
		a_add2 = feture_map[1][1];
		a_add3 = feture_map[2][1];
		a_add4 = feture_map[3][1];
	end
	else if(input_cnt == 232) begin
		a_add1 = feture_map[0][2];
		a_add2 = feture_map[2][2];
		a_add3 = 0;
		a_add4 = 0;
	end
	else if(input_cnt == 241 && !Opt_reg[1]) begin
		a_add1 = feture_map[0][3];
		a_add2 = feture_map[1][3];
		a_add3 = feture_map[2][3];
		a_add4 = feture_map[3][3];
	end
	else if(input_cnt == 242 && !Opt_reg[1]) begin
		a_add1 = feture_map[0][1];
		a_add2 = feture_map[1][1];
		a_add3 = feture_map[2][1];
		a_add4 = feture_map[3][1];
	end
	else if(input_cnt == 241 && Opt_reg[1]) begin
		a_add1 = feture_map[0][2];
		a_add2 = feture_map[1][2];
		a_add3 = feture_map[2][2];
		a_add4 = feture_map[3][2];
	end
	else if(input_cnt == 242 && Opt_reg[1]) begin
		a_add1 = feture_map[0][2];
		a_add2 = feture_map[1][2];
		a_add3 = feture_map[2][2];
		a_add4 = feture_map[3][2];
	end

	else if(input_cnt == 243 && Opt_reg[1]) begin
		a_add1 = feture_map[0][0];
		a_add2 = feture_map[1][0];
		a_add3 = feture_map[2][0];
		a_add4 = feture_map[3][0];
	end
	else if(input_cnt == 244 && Opt_reg[1]) begin
		a_add1 = feture_map[0][0];
		a_add2 = feture_map[1][0];
		a_add3 = feture_map[2][0];
		a_add4 = feture_map[3][0];
	end

	else if(input_cnt == 244 && !Opt_reg[1]) begin
		a_add1 = Img_reg[0];
		a_add2 = Img_reg[1];
		a_add3 = Img_reg[2];
		a_add4 = Img_reg[3];
	end
	else if(input_cnt == 245 && !Opt_reg[1]) begin
		a_add1 = {1'b0, Img_reg[0][30:0]};
		a_add2 = {1'b0, Img_reg[1][30:0]};
		a_add3 = 0;
		a_add4 = 0;
	end
	else if(input_cnt == 246 && !Opt_reg[1]) begin
		a_add1 = {1'b0, Img_reg[0][30:0]};
		a_add2 = 0;
		a_add3 = 0;
		a_add4 = 0;
	end
	else if(input_cnt == 246 && Opt_reg[1]) begin
		a_add1 = Img_reg[0];
		a_add2 = Img_reg[1];
		a_add3 = Img_reg[2];
		a_add4 = Img_reg[3];
	end
	else if(input_cnt == 247 && Opt_reg[1]) begin
		a_add1 = {1'b0, Img_reg[0][30:0]};
		a_add2 = {1'b0, Img_reg[1][30:0]};
		a_add3 = 0;
		a_add4 = 0;
	end
	else if(input_cnt == 248 && Opt_reg[1]) begin
		a_add1 = {1'b0, Img_reg[0][30:0]};
		a_add2 = 0;
		a_add3 = 0;
		a_add4 = 0;
	end
	else begin
		a_add1 = 0;
		a_add2 = 0;
		a_add3 = 0;
		a_add4 = 0;
	end
end

always @(*) begin
	if(input_cnt < 220) begin
		if(nine_cycle_cnt == 1 /*&& img_cnt == 0*/) begin
			b_add1 = feture_map[0][0];
			b_add2 = feture_map[0][1];
			b_add3 = feture_map[0][2];
			b_add4 = feture_map[0][3];
		end
		else if(nine_cycle_cnt == 2 /*&& img_cnt == 0*/) begin
			b_add1 = feture_map[1][0];
			b_add2 = feture_map[1][1];
			b_add3 = feture_map[1][2];
			b_add4 = feture_map[1][3];
		end
		else if(nine_cycle_cnt == 3 /*&& img_cnt == 0*/) begin
			b_add1 = feture_map[2][0];
			b_add2 = feture_map[2][1];
			b_add3 = feture_map[2][2];
			b_add4 = feture_map[2][3];
		end
		else if(nine_cycle_cnt == 0 /*&& img_cnt == 1*/) begin
			b_add1 = feture_map[3][0];
			b_add2 = feture_map[3][1];
			b_add3 = feture_map[3][2];
			b_add4 = feture_map[3][3];
		end
		else begin
			b_add1 = 0;
			b_add2 = 0;
			b_add3 = 0;
			b_add4 = 0;
		end
	end
	else if(input_cnt == 228) begin
		b_add1 = feture_map[1][2];
		b_add2 = feture_map[1][2];
		b_add3 = feture_map[1][2];
		b_add4 = feture_map[1][2];
	end
	else if(input_cnt == 231) begin
		b_add1 = feture_map[3][2];
		b_add2 = feture_map[3][2];
		b_add3 = feture_map[3][2];
		b_add4 = feture_map[3][2];
	end	
	else if(input_cnt == 232) begin
		b_add1 = feture_map[1][2];
		b_add2 = feture_map[3][2];
		b_add3 = 0;
		b_add4 = 0;
	end
	else if(input_cnt == 241 && !Opt_reg[1]) begin
		b_add1 = 32'b00111111100000000000000000000000;
		b_add2 = 32'b00111111100000000000000000000000;
		b_add3 = 32'b00111111100000000000000000000000;
		b_add4 = 32'b00111111100000000000000000000000;
	end
	else if(input_cnt == 242 && !Opt_reg[1]) begin
		b_add1 = 32'b00111111100000000000000000000000;
		b_add2 = 32'b00111111100000000000000000000000;
		b_add3 = 32'b00111111100000000000000000000000;
		b_add4 = 32'b00111111100000000000000000000000;
	end
	else if(input_cnt == 241 && Opt_reg[1]) begin
		b_add1 = feture_map[0][3];
		b_add2 = feture_map[1][3];
		b_add3 = feture_map[2][3];
		b_add4 = feture_map[3][3];
	end
	else if(input_cnt == 242 && Opt_reg[1]) begin
		b_add1 = {~feture_map[0][3][31], feture_map[0][3][30:0]};
		b_add2 = {~feture_map[1][3][31], feture_map[1][3][30:0]};
		b_add3 = {~feture_map[2][3][31], feture_map[2][3][30:0]};
		b_add4 = {~feture_map[3][3][31], feture_map[3][3][30:0]};
	end
	else if(input_cnt == 243 && Opt_reg[1]) begin
		b_add1 = feture_map[0][1];
		b_add2 = feture_map[1][1];
		b_add3 = feture_map[2][1];
		b_add4 = feture_map[3][1];
	end
	else if(input_cnt == 244 && Opt_reg[1]) begin
		b_add1 = {~feture_map[0][1][31], feture_map[0][1][30:0]};
		b_add2 = {~feture_map[1][1][31], feture_map[1][1][30:0]};
		b_add3 = {~feture_map[2][1][31], feture_map[2][1][30:0]};
		b_add4 = {~feture_map[3][1][31], feture_map[3][1][30:0]};
	end
	else if(input_cnt == 244 && !Opt_reg[1]) begin
		b_add1 = {~Img_reg[4][31], Img_reg[4][30:0]};
		b_add2 = {~Img_reg[5][31], Img_reg[5][30:0]};
		b_add3 = {~Img_reg[6][31], Img_reg[6][30:0]};
		b_add4 = {~Img_reg[7][31], Img_reg[7][30:0]};
	end
	else if(input_cnt == 245 && !Opt_reg[1]) begin
		b_add1 = {1'b0, Img_reg[2][30:0]};
		b_add2 = {1'b0, Img_reg[3][30:0]};
		b_add3 = 0;
		b_add4 = 0;
	end
	else if(input_cnt == 246 && !Opt_reg[1]) begin
		b_add1 = {1'b0, Img_reg[1][30:0]};
		b_add2 = 0;
		b_add3 = 0;
		b_add4 = 0;
	end
	else if(input_cnt == 246 && Opt_reg[1]) begin
		b_add1 = {~Img_reg[8][31], Img_reg[8][30:0]};
		b_add2 = {~Img_reg[9][31], Img_reg[9][30:0]};
		b_add3 = {~Img_reg[10][31], Img_reg[10][30:0]};
		b_add4 = {~Img_reg[11][31], Img_reg[11][30:0]};
	end
	else if(input_cnt == 247 && Opt_reg[1]) begin
		b_add1 = {1'b0, Img_reg[2][30:0]};
		b_add2 = {1'b0, Img_reg[3][30:0]};
		b_add3 = 0;
		b_add4 = 0;
	end
	else if(input_cnt == 248 && Opt_reg[1]) begin
		b_add1 = {1'b0, Img_reg[1][30:0]};
		b_add2 = 0;
		b_add3 = 0;
		b_add4 = 0;
	end
	else begin
		b_add1 = 0;
		b_add2 = 0;
		b_add3 = 0;
		b_add4 = 0;
	end


		
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		a_mac1 <= 0;
	else begin
		if(input_cnt < 219) begin
			case(conv_cnt)
				0: a_mac1 <= Image_group[img_cnt][nine_cycle_cnt + 0][0];
				1: a_mac1 <= Image_group[img_cnt][nine_cycle_cnt + 0][1];
				2: a_mac1 <= Image_group[img_cnt][nine_cycle_cnt + 0][2];
				3: a_mac1 <= Image_group[img_cnt][nine_cycle_cnt + 1][0];
				4: a_mac1 <= Image_group[img_cnt][nine_cycle_cnt + 1][1];
				5: a_mac1 <= Image_group[img_cnt][nine_cycle_cnt + 1][2];
				6: a_mac1 <= Image_group[img_cnt][nine_cycle_cnt + 2][0];
				7: a_mac1 <= Image_group[img_cnt][nine_cycle_cnt + 2][1];
				8: a_mac1 <= Image_group[img_cnt][nine_cycle_cnt + 2][2];
			endcase
		end
		else if(input_cnt == 220) 
			a_mac1 <= pooling[0][0][0];
		else if(input_cnt == 221) 
			a_mac1 <= pooling[0][0][1];
		else if(input_cnt == 225) 
			a_mac1 <= pooling[1][0][0];
		else if(input_cnt == 226) 
			a_mac1 <= pooling[1][0][1];
		// else if(input_cnt == 234)  /* receive x_scaled */
		// 	a_mac1 <= feture_map[0][0];
		// else if(input_cnt == 235) 
		// 	a_mac1 <= feture_map[0][1];
		// else if(input_cnt == 242 && Opt_reg[1]) 
		// 	a_mac1 <= z_recip1;
		// else if(input_cnt == 244 && Opt_reg[1]) 
		// 	a_mac1 <= z_recip1;
		else
			a_mac1 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		a_mac2 <= 0;
	else begin
		if(input_cnt < 219) begin
			case(conv_cnt)
				0: a_mac2 <= Image_group[img_cnt][nine_cycle_cnt + 0][1];
				1: a_mac2 <= Image_group[img_cnt][nine_cycle_cnt + 0][2];
				2: a_mac2 <= Image_group[img_cnt][nine_cycle_cnt + 0][3];
				3: a_mac2 <= Image_group[img_cnt][nine_cycle_cnt + 1][1];
				4: a_mac2 <= Image_group[img_cnt][nine_cycle_cnt + 1][2];
				5: a_mac2 <= Image_group[img_cnt][nine_cycle_cnt + 1][3];
				6: a_mac2 <= Image_group[img_cnt][nine_cycle_cnt + 2][1];
				7: a_mac2 <= Image_group[img_cnt][nine_cycle_cnt + 2][2];
				8: a_mac2 <= Image_group[img_cnt][nine_cycle_cnt + 2][3];
			endcase
		end
		else if(input_cnt == 220) 
			a_mac2 <= pooling[0][0][0];
		else if(input_cnt == 221) 
			a_mac2 <= pooling[0][0][1];
		else if(input_cnt == 225) 
			a_mac2 <= pooling[1][0][0];
		else if(input_cnt == 226) 
			a_mac2 <= pooling[1][0][1];
		// else if(input_cnt == 234) 
		// 	a_mac2 <= feture_map[1][0];
		// else if(input_cnt == 235) 
		// 	a_mac2 <= feture_map[1][1];
		// else if(input_cnt == 242 && Opt_reg[1]) 
		// 	a_mac2 <= z_recip2;
		// else if(input_cnt == 244 && Opt_reg[1]) 
		// 	a_mac2 <= z_recip2;
		else
			a_mac2 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		a_mac3 <= 0;
	else begin
		if(input_cnt < 219) begin
			case(conv_cnt)
				0: a_mac3 <= Image_group[img_cnt][nine_cycle_cnt + 0][2];
				1: a_mac3 <= Image_group[img_cnt][nine_cycle_cnt + 0][3];
				2: a_mac3 <= Image_group[img_cnt][nine_cycle_cnt + 0][4];
				3: a_mac3 <= Image_group[img_cnt][nine_cycle_cnt + 1][2];
				4: a_mac3 <= Image_group[img_cnt][nine_cycle_cnt + 1][3];
				5: a_mac3 <= Image_group[img_cnt][nine_cycle_cnt + 1][4];
				6: a_mac3 <= Image_group[img_cnt][nine_cycle_cnt + 2][2];
				7: a_mac3 <= Image_group[img_cnt][nine_cycle_cnt + 2][3];
				8: a_mac3 <= Image_group[img_cnt][nine_cycle_cnt + 2][4];
			endcase
		end
		else if(input_cnt == 220) 
			a_mac3 <= pooling[0][1][0];
		else if(input_cnt == 221) 
			a_mac3 <= pooling[0][1][1];
		else if(input_cnt == 225) 
			a_mac3 <= pooling[1][1][0];
		else if(input_cnt == 226) 
			a_mac3 <= pooling[1][1][1];
		// else if(input_cnt == 234) 
		// 	a_mac3 <= feture_map[2][0];
		// else if(input_cnt == 235) 
		// 	a_mac3 <= feture_map[2][1];
		// else if(input_cnt == 242 && Opt_reg[1]) 
		// 	a_mac3 <= z_recip3;
		// else if(input_cnt == 244 && Opt_reg[1]) 
		// 	a_mac3 <= z_recip3;
		else
			a_mac3 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		a_mac4 <= 0;
	else begin
		if(input_cnt < 219) begin
			case(conv_cnt)
				0: a_mac4 <= Image_group[img_cnt][nine_cycle_cnt + 0][3];
				1: a_mac4 <= Image_group[img_cnt][nine_cycle_cnt + 0][4];
				2: a_mac4 <= Image_group[img_cnt][nine_cycle_cnt + 0][5];
				3: a_mac4 <= Image_group[img_cnt][nine_cycle_cnt + 1][3];
				4: a_mac4 <= Image_group[img_cnt][nine_cycle_cnt + 1][4];
				5: a_mac4 <= Image_group[img_cnt][nine_cycle_cnt + 1][5];
				6: a_mac4 <= Image_group[img_cnt][nine_cycle_cnt + 2][3];
				7: a_mac4 <= Image_group[img_cnt][nine_cycle_cnt + 2][4];
				8: a_mac4 <= Image_group[img_cnt][nine_cycle_cnt + 2][5];
			endcase
		end
		else if(input_cnt == 220) 
			a_mac4 <= pooling[0][1][0];
		else if(input_cnt == 221) 
			a_mac4 <= pooling[0][1][1];
		else if(input_cnt == 225) 
			a_mac4 <= pooling[1][1][0];
		else if(input_cnt == 226) 
			a_mac4 <= pooling[1][1][1];
		// else if(input_cnt == 234) 
		// 	a_mac4 <= feture_map[3][0];
		// else if(input_cnt == 235) 
		// 	a_mac4 <= feture_map[3][1];
		// else if(input_cnt == 242 && Opt_reg[1]) 
		// 	a_mac4 <= z_recip4;
		// else if(input_cnt == 244 && Opt_reg[1]) 
		// 	a_mac4 <= z_recip4;
		else
			a_mac4 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		b_mac1 <= 0;
	else begin
		if(input_cnt < 219) begin
			case(conv_cnt)
				0: b_mac1 <= Kernel_sel[0];
				1: b_mac1 <= Kernel_sel[1];
				2: b_mac1 <= Kernel_sel[2];
				3: b_mac1 <= Kernel_sel[3];
				4: b_mac1 <= Kernel_sel[4];
				5: b_mac1 <= Kernel_sel[5];
				6: b_mac1 <= Kernel_sel[6]; 
				7: b_mac1 <= Kernel_sel[7];
				8: b_mac1 <= Kernel_sel[8];
			endcase
		end
		else if(input_cnt == 220 || input_cnt == 225) 
			b_mac1 <= Weight_reg[0];
		else if(input_cnt == 221 || input_cnt == 226) 
			b_mac1 <=  Weight_reg[2];
		// else if(input_cnt == 234) 
		// 	b_mac1 <= feture_map[0][3];
		// else if(input_cnt == 235) 
		// 	b_mac1 <= feture_map[2][3];
		else if(input_cnt == 242 && Opt_reg[1]) 
			b_mac1 <= z_add1;
		else if(input_cnt == 244 && Opt_reg[1]) 
			b_mac1 <= z_add1;
		else
			b_mac1 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		b_mac2 <= 0;
	else begin
		if(input_cnt < 219) begin
			case(conv_cnt)
				0: b_mac2 <= Kernel_sel[0];
				1: b_mac2 <= Kernel_sel[1];
				2: b_mac2 <= Kernel_sel[2];
				3: b_mac2 <= Kernel_sel[3];
				4: b_mac2 <= Kernel_sel[4];
				5: b_mac2 <= Kernel_sel[5];
				6: b_mac2 <= Kernel_sel[6]; 
				7: b_mac2 <= Kernel_sel[7];
				8: b_mac2 <= Kernel_sel[8];
			endcase
		end
		else if(input_cnt == 220 || input_cnt == 225) 
			b_mac2 <= Weight_reg[1];
		else if(input_cnt == 221 || input_cnt == 226) 
			b_mac2 <=  Weight_reg[3];
		// else if(input_cnt == 234) 
		// 	b_mac2 <= feture_map[0][3];
		// else if(input_cnt == 235) 
		// 	b_mac2 <= feture_map[2][3];
		else if(input_cnt == 242 && Opt_reg[1]) 
			b_mac2 <= z_add2;
		else if(input_cnt == 244 && Opt_reg[1]) 
			b_mac2 <= z_add2;
		else
			b_mac2 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		b_mac3 <= 0;
	else begin
		if(input_cnt < 219) begin
			case(conv_cnt)
				0: b_mac3 <= Kernel_sel[0];
				1: b_mac3 <= Kernel_sel[1];
				2: b_mac3 <= Kernel_sel[2];
				3: b_mac3 <= Kernel_sel[3];
				4: b_mac3 <= Kernel_sel[4];
				5: b_mac3 <= Kernel_sel[5];
				6: b_mac3 <= Kernel_sel[6]; 
				7: b_mac3 <= Kernel_sel[7];
				8: b_mac3 <= Kernel_sel[8];
			endcase
		end
		else if(input_cnt == 220 || input_cnt == 225) 
			b_mac3 <= Weight_reg[0];
		else if(input_cnt == 221 || input_cnt == 226) 
			b_mac3 <=  Weight_reg[2];
		// else if(input_cnt == 234) 
		// 	b_mac3 <= feture_map[0][3];
		// else if(input_cnt == 235) 
		// 	b_mac3 <= feture_map[2][3];
		else if(input_cnt == 242 && Opt_reg[1]) 
			b_mac3 <= z_add3;
		else if(input_cnt == 244 && Opt_reg[1]) 
			b_mac3 <= z_add3;
		else
			b_mac3 <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		b_mac4 <= 0;
	else begin
		if(input_cnt < 219) begin
			case(conv_cnt)
				0: b_mac4 <= Kernel_sel[0];
				1: b_mac4 <= Kernel_sel[1];
				2: b_mac4 <= Kernel_sel[2];
				3: b_mac4 <= Kernel_sel[3];
				4: b_mac4 <= Kernel_sel[4];
				5: b_mac4 <= Kernel_sel[5];
				6: b_mac4 <= Kernel_sel[6]; 
				7: b_mac4 <= Kernel_sel[7];
				8: b_mac4 <= Kernel_sel[8];
			endcase
		end
		else if(input_cnt == 220 || input_cnt == 225) 
			b_mac4 <= Weight_reg[1];
		else if(input_cnt == 221 || input_cnt == 226) 
			b_mac4 <=  Weight_reg[3];
		// else if(input_cnt == 234) 
		// 	b_mac4 <= feture_map[0][3];
		// else if(input_cnt == 235) 
		// 	b_mac4 <= feture_map[2][3];
		else if(input_cnt == 242 && Opt_reg[1]) 
			b_mac4 <= z_add4;
		else if(input_cnt == 244 && Opt_reg[1]) 
			b_mac4 <= z_add4;
		else
			b_mac4 <= 0;
	end
end

always @(*) begin

	case(img_cnt)
		0, 3: begin
			for(n = 0; n < 9; n = n + 1) 
				Kernel_sel[n] = Kernel_reg[n];
		end
		1, 4: begin
			for(n = 0; n < 9; n = n + 1) 
				Kernel_sel[n] = Kernel_reg[n+9];
		end
		2, 5: begin
			for(n = 0; n < 9; n = n + 1) 
				Kernel_sel[n] = Kernel_reg[n+18];
		end
		default: begin
			for(n = 0; n < 9; n = n + 1) 
				Kernel_sel[n] = 0;
		end
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		c_mac1 <= 0;
		c_mac2 <= 0;
		c_mac3 <= 0;
		c_mac4 <= 0;
	end
	else begin
		if(input_cnt >= 4 && input_cnt < 219) begin
			if(conv_cnt == 0) begin
				c_mac1 <= 0;
				c_mac2 <= 0;
				c_mac3 <= 0;
				c_mac4 <= 0;
			end
			else begin
				c_mac1 <= z_mac1;
				c_mac2 <= z_mac2;
				c_mac3 <= z_mac3;
				c_mac4 <= z_mac4;
			end
		end
		else if(input_cnt == 220 || input_cnt == 225) begin
			c_mac1 <= 0;
			c_mac2 <= 0;
			c_mac3 <= 0;
			c_mac4 <= 0;
		end
		else if(input_cnt == 221 || input_cnt == 226) begin
			c_mac1 <= z_mac1;
			c_mac2 <= z_mac2;
			c_mac3 <= z_mac3;
			c_mac4 <= z_mac4;
		end
		// else if(input_cnt == 234 || input_cnt == 235) begin
		// 	c_mac1 <= 0;
		// 	c_mac2 <= 0;
		// 	c_mac3 <= 0;
		// 	c_mac4 <= 0;
		// end
		else if(input_cnt == 242 && Opt_reg[1]) begin
			c_mac1 <= 0;
			c_mac2 <= 0;
			c_mac3 <= 0;
			c_mac4 <= 0;
		end
		else if(input_cnt == 244 && Opt_reg[1]) begin
			c_mac1 <= 0;
			c_mac2 <= 0;
			c_mac3 <= 0;
			c_mac4 <= 0;
		end
		else begin
			c_mac1 <= 0;
			c_mac2 <= 0;
			c_mac3 <= 0;
			c_mac4 <= 0;
		end

	end

end

always @(posedge clk or negedge rst_n) begin

	if(!rst_n)
		conv_cnt <= 0;
	else begin
		if(!Opt_reg[1] && input_cnt == 246 || Opt_reg[1] && input_cnt == 248)
			conv_cnt <= 0;
		else if(conv_cnt == 8)
			conv_cnt <= 0;
		else if(input_cnt >= 3)
			conv_cnt <= conv_cnt +1;
	end
end

always @(posedge clk or negedge rst_n) begin

	if(!rst_n)
		nine_cycle_cnt <= 0;
	else begin
		if(!Opt_reg[1] && input_cnt == 246 || Opt_reg[1] && input_cnt == 248)
			nine_cycle_cnt <= 0;
		else if(conv_cnt == 8)
			nine_cycle_cnt <= nine_cycle_cnt +1;

	end
end

always @(posedge clk or negedge rst_n) begin

	if(!rst_n)
		img_cnt <= 0;
	else begin
		if(!Opt_reg[1] && input_cnt == 246 || Opt_reg[1] && input_cnt == 248)
			img_cnt <= 0;
		else if(nine_cycle_cnt == 3 && conv_cnt == 8 && img_cnt < 5)
			img_cnt <= img_cnt +1;

	end
end


//////////////////////////////////////////////////////////
//                       Padding                        //
//////////////////////////////////////////////////////////

generate
	for(k = 0; k < 6; k = k + 1) begin
		for(i = 1; i <= 4; i = i + 1) begin
			for(j = 1; j <= 4; j = j + 1) begin
				always @(*) begin
					Image_group[k][i][j] = Img_reg[16*k + 4*i + j - 5];
				end
			end
		end
	end
endgenerate

generate
	for(k = 0; k < 6; k = k + 1) begin
		always @(*) begin
			Image_group[k][0][0] = Opt_reg[0] ? 0 : Image_group[k][1][1] ;
			Image_group[k][0][1] = Opt_reg[0] ? 0 : Image_group[k][1][1] ;
			Image_group[k][0][2] = Opt_reg[0] ? 0 : Image_group[k][1][2] ;
			Image_group[k][0][3] = Opt_reg[0] ? 0 : Image_group[k][1][3] ;
			Image_group[k][0][4] = Opt_reg[0] ? 0 : Image_group[k][1][4] ;
			Image_group[k][0][5] = Opt_reg[0] ? 0 : Image_group[k][1][4] ;

			Image_group[k][1][0] = Opt_reg[0] ? 0 : Image_group[k][1][1] ;
			Image_group[k][2][0] = Opt_reg[0] ? 0 : Image_group[k][2][1] ;
			Image_group[k][3][0] = Opt_reg[0] ? 0 : Image_group[k][3][1] ;
			Image_group[k][4][0] = Opt_reg[0] ? 0 : Image_group[k][4][1] ;

			Image_group[k][1][5] = Opt_reg[0] ? 0 : Image_group[k][1][4] ;
			Image_group[k][2][5] = Opt_reg[0] ? 0 : Image_group[k][2][4] ;
			Image_group[k][3][5] = Opt_reg[0] ? 0 : Image_group[k][3][4] ;
			Image_group[k][4][5] = Opt_reg[0] ? 0 : Image_group[k][4][4] ;

			Image_group[k][5][0] = Opt_reg[0] ? 0 : Image_group[k][4][1] ;
			Image_group[k][5][1] = Opt_reg[0] ? 0 : Image_group[k][4][1] ;
			Image_group[k][5][2] = Opt_reg[0] ? 0 : Image_group[k][4][2] ;
			Image_group[k][5][3] = Opt_reg[0] ? 0 : Image_group[k][4][3] ;
			Image_group[k][5][4] = Opt_reg[0] ? 0 : Image_group[k][4][4] ;
			Image_group[k][5][5] = Opt_reg[0] ? 0 : Image_group[k][4][4] ;
		end
	end
endgenerate


//////////////////////////////////////////////////////////
//                        INPUT                         //
//////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin

	if(!rst_n)
		input_cnt <= 0;
	else begin
		if(!Opt_reg[1] && input_cnt == 246 || Opt_reg[1] && input_cnt == 248)
			input_cnt <= 0;
		else if(in_valid)
			input_cnt <= input_cnt + 1;
		else if(input_cnt > 0)
			input_cnt <= input_cnt + 1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(n = 0; n < 96; n = n + 1)
			Img_reg[n] <= 32'b0;
	end
	else if(in_valid) 
		Img_reg[input_cnt] <= Img;
	else if(input_cnt == 241 && !Opt_reg[1]) begin /* 1+e^-z of map1 */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
		Img_reg[2] <= z_add3;
		Img_reg[3] <= z_add4;
	end
	else if(input_cnt == 242 && !Opt_reg[1]) begin /* 1+e^-z of map2 */ /* sigmoid of map1 */
		Img_reg[0] <= z_div1;
		Img_reg[1] <= z_div2;
		Img_reg[2] <= z_div3;
		Img_reg[3] <= z_div4;

		Img_reg[4] <= z_add1;
		Img_reg[5] <= z_add2;
		Img_reg[6] <= z_add3;
		Img_reg[7] <= z_add4;
	end
	else if(input_cnt == 243 && !Opt_reg[1]) begin /* sigmoid of map2 */
		Img_reg[4] <= z_div1;
		Img_reg[5] <= z_div2;
		Img_reg[6] <= z_div3;
		Img_reg[7] <= z_div4;
	end
	else if(input_cnt == 241 && Opt_reg[1]) begin /* e^z + e^-z of map1 */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
		Img_reg[2] <= z_add3;
		Img_reg[3] <= z_add4;
	end
	else if(input_cnt == 242 && Opt_reg[1]) begin /* e^z - e^-z of map1 */ /* (e^z + e^-z)^-1 of map1 */
		Img_reg[4] <= z_add1;
		Img_reg[5] <= z_add2;
		Img_reg[6] <= z_add3;
		Img_reg[7] <= z_add4;
	end
	else if(input_cnt == 243 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z + e^-z of map2 */
		Img_reg[0] <= z_div1;
		Img_reg[1] <= z_div2;
		Img_reg[2] <= z_div3;
		Img_reg[3] <= z_div4;

		Img_reg[8] <= z_add1;
		Img_reg[9] <= z_add2;
		Img_reg[10] <= z_add3;
		Img_reg[11] <= z_add4;
	end
	else if(input_cnt == 244 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z - e^-z of map2 */
		Img_reg[12] <= z_add1;
		Img_reg[13] <= z_add2;
		Img_reg[14] <= z_add3;
		Img_reg[15] <= z_add4;
	end
	else if(input_cnt == 245 && Opt_reg[1]) begin /* Tanh of map2 */ 
		Img_reg[8] <= z_div1;
		Img_reg[9] <= z_div2;
		Img_reg[10] <= z_div3;
		Img_reg[11] <= z_div4;
	end
	else if(input_cnt == 244 && !Opt_reg[1]) begin /* diff of map1, 2 */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
		Img_reg[2] <= z_add3;
		Img_reg[3] <= z_add4;
	end
	else if(input_cnt == 245 && !Opt_reg[1]) begin /* abs of sigmoid  */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
	end
	else if(input_cnt == 246 && !Opt_reg[1]) begin /* abs of sigmoid */
		Img_reg[0] <= z_add1;
	end
	else if(input_cnt == 246 && Opt_reg[1]) begin /* diff of map1, 2 */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
		Img_reg[2] <= z_add3;
		Img_reg[3] <= z_add4;
	end
	else if(input_cnt == 247 && Opt_reg[1]) begin /* abs of Tanh */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
	end
	else if(input_cnt == 248 && Opt_reg[1]) begin /* abs of Tanh */
		Img_reg[0] <= z_add1;
	end

end

generate
	for(i = 0; i < 27; i = i + 1) begin

		always @(posedge clk or negedge rst_n) begin
			if(!rst_n) 
                Kernel_reg[i] <= 32'b0;
			else if(input_cnt == i && in_valid) 
                Kernel_reg[i] <= Kernel;
			else 
                Kernel_reg[i] <= Kernel_reg[i];
		end
	end
endgenerate

generate
	for(i = 0; i < 4; i = i + 1) begin

		always @(posedge clk or negedge rst_n) begin
			if(!rst_n) 
                Weight_reg[i] <= 32'b0;
			else if(input_cnt == i && in_valid) 
                Weight_reg[i] <= Weight;
			else 
                Weight_reg[i] <= Weight_reg[i];
		end
	end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        Opt_reg <= 0;
    else begin
        if(input_cnt == 0 && in_valid) 
            Opt_reg <= Opt;
		else
            Opt_reg <= Opt_reg;
    end
end


DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) mac1 ( .a(a_mac1), .b(b_mac1), .c(c_mac1), .rnd(round), .z(z_mac1),.status(status_mac1) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) mac2 ( .a(a_mac2), .b(b_mac2), .c(c_mac2), .rnd(round), .z(z_mac2),.status(status_mac2) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) mac3 ( .a(a_mac3), .b(b_mac3), .c(c_mac3), .rnd(round), .z(z_mac3),.status(status_mac3) );
DW_fp_mac #(inst_sig_width, inst_exp_width, inst_ieee_compliance) mac4 ( .a(a_mac4), .b(b_mac4), .c(c_mac4), .rnd(round), .z(z_mac4),.status(status_mac4) );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) add1 ( .a(a_add1), .b(b_add1), .rnd(round), .z(z_add1), .status(status_add1) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) add2 ( .a(a_add2), .b(b_add2), .rnd(round), .z(z_add2), .status(status_add2) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) add3 ( .a(a_add3), .b(b_add3), .rnd(round), .z(z_add3), .status(status_add3) );
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) add4 ( .a(a_add4), .b(b_add4), .rnd(round), .z(z_add4), .status(status_add4) );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) cmp1 ( .a(a_cmp1), .b(b_cmp1), .zctr(1'b1), .aeqb(aeqb_cmp1), 
														.altb(altb_cmp1), .agtb(agtb_cmp1), .unordered(unordered_cmp1), 
														.z0(Max1), .z1(Min1), .status0(status0_cmp1), 
														.status1(status1_cmp1) );
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance) cmp2 ( .a(a_cmp2), .b(b_cmp2), .zctr(1'b1), .aeqb(aeqb_cmp2), 
														.altb(altb_cmp2), .agtb(agtb_cmp2), .unordered(unordered_cmp2), 
														.z0(Max2), .z1(Min2), .status0(status0_cmp2), 
														.status1(status1_cmp2) );

// DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) recip1 (.a(a_recip1),.rnd(round),.z(z_recip1),.status(status_recip1) );
// DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) recip2 (.a(a_recip2),.rnd(round),.z(z_recip2),.status(status_recip2) );
// DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) recip3 (.a(a_recip3),.rnd(round),.z(z_recip3),.status(status_recip3) );
// DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) recip4 (.a(a_recip4),.rnd(round),.z(z_recip4),.status(status_recip4) );

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) div1 ( .a(a_div1), .b(b_div1), .rnd(round), .z(z_div1));
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) div2 ( .a(a_div2), .b(b_div2), .rnd(round), .z(z_div2)) ;
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) div3 ( .a(a_div3), .b(b_div3), .rnd(round), .z(z_div3)) ;
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) div4 ( .a(a_div4), .b(b_div4), .rnd(round), .z(z_div4));


DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp1 (.a(a_exp1),.z(z_exp1),.status(status_exp1) );
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp2 (.a(a_exp2),.z(z_exp2),.status(status_exp2) );
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp3 (.a(a_exp3),.z(z_exp3),.status(status_exp3) );
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp4 (.a(a_exp4),.z(z_exp4),.status(status_exp4) );




//synopsys dc_script_begin
//set_implementation rtl mac1 
//set_implementation rtl mac2 
//set_implementation rtl mac3 
//set_implementation rtl mac4 
//set_implementation rtl add1 
//set_implementation rtl add2 
//set_implementation rtl add3 
//set_implementation rtl add4
//set_implementation rtl cmp1
//set_implementation rtl cmp2
//set_implementation rtl div1 
//set_implementation rtl div2
//set_implementation rtl div3 
//set_implementation rtl div4
//set_implementation rtl exp1
//set_implementation rtl exp2
//set_implementation rtl exp3
//set_implementation rtl exp4
//synopsys dc_script_end

endmodule
