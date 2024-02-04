module MRA(
	// CHIP IO
	clk            	,	
	rst_n          	,	
	in_valid       	,	
	frame_id        ,	
	net_id         	,	  
	loc_x          	,	  
    loc_y         	,
	cost	 		,		
	busy         	,

    // AXI4 IO
	     arid_m_inf,
	   araddr_m_inf,
	    arlen_m_inf,
	   arsize_m_inf,
	  arburst_m_inf,
	  arvalid_m_inf,
	  arready_m_inf,
	
	      rid_m_inf,
	    rdata_m_inf,
	    rresp_m_inf,
	    rlast_m_inf,
	   rvalid_m_inf,
	   rready_m_inf,
	
	     awid_m_inf,
	   awaddr_m_inf,
	   awsize_m_inf,
	  awburst_m_inf,
	    awlen_m_inf,
	  awvalid_m_inf,
	  awready_m_inf,
	
	    wdata_m_inf,
	    wlast_m_inf,
	   wvalid_m_inf,
	   wready_m_inf,
	
	      bid_m_inf,
	    bresp_m_inf,
	   bvalid_m_inf,
	   bready_m_inf 
);

// ===============================================================
//  					Input / Output 
// ===============================================================

// << CHIP io port with system >>
input 			  	clk,rst_n;
input 			   	in_valid;
input  [4:0] 		frame_id;
input  [3:0]       	net_id;     
input  [5:0]       	loc_x; 
input  [5:0]       	loc_y; 
output reg [13:0] 	cost;
output reg          busy;      

// ===============================================================
//  					Parameter Declaration 
// ===============================================================
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;

parameter IDLE = 0;
parameter INPUT = 1;
parameter READ_DRAM = 2;
parameter INITIAL_MAP = 3;
parameter FILL = 4;
parameter WAIT_WEIGHT_DONE = 5;
parameter RETRACE = 6;
parameter CLEAR = 7;
parameter WRITE_DRAM = 8;
parameter OUTPUT = 9;


// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)	axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output reg                  arvalid_m_inf;
input  wire                  arready_m_inf;
output reg [ADDR_WIDTH-1:0]  araddr_m_inf;
// ------------------------
// (2)	axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output reg                   rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1) 	axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output reg                  awvalid_m_inf;
input  wire                  awready_m_inf;
output reg [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)	axi write data channel 
output reg                   wvalid_m_inf;
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;
output reg                    wlast_m_inf;
// -------------------------
// (3)	axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output reg                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------



integer i, j;
reg [3:0] c_state, n_state;
reg input_cnt;
reg [3:0] input_net_cnt, cur_net_num;
reg [3:0] net_id_reg [0:14];
reg [4:0] frame_id_reg;
reg [5:0] source_x [0:14], source_y [0:14], sink_x [0:14], sink_y [0:14];
reg [6:0] cnt_128, write_cnt;

reg [6:0] addr_map, addr_weight;
reg [127:0] in_map, out_map, in_weight, out_weight;
reg web_map, web_weight;

reg frame_or_weight;

reg [1:0] step_cnt;
reg [1:0] fill_num;

reg [1:0] map [0:63] [0:63];

reg c_state_read, n_state_read;
reg c_state_write, n_state_write;
wire [5:0] offset;

wire n_IDLE, n_INPUT, c_READ_DRAM, c_FILL, c_RETRACE;

reg D_FOR_SINK, START_RETRACE;
reg [5:0] retrace_x, retrace_y;
reg cnt_0_1;
reg delay_flag;

assign n_IDLE = (n_state == IDLE);
assign n_INPUT = (n_state == INPUT);
assign c_READ_DRAM = (c_state == READ_DRAM);
assign c_FILL = (c_state == FILL);
assign c_RETRACE = (c_state == RETRACE);



