
// synopsys translate_off
`ifdef RTL
	`include "GATED_OR.v"
`else
	`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on


module SNN(
    //Input Port
    clk,
    rst_n,
    cg_en,
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
input cg_en;

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
reg [inst_sig_width+inst_exp_width:0] a_div1, a_div2, a_div3, a_div4, a_div5;
reg [inst_sig_width+inst_exp_width:0] b_div1, b_div2, b_div3, b_div4, b_div5;
reg [inst_sig_width+inst_exp_width:0] z_div1, z_div2, z_div3, z_div4, z_div5;
reg [7:0] status_div1, status_div2, status_div3, status_div4;
reg [inst_sig_width+inst_exp_width:0] a_exp1, a_exp2, a_exp3, a_exp4;
reg [inst_sig_width+inst_exp_width:0] z_exp1, z_exp2, z_exp3, z_exp4;
reg [inst_sig_width+inst_exp_width:0] a_sum3_1, a_sum3_2, a_sum3_3, a_sum3_4;
reg [inst_sig_width+inst_exp_width:0] b_sum3_1, b_sum3_2, b_sum3_3, b_sum3_4;
reg [inst_sig_width+inst_exp_width:0] c_sum3_1, c_sum3_2, c_sum3_3, c_sum3_4;
reg [inst_sig_width+inst_exp_width:0] z_sum3_1, z_sum3_2, z_sum3_3, z_sum3_4;
reg [inst_sig_width+inst_exp_width:0] sum_9_out;
wire [7:0] status_exp1, status_exp2, status_exp3, status_exp4;

reg [1:0] Opt_reg;
reg [inst_sig_width+inst_exp_width:0] Img_reg [0:95];
reg [inst_sig_width+inst_exp_width:0] Kernel_reg [0:26];
reg [inst_sig_width+inst_exp_width:0] Weight_reg [0:3];
reg [inst_sig_width+inst_exp_width:0] Image_group [0:5] [0:5] [0:5];
reg [inst_sig_width+inst_exp_width:0] Kernel_group [0:2] [0:2] [0:2];
reg [10:0] input_cnt;
reg [3:0] conv_cnt;
reg [1:0] nine_cycle_cnt;
reg [2:0] img_cnt;
reg [inst_sig_width+inst_exp_width:0] Kernel_sel [0:8];
reg [inst_sig_width+inst_exp_width:0] feture_map [0:3] [0:3];

reg [inst_sig_width+inst_exp_width:0] feture_map_0 [0:3] [0:3], new_feture_map_0[0:3] [0:3];
reg [inst_sig_width+inst_exp_width:0] feture_map_1 [0:3] [0:3], new_feture_map_1[0:3] [0:3];

reg [inst_sig_width+inst_exp_width:0] result1, result2, result3, result4;
reg [inst_sig_width+inst_exp_width:0] pooling [0:1] [0:1] [0:1];

reg [inst_sig_width+inst_exp_width:0] padding_feture_map_0 [0:5] [0:5], padding_feture_map_1 [0:5] [0:5];

wire sleep_ctrl_0, sleep_ctrl_1, sleep_ctrl_2, sleep_ctrl_3, sleep_ctrl_4, sleep_ctrl_5, sleep_ctrl_6, sleep_ctrl_7, sleep_ctrl_8, sleep_ctrl_9, sleep_ctrl_10, sleep_ctrl_11, sleep_ctrl_12, sleep_ctrl_13, sleep_ctrl_14;
wire G_clk_0, G_clk_1, G_clk_2, G_clk_3, G_clk_4, G_clk_5, G_clk_6, G_clk_7, G_clk_8, G_clk_9, G_clk_10, G_clk_11, G_clk_12, G_clk_13, G_clk_14;

wire sleep_ctrl_15, sleep_ctrl_16, sleep_ctrl_17, sleep_ctrl_18, sleep_ctrl_19, sleep_ctrl_20, sleep_ctrl_21, sleep_ctrl_22, sleep_ctrl_23, sleep_ctrl_24;
wire G_clk_15, G_clk_16, G_clk_17, G_clk_18, G_clk_19, G_clk_20, G_clk_21, G_clk_22, G_clk_23, G_clk_24;

wire sleep_ctrl_25, sleep_ctrl_26, sleep_ctrl_27, sleep_ctrl_28, sleep_ctrl_29, sleep_ctrl_30;
wire G_clk_25, G_clk_26, G_clk_27, G_clk_28, G_clk_29, G_clk_30;

wire sleep_ctrl_31, sleep_ctrl_32, sleep_ctrl_33, sleep_ctrl_34, sleep_ctrl_35, sleep_ctrl_36, sleep_ctrl_37, sleep_ctrl_38, sleep_ctrl_39;
wire G_clk_31, G_clk_32, G_clk_33, G_clk_34, G_clk_35, G_clk_36, G_clk_37, G_clk_38, G_clk_39;

wire sleep_ctrl_40, sleep_ctrl_41, sleep_ctrl_42, sleep_ctrl_43;
wire G_clk_40, G_clk_41, G_clk_42, G_clk_43;

wire sleep_ctrl_44, sleep_ctrl_45, sleep_ctrl_46, sleep_ctrl_47;
wire G_clk_44, G_clk_45, G_clk_46, G_clk_47;

GATED_OR GATED_0 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_0), .RST_N(rst_n), .CLOCK_GATED(G_clk_0));
GATED_OR GATED_1 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_1), .RST_N(rst_n), .CLOCK_GATED(G_clk_1));
GATED_OR GATED_2 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_2), .RST_N(rst_n), .CLOCK_GATED(G_clk_2));
GATED_OR GATED_3 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_3), .RST_N(rst_n), .CLOCK_GATED(G_clk_3));
GATED_OR GATED_4 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_4), .RST_N(rst_n), .CLOCK_GATED(G_clk_4));
GATED_OR GATED_5 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_5), .RST_N(rst_n), .CLOCK_GATED(G_clk_5));
GATED_OR GATED_6 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_6), .RST_N(rst_n), .CLOCK_GATED(G_clk_6));
GATED_OR GATED_7 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_7), .RST_N(rst_n), .CLOCK_GATED(G_clk_7));
GATED_OR GATED_8 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_8), .RST_N(rst_n), .CLOCK_GATED(G_clk_8));
GATED_OR GATED_9 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_9), .RST_N(rst_n), .CLOCK_GATED(G_clk_9));
GATED_OR GATED_10 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_10), .RST_N(rst_n), .CLOCK_GATED(G_clk_10));
GATED_OR GATED_11 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_11), .RST_N(rst_n), .CLOCK_GATED(G_clk_11));
GATED_OR GATED_12 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_12), .RST_N(rst_n), .CLOCK_GATED(G_clk_12));
GATED_OR GATED_13 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_13), .RST_N(rst_n), .CLOCK_GATED(G_clk_13));
GATED_OR GATED_14 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_14), .RST_N(rst_n), .CLOCK_GATED(G_clk_14));
GATED_OR GATED_15 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_15), .RST_N(rst_n), .CLOCK_GATED(G_clk_15));
GATED_OR GATED_16 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_16), .RST_N(rst_n), .CLOCK_GATED(G_clk_16));
GATED_OR GATED_17 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_17), .RST_N(rst_n), .CLOCK_GATED(G_clk_17));
GATED_OR GATED_18 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_18), .RST_N(rst_n), .CLOCK_GATED(G_clk_18));
GATED_OR GATED_19 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_19), .RST_N(rst_n), .CLOCK_GATED(G_clk_19));
GATED_OR GATED_20 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_20), .RST_N(rst_n), .CLOCK_GATED(G_clk_20));
GATED_OR GATED_21 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_21), .RST_N(rst_n), .CLOCK_GATED(G_clk_21));
GATED_OR GATED_22 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_22), .RST_N(rst_n), .CLOCK_GATED(G_clk_22));
GATED_OR GATED_23 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_23), .RST_N(rst_n), .CLOCK_GATED(G_clk_23));
GATED_OR GATED_24 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_24), .RST_N(rst_n), .CLOCK_GATED(G_clk_24));
GATED_OR GATED_25 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_25), .RST_N(rst_n), .CLOCK_GATED(G_clk_25));
GATED_OR GATED_26 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_26), .RST_N(rst_n), .CLOCK_GATED(G_clk_26));
GATED_OR GATED_27 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_27), .RST_N(rst_n), .CLOCK_GATED(G_clk_27));
GATED_OR GATED_28 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_28), .RST_N(rst_n), .CLOCK_GATED(G_clk_28));
GATED_OR GATED_29 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_29), .RST_N(rst_n), .CLOCK_GATED(G_clk_29));
GATED_OR GATED_30 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_30), .RST_N(rst_n), .CLOCK_GATED(G_clk_30));

GATED_OR GATED_31 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_31), .RST_N(rst_n), .CLOCK_GATED(G_clk_31));
GATED_OR GATED_32 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_32), .RST_N(rst_n), .CLOCK_GATED(G_clk_32));
GATED_OR GATED_33 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_33), .RST_N(rst_n), .CLOCK_GATED(G_clk_33));
GATED_OR GATED_34 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_34), .RST_N(rst_n), .CLOCK_GATED(G_clk_34));
GATED_OR GATED_35 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_35), .RST_N(rst_n), .CLOCK_GATED(G_clk_35));
GATED_OR GATED_36 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_36), .RST_N(rst_n), .CLOCK_GATED(G_clk_36));
GATED_OR GATED_37 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_37), .RST_N(rst_n), .CLOCK_GATED(G_clk_37));
GATED_OR GATED_38 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_38), .RST_N(rst_n), .CLOCK_GATED(G_clk_38));
GATED_OR GATED_39 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_39), .RST_N(rst_n), .CLOCK_GATED(G_clk_39));

GATED_OR GATED_40 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_40), .RST_N(rst_n), .CLOCK_GATED(G_clk_40));
GATED_OR GATED_41 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_41), .RST_N(rst_n), .CLOCK_GATED(G_clk_41));
GATED_OR GATED_42 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_42), .RST_N(rst_n), .CLOCK_GATED(G_clk_42));
GATED_OR GATED_43 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_43), .RST_N(rst_n), .CLOCK_GATED(G_clk_43));

GATED_OR GATED_44 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_44), .RST_N(rst_n), .CLOCK_GATED(G_clk_44));
GATED_OR GATED_45 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_45), .RST_N(rst_n), .CLOCK_GATED(G_clk_45));
GATED_OR GATED_46 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_46), .RST_N(rst_n), .CLOCK_GATED(G_clk_46));
GATED_OR GATED_47 (.CLOCK(clk), .SLEEP_CTRL(sleep_ctrl_47), .RST_N(rst_n), .CLOCK_GATED(G_clk_47));


reg [31:0] temp_out;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		temp_out <= 0;
	end
	else begin
		if(!Opt_reg[1] && input_cnt == 277)
			temp_out <= z_add1;
		else if(Opt_reg[1] && input_cnt == 279)
			temp_out <= z_add1;
	end
end
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out <= 0;
		out_valid <= 0;
	end
	else begin
		// case(Opt_reg[1])
		// 	0: begin
		// 		if(input_cnt == 277) begin
		// 			out_valid <= 1;
		// 			out <= z_add1;
		// 		end
		// 		else begin
		// 			out_valid <= 0;
		// 			out <= 0;
		// 		end

		// 	end
		// 	1: begin
		// 		if(input_cnt == 279) begin
		// 			out_valid <= 1;
		// 			out <= z_add1;
		// 		end
		// 		else begin
		// 			out_valid <= 0;
		// 			out <= 0;
		// 		end
		// 	end
		// endcase

		if(input_cnt == 1093) begin
			out_valid <= 1;
			out <= temp_out;
		end
		else begin
			out <= 0;
			out_valid <= 0;
		end

	end
end

//////////////////////////////////////////////////////////
//                          sum3                        //
//////////////////////////////////////////////////////////