SRAM_128x128 LOC_MAP(
	.A0  (addr_map[0]),   .A1  (addr_map[1]),   .A2  (addr_map[2]),   .A3  (addr_map[3]),   .A4  (addr_map[4]),   .A5  (addr_map[5]),   .A6  (addr_map[6]),

	.DO0 (out_map[0]),   .DO1 (out_map[1]),   .DO2 (out_map[2]),   .DO3 (out_map[3]),   .DO4 (out_map[4]),   .DO5 (out_map[5]),   .DO6 (out_map[6]),   .DO7 (out_map[7]),
	.DO8 (out_map[8]),   .DO9 (out_map[9]),   .DO10(out_map[10]),  .DO11(out_map[11]),  .DO12(out_map[12]),  .DO13(out_map[13]),  .DO14(out_map[14]),  .DO15(out_map[15]),
	.DO16(out_map[16]),  .DO17(out_map[17]),  .DO18(out_map[18]),  .DO19(out_map[19]),  .DO20(out_map[20]),  .DO21(out_map[21]),  .DO22(out_map[22]),  .DO23(out_map[23]),
	.DO24(out_map[24]),  .DO25(out_map[25]),  .DO26(out_map[26]),  .DO27(out_map[27]),  .DO28(out_map[28]),  .DO29(out_map[29]),  .DO30(out_map[30]),  .DO31(out_map[31]),
	.DO32(out_map[32]),  .DO33(out_map[33]),  .DO34(out_map[34]),  .DO35(out_map[35]),  .DO36(out_map[36]),  .DO37(out_map[37]),  .DO38(out_map[38]),  .DO39(out_map[39]),
	.DO40(out_map[40]),  .DO41(out_map[41]),  .DO42(out_map[42]),  .DO43(out_map[43]),  .DO44(out_map[44]),  .DO45(out_map[45]),  .DO46(out_map[46]),  .DO47(out_map[47]),
	.DO48(out_map[48]),  .DO49(out_map[49]),  .DO50(out_map[50]),  .DO51(out_map[51]),  .DO52(out_map[52]),  .DO53(out_map[53]),  .DO54(out_map[54]),  .DO55(out_map[55]),
	.DO56(out_map[56]),  .DO57(out_map[57]),  .DO58(out_map[58]),  .DO59(out_map[59]),  .DO60(out_map[60]),  .DO61(out_map[61]),  .DO62(out_map[62]),  .DO63(out_map[63]),
	.DO64(out_map[64]),  .DO65(out_map[65]),  .DO66(out_map[66]),  .DO67(out_map[67]),  .DO68(out_map[68]),  .DO69(out_map[69]),  .DO70(out_map[70]),  .DO71(out_map[71]),
	.DO72(out_map[72]),  .DO73(out_map[73]),  .DO74(out_map[74]),  .DO75(out_map[75]),  .DO76(out_map[76]),  .DO77(out_map[77]),  .DO78(out_map[78]),  .DO79(out_map[79]),
	.DO80(out_map[80]),  .DO81(out_map[81]),  .DO82(out_map[82]),  .DO83(out_map[83]),  .DO84(out_map[84]),  .DO85(out_map[85]),  .DO86(out_map[86]),  .DO87(out_map[87]),
	.DO88(out_map[88]),  .DO89(out_map[89]),  .DO90(out_map[90]),  .DO91(out_map[91]),  .DO92(out_map[92]),  .DO93(out_map[93]),  .DO94(out_map[94]),  .DO95(out_map[95]),
	.DO96(out_map[96]),  .DO97(out_map[97]),  .DO98(out_map[98]),  .DO99(out_map[99]),  .DO100(out_map[100]),.DO101(out_map[101]),.DO102(out_map[102]),.DO103(out_map[103]),
	.DO104(out_map[104]),.DO105(out_map[105]),.DO106(out_map[106]),.DO107(out_map[107]),.DO108(out_map[108]),.DO109(out_map[109]),.DO110(out_map[110]),.DO111(out_map[111]),
	.DO112(out_map[112]),.DO113(out_map[113]),.DO114(out_map[114]),.DO115(out_map[115]),.DO116(out_map[116]),.DO117(out_map[117]),.DO118(out_map[118]),.DO119(out_map[119]),
	.DO120(out_map[120]),.DO121(out_map[121]),.DO122(out_map[122]),.DO123(out_map[123]),.DO124(out_map[124]),.DO125(out_map[125]),.DO126(out_map[126]),.DO127(out_map[127]),

	.DI0 (in_map[0]),   .DI1 (in_map[1]),   .DI2 (in_map[2]),   .DI3 (in_map[3]),   .DI4 (in_map[4]),   .DI5 (in_map[5]),   .DI6 (in_map[6]),   .DI7 (in_map[7]),
	.DI8 (in_map[8]),   .DI9 (in_map[9]),   .DI10(in_map[10]),  .DI11(in_map[11]),  .DI12(in_map[12]),  .DI13(in_map[13]),  .DI14(in_map[14]),  .DI15(in_map[15]),
	.DI16(in_map[16]),  .DI17(in_map[17]),  .DI18(in_map[18]),  .DI19(in_map[19]),  .DI20(in_map[20]),  .DI21(in_map[21]),  .DI22(in_map[22]),  .DI23(in_map[23]),
	.DI24(in_map[24]),  .DI25(in_map[25]),  .DI26(in_map[26]),  .DI27(in_map[27]),  .DI28(in_map[28]),  .DI29(in_map[29]),  .DI30(in_map[30]),  .DI31(in_map[31]),
	.DI32(in_map[32]),  .DI33(in_map[33]),  .DI34(in_map[34]),  .DI35(in_map[35]),  .DI36(in_map[36]),  .DI37(in_map[37]),  .DI38(in_map[38]),  .DI39(in_map[39]),
	.DI40(in_map[40]),  .DI41(in_map[41]),  .DI42(in_map[42]),  .DI43(in_map[43]),  .DI44(in_map[44]),  .DI45(in_map[45]),  .DI46(in_map[46]),  .DI47(in_map[47]),
	.DI48(in_map[48]),  .DI49(in_map[49]),  .DI50(in_map[50]),  .DI51(in_map[51]),  .DI52(in_map[52]),  .DI53(in_map[53]),  .DI54(in_map[54]),  .DI55(in_map[55]),
	.DI56(in_map[56]),  .DI57(in_map[57]),  .DI58(in_map[58]),  .DI59(in_map[59]),  .DI60(in_map[60]),  .DI61(in_map[61]),  .DI62(in_map[62]),  .DI63(in_map[63]),
	.DI64(in_map[64]),  .DI65(in_map[65]),  .DI66(in_map[66]),  .DI67(in_map[67]),  .DI68(in_map[68]),  .DI69(in_map[69]),  .DI70(in_map[70]),  .DI71(in_map[71]),
	.DI72(in_map[72]),  .DI73(in_map[73]),  .DI74(in_map[74]),  .DI75(in_map[75]),  .DI76(in_map[76]),  .DI77(in_map[77]),  .DI78(in_map[78]),  .DI79(in_map[79]),
	.DI80(in_map[80]),  .DI81(in_map[81]),  .DI82(in_map[82]),  .DI83(in_map[83]),  .DI84(in_map[84]),  .DI85(in_map[85]),  .DI86(in_map[86]),  .DI87(in_map[87]),
	.DI88(in_map[88]),  .DI89(in_map[89]),  .DI90(in_map[90]),  .DI91(in_map[91]),  .DI92(in_map[92]),  .DI93(in_map[93]),  .DI94(in_map[94]),  .DI95(in_map[95]),
	.DI96(in_map[96]),  .DI97(in_map[97]),  .DI98(in_map[98]),  .DI99(in_map[99]),  .DI100(in_map[100]),.DI101(in_map[101]),.DI102(in_map[102]),.DI103(in_map[103]),
	.DI104(in_map[104]),.DI105(in_map[105]),.DI106(in_map[106]),.DI107(in_map[107]),.DI108(in_map[108]),.DI109(in_map[109]),.DI110(in_map[110]),.DI111(in_map[111]),
	.DI112(in_map[112]),.DI113(in_map[113]),.DI114(in_map[114]),.DI115(in_map[115]),.DI116(in_map[116]),.DI117(in_map[117]),.DI118(in_map[118]),.DI119(in_map[119]),
	.DI120(in_map[120]),.DI121(in_map[121]),.DI122(in_map[122]),.DI123(in_map[123]),.DI124(in_map[124]),.DI125(in_map[125]),.DI126(in_map[126]),.DI127(in_map[127]),

	.CK(clk), .WEB(web_map), .OE(1'b1), .CS(1'b1)
);