always @(*) begin

    a_sum3_1 = 0;
    b_sum3_1 = 0;
    c_sum3_1 = 0;

    case(input_cnt)
        113:begin
            a_sum3_1 = padding_feture_map_0[0][0];
            b_sum3_1 = padding_feture_map_0[0][1];
            c_sum3_1 = padding_feture_map_0[0][2];
        end
        114:begin
            a_sum3_1 = padding_feture_map_0[0][1];
            b_sum3_1 = padding_feture_map_0[0][2];
            c_sum3_1 = padding_feture_map_0[0][3];
        end
        115:begin
            a_sum3_1 = padding_feture_map_0[0][2];
            b_sum3_1 = padding_feture_map_0[0][3];
            c_sum3_1 = padding_feture_map_0[0][4];
        end
        116:begin
            a_sum3_1 = padding_feture_map_0[0][3];
            b_sum3_1 = padding_feture_map_0[0][4];
            c_sum3_1 = padding_feture_map_0[0][5];
        end
        117:begin
            a_sum3_1 = padding_feture_map_0[1][0];
            b_sum3_1 = padding_feture_map_0[1][1];
            c_sum3_1 = padding_feture_map_0[1][2];
        end
        118:begin
            a_sum3_1 = padding_feture_map_0[1][1];
            b_sum3_1 = padding_feture_map_0[1][2];
            c_sum3_1 = padding_feture_map_0[1][3];
        end
        119:begin
            a_sum3_1 = padding_feture_map_0[1][2];
            b_sum3_1 = padding_feture_map_0[1][3];
            c_sum3_1 = padding_feture_map_0[1][4];
        end
        120:begin
            a_sum3_1 = padding_feture_map_0[1][3];
            b_sum3_1 = padding_feture_map_0[1][4];
            c_sum3_1 = padding_feture_map_0[1][5];
        end
        121:begin
            a_sum3_1 = padding_feture_map_0[2][0];
            b_sum3_1 = padding_feture_map_0[2][1];
            c_sum3_1 = padding_feture_map_0[2][2];
        end
        122:begin
            a_sum3_1 = padding_feture_map_0[2][1];
            b_sum3_1 = padding_feture_map_0[2][2];
            c_sum3_1 = padding_feture_map_0[2][3];
        end
        123:begin
            a_sum3_1 = padding_feture_map_0[2][2];
            b_sum3_1 = padding_feture_map_0[2][3];
            c_sum3_1 = padding_feture_map_0[2][4];
        end
        124:begin
            a_sum3_1 = padding_feture_map_0[2][3];
            b_sum3_1 = padding_feture_map_0[2][4];
            c_sum3_1 = padding_feture_map_0[2][5];
        end
        125:begin
            a_sum3_1 = padding_feture_map_0[3][0];
            b_sum3_1 = padding_feture_map_0[3][1];
            c_sum3_1 = padding_feture_map_0[3][2];
        end
        126:begin
            a_sum3_1 = padding_feture_map_0[3][1];
            b_sum3_1 = padding_feture_map_0[3][2];
            c_sum3_1 = padding_feture_map_0[3][3];
        end
        127:begin
            a_sum3_1 = padding_feture_map_0[3][2];
            b_sum3_1 = padding_feture_map_0[3][3];
            c_sum3_1 = padding_feture_map_0[3][4];
        end
        128:begin
            a_sum3_1 = padding_feture_map_0[3][3];
            b_sum3_1 = padding_feture_map_0[3][4];
            c_sum3_1 = padding_feture_map_0[3][5];
        end


        221:begin
            a_sum3_1 = padding_feture_map_1[0][0];
            b_sum3_1 = padding_feture_map_1[0][1];
            c_sum3_1 = padding_feture_map_1[0][2];
        end
        222:begin
            a_sum3_1 = padding_feture_map_1[0][1];
            b_sum3_1 = padding_feture_map_1[0][2];
            c_sum3_1 = padding_feture_map_1[0][3];
        end
        223:begin
            a_sum3_1 = padding_feture_map_1[0][2];
            b_sum3_1 = padding_feture_map_1[0][3];
            c_sum3_1 = padding_feture_map_1[0][4];
        end
        224:begin
            a_sum3_1 = padding_feture_map_1[0][3];
            b_sum3_1 = padding_feture_map_1[0][4];
            c_sum3_1 = padding_feture_map_1[0][5];
        end
        225:begin
            a_sum3_1 = padding_feture_map_1[1][0];
            b_sum3_1 = padding_feture_map_1[1][1];
            c_sum3_1 = padding_feture_map_1[1][2];
        end
        226:begin
            a_sum3_1 = padding_feture_map_1[1][1];
            b_sum3_1 = padding_feture_map_1[1][2];
            c_sum3_1 = padding_feture_map_1[1][3];
        end
        227:begin
            a_sum3_1 = padding_feture_map_1[1][2];
            b_sum3_1 = padding_feture_map_1[1][3];
            c_sum3_1 = padding_feture_map_1[1][4];
        end
        228:begin
            a_sum3_1 = padding_feture_map_1[1][3];
            b_sum3_1 = padding_feture_map_1[1][4];
            c_sum3_1 = padding_feture_map_1[1][5];
        end
        229:begin
            a_sum3_1 = padding_feture_map_1[2][0];
            b_sum3_1 = padding_feture_map_1[2][1];
            c_sum3_1 = padding_feture_map_1[2][2];
        end
        230:begin
            a_sum3_1 = padding_feture_map_1[2][1];
            b_sum3_1 = padding_feture_map_1[2][2];
            c_sum3_1 = padding_feture_map_1[2][3];
        end
        231:begin
            a_sum3_1 = padding_feture_map_1[2][2];
            b_sum3_1 = padding_feture_map_1[2][3];
            c_sum3_1 = padding_feture_map_1[2][4];
        end
        232:begin
            a_sum3_1 = padding_feture_map_1[2][3];
            b_sum3_1 = padding_feture_map_1[2][4];
            c_sum3_1 = padding_feture_map_1[2][5];
        end
        233:begin
            a_sum3_1 = padding_feture_map_1[3][0];
            b_sum3_1 = padding_feture_map_1[3][1];
            c_sum3_1 = padding_feture_map_1[3][2];
        end
        234:begin
            a_sum3_1 = padding_feture_map_1[3][1];
            b_sum3_1 = padding_feture_map_1[3][2];
            c_sum3_1 = padding_feture_map_1[3][3];
        end
        235:begin
            a_sum3_1 = padding_feture_map_1[3][2];
            b_sum3_1 = padding_feture_map_1[3][3];
            c_sum3_1 = padding_feture_map_1[3][4];
        end
        236:begin
            a_sum3_1 = padding_feture_map_1[3][3];
            b_sum3_1 = padding_feture_map_1[3][4];
            c_sum3_1 = padding_feture_map_1[3][5];
        end
    endcase
end

always @(*) begin

    a_sum3_2 = 0;
    b_sum3_2 = 0;
    c_sum3_2 = 0;

    case(input_cnt)
        113:begin
            a_sum3_2 = padding_feture_map_0[1][0];
            b_sum3_2 = padding_feture_map_0[1][1];
            c_sum3_2 = padding_feture_map_0[1][2];
        end
        114:begin
            a_sum3_2 = padding_feture_map_0[1][1];
            b_sum3_2 = padding_feture_map_0[1][2];
            c_sum3_2 = padding_feture_map_0[1][3];
        end
        115:begin
            a_sum3_2 = padding_feture_map_0[1][2];
            b_sum3_2 = padding_feture_map_0[1][3];
            c_sum3_2 = padding_feture_map_0[1][4];
        end
        116:begin
            a_sum3_2 = padding_feture_map_0[1][3];
            b_sum3_2 = padding_feture_map_0[1][4];
            c_sum3_2 = padding_feture_map_0[1][5];
        end
        117:begin
            a_sum3_2 = padding_feture_map_0[2][0];
            b_sum3_2 = padding_feture_map_0[2][1];
            c_sum3_2 = padding_feture_map_0[2][2];
        end
        118:begin
            a_sum3_2 = padding_feture_map_0[2][1];
            b_sum3_2 = padding_feture_map_0[2][2];
            c_sum3_2 = padding_feture_map_0[2][3];
        end
        119:begin
            a_sum3_2 = padding_feture_map_0[2][2];
            b_sum3_2 = padding_feture_map_0[2][3];
            c_sum3_2 = padding_feture_map_0[2][4];
        end
        120:begin
            a_sum3_2 = padding_feture_map_0[2][3];
            b_sum3_2 = padding_feture_map_0[2][4];
            c_sum3_2 = padding_feture_map_0[2][5];
        end
        121:begin
            a_sum3_2 = padding_feture_map_0[3][0];
            b_sum3_2 = padding_feture_map_0[3][1];
            c_sum3_2 = padding_feture_map_0[3][2];
        end
        122:begin
            a_sum3_2 = padding_feture_map_0[3][1];
            b_sum3_2 = padding_feture_map_0[3][2];
            c_sum3_2 = padding_feture_map_0[3][3];
        end
        123:begin
            a_sum3_2 = padding_feture_map_0[3][2];
            b_sum3_2 = padding_feture_map_0[3][3];
            c_sum3_2 = padding_feture_map_0[3][4];
        end
        124:begin
            a_sum3_2 = padding_feture_map_0[3][3];
            b_sum3_2 = padding_feture_map_0[3][4];
            c_sum3_2 = padding_feture_map_0[3][5];
        end
        125:begin
            a_sum3_2 = padding_feture_map_0[4][0];
            b_sum3_2 = padding_feture_map_0[4][1];
            c_sum3_2 = padding_feture_map_0[4][2];
        end
        126:begin
            a_sum3_2 = padding_feture_map_0[4][1];
            b_sum3_2 = padding_feture_map_0[4][2];
            c_sum3_2 = padding_feture_map_0[4][3];
        end
        127:begin
            a_sum3_2 = padding_feture_map_0[4][2];
            b_sum3_2 = padding_feture_map_0[4][3];
            c_sum3_2 = padding_feture_map_0[4][4];
        end
        128:begin
            a_sum3_2 = padding_feture_map_0[4][3];
            b_sum3_2 = padding_feture_map_0[4][4];
            c_sum3_2 = padding_feture_map_0[4][5];
        end


        221:begin
            a_sum3_2 = padding_feture_map_1[1][0];
            b_sum3_2 = padding_feture_map_1[1][1];
            c_sum3_2 = padding_feture_map_1[1][2];
        end
        222:begin
            a_sum3_2 = padding_feture_map_1[1][1];
            b_sum3_2 = padding_feture_map_1[1][2];
            c_sum3_2 = padding_feture_map_1[1][3];
        end
        223:begin
            a_sum3_2 = padding_feture_map_1[1][2];
            b_sum3_2 = padding_feture_map_1[1][3];
            c_sum3_2 = padding_feture_map_1[1][4];
        end
        224:begin
            a_sum3_2 = padding_feture_map_1[1][3];
            b_sum3_2 = padding_feture_map_1[1][4];
            c_sum3_2 = padding_feture_map_1[1][5];
        end
        225:begin
            a_sum3_2 = padding_feture_map_1[2][0];
            b_sum3_2 = padding_feture_map_1[2][1];
            c_sum3_2 = padding_feture_map_1[2][2];
        end
        226:begin
            a_sum3_2 = padding_feture_map_1[2][1];
            b_sum3_2 = padding_feture_map_1[2][2];
            c_sum3_2 = padding_feture_map_1[2][3];
        end
        227:begin
            a_sum3_2 = padding_feture_map_1[2][2];
            b_sum3_2 = padding_feture_map_1[2][3];
            c_sum3_2 = padding_feture_map_1[2][4];
        end
        228:begin
            a_sum3_2 = padding_feture_map_1[2][3];
            b_sum3_2 = padding_feture_map_1[2][4];
            c_sum3_2 = padding_feture_map_1[2][5];
        end
        229:begin
            a_sum3_2 = padding_feture_map_1[3][0];
            b_sum3_2 = padding_feture_map_1[3][1];
            c_sum3_2 = padding_feture_map_1[3][2];
        end
        230:begin
            a_sum3_2 = padding_feture_map_1[3][1];
            b_sum3_2 = padding_feture_map_1[3][2];
            c_sum3_2 = padding_feture_map_1[3][3];
        end
        231:begin
            a_sum3_2 = padding_feture_map_1[3][2];
            b_sum3_2 = padding_feture_map_1[3][3];
            c_sum3_2 = padding_feture_map_1[3][4];
        end
        232:begin
            a_sum3_2 = padding_feture_map_1[3][3];
            b_sum3_2 = padding_feture_map_1[3][4];
            c_sum3_2 = padding_feture_map_1[3][5];
        end
        233:begin
            a_sum3_2 = padding_feture_map_1[4][0];
            b_sum3_2 = padding_feture_map_1[4][1];
            c_sum3_2 = padding_feture_map_1[4][2];
        end
        234:begin
            a_sum3_2 = padding_feture_map_1[4][1];
            b_sum3_2 = padding_feture_map_1[4][2];
            c_sum3_2 = padding_feture_map_1[4][3];
        end
        235:begin
            a_sum3_2 = padding_feture_map_1[4][2];
            b_sum3_2 = padding_feture_map_1[4][3];
            c_sum3_2 = padding_feture_map_1[4][4];
        end
        236:begin
            a_sum3_2 = padding_feture_map_1[4][3];
            b_sum3_2 = padding_feture_map_1[4][4];
            c_sum3_2 = padding_feture_map_1[4][5];
        end
    endcase
end