SRAM_128x128 WEIGHT(
	.A0  (addr_weight[0]),   .A1  (addr_weight[1]),   .A2  (addr_weight[2]),   .A3  (addr_weight[3]),   .A4  (addr_weight[4]),   .A5  (addr_weight[5]),   .A6  (addr_weight[6]),

	.DO0 (out_weight[0]),   .DO1 (out_weight[1]),   .DO2 (out_weight[2]),   .DO3 (out_weight[3]),   .DO4 (out_weight[4]),   .DO5 (out_weight[5]),   .DO6 (out_weight[6]),   .DO7 (out_weight[7]),
	.DO8 (out_weight[8]),   .DO9 (out_weight[9]),   .DO10(out_weight[10]),  .DO11(out_weight[11]),  .DO12(out_weight[12]),  .DO13(out_weight[13]),  .DO14(out_weight[14]),  .DO15(out_weight[15]),
	.DO16(out_weight[16]),  .DO17(out_weight[17]),  .DO18(out_weight[18]),  .DO19(out_weight[19]),  .DO20(out_weight[20]),  .DO21(out_weight[21]),  .DO22(out_weight[22]),  .DO23(out_weight[23]),
	.DO24(out_weight[24]),  .DO25(out_weight[25]),  .DO26(out_weight[26]),  .DO27(out_weight[27]),  .DO28(out_weight[28]),  .DO29(out_weight[29]),  .DO30(out_weight[30]),  .DO31(out_weight[31]),
	.DO32(out_weight[32]),  .DO33(out_weight[33]),  .DO34(out_weight[34]),  .DO35(out_weight[35]),  .DO36(out_weight[36]),  .DO37(out_weight[37]),  .DO38(out_weight[38]),  .DO39(out_weight[39]),
	.DO40(out_weight[40]),  .DO41(out_weight[41]),  .DO42(out_weight[42]),  .DO43(out_weight[43]),  .DO44(out_weight[44]),  .DO45(out_weight[45]),  .DO46(out_weight[46]),  .DO47(out_weight[47]),
	.DO48(out_weight[48]),  .DO49(out_weight[49]),  .DO50(out_weight[50]),  .DO51(out_weight[51]),  .DO52(out_weight[52]),  .DO53(out_weight[53]),  .DO54(out_weight[54]),  .DO55(out_weight[55]),
	.DO56(out_weight[56]),  .DO57(out_weight[57]),  .DO58(out_weight[58]),  .DO59(out_weight[59]),  .DO60(out_weight[60]),  .DO61(out_weight[61]),  .DO62(out_weight[62]),  .DO63(out_weight[63]),
	.DO64(out_weight[64]),  .DO65(out_weight[65]),  .DO66(out_weight[66]),  .DO67(out_weight[67]),  .DO68(out_weight[68]),  .DO69(out_weight[69]),  .DO70(out_weight[70]),  .DO71(out_weight[71]),
	.DO72(out_weight[72]),  .DO73(out_weight[73]),  .DO74(out_weight[74]),  .DO75(out_weight[75]),  .DO76(out_weight[76]),  .DO77(out_weight[77]),  .DO78(out_weight[78]),  .DO79(out_weight[79]),
	.DO80(out_weight[80]),  .DO81(out_weight[81]),  .DO82(out_weight[82]),  .DO83(out_weight[83]),  .DO84(out_weight[84]),  .DO85(out_weight[85]),  .DO86(out_weight[86]),  .DO87(out_weight[87]),
	.DO88(out_weight[88]),  .DO89(out_weight[89]),  .DO90(out_weight[90]),  .DO91(out_weight[91]),  .DO92(out_weight[92]),  .DO93(out_weight[93]),  .DO94(out_weight[94]),  .DO95(out_weight[95]),
	.DO96(out_weight[96]),  .DO97(out_weight[97]),  .DO98(out_weight[98]),  .DO99(out_weight[99]),  .DO100(out_weight[100]),.DO101(out_weight[101]),.DO102(out_weight[102]),.DO103(out_weight[103]),
	.DO104(out_weight[104]),.DO105(out_weight[105]),.DO106(out_weight[106]),.DO107(out_weight[107]),.DO108(out_weight[108]),.DO109(out_weight[109]),.DO110(out_weight[110]),.DO111(out_weight[111]),
	.DO112(out_weight[112]),.DO113(out_weight[113]),.DO114(out_weight[114]),.DO115(out_weight[115]),.DO116(out_weight[116]),.DO117(out_weight[117]),.DO118(out_weight[118]),.DO119(out_weight[119]),
	.DO120(out_weight[120]),.DO121(out_weight[121]),.DO122(out_weight[122]),.DO123(out_weight[123]),.DO124(out_weight[124]),.DO125(out_weight[125]),.DO126(out_weight[126]),.DO127(out_weight[127]),

	.DI0 (in_weight[0]),   .DI1 (in_weight[1]),   .DI2 (in_weight[2]),   .DI3 (in_weight[3]),   .DI4 (in_weight[4]),   .DI5 (in_weight[5]),   .DI6 (in_weight[6]),   .DI7 (in_weight[7]),
	.DI8 (in_weight[8]),   .DI9 (in_weight[9]),   .DI10(in_weight[10]),  .DI11(in_weight[11]),  .DI12(in_weight[12]),  .DI13(in_weight[13]),  .DI14(in_weight[14]),  .DI15(in_weight[15]),
	.DI16(in_weight[16]),  .DI17(in_weight[17]),  .DI18(in_weight[18]),  .DI19(in_weight[19]),  .DI20(in_weight[20]),  .DI21(in_weight[21]),  .DI22(in_weight[22]),  .DI23(in_weight[23]),
	.DI24(in_weight[24]),  .DI25(in_weight[25]),  .DI26(in_weight[26]),  .DI27(in_weight[27]),  .DI28(in_weight[28]),  .DI29(in_weight[29]),  .DI30(in_weight[30]),  .DI31(in_weight[31]),
	.DI32(in_weight[32]),  .DI33(in_weight[33]),  .DI34(in_weight[34]),  .DI35(in_weight[35]),  .DI36(in_weight[36]),  .DI37(in_weight[37]),  .DI38(in_weight[38]),  .DI39(in_weight[39]),
	.DI40(in_weight[40]),  .DI41(in_weight[41]),  .DI42(in_weight[42]),  .DI43(in_weight[43]),  .DI44(in_weight[44]),  .DI45(in_weight[45]),  .DI46(in_weight[46]),  .DI47(in_weight[47]),
	.DI48(in_weight[48]),  .DI49(in_weight[49]),  .DI50(in_weight[50]),  .DI51(in_weight[51]),  .DI52(in_weight[52]),  .DI53(in_weight[53]),  .DI54(in_weight[54]),  .DI55(in_weight[55]),
	.DI56(in_weight[56]),  .DI57(in_weight[57]),  .DI58(in_weight[58]),  .DI59(in_weight[59]),  .DI60(in_weight[60]),  .DI61(in_weight[61]),  .DI62(in_weight[62]),  .DI63(in_weight[63]),
	.DI64(in_weight[64]),  .DI65(in_weight[65]),  .DI66(in_weight[66]),  .DI67(in_weight[67]),  .DI68(in_weight[68]),  .DI69(in_weight[69]),  .DI70(in_weight[70]),  .DI71(in_weight[71]),
	.DI72(in_weight[72]),  .DI73(in_weight[73]),  .DI74(in_weight[74]),  .DI75(in_weight[75]),  .DI76(in_weight[76]),  .DI77(in_weight[77]),  .DI78(in_weight[78]),  .DI79(in_weight[79]),
	.DI80(in_weight[80]),  .DI81(in_weight[81]),  .DI82(in_weight[82]),  .DI83(in_weight[83]),  .DI84(in_weight[84]),  .DI85(in_weight[85]),  .DI86(in_weight[86]),  .DI87(in_weight[87]),
	.DI88(in_weight[88]),  .DI89(in_weight[89]),  .DI90(in_weight[90]),  .DI91(in_weight[91]),  .DI92(in_weight[92]),  .DI93(in_weight[93]),  .DI94(in_weight[94]),  .DI95(in_weight[95]),
	.DI96(in_weight[96]),  .DI97(in_weight[97]),  .DI98(in_weight[98]),  .DI99(in_weight[99]),  .DI100(in_weight[100]),.DI101(in_weight[101]),.DI102(in_weight[102]),.DI103(in_weight[103]),
	.DI104(in_weight[104]),.DI105(in_weight[105]),.DI106(in_weight[106]),.DI107(in_weight[107]),.DI108(in_weight[108]),.DI109(in_weight[109]),.DI110(in_weight[110]),.DI111(in_weight[111]),
	.DI112(in_weight[112]),.DI113(in_weight[113]),.DI114(in_weight[114]),.DI115(in_weight[115]),.DI116(in_weight[116]),.DI117(in_weight[117]),.DI118(in_weight[118]),.DI119(in_weight[119]),
	.DI120(in_weight[120]),.DI121(in_weight[121]),.DI122(in_weight[122]),.DI123(in_weight[123]),.DI124(in_weight[124]),.DI125(in_weight[125]),.DI126(in_weight[126]),.DI127(in_weight[127]),

	.CK(clk), .WEB(web_weight), .OE(1'b1), .CS(1'b1)
);


//////////////////////////////////////////////////////////////////
//                             FILL                             //
//////////////////////////////////////////////////////////////////

always @(*) begin
	fill_num = 0;
	case(step_cnt)
		0: fill_num = 2'd2;
		1: fill_num = 2'd2;
		2: fill_num = 2'd3;
		3: fill_num = 2'd3;
	endcase
end

always @(posedge clk or negedge rst_n) begin 
	if(!rst_n) 
		step_cnt <= 1;
	else begin
		if(n_IDLE)
			step_cnt <= 1;
		else if(c_state == CLEAR)
			step_cnt <= 1;
		else if(c_FILL)  
			step_cnt <= step_cnt + 1;
		else if(c_RETRACE && !D_FOR_SINK)
			step_cnt <= step_cnt - 2;
		else if(cnt_0_1)
			step_cnt <= step_cnt - 1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i = 0; i < 64; i = i + 1) 
			for(j = 0; j < 64; j = j + 1) 
				map[i][j] <= 0;
	end
	else begin
		if(c_READ_DRAM) begin
			if(rvalid_m_inf == 1) begin
				map[cnt_128[6:1]][offset + 0]  <= rdata_m_inf[3:0]     ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 1]  <= rdata_m_inf[7:4]     ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 2]  <= rdata_m_inf[11:8]    ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 3]  <= rdata_m_inf[15:12]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 4]  <= rdata_m_inf[19:16]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 5]  <= rdata_m_inf[23:20]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 6]  <= rdata_m_inf[27:24]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 7]  <= rdata_m_inf[31:28]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 8]  <= rdata_m_inf[35:32]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 9]  <= rdata_m_inf[39:36]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 10] <= rdata_m_inf[43:40]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 11] <= rdata_m_inf[47:44]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 12] <= rdata_m_inf[51:48]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 13] <= rdata_m_inf[55:52]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 14] <= rdata_m_inf[59:56]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 15] <= rdata_m_inf[63:60]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 16] <= rdata_m_inf[67:64]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 17] <= rdata_m_inf[71:68]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 18] <= rdata_m_inf[75:72]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 19] <= rdata_m_inf[79:76]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 20] <= rdata_m_inf[83:80]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 21] <= rdata_m_inf[87:84]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 22] <= rdata_m_inf[91:88]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 23] <= rdata_m_inf[95:92]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 24] <= rdata_m_inf[99:96]   ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 25] <= rdata_m_inf[103:100] ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 26] <= rdata_m_inf[107:104] ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 27] <= rdata_m_inf[111:108] ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 28] <= rdata_m_inf[115:112] ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 29] <= rdata_m_inf[119:116] ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 30] <= rdata_m_inf[123:120] ? 2'd1 : 2'd0;
				map[cnt_128[6:1]][offset + 31] <= rdata_m_inf[127:124] ? 2'd1 : 2'd0;
			end
		end
		else if(c_state == INITIAL_MAP) begin
			map[source_y[cur_net_num]][source_x[cur_net_num]] <= 2'd2;
			map[sink_y[cur_net_num]][sink_x[cur_net_num]] <= 2'd0;
		end
		else if(c_FILL) begin
			for(i = 1; i < 63; i = i + 1)
				for(j = 1; j < 63; j = j + 1)
					if(map[i][j] == 2'd0 && (map[i-1][j][1] | map[i+1][j][1] | map[i][j-1][1] | map[i][j+1][1]))
						map[i][j] <= fill_num;
						
			for(j = 1; j < 63; j = j + 1) begin
				if(map[0][j] == 2'd0 && (map[0][j-1][1] | map[0][j+1][1] | map[1][j][1]))
					map[0][j] <= fill_num;

				if(map[63][j] == 2'd0 && (map[63][j-1][1] | map[63][j+1][1] | map[62][j][1]))
					map[63][j] <= fill_num;
			end
			
			for(i = 1; i < 63; i = i + 1) begin
				if(map[i][0] == 2'd0 && (map[i-1][0][1] | map[i+1][0][1] | map[i][1][1]))
					map[i][0] <= fill_num;
	
				if(map[i][63] == 2'd0 && (map[i-1][63][1] | map[i+1][63][1] | map[i][62][1]))
					map[i][63] <= fill_num;

			end
			
			if(map[0][0] == 2'd0 && (map[0][1][1] | map[1][0][1]))
				map[0][0] <= fill_num;

				
			if(map[0][63] == 2'd0 && (map[0][62][1] | map[1][63][1]))
				map[0][63] <= fill_num;

				
			if(map[63][0] == 2'd0 && (map[62][0][1] | map[63][1][1]))
				map[63][0] <= fill_num;

				
			if(map[63][63] == 2'd0 && (map[62][63][1] | map[63][62][1]))
				map[63][63] <= fill_num;

		end
		else if(START_RETRACE && !cnt_0_1)
			map[retrace_y][retrace_x] <= 2'd1;
		else if(c_state == CLEAR) begin
			for(i = 0; i < 64; i = i + 1) begin
				for(j = 0; j < 64; j = j + 1) begin
					if(map[i][j][1])
						map[i][j] <= 2'd0;
				end
			end
		end
	end
end



//////////////////////////////////////////////////////////////////
//                           RETRACE                            //
//////////////////////////////////////////////////////////////////


always @(posedge clk or negedge rst_n) begin // ! HERE RETRACE
	if(!rst_n) begin
		retrace_x <= 0;
		retrace_y <= 0;
	end
	else begin
		if(c_RETRACE && !D_FOR_SINK) begin
			retrace_x <= sink_x[cur_net_num]; 
			retrace_y <= sink_y[cur_net_num]; 
		end
		else if(START_RETRACE && cnt_0_1) begin 
			if(map[retrace_y + 1][retrace_x] == fill_num && ~&retrace_y) 
				retrace_y <= retrace_y + 1;
			else if(map[retrace_y - 1][retrace_x] == fill_num && |retrace_y)
				retrace_y <= retrace_y - 1;
			else if(map[retrace_y][retrace_x + 1] == fill_num && ~&retrace_x)
				retrace_x <= retrace_x + 1;
			else
				retrace_x <= retrace_x - 1;
		end

	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		delay_flag <= 0;
	else begin
		if(c_state == INITIAL_MAP)
			delay_flag <= 0;
		else if(START_RETRACE && cnt_0_1 && !delay_flag) 
			delay_flag <= delay_flag + 1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		cnt_0_1 <= 0;
	else begin
		if(n_IDLE) 
			cnt_0_1 <= 0;
		else if(c_state == CLEAR)
			cnt_0_1 <= 0;
		else if(c_RETRACE) 
			cnt_0_1 <= cnt_0_1 + 1;
	end
end


always @(posedge clk or negedge rst_n) begin 
	if(!rst_n) 
		D_FOR_SINK <= 0;
	else 
		D_FOR_SINK <= c_RETRACE;
end

always @(posedge clk or negedge rst_n) begin 
	if(!rst_n) 
		START_RETRACE <= 0;
	else 
		START_RETRACE <= D_FOR_SINK;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		cur_net_num <= 0;
	else begin
		if(n_IDLE)
			cur_net_num <= 0;
		else if(c_state == CLEAR)
			cur_net_num <= cur_net_num + 1;
	end
end

//////////////////////////////////////////////////////////////////
//                          SRAM CTRL                           //
//////////////////////////////////////////////////////////////////

always @(*) begin
	addr_weight = 0;
	in_weight = 0;
	web_weight = 1;
	if(frame_or_weight == 1) begin
		if(rvalid_m_inf == 1) begin
			addr_weight = cnt_128;
			in_weight = rdata_m_inf;
			web_weight = 0;
		end
	end
	else if(!cnt_0_1) begin
		addr_weight = {retrace_y,retrace_x[5]};
	end
end

always @(*) begin
	addr_map = 0;
	in_map = 0;
	web_map = 1;
	if(c_READ_DRAM) begin
		if(rvalid_m_inf == 1) begin
			web_map = 0;
			addr_map = cnt_128;
			in_map = rdata_m_inf;
		end
	end
	else if(c_RETRACE && !cnt_0_1) begin
		addr_map = {retrace_y,retrace_x[5]};
	end
	else if(START_RETRACE && c_RETRACE && cnt_0_1) begin
		web_map = 0;
		addr_map = {retrace_y,retrace_x[5]};
		for(i = 0; i < 32; i = i + 1) begin
			if(retrace_x[4:0] == i)
				in_map[i*4 +: 4] = net_id_reg[cur_net_num];
			else
				in_map[i*4 +: 4] = out_map[i*4 +: 4];
		end
	end
	else if(c_state == WRITE_DRAM) begin
		if(wready_m_inf)
			addr_map = cnt_128;
		else
			addr_map = 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		cnt_128 <= 0;
	else begin
		if(n_IDLE)
			cnt_128 <= 0;
		else if(rvalid_m_inf == 1) 
			cnt_128 <= cnt_128 + 1;
		else if(wready_m_inf == 1'b1)
			cnt_128 <= cnt_128 + 1'b1;
		else if(!D_FOR_SINK && START_RETRACE) 
			cnt_128 <= 1;
	end
end

// always @(posedge clk or negedge rst_n) begin
// 	if(!rst_n) 
// 		frame_or_weight <= 0;
// 	else begin
// 		if(frame_or_weight == 0 && rlast_m_inf == 1)
// 			frame_or_weight <= 1;
// 		else if(frame_or_weight == 1 && rlast_m_inf == 1)
// 			frame_or_weight <= 0;
// 	end
// end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		frame_or_weight <= 0;
	else begin
		case({frame_or_weight, rlast_m_inf})
			2'b01: frame_or_weight <= 1;
			2'b11: frame_or_weight <= 0;
		endcase
	end
end

//////////////////////////////////////////////////////////////////
//                             STATE                            //
//////////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) c_state <= IDLE;
	else c_state <= n_state;
end

always @(*) begin
	n_state = c_state;
	
	case(c_state) 
		IDLE: begin
			if(in_valid)
				n_state = INPUT;
		end
		INPUT: begin
			if(in_valid == 0)
				n_state = READ_DRAM;
		end
		READ_DRAM: begin
			if(rlast_m_inf == 1)
				n_state = INITIAL_MAP;
		end
		INITIAL_MAP: 
			n_state = FILL;
		FILL: begin
			// if(map[sink_y[cur_net_num]][sink_x[cur_net_num]][1] == 1 && cur_net_num == 0) 
			// 	n_state = WAIT_WEIGHT_DONE;
			// else if(map[sink_y[cur_net_num]][sink_x[cur_net_num]][1])
			// 	n_state = RETRACE;
			if(map[sink_y[cur_net_num]][sink_x[cur_net_num]][1])  // !!
				n_state = (cur_net_num) ?  RETRACE : WAIT_WEIGHT_DONE ;

		end
		WAIT_WEIGHT_DONE: begin
			// if(rlast_m_inf == 1)
			// 	n_state = RETRACE;
			n_state = rlast_m_inf ? RETRACE : c_state ;
		end
		RETRACE: begin
			// if(source_y[cur_net_num] == retrace_y && source_x[cur_net_num] == retrace_x) begin
			// 	if(cur_net_num + 1 == input_net_cnt)
			// 		n_state = WRITE_DRAM;
			// 	else
			// 		n_state = CLEAR;
			// end
			if(source_y[cur_net_num] == retrace_y && source_x[cur_net_num] == retrace_x)  // !!
				n_state = (cur_net_num + 1 == input_net_cnt) ? WRITE_DRAM : CLEAR ;
			
		end
		CLEAR: 
			n_state = INITIAL_MAP;
		WRITE_DRAM: begin
			if(bvalid_m_inf)
				n_state = OUTPUT;
		end
		OUTPUT: 
			n_state = IDLE;
	endcase
end

//////////////////////////////////////////////////////////////////
//                            OUTPUT                            //
//////////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) 
		cost <= 0;
	else begin
		if(n_IDLE)
			cost <= 0;
		else if(delay_flag&& c_RETRACE && cnt_0_1)
			cost <= cost + out_weight[retrace_x[4:0]*4 +: 4];
	end
end


always @(*) begin
	busy = 1;

	case(c_state) 
		IDLE: busy = 0;
		INPUT: busy = 0;
		OUTPUT: busy = 0;
		default: busy = 1;
	endcase
end

//////////////////////////////////////////////////////////////////
//                            INPUT                             //
//////////////////////////////////////////////////////////////////

assign offset = cnt_128[0] ? 6'd32 : 6'd0;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i = 0; i <= 14; i = i + 1) 
			net_id_reg[i] <= 0;
	end
	else begin
		if(n_INPUT)
			net_id_reg[input_net_cnt] <= net_id;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i = 0; i <= 14; i = i + 1) begin
			source_x[i] <= 0;
			source_y[i] <= 0;
			sink_x[i] <= 0;
			sink_y[i] <= 0;
		end
	end
	else begin
		if(n_INPUT) begin
			if(input_cnt == 0) begin
				source_x[input_net_cnt] <= loc_x;
				source_y[input_net_cnt] <= loc_y;
			end
			else begin
				sink_x[input_net_cnt] <= loc_x;
				sink_y[input_net_cnt] <= loc_y;
			end
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		frame_id_reg <= 0;
	else begin
		if(n_INPUT)
			frame_id_reg <= frame_id;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		input_cnt <= 0;
	else begin
		if(n_IDLE)
			input_cnt <= 0;
		else if(n_INPUT)
			input_cnt <= input_cnt + 1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		input_net_cnt <= 0;
	else begin
		if(n_IDLE)
			input_net_cnt <= 0;
		else if(n_INPUT) begin
			if(input_cnt == 1)
				input_net_cnt <= input_net_cnt + 1;
		end
	end
end

//////////////////////////////////////////////////////////////////
//                           AXI READ                           //
//////////////////////////////////////////////////////////////////

assign arid_m_inf = 4'd0;
assign arburst_m_inf = 2'b01;
assign arsize_m_inf = 3'b100;
assign arlen_m_inf = 8'd127;

always @(*) begin
	arvalid_m_inf = 0;
	araddr_m_inf = 0;

	rready_m_inf = 0;

	if(c_READ_DRAM || frame_or_weight == 1) begin
		case(c_state_read)
			0: begin // AR_VALID STATE
					arvalid_m_inf = 1;
					
				case(frame_or_weight)
					0: araddr_m_inf = {16'h1, frame_id_reg, 11'h0};
					1: araddr_m_inf = {16'h2, frame_id_reg, 11'h0};
				endcase
			end
			1: begin // R_VALID STATE
				rready_m_inf = 1;

			end
		endcase
	end
end

always @(*) begin
	n_state_read = c_state_read;

	if(c_READ_DRAM || frame_or_weight == 1) begin
		case(c_state_read)
			0: begin // AR_VALID STATE
					if(arready_m_inf == 1)
						n_state_read = 1; // R_VALID STATE
			end
			1: begin // R_VALID STATE
				if(rlast_m_inf == 1)
					n_state_read = 0; // AR_VALID STATE
			end
		endcase
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) c_state_read <= 0;  // AR_VALID STATE
	else c_state_read <= n_state_read;
end

//////////////////////////////////////////////////////////////////
//                          AXI WRITE                           //
//////////////////////////////////////////////////////////////////


	assign awid_m_inf = 0;
	assign awburst_m_inf = 2'b01;
	assign awsize_m_inf = 3'b100;
	assign awlen_m_inf = 8'd127;
	assign wdata_m_inf = out_map;


	always @(*) begin
		awvalid_m_inf = 0;
		awaddr_m_inf = 0;

		wvalid_m_inf = 0;
		wlast_m_inf = 0;

		bready_m_inf = 0;

		if(c_state == WRITE_DRAM) begin
			case(c_state_write)
				0: begin // AW_VALID STATE
					awvalid_m_inf = 1;
					awaddr_m_inf = {16'h1, frame_id_reg, 11'h0};
				end
				1: begin  // W_VALID STATE
					wvalid_m_inf = 1;
					bready_m_inf = 1;
					
					if(write_cnt == awlen_m_inf)
						wlast_m_inf = 1;
				end
			endcase
		end
	end

	always @(*) begin
		n_state_write = c_state_write;

		if(c_state == WRITE_DRAM) begin
			case(c_state_write)
				0: begin // AW_VALID STATE
					if(awready_m_inf == 1'b1)
						n_state_write = 1; // W_VALID STATE
				end
				1: begin // W_VALID STATE
					if(bvalid_m_inf == 1'b1)
						n_state_write = 0; // AW_VALID STATE
				end
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) c_state_write <= 0; // AW_VALID STATE
		else c_state_write <= n_state_write;
	end


	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) write_cnt <= 0;
		else begin
			if(bvalid_m_inf == 1'b1)
				write_cnt <= 0;
			else if(wready_m_inf == 1'b1)
				write_cnt <= write_cnt + 1'b1;
		end
	end

endmodule