always @(*) begin

    a_sum3_3 = 0;
    b_sum3_3 = 0;
    c_sum3_3 = 0;

    case(input_cnt)
        113:begin
            a_sum3_3 = padding_feture_map_0[2][0];
            b_sum3_3 = padding_feture_map_0[2][1];
            c_sum3_3 = padding_feture_map_0[2][2];
        end
        114:begin
            a_sum3_3 = padding_feture_map_0[2][1];
            b_sum3_3 = padding_feture_map_0[2][2];
            c_sum3_3 = padding_feture_map_0[2][3];
        end
        115:begin
            a_sum3_3 = padding_feture_map_0[2][2];
            b_sum3_3 = padding_feture_map_0[2][3];
            c_sum3_3 = padding_feture_map_0[2][4];
        end
        116:begin
            a_sum3_3 = padding_feture_map_0[2][3];
            b_sum3_3 = padding_feture_map_0[2][4];
            c_sum3_3 = padding_feture_map_0[2][5];
        end
        117:begin
            a_sum3_3 = padding_feture_map_0[3][0];
            b_sum3_3 = padding_feture_map_0[3][1];
            c_sum3_3 = padding_feture_map_0[3][2];
        end
        118:begin
            a_sum3_3 = padding_feture_map_0[3][1];
            b_sum3_3 = padding_feture_map_0[3][2];
            c_sum3_3 = padding_feture_map_0[3][3];
        end
        119:begin
            a_sum3_3 = padding_feture_map_0[3][2];
            b_sum3_3 = padding_feture_map_0[3][3];
            c_sum3_3 = padding_feture_map_0[3][4];
        end
        120:begin
            a_sum3_3 = padding_feture_map_0[3][3];
            b_sum3_3 = padding_feture_map_0[3][4];
            c_sum3_3 = padding_feture_map_0[3][5];
        end
        121:begin
            a_sum3_3 = padding_feture_map_0[4][0];
            b_sum3_3 = padding_feture_map_0[4][1];
            c_sum3_3 = padding_feture_map_0[4][2];
        end
        122:begin
            a_sum3_3 = padding_feture_map_0[4][1];
            b_sum3_3 = padding_feture_map_0[4][2];
            c_sum3_3 = padding_feture_map_0[4][3];
        end
        123:begin
            a_sum3_3 = padding_feture_map_0[4][2];
            b_sum3_3 = padding_feture_map_0[4][3];
            c_sum3_3 = padding_feture_map_0[4][4];
        end
        124:begin
            a_sum3_3 = padding_feture_map_0[4][3];
            b_sum3_3 = padding_feture_map_0[4][4];
            c_sum3_3 = padding_feture_map_0[4][5];
        end
        125:begin
            a_sum3_3 = padding_feture_map_0[5][0];
            b_sum3_3 = padding_feture_map_0[5][1];
            c_sum3_3 = padding_feture_map_0[5][2];
        end
        126:begin
            a_sum3_3 = padding_feture_map_0[5][1];
            b_sum3_3 = padding_feture_map_0[5][2];
            c_sum3_3 = padding_feture_map_0[5][3];
        end
        127:begin
            a_sum3_3 = padding_feture_map_0[5][2];
            b_sum3_3 = padding_feture_map_0[5][3];
            c_sum3_3 = padding_feture_map_0[5][4];
        end
        128:begin
            a_sum3_3 = padding_feture_map_0[5][3];
            b_sum3_3 = padding_feture_map_0[5][4];
            c_sum3_3 = padding_feture_map_0[5][5];
        end



        221:begin
            a_sum3_3 = padding_feture_map_1[2][0];
            b_sum3_3 = padding_feture_map_1[2][1];
            c_sum3_3 = padding_feture_map_1[2][2];
        end
        222:begin
            a_sum3_3 = padding_feture_map_1[2][1];
            b_sum3_3 = padding_feture_map_1[2][2];
            c_sum3_3 = padding_feture_map_1[2][3];
        end
        223:begin
            a_sum3_3 = padding_feture_map_1[2][2];
            b_sum3_3 = padding_feture_map_1[2][3];
            c_sum3_3 = padding_feture_map_1[2][4];
        end
        224:begin
            a_sum3_3 = padding_feture_map_1[2][3];
            b_sum3_3 = padding_feture_map_1[2][4];
            c_sum3_3 = padding_feture_map_1[2][5];
        end
        225:begin
            a_sum3_3 = padding_feture_map_1[3][0];
            b_sum3_3 = padding_feture_map_1[3][1];
            c_sum3_3 = padding_feture_map_1[3][2];
        end
        226:begin
            a_sum3_3 = padding_feture_map_1[3][1];
            b_sum3_3 = padding_feture_map_1[3][2];
            c_sum3_3 = padding_feture_map_1[3][3];
        end
        227:begin
            a_sum3_3 = padding_feture_map_1[3][2];
            b_sum3_3 = padding_feture_map_1[3][3];
            c_sum3_3 = padding_feture_map_1[3][4];
        end
        228:begin
            a_sum3_3 = padding_feture_map_1[3][3];
            b_sum3_3 = padding_feture_map_1[3][4];
            c_sum3_3 = padding_feture_map_1[3][5];
        end
        229:begin
            a_sum3_3 = padding_feture_map_1[4][0];
            b_sum3_3 = padding_feture_map_1[4][1];
            c_sum3_3 = padding_feture_map_1[4][2];
        end
        230:begin
            a_sum3_3 = padding_feture_map_1[4][1];
            b_sum3_3 = padding_feture_map_1[4][2];
            c_sum3_3 = padding_feture_map_1[4][3];
        end
        231:begin
            a_sum3_3 = padding_feture_map_1[4][2];
            b_sum3_3 = padding_feture_map_1[4][3];
            c_sum3_3 = padding_feture_map_1[4][4];
        end
        232:begin
            a_sum3_3 = padding_feture_map_1[4][3];
            b_sum3_3 = padding_feture_map_1[4][4];
            c_sum3_3 = padding_feture_map_1[4][5];
        end
        233:begin
            a_sum3_3 = padding_feture_map_1[5][0];
            b_sum3_3 = padding_feture_map_1[5][1];
            c_sum3_3 = padding_feture_map_1[5][2];
        end
        234:begin
            a_sum3_3 = padding_feture_map_1[5][1];
            b_sum3_3 = padding_feture_map_1[5][2];
            c_sum3_3 = padding_feture_map_1[5][3];
        end
        235:begin
            a_sum3_3 = padding_feture_map_1[5][2];
            b_sum3_3 = padding_feture_map_1[5][3];
            c_sum3_3 = padding_feture_map_1[5][4];
        end
        236:begin
            a_sum3_3 = padding_feture_map_1[5][3];
            b_sum3_3 = padding_feture_map_1[5][4];
            c_sum3_3 = padding_feture_map_1[5][5];
        end
    endcase
end

always @(*) begin
    a_sum3_4 = z_sum3_1;
    b_sum3_4 = z_sum3_2;
    c_sum3_4 = z_sum3_3;
end

// SLEEP_0
assign sleep_ctrl_0 = cg_en && !(input_cnt >= 113 && input_cnt <= 128 || input_cnt >= 221 && input_cnt <= 236);

always @(posedge G_clk_0 or negedge rst_n) begin
    if(!rst_n)
        sum_9_out <= 0;
    else begin
        if(input_cnt >= 113 && input_cnt <= 128 || input_cnt >= 221 && input_cnt <= 236)
            sum_9_out <= z_sum3_4;
    end
end

//////////////////////////////////////////////////////////
//                          ?????                       //
//////////////////////////////////////////////////////////


// SLEEP_1 // !TEST
assign sleep_ctrl_1 = cg_en && !(input_cnt == 1093 || input_cnt == 112);

always @(posedge G_clk_1 or negedge rst_n) begin
    if(!rst_n) begin
        feture_map_0[0][0] <= 0;
        feture_map_0[0][1] <= 0;
        feture_map_0[0][2] <= 0;
        feture_map_0[0][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            feture_map_0[0][0] <= 0;
            feture_map_0[0][1] <= 0;
            feture_map_0[0][2] <= 0;
            feture_map_0[0][3] <= 0;
        end
        case(input_cnt)
            112: begin
                feture_map_0[0][0] <= feture_map[0][0];
                feture_map_0[0][1] <= feture_map[0][1];
                feture_map_0[0][2] <= feture_map[0][2];
                feture_map_0[0][3] <= feture_map[0][3];
            end
        endcase
    end
end

// SLEEP_37
assign sleep_ctrl_37 = cg_en && !(input_cnt == 1093 || input_cnt == 112);

always @(posedge G_clk_37 or negedge rst_n) begin
    if(!rst_n) begin
        feture_map_0[1][0] <= 0;
        feture_map_0[1][1] <= 0;
        feture_map_0[1][2] <= 0;
        feture_map_0[1][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            feture_map_0[1][0] <= 0;
            feture_map_0[1][1] <= 0;
            feture_map_0[1][2] <= 0;
            feture_map_0[1][3] <= 0;
        end

        case(input_cnt)
            112: begin
                feture_map_0[1][0] <= feture_map[1][0];
                feture_map_0[1][1] <= feture_map[1][1];
                feture_map_0[1][2] <= feture_map[1][2];
                feture_map_0[1][3] <= feture_map[1][3];
            end
        endcase
    end
end

// SLEEP_38
assign sleep_ctrl_38 = cg_en && !(input_cnt == 1093 || input_cnt == 112);

always @(posedge G_clk_38 or negedge rst_n) begin
    if(!rst_n) begin
        feture_map_0[2][0] <= 0;
        feture_map_0[2][1] <= 0;
        feture_map_0[2][2] <= 0;
        feture_map_0[2][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            feture_map_0[2][0] <= 0;
            feture_map_0[2][1] <= 0;
            feture_map_0[2][2] <= 0;
            feture_map_0[2][3] <= 0;
        end

        case(input_cnt)
            112: begin
                feture_map_0[2][0] <= feture_map[2][0];
                feture_map_0[2][1] <= feture_map[2][1];
                feture_map_0[2][2] <= feture_map[2][2];
                feture_map_0[2][3] <= feture_map[2][3];
            end
        endcase
    end
end

// SLEEP_39 
assign sleep_ctrl_39 = cg_en && !(input_cnt == 1093 || input_cnt == 112);

always @(posedge G_clk_39 or negedge rst_n) begin
    if(!rst_n) begin
        feture_map_0[3][0] <= 0;
        feture_map_0[3][1] <= 0;
        feture_map_0[3][2] <= 0;
        feture_map_0[3][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            feture_map_0[3][0] <= 0;
            feture_map_0[3][1] <= 0;
            feture_map_0[3][2] <= 0;
            feture_map_0[3][3] <= 0;
        end

        case(input_cnt)
            112: begin
                feture_map_0[3][0] <= feture_map[3][0];
                feture_map_0[3][1] <= feture_map[3][1];
                feture_map_0[3][2] <= feture_map[3][2];
                feture_map_0[3][3] <= feture_map[3][3];
            end
        endcase
    end
end

always @(*) begin
    for(n = 0; n <= 3; n = n + 1) begin
        for(m = 0; m <= 3; m = m + 1) begin
            padding_feture_map_0[n+1][m+1] = feture_map_0[n][m];
        end
    end

    padding_feture_map_0[0][0] = (Opt_reg[0]) ? 0 : feture_map_0[0][0] ; // bit 0 is 1: zero

    padding_feture_map_0[0][1] = (Opt_reg[0]) ? 0 : feture_map_0[0][0] ;
    padding_feture_map_0[0][2] = (Opt_reg[0]) ? 0 : feture_map_0[0][1] ;
    padding_feture_map_0[0][3] = (Opt_reg[0]) ? 0 : feture_map_0[0][2] ;
    padding_feture_map_0[0][4] = (Opt_reg[0]) ? 0 : feture_map_0[0][3] ;

    padding_feture_map_0[0][5] = (Opt_reg[0]) ? 0 : feture_map_0[0][3] ;

    padding_feture_map_0[5][0] = (Opt_reg[0]) ? 0 : feture_map_0[3][0] ;

    padding_feture_map_0[5][1] = (Opt_reg[0]) ? 0 : feture_map_0[3][0] ;
    padding_feture_map_0[5][2] = (Opt_reg[0]) ? 0 : feture_map_0[3][1] ;
    padding_feture_map_0[5][3] = (Opt_reg[0]) ? 0 : feture_map_0[3][2] ;
    padding_feture_map_0[5][4] = (Opt_reg[0]) ? 0 : feture_map_0[3][3] ;

    padding_feture_map_0[5][5] = (Opt_reg[0]) ? 0 : feture_map_0[3][3] ;

    padding_feture_map_0[1][0] = (Opt_reg[0]) ? 0 : feture_map_0[0][0] ;
    padding_feture_map_0[2][0] = (Opt_reg[0]) ? 0 : feture_map_0[1][0] ;
    padding_feture_map_0[3][0] = (Opt_reg[0]) ? 0 : feture_map_0[2][0] ;
    padding_feture_map_0[4][0] = (Opt_reg[0]) ? 0 : feture_map_0[3][0] ;

    padding_feture_map_0[1][5] = (Opt_reg[0]) ? 0 : feture_map_0[0][3] ;
    padding_feture_map_0[2][5] = (Opt_reg[0]) ? 0 : feture_map_0[1][3] ;
    padding_feture_map_0[3][5] = (Opt_reg[0]) ? 0 : feture_map_0[2][3] ;
    padding_feture_map_0[4][5] = (Opt_reg[0]) ? 0 : feture_map_0[3][3] ;

end

// SLEEP_2 // !TEST
assign sleep_ctrl_2 = cg_en && !(input_cnt == 1093 || (input_cnt >= 114 && input_cnt <= 117));

always @(posedge G_clk_2 or negedge rst_n) begin
    if(!rst_n) begin
        new_feture_map_0[0][0] <= 0;
        new_feture_map_0[0][1] <= 0;
        new_feture_map_0[0][2] <= 0;
        new_feture_map_0[0][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            new_feture_map_0[0][0] <= 0;
            new_feture_map_0[0][1] <= 0;
            new_feture_map_0[0][2] <= 0;
            new_feture_map_0[0][3] <= 0;
        end
        case(input_cnt)
            114: new_feture_map_0[0][0] <= z_div5;
            115: new_feture_map_0[0][1] <= z_div5;
            116: new_feture_map_0[0][2] <= z_div5;
            117: new_feture_map_0[0][3] <= z_div5;
        endcase
    end
end

// SLEEP_25
assign sleep_ctrl_25 = cg_en && !((input_cnt == 1093) || (input_cnt >= 118 && input_cnt <= 121));

always @(posedge G_clk_25 or negedge rst_n) begin
    if(!rst_n) begin
        new_feture_map_0[1][0] <= 0;
        new_feture_map_0[1][1] <= 0;
        new_feture_map_0[1][2] <= 0;
        new_feture_map_0[1][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            new_feture_map_0[1][0] <= 0;
            new_feture_map_0[1][1] <= 0;
            new_feture_map_0[1][2] <= 0;
            new_feture_map_0[1][3] <= 0;
        end

        case(input_cnt)
            118: new_feture_map_0[1][0] <= z_div5;
            119: new_feture_map_0[1][1] <= z_div5;
            120: new_feture_map_0[1][2] <= z_div5;
            121: new_feture_map_0[1][3] <= z_div5;
        endcase
    end
end

// SLEEP_26 
assign sleep_ctrl_26 = cg_en && !((input_cnt == 1093) || (input_cnt >= 122 && input_cnt <= 125));

always @(posedge G_clk_26 or negedge rst_n) begin
    if(!rst_n) begin
        new_feture_map_0[2][0] <= 0;
        new_feture_map_0[2][1] <= 0;
        new_feture_map_0[2][2] <= 0;
        new_feture_map_0[2][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            new_feture_map_0[2][0] <= 0;
            new_feture_map_0[2][1] <= 0;
            new_feture_map_0[2][2] <= 0;
            new_feture_map_0[2][3] <= 0;
        end
        case(input_cnt)
            122: new_feture_map_0[2][0] <= z_div5;
            123: new_feture_map_0[2][1] <= z_div5;
            124: new_feture_map_0[2][2] <= z_div5;
            125: new_feture_map_0[2][3] <= z_div5;
        endcase
    end
end

// SLEEP_27 
assign sleep_ctrl_27 = cg_en && !((input_cnt == 1093) || (input_cnt >= 126 && input_cnt <= 129));

always @(posedge G_clk_27 or negedge rst_n) begin
    if(!rst_n) begin
        new_feture_map_0[3][0] <= 0;
        new_feture_map_0[3][1] <= 0;
        new_feture_map_0[3][2] <= 0;
        new_feture_map_0[3][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            new_feture_map_0[3][0] <= 0;
            new_feture_map_0[3][1] <= 0;
            new_feture_map_0[3][2] <= 0;
            new_feture_map_0[3][3] <= 0;
        end

        case(input_cnt)
            126: new_feture_map_0[3][0] <= z_div5;
            127: new_feture_map_0[3][1] <= z_div5;
            128: new_feture_map_0[3][2] <= z_div5;
            129: new_feture_map_0[3][3] <= z_div5;
        endcase
    end
end

// SLEEP_3 // !TEST
assign sleep_ctrl_3 = cg_en && !((input_cnt == 1093) || input_cnt == 220);

always @(posedge G_clk_3 or negedge rst_n) begin
    if(!rst_n) begin
        feture_map_1[0][0] <= 0;
        feture_map_1[0][1] <= 0;
        feture_map_1[0][2] <= 0;
        feture_map_1[0][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            feture_map_1[0][0] <= 0;
            feture_map_1[0][1] <= 0;
            feture_map_1[0][2] <= 0;
            feture_map_1[0][3] <= 0;
        end

        case(input_cnt)
            220: begin
                feture_map_1[0][0] <= feture_map[0][0];
                feture_map_1[0][1] <= feture_map[0][1];
                feture_map_1[0][2] <= feture_map[0][2];
                feture_map_1[0][3] <= feture_map[0][3];
            end
        endcase
    end
end

// SLEEP_31
assign sleep_ctrl_31 = cg_en && !((input_cnt == 1093) || input_cnt == 220);

always @(posedge G_clk_31 or negedge rst_n) begin
    if(!rst_n) begin
        feture_map_1[1][0] <= 0;
        feture_map_1[1][1] <= 0;
        feture_map_1[1][2] <= 0;
        feture_map_1[1][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            feture_map_1[1][0] <= 0;
            feture_map_1[1][1] <= 0;
            feture_map_1[1][2] <= 0;
            feture_map_1[1][3] <= 0;
        end

        case(input_cnt)
            220: begin
                feture_map_1[1][0] <= feture_map[1][0];
                feture_map_1[1][1] <= feture_map[1][1];
                feture_map_1[1][2] <= feture_map[1][2];
                feture_map_1[1][3] <= feture_map[1][3];
            end
        endcase
    end
end

// SLEEP_32
assign sleep_ctrl_32 = cg_en && !((input_cnt == 1093) || input_cnt == 220);

always @(posedge G_clk_32 or negedge rst_n) begin
    if(!rst_n) begin
        feture_map_1[2][0] <= 0;
        feture_map_1[2][1] <= 0;
        feture_map_1[2][2] <= 0;
        feture_map_1[2][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            feture_map_1[2][0] <= 0;
            feture_map_1[2][1] <= 0;
            feture_map_1[2][2] <= 0;
            feture_map_1[2][3] <= 0;
        end

        case(input_cnt)
            220: begin
                feture_map_1[2][0] <= feture_map[2][0];
                feture_map_1[2][1] <= feture_map[2][1];
                feture_map_1[2][2] <= feture_map[2][2];
                feture_map_1[2][3] <= feture_map[2][3];
            end
        endcase
    end
end

// SLEEP_33
assign sleep_ctrl_33 = cg_en && !((input_cnt == 1093) || input_cnt == 220);

always @(posedge G_clk_33 or negedge rst_n) begin
    if(!rst_n) begin
        feture_map_1[3][0] <= 0;
        feture_map_1[3][1] <= 0;
        feture_map_1[3][2] <= 0;
        feture_map_1[3][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            feture_map_1[3][0] <= 0;
            feture_map_1[3][1] <= 0;
            feture_map_1[3][2] <= 0;
            feture_map_1[3][3] <= 0;
        end

        case(input_cnt)
            220: begin
                feture_map_1[3][0] <= feture_map[3][0];
                feture_map_1[3][1] <= feture_map[3][1];
                feture_map_1[3][2] <= feture_map[3][2];
                feture_map_1[3][3] <= feture_map[3][3];
            end
        endcase
    end
end

always @(*) begin
    for(n = 0; n <= 3; n = n + 1) begin
        for(m = 0; m <= 3; m = m + 1) begin
            padding_feture_map_1[n+1][m+1] = feture_map_1[n][m];
        end
    end

    padding_feture_map_1[0][0] = (Opt_reg[0]) ? 0 : feture_map[0][0] ; // bit 0 is 1: zero

    padding_feture_map_1[0][1] = (Opt_reg[0]) ? 0 : feture_map_1[0][0] ;
    padding_feture_map_1[0][2] = (Opt_reg[0]) ? 0 : feture_map_1[0][1] ;
    padding_feture_map_1[0][3] = (Opt_reg[0]) ? 0 : feture_map_1[0][2] ;
    padding_feture_map_1[0][4] = (Opt_reg[0]) ? 0 : feture_map_1[0][3] ;

    padding_feture_map_1[0][5] = (Opt_reg[0]) ? 0 : feture_map_1[0][3] ;

    padding_feture_map_1[5][0] = (Opt_reg[0]) ? 0 : feture_map_1[3][0] ;

    padding_feture_map_1[5][1] = (Opt_reg[0]) ? 0 : feture_map_1[3][0] ;
    padding_feture_map_1[5][2] = (Opt_reg[0]) ? 0 : feture_map_1[3][1] ;
    padding_feture_map_1[5][3] = (Opt_reg[0]) ? 0 : feture_map_1[3][2] ;
    padding_feture_map_1[5][4] = (Opt_reg[0]) ? 0 : feture_map_1[3][3] ;

    padding_feture_map_1[5][5] = (Opt_reg[0]) ? 0 : feture_map_1[3][3] ;

    padding_feture_map_1[1][0] = (Opt_reg[0]) ? 0 : feture_map_1[0][0] ;
    padding_feture_map_1[2][0] = (Opt_reg[0]) ? 0 : feture_map_1[1][0] ;
    padding_feture_map_1[3][0] = (Opt_reg[0]) ? 0 : feture_map_1[2][0] ;
    padding_feture_map_1[4][0] = (Opt_reg[0]) ? 0 : feture_map_1[3][0] ;

    padding_feture_map_1[1][5] = (Opt_reg[0]) ? 0 : feture_map_1[0][3] ;
    padding_feture_map_1[2][5] = (Opt_reg[0]) ? 0 : feture_map_1[1][3] ;
    padding_feture_map_1[3][5] = (Opt_reg[0]) ? 0 : feture_map_1[2][3] ;
    padding_feture_map_1[4][5] = (Opt_reg[0]) ? 0 : feture_map_1[3][3] ;
end


// SLEEP_4 // !TEST
assign sleep_ctrl_4 = cg_en && !((input_cnt == 1093) || (input_cnt >= 222 && input_cnt <= 225));

always @(posedge G_clk_4 or negedge rst_n) begin
    if(!rst_n) begin
        new_feture_map_1[0][0] <= 0;
        new_feture_map_1[0][1] <= 0;
        new_feture_map_1[0][2] <= 0;
        new_feture_map_1[0][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            new_feture_map_1[0][0] <= 0;
            new_feture_map_1[0][1] <= 0;
            new_feture_map_1[0][2] <= 0;
            new_feture_map_1[0][3] <= 0;
        end
        
        case(input_cnt)
            222: new_feture_map_1[0][0] <= z_div5;
            223: new_feture_map_1[0][1] <= z_div5;
            224: new_feture_map_1[0][2] <= z_div5;
            225: new_feture_map_1[0][3] <= z_div5;
        endcase
    end
end

// SLEEP_28 
assign sleep_ctrl_28 = cg_en && !((input_cnt == 1093) || (input_cnt >= 226 && input_cnt <= 229));

always @(posedge G_clk_28 or negedge rst_n) begin
    if(!rst_n) begin
        new_feture_map_1[1][0] <= 0;
        new_feture_map_1[1][1] <= 0;
        new_feture_map_1[1][2] <= 0;
        new_feture_map_1[1][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            new_feture_map_1[1][0] <= 0;
            new_feture_map_1[1][1] <= 0;
            new_feture_map_1[1][2] <= 0;
            new_feture_map_1[1][3] <= 0;
        end
        
        case(input_cnt)
            226: new_feture_map_1[1][0] <= z_div5;
            227: new_feture_map_1[1][1] <= z_div5;
            228: new_feture_map_1[1][2] <= z_div5;
            229: new_feture_map_1[1][3] <= z_div5;
        endcase
    end
end

// SLEEP_29 
assign sleep_ctrl_29 = cg_en && !((input_cnt == 1093) || (input_cnt >= 230 && input_cnt <= 233));

always @(posedge G_clk_29 or negedge rst_n) begin
    if(!rst_n) begin
        new_feture_map_1[2][0] <= 0;
        new_feture_map_1[2][1] <= 0;
        new_feture_map_1[2][2] <= 0;
        new_feture_map_1[2][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            new_feture_map_1[2][0] <= 0;
            new_feture_map_1[2][1] <= 0;
            new_feture_map_1[2][2] <= 0;
            new_feture_map_1[2][3] <= 0;
        end
        
        case(input_cnt)
            230: new_feture_map_1[2][0] <= z_div5;
            231: new_feture_map_1[2][1] <= z_div5;
            232: new_feture_map_1[2][2] <= z_div5;
            233: new_feture_map_1[2][3] <= z_div5;
        endcase
    end
end

// SLEEP_30
assign sleep_ctrl_30 = cg_en && !((input_cnt == 1093) || (input_cnt >= 234 && input_cnt <= 237));

always @(posedge G_clk_30 or negedge rst_n) begin
    if(!rst_n) begin
        new_feture_map_1[3][0] <= 0;
        new_feture_map_1[3][1] <= 0;
        new_feture_map_1[3][2] <= 0;
        new_feture_map_1[3][3] <= 0;
    end
    else begin
        if(input_cnt == 1093) begin
            new_feture_map_1[3][0] <= 0;
            new_feture_map_1[3][1] <= 0;
            new_feture_map_1[3][2] <= 0;
            new_feture_map_1[3][3] <= 0;
        end
        
        case(input_cnt)
            234: new_feture_map_1[3][0] <= z_div5;
            235: new_feture_map_1[3][1] <= z_div5;
            236: new_feture_map_1[3][2] <= z_div5;
            237: new_feture_map_1[3][3] <= z_div5;
        endcase
    end
end

//////////////////////////////////////////////////////////
//                         Output                       //
//////////////////////////////////////////////////////////

// SLEEP_5
// assign sleep_ctrl_5 = cg_en && !();

// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) begin
// 		out <= 0;
// 		out_valid <= 0;
// 	end
// 	else begin
// 		case(Opt_reg[1])
// 			0: begin
// 				if(input_cnt == 277) begin
// 					out_valid <= 1;
// 					out <= z_add1;
// 				end
// 				else begin
// 					out_valid <= 0;
// 					out <= 0;
// 				end

// 			end
// 			1: begin
// 				if(input_cnt == 279) begin
// 					out_valid <= 1;
// 					out <= z_add1;
// 				end
// 				else begin
// 					out_valid <= 0;
// 					out <= 0;
// 				end
// 			end
// 		endcase
// 	end
// end


//////////////////////////////////////////////////////////
//                           exp                        //
//////////////////////////////////////////////////////////

always @(*) begin
	if(input_cnt == 268) begin
		a_exp1 = feture_map[0][0];
		a_exp2 = feture_map[1][0];
		a_exp3 = feture_map[2][0];
		a_exp4 = feture_map[3][0];
	end
	else if(input_cnt == 269) begin
		a_exp1 = {~feture_map[0][0][31], feture_map[0][0][30:0]};
		a_exp2 = {~feture_map[1][0][31], feture_map[1][0][30:0]};
		a_exp3 = {~feture_map[2][0][31], feture_map[2][0][30:0]};
		a_exp4 = {~feture_map[3][0][31], feture_map[3][0][30:0]};
	end
	else if(input_cnt == 270) begin
		a_exp1 = feture_map[0][1];
		a_exp2 = feture_map[1][1];
		a_exp3 = feture_map[2][1];
		a_exp4 = feture_map[3][1];
	end
	else if(input_cnt == 271) begin
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

always @(*)begin
    a_div5 = 0;
    if(input_cnt >= 114 && input_cnt <= 129 || input_cnt >= 222 && input_cnt <= 237)
        a_div5 = sum_9_out;
end

always @(*) begin
	if(input_cnt == 266) begin
		b_div1 = feture_map[0][3];
		b_div2 = feture_map[0][3];
		b_div3 = feture_map[0][3];
		b_div4 = feture_map[0][3];
	end
	else if(input_cnt == 267) begin
		b_div1 = feture_map[2][3];
		b_div2 = feture_map[2][3];
		b_div3 = feture_map[2][3];
		b_div4 = feture_map[2][3];
	end
	else if(input_cnt == 273 && !Opt_reg[1]) begin
		b_div1 = Img_reg[0];
		b_div2 = Img_reg[1];
		b_div3 = Img_reg[2];
		b_div4 = Img_reg[3];
	end
	else if(input_cnt == 274 && !Opt_reg[1]) begin
		b_div1 = Img_reg[4];
		b_div2 = Img_reg[5];
		b_div3 = Img_reg[6];
		b_div4 = Img_reg[7];
	end
	else if(input_cnt == 274 && Opt_reg[1]) begin
		b_div1 = Img_reg[0];
		b_div2 = Img_reg[1];
		b_div3 = Img_reg[2];
		b_div4 = Img_reg[3];
	end
	else if(input_cnt == 276 && Opt_reg[1]) begin
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
	if(input_cnt == 266) begin
		a_div1 = feture_map[0][0];
		a_div2 = feture_map[1][0];
		a_div3 = feture_map[2][0];
		a_div4 = feture_map[3][0];
	end
	else if(input_cnt == 267) begin
		a_div1 = feture_map[0][1];
		a_div2 = feture_map[1][1];
		a_div3 = feture_map[2][1];
		a_div4 = feture_map[3][1];
	end
	else if(input_cnt == 273 && !Opt_reg[1]) begin
		a_div1 = 32'b00111111100000000000000000000000;;
		a_div2 = 32'b00111111100000000000000000000000;;
		a_div3 = 32'b00111111100000000000000000000000;;
		a_div4 = 32'b00111111100000000000000000000000;;
	end
	else if(input_cnt == 274 && !Opt_reg[1]) begin
		a_div1 = 32'b00111111100000000000000000000000;;
		a_div2 = 32'b00111111100000000000000000000000;;
		a_div3 = 32'b00111111100000000000000000000000;;
		a_div4 = 32'b00111111100000000000000000000000;;
	end
	else if(input_cnt == 274 && Opt_reg[1]) begin
		a_div1 = Img_reg[4];
		a_div2 = Img_reg[5];
		a_div3 = Img_reg[6];
		a_div4 = Img_reg[7];
	end
	else if(input_cnt == 276 && Opt_reg[1]) begin
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
		130: begin
			a_cmp1 = new_feture_map_0[0][0];
			b_cmp1 = new_feture_map_0[0][1];
		end
		131: begin
			a_cmp1 = new_feture_map_0[0][2];
			b_cmp1 = new_feture_map_0[0][3];
		end
		132: begin
			a_cmp1 = result1;
			b_cmp1 = new_feture_map_0[1][0];
		end
		133: begin
			a_cmp1 = result1;
			b_cmp1 = new_feture_map_0[1][1];
		end
		134: begin
			a_cmp1 = result2;
			b_cmp1 = new_feture_map_0[1][2];
		end
		135: begin
			a_cmp1 = result2;
			b_cmp1 = new_feture_map_0[1][3];
		end




		136: begin
			a_cmp1 = new_feture_map_0[2][0];
			b_cmp1 = new_feture_map_0[2][1];
		end
		137: begin
			a_cmp1 = new_feture_map_0[2][2];
			b_cmp1 = new_feture_map_0[2][3];
		end
		138: begin
			a_cmp1 = result1;
			b_cmp1 = new_feture_map_0[3][0];
		end
		139: begin
			a_cmp1 = result1;
			b_cmp1 = new_feture_map_0[3][1];
		end
		140: begin
			a_cmp1 = result2;
			b_cmp1 = new_feture_map_0[3][2];
		end
		141: begin
			a_cmp1 = result2;
			b_cmp1 = new_feture_map_0[3][3];
		end


		238: begin
			a_cmp1 = new_feture_map_1[0][0];
			b_cmp1 = new_feture_map_1[0][1];
		end
		239: begin
			a_cmp1 = new_feture_map_1[0][2];
			b_cmp1 = new_feture_map_1[0][3];
		end
		240: begin
			a_cmp1 = result1;
			b_cmp1 = new_feture_map_1[1][0];
		end
		241: begin
			a_cmp1 = result1;
			b_cmp1 = new_feture_map_1[1][1];
		end
		242: begin
			a_cmp1 = result2;
			b_cmp1 = new_feture_map_1[1][2];
		end
		243: begin
			a_cmp1 = result2;
			b_cmp1 = new_feture_map_1[1][3];
		end



		244: begin
			a_cmp1 = new_feture_map_1[2][0];
			b_cmp1 = new_feture_map_1[2][1];
		end
		245: begin
			a_cmp1 = new_feture_map_1[2][2];
			b_cmp1 = new_feture_map_1[2][3];
		end
		246: begin
			a_cmp1 = result1;
			b_cmp1 = new_feture_map_1[3][0];
		end
		247: begin
			a_cmp1 = result1;
			b_cmp1 = new_feture_map_1[3][1];
		end
		248: begin
			a_cmp1 = result2;
			b_cmp1 = new_feture_map_1[3][2];
		end
		249: begin
			a_cmp1 = result2;
			b_cmp1 = new_feture_map_1[3][3];
		end



		256: begin
			a_cmp1 = feture_map[0][0];
			b_cmp1 = feture_map[1][0];
		end
		257: begin
			a_cmp1 = result1;
			b_cmp1 = result3;
		end
		259: begin
			a_cmp1 = feture_map[0][1];
			b_cmp1 = feture_map[1][1];
		end
		260: begin
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

		256: begin
			a_cmp2 = feture_map[2][0];
			b_cmp2 = feture_map[3][0];
		end
		257: begin
			a_cmp2 = result2;
			b_cmp2 = result4;
		end
		259: begin
			a_cmp2 = feture_map[2][1];
			b_cmp2 = feture_map[3][1];
		end
		260: begin
			a_cmp2 = result2;
			b_cmp2 = result4;
		end

		default: begin
			a_cmp2 = 0;
			b_cmp2 = 0;
		end

	endcase

end


// SLEEP_6
assign sleep_ctrl_6 = cg_en && !((input_cnt >= 130 && input_cnt <= 141) || (input_cnt >= 238 && input_cnt <= 249) || (input_cnt == 256)|| (input_cnt == 257)|| (input_cnt == 259)|| (input_cnt == 260));

always @(posedge G_clk_6 or negedge rst_n) begin
	if(!rst_n) begin
		result1 <= 0;
		result2 <= 0;
		result3 <= 0;
		result4 <= 0;
	end
	else begin
		case(input_cnt)
			130, 238: result1 <= Max1;
			131, 239: result2 <= Max1;
			132, 240: result1 <= Max1;
			133, 241: result1 <= Max1;
			134, 242: result2 <= Max1;
			135, 243: result2 <= Max1;

			136, 244: result1 <= Max1;
			137, 245: result2 <= Max1;
			138, 246: result1 <= Max1;
			139, 247: result1 <= Max1;
			140, 248: result2 <= Max1;
			141, 249: result2 <= Max1;

			256: begin
				result1 <= Max1;
				result2 <= Min1;
				result3 <= Max2;
				result4 <= Min2;
			end
			257: begin
				result1 <= Max1; /* Find x_max of first map */
				result2 <= Min2; /* Find x_min of first map */
			end
			259: begin
				result1 <= Max1;
				result2 <= Min1;
				result3 <= Max2;
				result4 <= Min2;
			end
			260: begin
				result1 <= Max1; /* Find x_max of second map */
				result2 <= Min2; /* Find x_min of second map */
			end

		endcase
	end

end

// SLEEP_7
assign sleep_ctrl_7 = cg_en && !((input_cnt == 134) || (input_cnt == 136) || (input_cnt == 140) || (input_cnt == 142) || (input_cnt == 242) || (input_cnt == 244) || (input_cnt == 248) || (input_cnt == 250));

always @(posedge G_clk_7 or negedge rst_n) begin
	if(!rst_n) begin
		for(n = 0; n <= 1; n = n + 1) begin
			for(m = 0; m <= 1; m = m + 1) begin
				pooling[0][n][m] <= 0;
				pooling[1][n][m] <= 0;
			end
		end
	end
	else begin
	case(input_cnt)

		134: pooling[0][0][0] <= result1;
		136: pooling[0][0][1] <= result2;
		140: pooling[0][1][0] <= result1;
		142: pooling[0][1][1] <= result2;
		
		242: pooling[1][0][0] <= result1;
		244: pooling[1][0][1] <= result2;
		248: pooling[1][1][0] <= result1;
		250: pooling[1][1][1] <= result2;
		
	endcase
	end
end

//////////////////////////////////////////////////////////
//                     Convolution                      //
//////////////////////////////////////////////////////////


// SLEEP_8 // !TEST
assign sleep_ctrl_8 = cg_en && !(  (  (input_cnt < 220) && ( ((conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) && (nine_cycle_cnt == 1)) || (img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) )       ) ||
									(input_cnt == 253)  || (input_cnt == 258) || (input_cnt == 259) ||
									(input_cnt == 262) || (input_cnt == 266) || (input_cnt == 267) ||
									(input_cnt == 270) || (input_cnt == 271) || 
									(input_cnt == 1093));

always @(posedge G_clk_8 or negedge rst_n) begin
	if(!rst_n) begin
		feture_map[0][0] <= 0;
        feture_map[0][1] <= 0;
	end
	else begin
		if(input_cnt < 220) begin
			if(conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) begin
				if(nine_cycle_cnt == 1 /*&& img_cnt == 0*/) begin
					feture_map[0][0] <= z_add1;
					feture_map[0][1] <= z_add2;
				end
			end
			else if(img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) begin
                feture_map[0][0] <= 0;
                feture_map[0][1] <= 0;
			end
		end
		else if(input_cnt == 253) begin
			feture_map[0][0] <= z_mac1;
		end
		else if(input_cnt == 258) begin
			feture_map[0][1] <= z_mac1;
		end
		else if(input_cnt == 259) begin
			feture_map[0][0] <= z_add1;
		end
		else if(input_cnt == 262) begin
			feture_map[0][1] <= z_add1;
		end	
		else if(input_cnt == 266) begin
			feture_map[0][0] <= z_div1;
		end
		else if(input_cnt == 267) begin
			feture_map[0][1] <= z_div1;
		end
		else if(input_cnt == 270) begin
			feture_map[0][0] <= z_exp1;
		end
		else if(input_cnt == 271) begin
			feture_map[0][1] <= z_exp1;
		end
		else if(input_cnt == 1093) begin
			feture_map[0][0] <= 0;
            feture_map[0][1] <= 0;
		end

	end
end

// SLEEP_40
assign sleep_ctrl_40 = cg_en && !(  (  (input_cnt < 220) && ( ((conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) && (nine_cycle_cnt == 1)) || (img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) )       ) ||
									(input_cnt == 258)  || (input_cnt == 263) || (input_cnt == 268) || (input_cnt == 269) ||
									(input_cnt == 1093));

always @(posedge G_clk_40 or negedge rst_n) begin
	if(!rst_n) begin
        feture_map[0][2] <= 0;
        feture_map[0][3] <= 0;
	end
	else begin
		if(input_cnt < 220) begin
			if(conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) begin
				if(nine_cycle_cnt == 1 /*&& img_cnt == 0*/) begin
					feture_map[0][2] <= z_add3;
					feture_map[0][3] <= z_add4;
				end
			end
			else if(img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) begin
                feture_map[0][2] <= 0;
                feture_map[0][3] <= 0;
			end
		end
		else if(input_cnt == 258) begin
			feture_map[0][2] <= result1; /* x_max of map 1 */
		end
		else if(input_cnt == 263) begin
			feture_map[0][3] <= z_add1; /*  of map1 */
		end
		else if(input_cnt == 268) begin
			feture_map[0][2] <= z_exp1;
		end
		else if(input_cnt == 269) begin
			feture_map[0][3] <= z_exp1;
		end
		else if(input_cnt == 1093) begin
            feture_map[0][2] <= 0;
            feture_map[0][3] <= 0;
		end

	end
end

// SLEEP_34
assign sleep_ctrl_34 = cg_en && !(  (  (input_cnt < 220) && ( ((conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) && (nine_cycle_cnt == 2)) || (img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) )       ) ||
									(input_cnt == 253)  || (input_cnt == 258) || (input_cnt == 259) || (input_cnt == 262) ||
									(input_cnt == 266) || (input_cnt == 267) || (input_cnt == 270) || (input_cnt == 271) || 
									(input_cnt == 1093));

always @(posedge G_clk_34 or negedge rst_n) begin
	if(!rst_n) begin
        feture_map[1][0] <= 0;
        feture_map[1][1] <= 0;
	end
	else begin
		if(input_cnt < 220) begin
			if(conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) begin
				if(nine_cycle_cnt == 2 /*&& img_cnt == 0*/) begin
					feture_map[1][0] <= z_add1;
					feture_map[1][1] <= z_add2;
				end
			end
			else if(img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) begin
                feture_map[1][0] <= 0;
                feture_map[1][1] <= 0;
			end
		end
		else if(input_cnt == 253) begin
			feture_map[1][0] <= z_mac2;
		end
		else if(input_cnt == 258) begin
			feture_map[1][1] <= z_mac2;
		end
		else if(input_cnt == 259) begin
			feture_map[1][0] <= z_add2;
		end
		else if(input_cnt == 262) begin
			feture_map[1][1] <= z_add2;
		end	
		else if(input_cnt == 266) begin
			feture_map[1][0] <= z_div2;
		end
		else if(input_cnt == 267) begin
			feture_map[1][1] <= z_div2;
		end
		else if(input_cnt == 270) begin
			feture_map[1][0] <= z_exp2;
		end
		else if(input_cnt == 271) begin
			feture_map[1][1] <= z_exp2;
		end
		else if(input_cnt == 1093) begin
            feture_map[1][0] <= 0;
            feture_map[1][1] <= 0;
		end

	end
end

// SLEEP_41
assign sleep_ctrl_41 = cg_en && !(  (  (input_cnt < 220) && ( ((conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) && (nine_cycle_cnt == 2)) || (img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) )       ) ||
									(input_cnt == 258)  || (input_cnt == 268) || (input_cnt == 269) || 
									(input_cnt == 1093));

always @(posedge G_clk_41 or negedge rst_n) begin
	if(!rst_n) begin
        feture_map[1][2] <= 0;
        feture_map[1][3] <= 0;
	end
	else begin
		if(input_cnt < 220) begin
			if(conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) begin
				if(nine_cycle_cnt == 2 /*&& img_cnt == 0*/) begin
					feture_map[1][2] <= z_add3;
					feture_map[1][3] <= z_add4;
				end
			end
			else if(img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) begin
                feture_map[1][2] <= 0;
                feture_map[1][3] <= 0;
			end
		end
		else if(input_cnt == 258) begin
			feture_map[1][2] <= {~result2[31], result2[30:0]}; /* x_min of map 1 */
		end
		else if(input_cnt == 268) begin
			feture_map[1][2] <= z_exp2;
		end
		else if(input_cnt == 269) begin
			feture_map[1][3] <= z_exp2;
		end
		else if(input_cnt == 1093) begin
            feture_map[1][2] <= 0;
            feture_map[1][3] <= 0;
		end

	end
end



// SLEEP_35
assign sleep_ctrl_35 = cg_en && !(  (  (input_cnt < 220) && ( ((conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) && (nine_cycle_cnt == 3)) || (img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) )       ) ||
									(input_cnt == 253)  || (input_cnt == 258) || (input_cnt == 259) || 
									(input_cnt == 262)  || (input_cnt == 266) || (input_cnt == 267) || 
									(input_cnt == 270)  || (input_cnt == 271) || 
									(input_cnt == 1093));

always @(posedge G_clk_35 or negedge rst_n) begin
	if(!rst_n) begin
        feture_map[2][0] <= 0;
        feture_map[2][1] <= 0;
	end
	else begin
		if(input_cnt < 220) begin
			if(conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) begin
				if(nine_cycle_cnt == 3 /*&& img_cnt == 0*/) begin
					feture_map[2][0] <= z_add1;
					feture_map[2][1] <= z_add2;
				end
			end
			else if(img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) begin
                feture_map[2][0] <= 0;
                feture_map[2][1] <= 0;
			end
		end
		else if(input_cnt == 253) begin
			feture_map[2][0] <= z_mac3;
		end
		else if(input_cnt == 258) begin
			feture_map[2][1] <= z_mac3;
		end
		else if(input_cnt == 259) begin
			feture_map[2][0] <= z_add3;
		end
		else if(input_cnt == 262) begin
			feture_map[2][1] <= z_add3;
		end	
		else if(input_cnt == 266) begin
			feture_map[2][0] <= z_div3;
		end
		else if(input_cnt == 267) begin
			feture_map[2][1] <= z_div3;
		end
		else if(input_cnt == 270) begin
			feture_map[2][0] <= z_exp3;
		end
		else if(input_cnt == 271) begin
			feture_map[2][1] <= z_exp3;
		end
		else if(input_cnt == 1093) begin
            feture_map[2][0] <= 0;
            feture_map[2][1] <= 0;
		end

	end
end

// SLEEP_42
assign sleep_ctrl_42 = cg_en && !(  (  (input_cnt < 220) && ( ((conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) && (nine_cycle_cnt == 3)) || (img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) )       ) ||
									(input_cnt == 261)  || (input_cnt == 263) || (input_cnt == 268) || 
									(input_cnt == 269)  ||
									(input_cnt == 1093));

always @(posedge G_clk_42 or negedge rst_n) begin
	if(!rst_n) begin
        feture_map[2][2] <= 0;
        feture_map[2][3] <= 0;
	end
	else begin
		if(input_cnt < 220) begin
			if(conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) begin
				if(nine_cycle_cnt == 3 /*&& img_cnt == 0*/) begin
					feture_map[2][2] <= z_add3;
					feture_map[2][3] <= z_add4;
				end
			end
			else if(img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) begin
                feture_map[2][2] <= 0;
                feture_map[2][3] <= 0;
			end
		end
		else if(input_cnt == 261) begin
			feture_map[2][2] <= result1; /* x_max of map 2 */
		end
		else if(input_cnt == 263) begin
			feture_map[2][3] <= z_add2; /*  of map2 */
		end
		else if(input_cnt == 268) begin
			feture_map[2][2] <= z_exp3;
		end
		else if(input_cnt == 269) begin
			feture_map[2][3] <= z_exp3;
		end
		else if(input_cnt == 1093) begin
            feture_map[2][2] <= 0;
            feture_map[2][3] <= 0;
		end

	end
end

// SLEEP_36
assign sleep_ctrl_36 = cg_en && !(  (  (input_cnt < 220) && ( ((conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) && (nine_cycle_cnt == 0)) || (img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) )       ) ||
									(input_cnt == 253)  || (input_cnt == 258) || (input_cnt == 259) || 
									(input_cnt == 262)  || (input_cnt == 266)  || (input_cnt == 267)  ||
									(input_cnt == 270)  || (input_cnt == 271)  || 
									(input_cnt == 1093));

always @(posedge G_clk_36 or negedge rst_n) begin
	if(!rst_n) begin
        feture_map[3][0] <= 0;
        feture_map[3][1] <= 0;
	end
	else begin
		if(input_cnt < 220) begin
			if(conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) begin
				if(nine_cycle_cnt == 0 /*&& img_cnt == 1*/) begin
					feture_map[3][0] <= z_add1;
					feture_map[3][1] <= z_add2;
				end
			end
			else if(img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) begin
                feture_map[3][0] <= 0;
                feture_map[3][1] <= 0;
			end
		end
		else if(input_cnt == 253) begin
			feture_map[3][0] <= z_mac4; /* flatten map1 after matrix mult */
		end
		else if(input_cnt == 258) begin
			feture_map[3][1] <= z_mac4; /* flatten map2 after matrix mult */
		end
		else if(input_cnt == 259) begin
			feture_map[3][0] <= z_add4; /*  of map1 */
		end
		else if(input_cnt == 262) begin
			feture_map[3][1] <= z_add4; /*  of map2 */
		end	
		else if(input_cnt == 266) begin
			feture_map[3][0] <= z_div4;
		end
		else if(input_cnt == 267) begin
			feture_map[3][1] <= z_div4;
		end
		else if(input_cnt == 270) begin
			feture_map[3][0] <= z_exp4;
		end
		else if(input_cnt == 271) begin
			feture_map[3][1] <= z_exp4;
		end
		else if(input_cnt == 1093) begin
            feture_map[3][0] <= 0;
            feture_map[3][1] <= 0;
		end

	end
end

// SLEEP_43
assign sleep_ctrl_43 = cg_en && !(  (  (input_cnt < 220) && ( ((conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) && (nine_cycle_cnt == 0)) || (img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) )       ) ||
									(input_cnt == 261)  || (input_cnt == 268) || (input_cnt == 269) || 
									(input_cnt == 1093));

always @(posedge G_clk_43 or negedge rst_n) begin
	if(!rst_n) begin
        feture_map[3][2] <= 0;
        feture_map[3][3] <= 0;
	end
	else begin
		if(input_cnt < 220) begin
			if(conv_cnt == 0 && !(nine_cycle_cnt == 0 && img_cnt == 0)) begin
				if(nine_cycle_cnt == 0 /*&& img_cnt == 1*/) begin
					feture_map[3][2] <= z_add3;
					feture_map[3][3] <= z_add4;
				end
			end
			else if(img_cnt == 3 && nine_cycle_cnt == 0 && conv_cnt == 7) begin
                feture_map[3][2] <= 0;
                feture_map[3][3] <= 0;
			end
		end
		else if(input_cnt == 261) begin
			feture_map[3][2] <= {~result2[31], result2[30:0]}; /* x_min of map 2 */
		end
		else if(input_cnt == 268) begin
			feture_map[3][2] <= z_exp4;
		end
		else if(input_cnt == 269) begin
			feture_map[3][3] <= z_exp4;
		end
		else if(input_cnt == 1093) begin
            feture_map[3][2] <= 0;
            feture_map[3][3] <= 0;
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
	else if(input_cnt == 259) begin
		a_add1 = feture_map[0][0];
		a_add2 = feture_map[1][0];
		a_add3 = feture_map[2][0];
		a_add4 = feture_map[3][0];
	end
	else if(input_cnt == 262) begin
		a_add1 = feture_map[0][1];
		a_add2 = feture_map[1][1];
		a_add3 = feture_map[2][1];
		a_add4 = feture_map[3][1];
	end
	else if(input_cnt == 263) begin
		a_add1 = feture_map[0][2];
		a_add2 = feture_map[2][2];
		a_add3 = 0;
		a_add4 = 0;
	end
	else if(input_cnt == 272 && !Opt_reg[1]) begin
		a_add1 = feture_map[0][3];
		a_add2 = feture_map[1][3];
		a_add3 = feture_map[2][3];
		a_add4 = feture_map[3][3];
	end
	else if(input_cnt == 273 && !Opt_reg[1]) begin
		a_add1 = feture_map[0][1];
		a_add2 = feture_map[1][1];
		a_add3 = feture_map[2][1];
		a_add4 = feture_map[3][1];
	end
	else if(input_cnt == 272 && Opt_reg[1]) begin
		a_add1 = feture_map[0][2];
		a_add2 = feture_map[1][2];
		a_add3 = feture_map[2][2];
		a_add4 = feture_map[3][2];
	end
	else if(input_cnt == 273 && Opt_reg[1]) begin
		a_add1 = feture_map[0][2];
		a_add2 = feture_map[1][2];
		a_add3 = feture_map[2][2];
		a_add4 = feture_map[3][2];
	end

	else if(input_cnt == 274 && Opt_reg[1]) begin
		a_add1 = feture_map[0][0];
		a_add2 = feture_map[1][0];
		a_add3 = feture_map[2][0];
		a_add4 = feture_map[3][0];
	end
	else if(input_cnt == 275 && Opt_reg[1]) begin
		a_add1 = feture_map[0][0];
		a_add2 = feture_map[1][0];
		a_add3 = feture_map[2][0];
		a_add4 = feture_map[3][0];
	end

	else if(input_cnt == 275 && !Opt_reg[1]) begin
		a_add1 = Img_reg[0];
		a_add2 = Img_reg[1];
		a_add3 = Img_reg[2];
		a_add4 = Img_reg[3];
	end
	else if(input_cnt == 276 && !Opt_reg[1]) begin
		a_add1 = {1'b0, Img_reg[0][30:0]};
		a_add2 = {1'b0, Img_reg[1][30:0]};
		a_add3 = 0;
		a_add4 = 0;
	end
	else if(input_cnt == 277 && !Opt_reg[1]) begin
		a_add1 = {1'b0, Img_reg[0][30:0]};
		a_add2 = 0;
		a_add3 = 0;
		a_add4 = 0;
	end
	else if(input_cnt == 277 && Opt_reg[1]) begin
		a_add1 = Img_reg[0];
		a_add2 = Img_reg[1];
		a_add3 = Img_reg[2];
		a_add4 = Img_reg[3];
	end
	else if(input_cnt == 278 && Opt_reg[1]) begin
		a_add1 = {1'b0, Img_reg[0][30:0]};
		a_add2 = {1'b0, Img_reg[1][30:0]};
		a_add3 = 0;
		a_add4 = 0;
	end
	else if(input_cnt == 279 && Opt_reg[1]) begin
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
	else if(input_cnt == 259) begin
		b_add1 = feture_map[1][2];
		b_add2 = feture_map[1][2];
		b_add3 = feture_map[1][2];
		b_add4 = feture_map[1][2];
	end
	else if(input_cnt == 262) begin
		b_add1 = feture_map[3][2];
		b_add2 = feture_map[3][2];
		b_add3 = feture_map[3][2];
		b_add4 = feture_map[3][2];
	end	
	else if(input_cnt == 263) begin
		b_add1 = feture_map[1][2];
		b_add2 = feture_map[3][2];
		b_add3 = 0;
		b_add4 = 0;
	end
	else if(input_cnt == 272 && !Opt_reg[1]) begin
		b_add1 = 32'b00111111100000000000000000000000;
		b_add2 = 32'b00111111100000000000000000000000;
		b_add3 = 32'b00111111100000000000000000000000;
		b_add4 = 32'b00111111100000000000000000000000;
	end
	else if(input_cnt == 273 && !Opt_reg[1]) begin
		b_add1 = 32'b00111111100000000000000000000000;
		b_add2 = 32'b00111111100000000000000000000000;
		b_add3 = 32'b00111111100000000000000000000000;
		b_add4 = 32'b00111111100000000000000000000000;
	end
	else if(input_cnt == 272 && Opt_reg[1]) begin
		b_add1 = feture_map[0][3];
		b_add2 = feture_map[1][3];
		b_add3 = feture_map[2][3];
		b_add4 = feture_map[3][3];
	end
	else if(input_cnt == 273 && Opt_reg[1]) begin
		b_add1 = {~feture_map[0][3][31], feture_map[0][3][30:0]};
		b_add2 = {~feture_map[1][3][31], feture_map[1][3][30:0]};
		b_add3 = {~feture_map[2][3][31], feture_map[2][3][30:0]};
		b_add4 = {~feture_map[3][3][31], feture_map[3][3][30:0]};
	end
	else if(input_cnt == 274 && Opt_reg[1]) begin
		b_add1 = feture_map[0][1];
		b_add2 = feture_map[1][1];
		b_add3 = feture_map[2][1];
		b_add4 = feture_map[3][1];
	end
	else if(input_cnt == 275 && Opt_reg[1]) begin
		b_add1 = {~feture_map[0][1][31], feture_map[0][1][30:0]};
		b_add2 = {~feture_map[1][1][31], feture_map[1][1][30:0]};
		b_add3 = {~feture_map[2][1][31], feture_map[2][1][30:0]};
		b_add4 = {~feture_map[3][1][31], feture_map[3][1][30:0]};
	end
	else if(input_cnt == 275 && !Opt_reg[1]) begin
		b_add1 = {~Img_reg[4][31], Img_reg[4][30:0]};
		b_add2 = {~Img_reg[5][31], Img_reg[5][30:0]};
		b_add3 = {~Img_reg[6][31], Img_reg[6][30:0]};
		b_add4 = {~Img_reg[7][31], Img_reg[7][30:0]};
	end
	else if(input_cnt == 276 && !Opt_reg[1]) begin
		b_add1 = {1'b0, Img_reg[2][30:0]};
		b_add2 = {1'b0, Img_reg[3][30:0]};
		b_add3 = 0;
		b_add4 = 0;
	end
	else if(input_cnt == 277 && !Opt_reg[1]) begin
		b_add1 = {1'b0, Img_reg[1][30:0]};
		b_add2 = 0;
		b_add3 = 0;
		b_add4 = 0;
	end
	else if(input_cnt == 277 && Opt_reg[1]) begin
		b_add1 = {~Img_reg[8][31], Img_reg[8][30:0]};
		b_add2 = {~Img_reg[9][31], Img_reg[9][30:0]};
		b_add3 = {~Img_reg[10][31], Img_reg[10][30:0]};
		b_add4 = {~Img_reg[11][31], Img_reg[11][30:0]};
	end
	else if(input_cnt == 278 && Opt_reg[1]) begin
		b_add1 = {1'b0, Img_reg[2][30:0]};
		b_add2 = {1'b0, Img_reg[3][30:0]};
		b_add3 = 0;
		b_add4 = 0;
	end
	else if(input_cnt == 279 && Opt_reg[1]) begin
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

// SLEEP_9
assign sleep_ctrl_9 = cg_en && !(((input_cnt < 219) && (conv_cnt >= 0 && conv_cnt <= 8)) || (input_cnt == 251) || (input_cnt == 252) || (input_cnt == 256) || (input_cnt == 257));

always @(posedge G_clk_9 or negedge rst_n) begin
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
		else if(input_cnt == 251) 
			a_mac1 <= pooling[0][0][0];
		else if(input_cnt == 252) 
			a_mac1 <= pooling[0][0][1];
		else if(input_cnt == 256) 
			a_mac1 <= pooling[1][0][0];
		else if(input_cnt == 257) 
			a_mac1 <= pooling[1][0][1];

		// else
		// 	a_mac1 <= 0;
	end
end

// SLEEP_10
// assign sleep_ctrl_10 = cg_en && !();

always @(posedge G_clk_9 or negedge rst_n) begin
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
		else if(input_cnt == 251) 
			a_mac2 <= pooling[0][0][0];
		else if(input_cnt == 252) 
			a_mac2 <= pooling[0][0][1];
		else if(input_cnt == 256) 
			a_mac2 <= pooling[1][0][0];
		else if(input_cnt == 257) 
			a_mac2 <= pooling[1][0][1];

		// else
		// 	a_mac2 <= 0;
	end
end

// SLEEP_11
// assign sleep_ctrl_11 = cg_en && !();

always @(posedge G_clk_9 or negedge rst_n) begin
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
		else if(input_cnt == 251) 
			a_mac3 <= pooling[0][1][0];
		else if(input_cnt == 252) 
			a_mac3 <= pooling[0][1][1];
		else if(input_cnt == 256) 
			a_mac3 <= pooling[1][1][0];
		else if(input_cnt == 257) 
			a_mac3 <= pooling[1][1][1];

		// else
		// 	a_mac3 <= 0;
	end
end

// SLEEP_12
// assign sleep_ctrl_12 = cg_en && !();

always @(posedge G_clk_9 or negedge rst_n) begin
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
		else if(input_cnt == 251) 
			a_mac4 <= pooling[0][1][0];
		else if(input_cnt == 252) 
			a_mac4 <= pooling[0][1][1];
		else if(input_cnt == 256) 
			a_mac4 <= pooling[1][1][0];
		else if(input_cnt == 257) 
			a_mac4 <= pooling[1][1][1];

		// else
		// 	a_mac4 <= 0;
	end
end

// SLEEP_13
assign sleep_ctrl_13 = cg_en && !(((input_cnt < 219) && (conv_cnt >= 0 && conv_cnt <= 8)) || (input_cnt == 251) || (input_cnt == 252) || (input_cnt == 256) || (input_cnt == 257) || (input_cnt == 273 && Opt_reg[1]) || (input_cnt == 275 && Opt_reg[1]));

always @(posedge G_clk_13 or negedge rst_n) begin
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
		else if(input_cnt == 251 || input_cnt == 256) 
			b_mac1 <= Weight_reg[0];
		else if(input_cnt == 252 || input_cnt == 257) 
			b_mac1 <=  Weight_reg[2];

		else if(input_cnt == 273 && Opt_reg[1]) 
			b_mac1 <= z_add1;
		else if(input_cnt == 275 && Opt_reg[1]) 
			b_mac1 <= z_add1;
		// else
		// 	b_mac1 <= 0;
	end
end



always @(posedge G_clk_13 or negedge rst_n) begin
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
		else if(input_cnt == 251 || input_cnt == 256) 
			b_mac2 <= Weight_reg[1];
		else if(input_cnt == 252 || input_cnt == 257) 
			b_mac2 <=  Weight_reg[3];

		else if(input_cnt == 273 && Opt_reg[1]) 
			b_mac2 <= z_add2;
		else if(input_cnt == 275 && Opt_reg[1]) 
			b_mac2 <= z_add2;
		// else
		// 	b_mac2 <= 0;
	end
end

// SLEEP_14
// assign sleep_ctrl_14 = cg_en && !();

always @(posedge G_clk_13 or negedge rst_n) begin
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
		else if(input_cnt == 251 || input_cnt == 256) 
			b_mac3 <= Weight_reg[0];
		else if(input_cnt == 252 || input_cnt == 257) 
			b_mac3 <=  Weight_reg[2];

		else if(input_cnt == 273 && Opt_reg[1]) 
			b_mac3 <= z_add3;
		else if(input_cnt == 275 && Opt_reg[1]) 
			b_mac3 <= z_add3;
		// else
		// 	b_mac3 <= 0;
	end
end

// SLEEP_15
// assign sleep_ctrl_15 = cg_en && !();

always @(posedge G_clk_13 or negedge rst_n) begin
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
		else if(input_cnt == 251 || input_cnt == 256) 
			b_mac4 <= Weight_reg[1];
		else if(input_cnt == 252 || input_cnt == 257) 
			b_mac4 <=  Weight_reg[3];

		else if(input_cnt == 273 && Opt_reg[1]) 
			b_mac4 <= z_add4;
		else if(input_cnt == 275 && Opt_reg[1]) 
			b_mac4 <= z_add4;
		// else
		// 	b_mac4 <= 0;
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

// SLEEP_16
assign sleep_ctrl_16 = cg_en && !((input_cnt >= 4 && input_cnt < 219) || (input_cnt == 251 || input_cnt == 256) || (input_cnt == 252 || input_cnt == 257) || (input_cnt == 273 && Opt_reg[1]) || (input_cnt == 275 && Opt_reg[1]) || (input_cnt == 1093));

always @(posedge G_clk_16 or negedge rst_n) begin
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
		else if(input_cnt == 251 || input_cnt == 256) begin
			c_mac1 <= 0;
			c_mac2 <= 0;
			c_mac3 <= 0;
			c_mac4 <= 0;
		end
		else if(input_cnt == 252 || input_cnt == 257) begin
			c_mac1 <= z_mac1;
			c_mac2 <= z_mac2;
			c_mac3 <= z_mac3;
			c_mac4 <= z_mac4;
		end
		else if(input_cnt == 273 && Opt_reg[1]) begin
			c_mac1 <= 0;
			c_mac2 <= 0;
			c_mac3 <= 0;
			c_mac4 <= 0;
		end
		else if(input_cnt == 275 && Opt_reg[1]) begin
			c_mac1 <= 0;
			c_mac2 <= 0;
			c_mac3 <= 0;
			c_mac4 <= 0;
		end
		else if(input_cnt == 1093)begin
			c_mac1 <= 0;
			c_mac2 <= 0;
			c_mac3 <= 0;
			c_mac4 <= 0;
		end

	end

end

// SLEEP_17
assign sleep_ctrl_17 = cg_en && !((input_cnt == 1093) || (conv_cnt == 8) || (input_cnt >= 3));

always @(posedge G_clk_17 or negedge rst_n) begin

	if(!rst_n)
		conv_cnt <= 0;
	else begin
		if(input_cnt == 1093)
			conv_cnt <= 0;
		else if(conv_cnt == 8)
			conv_cnt <= 0;
		else if(input_cnt >= 3)
			conv_cnt <= conv_cnt +1;
	end
end

// SLEEP_18
assign sleep_ctrl_18 = cg_en && !((input_cnt == 1093) || (conv_cnt == 8));

always @(posedge G_clk_18 or negedge rst_n) begin

	if(!rst_n)
		nine_cycle_cnt <= 0;
	else begin
		if(input_cnt == 1093)
			nine_cycle_cnt <= 0;
		else if(conv_cnt == 8)
			nine_cycle_cnt <= nine_cycle_cnt +1;

	end
end

// SLEEP_19
assign sleep_ctrl_19 = cg_en && !((input_cnt == 1093) || (nine_cycle_cnt == 3 && conv_cnt == 8 && img_cnt < 5));

always @(posedge G_clk_19 or negedge rst_n) begin

	if(!rst_n)
		img_cnt <= 0;
	else begin
		if(input_cnt == 1093)
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

// SLEEP_20
// assign sleep_ctrl_20 = cg_en && !();

always @(posedge clk or negedge rst_n) begin

	if(!rst_n)
		input_cnt <= 0;
	else begin
		if(input_cnt == 1093)
			input_cnt <= 0;
        // if(!Opt_reg[1] && input_cnt == 255 || Opt_reg[1] && input_cnt == 257)
		// 	input_cnt <= 0;
		else if(in_valid)
			input_cnt <= input_cnt + 1;
		else if(input_cnt > 0)
			input_cnt <= input_cnt + 1;
	end
end

// SLEEP_21
assign sleep_ctrl_21 = cg_en && !((input_cnt >= 0 && input_cnt <= 3) || (input_cnt == 272 && !Opt_reg[1]) || (input_cnt == 273 && !Opt_reg[1]) ||
									(input_cnt == 272 && Opt_reg[1]) || (input_cnt == 274 && Opt_reg[1]) || (input_cnt == 275 && !Opt_reg[1]) ||
										(input_cnt == 276 && !Opt_reg[1]) || (input_cnt == 277 && !Opt_reg[1])  || (input_cnt == 277 && Opt_reg[1]) ||
											(input_cnt == 278 && Opt_reg[1]) || (input_cnt == 279 && Opt_reg[1]));

always @(posedge G_clk_21 or negedge rst_n) begin
	if(!rst_n) begin
		for(n = 0; n <= 3; n = n + 1)
			Img_reg[n] <= 32'b0;
	end
	else if(in_valid) begin
		case(input_cnt)
			0: Img_reg[0] <= Img;
			1: Img_reg[1] <= Img;
			2: Img_reg[2] <= Img;
			3: Img_reg[3] <= Img;
		endcase

	end
	else if(input_cnt == 272 && !Opt_reg[1]) begin /* 1+e^-z of map1 */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
		Img_reg[2] <= z_add3;
		Img_reg[3] <= z_add4;
	end
	else if(input_cnt == 273 && !Opt_reg[1]) begin /* 1+e^-z of map2 */ /* sigmoid of map1 */
		Img_reg[0] <= z_div1;
		Img_reg[1] <= z_div2;
		Img_reg[2] <= z_div3;
		Img_reg[3] <= z_div4;
	end
	// else if(input_cnt == 274 && !Opt_reg[1]) begin /* sigmoid of map2 */
	// end
	else if(input_cnt == 272 && Opt_reg[1]) begin /* e^z + e^-z of map1 */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
		Img_reg[2] <= z_add3;
		Img_reg[3] <= z_add4;
	end
	// else if(input_cnt == 273 && Opt_reg[1]) begin /* e^z - e^-z of map1 */ /* (e^z + e^-z)^-1 of map1 */
	// end
	else if(input_cnt == 274 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z + e^-z of map2 */
		Img_reg[0] <= z_div1;
		Img_reg[1] <= z_div2;
		Img_reg[2] <= z_div3;
		Img_reg[3] <= z_div4;
	end
	// else if(input_cnt == 275 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z - e^-z of map2 */
	// end
	// else if(input_cnt == 276 && Opt_reg[1]) begin /* Tanh of map2 */ 
	// end
	else if(input_cnt == 275 && !Opt_reg[1]) begin /* diff of map1, 2 */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
		Img_reg[2] <= z_add3;
		Img_reg[3] <= z_add4;
	end
	else if(input_cnt == 276 && !Opt_reg[1]) begin /* abs of sigmoid  */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
	end
	else if(input_cnt == 277 && !Opt_reg[1]) begin /* abs of sigmoid */
		Img_reg[0] <= z_add1;
	end
	else if(input_cnt == 277 && Opt_reg[1]) begin /* diff of map1, 2 */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
		Img_reg[2] <= z_add3;
		Img_reg[3] <= z_add4;
	end
	else if(input_cnt == 278 && Opt_reg[1]) begin /* abs of Tanh */
		Img_reg[0] <= z_add1;
		Img_reg[1] <= z_add2;
	end
	else if(input_cnt == 279 && Opt_reg[1]) begin /* abs of Tanh */
		Img_reg[0] <= z_add1;
	end

end


// SLEEP_44
assign sleep_ctrl_44 = cg_en && !((input_cnt >= 4 && input_cnt <= 7) || (input_cnt == 273 && !Opt_reg[1]) || (input_cnt == 274 && !Opt_reg[1]) ||
									(input_cnt == 273 && Opt_reg[1]));

always @(posedge G_clk_44 or negedge rst_n) begin
	if(!rst_n) begin
		for(n = 4; n <= 7; n = n + 1)
			Img_reg[n] <= 32'b0;
	end
	else if(in_valid) begin
		case(input_cnt)
			4: Img_reg[4] <= Img;
			5: Img_reg[5] <= Img;
			6: Img_reg[6] <= Img;
			7: Img_reg[7] <= Img;
		endcase

	end
	// else if(input_cnt == 272 && !Opt_reg[1]) begin /* 1+e^-z of map1 */
	// end
	else if(input_cnt == 273 && !Opt_reg[1]) begin /* 1+e^-z of map2 */ /* sigmoid of map1 */
		Img_reg[4] <= z_add1;
		Img_reg[5] <= z_add2;
		Img_reg[6] <= z_add3;
		Img_reg[7] <= z_add4;
	end
	else if(input_cnt == 274 && !Opt_reg[1]) begin /* sigmoid of map2 */
		Img_reg[4] <= z_div1;
		Img_reg[5] <= z_div2;
		Img_reg[6] <= z_div3;
		Img_reg[7] <= z_div4;
	end
	// else if(input_cnt == 272 && Opt_reg[1]) begin /* e^z + e^-z of map1 */
	// end
	else if(input_cnt == 273 && Opt_reg[1]) begin /* e^z - e^-z of map1 */ /* (e^z + e^-z)^-1 of map1 */
		Img_reg[4] <= z_add1;
		Img_reg[5] <= z_add2;
		Img_reg[6] <= z_add3;
		Img_reg[7] <= z_add4;
	end
	// else if(input_cnt == 274 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z + e^-z of map2 */
	// end
	// else if(input_cnt == 275 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z - e^-z of map2 */
	// end
	// else if(input_cnt == 276 && Opt_reg[1]) begin /* Tanh of map2 */ 
	// end
	// else if(input_cnt == 275 && !Opt_reg[1]) begin /* diff of map1, 2 */
	// end
	// else if(input_cnt == 276 && !Opt_reg[1]) begin /* abs of sigmoid  */
	// end
	// else if(input_cnt == 277 && !Opt_reg[1]) begin /* abs of sigmoid */
	// end
	// else if(input_cnt == 277 && Opt_reg[1]) begin /* diff of map1, 2 */
	// end
	// else if(input_cnt == 278 && Opt_reg[1]) begin /* abs of Tanh */
	// end
	// else if(input_cnt == 279 && Opt_reg[1]) begin /* abs of Tanh */
	// end

end

// SLEEP_45
assign sleep_ctrl_45 = cg_en && !((input_cnt >= 8 && input_cnt <= 11) || (input_cnt == 274 && Opt_reg[1]) || (input_cnt == 276 && Opt_reg[1])
									);

always @(posedge G_clk_45 or negedge rst_n) begin
	if(!rst_n) begin
		for(n = 8; n <= 11; n = n + 1)
			Img_reg[n] <= 32'b0;
	end
	else if(in_valid) begin
		case(input_cnt)
			8: Img_reg[8] <= Img;
			9: Img_reg[9] <= Img;
			10: Img_reg[10] <= Img;
			11: Img_reg[11] <= Img;
		endcase

	end
	// else if(input_cnt == 272 && !Opt_reg[1]) begin /* 1+e^-z of map1 */
	// end
	// else if(input_cnt == 273 && !Opt_reg[1]) begin /* 1+e^-z of map2 */ /* sigmoid of map1 */
	// end
	// else if(input_cnt == 274 && !Opt_reg[1]) begin /* sigmoid of map2 */
	// end
	// else if(input_cnt == 272 && Opt_reg[1]) begin /* e^z + e^-z of map1 */
	// end
	// else if(input_cnt == 273 && Opt_reg[1]) begin /* e^z - e^-z of map1 */ /* (e^z + e^-z)^-1 of map1 */
	// end
	else if(input_cnt == 274 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z + e^-z of map2 */
		Img_reg[8] <= z_add1;
		Img_reg[9] <= z_add2;
		Img_reg[10] <= z_add3;
		Img_reg[11] <= z_add4;
	end
	// else if(input_cnt == 275 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z - e^-z of map2 */
	// end
	else if(input_cnt == 276 && Opt_reg[1]) begin /* Tanh of map2 */ 
		Img_reg[8] <= z_div1;
		Img_reg[9] <= z_div2;
		Img_reg[10] <= z_div3;
		Img_reg[11] <= z_div4;
	end
	// else if(input_cnt == 275 && !Opt_reg[1]) begin /* diff of map1, 2 */
	// end
	// else if(input_cnt == 276 && !Opt_reg[1]) begin /* abs of sigmoid  */
	// end
	// else if(input_cnt == 277 && !Opt_reg[1]) begin /* abs of sigmoid */
	// end
	// else if(input_cnt == 277 && Opt_reg[1]) begin /* diff of map1, 2 */
	// end
	// else if(input_cnt == 278 && Opt_reg[1]) begin /* abs of Tanh */
	// end
	// else if(input_cnt == 279 && Opt_reg[1]) begin /* abs of Tanh */
	// end

end

// SLEEP_21
assign sleep_ctrl_46 = cg_en && !((input_cnt >= 12 && input_cnt <= 15) || (input_cnt == 275 && Opt_reg[1]));

always @(posedge G_clk_46 or negedge rst_n) begin
	if(!rst_n) begin
		for(n = 12; n <= 15; n = n + 1)
			Img_reg[n] <= 32'b0;
	end
	else if(in_valid) begin
		case(input_cnt)
			12: Img_reg[12] <= Img;
			13: Img_reg[13] <= Img;
			14: Img_reg[14] <= Img;
			15: Img_reg[15] <= Img;
		endcase
	end
	// else if(input_cnt == 272 && !Opt_reg[1]) begin /* 1+e^-z of map1 */
	// end
	// else if(input_cnt == 273 && !Opt_reg[1]) begin /* 1+e^-z of map2 */ /* sigmoid of map1 */
	// end
	// else if(input_cnt == 274 && !Opt_reg[1]) begin /* sigmoid of map2 */
	// end
	// else if(input_cnt == 272 && Opt_reg[1]) begin /* e^z + e^-z of map1 */
	// end
	// else if(input_cnt == 273 && Opt_reg[1]) begin /* e^z - e^-z of map1 */ /* (e^z + e^-z)^-1 of map1 */
	// end
	// else if(input_cnt == 274 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z + e^-z of map2 */
	// end
	else if(input_cnt == 275 && Opt_reg[1]) begin /* Tanh of map1 */ /* e^z - e^-z of map2 */
		Img_reg[12] <= z_add1;
		Img_reg[13] <= z_add2;
		Img_reg[14] <= z_add3;
		Img_reg[15] <= z_add4;
	end
	// else if(input_cnt == 276 && Opt_reg[1]) begin /* Tanh of map2 */ 
	// end
	// else if(input_cnt == 275 && !Opt_reg[1]) begin /* diff of map1, 2 */
	// end
	// else if(input_cnt == 276 && !Opt_reg[1]) begin /* abs of sigmoid  */
	// end
	// else if(input_cnt == 277 && !Opt_reg[1]) begin /* abs of sigmoid */
	// end
	// else if(input_cnt == 277 && Opt_reg[1]) begin /* diff of map1, 2 */
	// end
	// else if(input_cnt == 278 && Opt_reg[1]) begin /* abs of Tanh */
	// end
	// else if(input_cnt == 279 && Opt_reg[1]) begin /* abs of Tanh */
	// end

end


/// !!!!!!!



wire img_ctrl [16:95], img_clk [16:95];
generate
	for(i = 16; i <= 95; i = i + 1) begin
		assign img_ctrl[i] = cg_en && !(input_cnt == i);
		GATED_OR U0(.CLOCK(clk), .SLEEP_CTRL(img_ctrl[i]), .RST_N(rst_n), .CLOCK_GATED(img_clk[i]));
		always @(posedge img_clk[i] or negedge rst_n) begin
			if(!rst_n)
				Img_reg[i] <= 0;
			else if(in_valid && input_cnt == i)
				Img_reg[i] <= Img;
		end
	end
endgenerate


// SLEEP_24
// assign sleep_ctrl_24 = cg_en && !(input_cnt >= 0 && input_cnt < 27);


wire weight_ctrl [0:26], weight_clk [0:26];
generate
	for(i = 0; i < 27; i = i + 1) begin
		assign weight_ctrl[i] = cg_en && !(input_cnt == i);
		GATED_OR U0(.CLOCK(clk), .SLEEP_CTRL(weight_ctrl[i]), .RST_N(rst_n), .CLOCK_GATED(weight_clk[i]));
		always @(posedge weight_clk[i] or negedge rst_n) begin
			if(!rst_n) 
                Kernel_reg[i] <= 32'b0;
			else if(input_cnt == i && in_valid) 
                Kernel_reg[i] <= Kernel;
			else 
                Kernel_reg[i] <= Kernel_reg[i];
		end
	end
endgenerate

// SLEEP_23
assign sleep_ctrl_23 = cg_en && !(input_cnt >= 0 && input_cnt < 4);

generate
	for(i = 0; i < 4; i = i + 1) begin

		always @(posedge G_clk_23 or negedge rst_n) begin
			if(!rst_n) 
                Weight_reg[i] <= 32'b0;
			else if(input_cnt == i && in_valid) 
                Weight_reg[i] <= Weight;
			else 
                Weight_reg[i] <= Weight_reg[i];
		end
	end
endgenerate

// SLEEP_22
assign sleep_ctrl_22 = cg_en && !(input_cnt == 0);

always @(posedge G_clk_22 or negedge rst_n) begin
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
DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) div5 ( .a(a_div5), .b(32'b01000001000100000000000000000000), .rnd(round), .z(z_div5));


DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp1 (.a(a_exp1),.z(z_exp1),.status(status_exp1) );
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp2 (.a(a_exp2),.z(z_exp2),.status(status_exp2) );
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp3 (.a(a_exp3),.z(z_exp3),.status(status_exp3) );
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) exp4 (.a(a_exp4),.z(z_exp4),.status(status_exp4) );

DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) sum3_1(.a(a_sum3_1),.b(b_sum3_1),.c(c_sum3_1),.rnd(3'b0),.z(z_sum3_1));
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) sum3_2(.a(a_sum3_2),.b(b_sum3_2),.c(c_sum3_2),.rnd(3'b0),.z(z_sum3_2));
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) sum3_3(.a(a_sum3_3),.b(b_sum3_3),.c(c_sum3_3),.rnd(3'b0),.z(z_sum3_3));
DW_fp_sum3 #(inst_sig_width,inst_exp_width,inst_ieee_compliance,inst_arch_type) sum3_4(.a(a_sum3_4),.b(b_sum3_4),.c(c_sum3_4),.rnd(3'b0),.z(z_sum3_4));




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
