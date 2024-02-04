//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

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
       bready_m_inf,
                    
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
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  reg [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  reg [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  reg [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  reg [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  reg [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  reg [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  reg [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  reg [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;


//####################################################
//               reg & wire
//####################################################

reg [11:0] inst_PC, data_PC;
reg [11:0] inst_start_PC, data_start_PC;
reg [6:0] addr_inst, addr_data;
reg [15:0] out_inst, out_data, in_inst, in_data;
reg web_inst, web_data;
reg [15:0] dram_write_in;
reg [4:0] c_state, n_state;
reg [6:0] cnt_128;

reg [2:0] opcode;
reg [3:0] rs, rt, rd;
reg func;
reg signed [4:0] immediate;
reg [12:0] jump_addr;

reg signed [15:0] rs_reg, rt_reg, rd_reg;

reg data_cache_empty;

parameter IDLE = 0;
parameter READ_INST_MEM = 1;
parameter WAIT_LAST_INST = 2;
parameter FETCH = 3;
parameter DECODE = 4;
parameter EXE = 5;
parameter BUF = 6;
parameter READ_DATA_MEM = 7;
parameter WAIT_LAST_DATA = 8;
parameter CHECK_RANGE = 9;
parameter WAIT_DARA_CACHE = 10;
parameter LOAD = 11;
parameter STORE = 12;
parameter WRITE_BACK = 13;
// parameter WRITE_BACK_BUF = 14;



//###########################################
//
// Wrtie down your design below
//
//###########################################

////////////////////////////////////////////////////////////
//                         STATE                          //
////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) c_state <= IDLE;
  else c_state <= n_state;
end

always @(*) begin
  n_state = c_state;
  case(c_state)
    IDLE: begin
      n_state = READ_INST_MEM;
    end
    READ_INST_MEM: begin
      n_state = (rlast_m_inf[1]) ? WAIT_LAST_INST : c_state ;
    end
    WAIT_LAST_INST: begin
      n_state = FETCH;
    end
    FETCH: begin
      n_state = DECODE;
    end
    DECODE: begin
      n_state = EXE;
    end
    EXE: begin
      case(opcode)
        3'b010: n_state = BUF;          // Load
        3'b011: n_state = STORE;        // Store
        3'b100: n_state = CHECK_RANGE;  // Branch 
        3'b101: n_state = CHECK_RANGE;  // Jump
        default: n_state = WRITE_BACK;  // R type
      endcase
    end
    BUF: begin
      n_state = (data_cache_empty == 0 || data_PC >= data_start_PC + 256 || data_PC < data_start_PC) ? READ_DATA_MEM : WAIT_LAST_DATA ;
    end
    READ_DATA_MEM: begin
      n_state = (rlast_m_inf[0]) ? WAIT_LAST_DATA : c_state ;
    end
    WAIT_LAST_DATA: begin
      n_state = WAIT_DARA_CACHE;
    end
    CHECK_RANGE: begin
      n_state = (inst_PC >= inst_start_PC + 256 || inst_PC < inst_start_PC) ? READ_INST_MEM : FETCH ;
    end
    WAIT_DARA_CACHE: begin
      n_state = LOAD;
    end
    LOAD: begin
      n_state = (inst_PC >= inst_start_PC + 256 || inst_PC < inst_start_PC) ? READ_INST_MEM : FETCH ;
    end
    STORE: begin
      n_state = (bvalid_m_inf) ? ((inst_PC >= inst_start_PC + 256 || inst_PC < inst_start_PC) ? READ_INST_MEM : FETCH) : c_state ;
    end
    WRITE_BACK: begin
      // n_state = WRITE_BACK_BUF;
      n_state = (inst_PC >= inst_start_PC + 256 || inst_PC < inst_start_PC) ? READ_INST_MEM : FETCH ;
    end
    // WRITE_BACK_BUF: begin 
    //   n_state = (inst_PC >= inst_start_PC + 256 || inst_PC < inst_start_PC) ? READ_INST_MEM : FETCH ;
    // end

  endcase
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    data_cache_empty <= 0;
  else begin
    if(c_state == LOAD)
      data_cache_empty <= 1;
  end
end

////////////////////////////////////////////////////////////
//                        OUTPUT                          //
////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) 
    IO_stall <= 1;
  else begin
    if(c_state == CHECK_RANGE || c_state == LOAD || (c_state == STORE && bvalid_m_inf == 1'b1) || c_state == WRITE_BACK)
      IO_stall <= 0;
    else
      IO_stall <= 1;
  end
end

////////////////////////////////////////////////////////////
//                        DECODE                          //
////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    opcode <= 0;
    rs <= 0; 
    rt <= 0; 
    rd <= 0;
    func <= 0;
    immediate <= 0;
    jump_addr <= 0;
  end
  else begin
    if(c_state == DECODE) begin
      opcode <= out_inst[15:13];
      rs <= out_inst[12:9];
      rt <= out_inst[8:5];
      rd <= out_inst[4:1];
      func <= out_inst[0];
      immediate <= out_inst[4:0];
      jump_addr <= out_inst[12:0];
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    rs_reg <= 0;
    rt_reg <= 0;
  end
  else begin
    if(c_state == DECODE) begin
      case(out_inst[12:9])
        0: rs_reg <= core_r0;
        1: rs_reg <= core_r1;
        2: rs_reg <= core_r2;
        3: rs_reg <= core_r3;
        4: rs_reg <= core_r4;
        5: rs_reg <= core_r5;
        6: rs_reg <= core_r6;
        7: rs_reg <= core_r7;
        8: rs_reg <= core_r8;
        9: rs_reg <= core_r9;
        10: rs_reg <= core_r10;
        11: rs_reg <= core_r11;
        12: rs_reg <= core_r12;
        13: rs_reg <= core_r13;
        14: rs_reg <= core_r14;
        15: rs_reg <= core_r15;
      endcase

      case(out_inst[8:5])
        0: rt_reg <= core_r0;
        1: rt_reg <= core_r1;
        2: rt_reg <= core_r2;
        3: rt_reg <= core_r3;
        4: rt_reg <= core_r4;
        5: rt_reg <= core_r5;
        6: rt_reg <= core_r6;
        7: rt_reg <= core_r7;
        8: rt_reg <= core_r8;
        9: rt_reg <= core_r9;
        10: rt_reg <= core_r10;
        11: rt_reg <= core_r11;
        12: rt_reg <= core_r12;
        13: rt_reg <= core_r13;
        14: rt_reg <= core_r14;
        15: rt_reg <= core_r15;
      endcase
    end
  end
end

////////////////////////////////////////////////////////////
//                         EXE                            //
////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    rd_reg <= 0;
  else begin
    if(c_state == EXE) begin
      if(opcode == 3'b000) begin
        case(func)
          0: rd_reg <= rs_reg + rt_reg; // ADD
          1: rd_reg <= rs_reg - rt_reg; // SUB
        endcase
      end
      else if(opcode == 3'b001) begin
        case(func)
          0: rd_reg <= (rs_reg < rt_reg) ? 1 : 0; // SLT
          1: rd_reg <= rs_reg * rt_reg; // MULT
        endcase
      end
    end
  end
end

////////////////////////////////////////////////////////////
//                       REG FILE                         //
////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    core_r0 <= 0;
    core_r1 <= 0;
    core_r2 <= 0;
    core_r3 <= 0;
    core_r4 <= 0;
    core_r5 <= 0;
    core_r6 <= 0;
    core_r7 <= 0;
    core_r8 <= 0;
    core_r9 <= 0;
    core_r10 <= 0;
    core_r11 <= 0;
    core_r12 <= 0;
    core_r13 <= 0;
    core_r14 <= 0;
    core_r15 <= 0;
  end
  else begin
    if(c_state == LOAD) begin
      case(rt)
        0: core_r0 <= out_data;
        1: core_r1 <= out_data;
        2: core_r2 <= out_data;
        3: core_r3 <= out_data;
        4: core_r4 <= out_data;
        5: core_r5 <= out_data;
        6: core_r6 <= out_data;
        7: core_r7 <= out_data;
        8: core_r8 <= out_data;
        9: core_r9 <= out_data;
        10: core_r10 <= out_data;
        11: core_r11 <= out_data;
        12: core_r12 <= out_data;
        13: core_r13 <= out_data;
        14: core_r14 <= out_data;
        15: core_r15 <= out_data;
      endcase
    end
    else if(c_state == WRITE_BACK)begin
      case(rd)
        0: core_r0 <= rd_reg;
        1: core_r1 <= rd_reg;
        2: core_r2 <= rd_reg;
        3: core_r3 <= rd_reg;
        4: core_r4 <= rd_reg;
        5: core_r5 <= rd_reg;
        6: core_r6 <= rd_reg;
        7: core_r7 <= rd_reg;
        8: core_r8 <= rd_reg;
        9: core_r9 <= rd_reg;
        10: core_r10 <= rd_reg;
        11: core_r11 <= rd_reg;
        12: core_r12 <= rd_reg;
        13: core_r13 <= rd_reg;
        14: core_r14 <= rd_reg;
        15: core_r15 <= rd_reg;
      endcase
    end
  end

end

////////////////////////////////////////////////////////////
//                           PC                           //
////////////////////////////////////////////////////////////

wire signed [12:0] inst_PC_signed;
wire signed [11:0] inst_PC_signed_beq;

assign inst_PC_signed = {1'b0, inst_PC};
assign inst_PC_signed_beq = inst_PC_signed + 2 + (immediate << 1);

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) 
    inst_PC <= 0;
  else begin
    if(c_state == EXE) begin
      if(opcode == 3'b100 && rs_reg == rt_reg)  // Branch
        inst_PC <= inst_PC_signed_beq;
      else if(opcode == 3'b101)  // Jump
        inst_PC <= jump_addr[11:0];
      else 
        inst_PC <= inst_PC + 2;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) 
    data_PC <= 0;
  else begin
    if(c_state == EXE) begin
      if(opcode[1] == 1'b1) // Load, Store
        data_PC <= (rs_reg + immediate) << 1;
    end
  end
end


////////////////////////////////////////////////////////////
//                        SRAM SIG                        //
////////////////////////////////////////////////////////////

always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    cnt_128 <= 0;
  else begin
    if(c_state == READ_INST_MEM) begin
      if(rvalid_m_inf[1] == 1'b1)
        cnt_128 <= cnt_128 + 1;
    end
    else if(c_state == READ_DATA_MEM) begin
      if(rvalid_m_inf[0] == 1'b1)
        cnt_128 <= cnt_128 + 1;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    addr_inst <= 0;
    in_inst <= 0;
    web_inst <= 1;
  end
  else begin
    if(c_state == READ_INST_MEM) begin
      if(rvalid_m_inf[1] == 1'b1) begin
        addr_inst <= cnt_128;
        in_inst <= rdata_m_inf[31:16];
        web_inst <= 0;
      end
    end
    else begin
      addr_inst <= (inst_PC - inst_start_PC) >> 1;
      in_inst <= 0;
      web_inst <= 1;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    addr_data <= 0;
    in_data <= 0;
    web_data <= 1;
  end
  else begin
    if(c_state == READ_DATA_MEM) begin
        addr_data <= cnt_128;
        in_data <= rdata_m_inf[15:0];
        web_data <= 0;
    end
    else if(c_state == WAIT_LAST_DATA) begin
      addr_data <= (data_PC - data_start_PC) >> 1;
      in_data <= 0;
      web_data <= 1;
    end
    else if(c_state == STORE && (data_PC >= data_start_PC && data_PC <= data_start_PC + 255)) begin
      addr_data <= (data_PC - data_start_PC) >> 1;
      in_data <= rt_reg;
      web_data <= 0;
    end
    else begin
      addr_data <= 0;
      in_data <= 0;
      web_data <= 1;
    end
  end

end


CACHE INST_CACHE(
 .A0  (addr_inst[0]),   .A1  (addr_inst[1]),   .A2  (addr_inst[2]),   .A3  (addr_inst[3]),   .A4  (addr_inst[4]),   .A5  (addr_inst[5]),   .A6  (addr_inst[6]),

 .DO0 (out_inst[0]),   .DO1 (out_inst[1]),   .DO2 (out_inst[2]),   .DO3 (out_inst[3]),   .DO4 (out_inst[4]),   .DO5 (out_inst[5]),   .DO6 (out_inst[6]),   .DO7 (out_inst[7]),
 .DO8 (out_inst[8]),   .DO9 (out_inst[9]),   .DO10(out_inst[10]),  .DO11(out_inst[11]),  .DO12(out_inst[12]),  .DO13(out_inst[13]),  .DO14(out_inst[14]),  .DO15(out_inst[15]),

 .DI0 (in_inst[0]),   .DI1 (in_inst[1]),   .DI2 (in_inst[2]),   .DI3 (in_inst[3]),   .DI4 (in_inst[4]),   .DI5 (in_inst[5]),   .DI6 (in_inst[6]),   .DI7 (in_inst[7]),
 .DI8 (in_inst[8]),   .DI9 (in_inst[9]),   .DI10(in_inst[10]),  .DI11(in_inst[11]),  .DI12(in_inst[12]),  .DI13(in_inst[13]),  .DI14(in_inst[14]),  .DI15(in_inst[15]),

 .CK(clk), .WEB(web_inst), .OE(1'b1), .CS(1'b1)
);

CACHE DATA_CACHE(
 .A0  (addr_data[0]),   .A1  (addr_data[1]),   .A2  (addr_data[2]),   .A3  (addr_data[3]),   .A4  (addr_data[4]),   .A5  (addr_data[5]),   .A6  (addr_data[6]),

 .DO0 (out_data[0]),   .DO1 (out_data[1]),   .DO2 (out_data[2]),   .DO3 (out_data[3]),   .DO4 (out_data[4]),   .DO5 (out_data[5]),   .DO6 (out_data[6]),   .DO7 (out_data[7]),
 .DO8 (out_data[8]),   .DO9 (out_data[9]),   .DO10(out_data[10]),  .DO11(out_data[11]),  .DO12(out_data[12]),  .DO13(out_data[13]),  .DO14(out_data[14]),  .DO15(out_data[15]),

 .DI0 (in_data[0]),   .DI1 (in_data[1]),   .DI2 (in_data[2]),   .DI3 (in_data[3]),   .DI4 (in_data[4]),   .DI5 (in_data[5]),   .DI6 (in_data[6]),   .DI7 (in_data[7]),
 .DI8 (in_data[8]),   .DI9 (in_data[9]),   .DI10(in_data[10]),  .DI11(in_data[11]),  .DI12(in_data[12]),  .DI13(in_data[13]),  .DI14(in_data[14]),  .DI15(in_data[15]),

 .CK(clk), .WEB(web_data), .OE(1'b1), .CS(1'b1)
);


////////////////////////////////////////////////////////////
//                        AXI READ                        //
////////////////////////////////////////////////////////////

assign arsize_m_inf = {3'b001,3'b001};
assign arid_m_inf = 8'd0;
assign arburst_m_inf = {2'b01,2'b01};
assign arlen_m_inf = {7'd127,7'd127};


reg [1:0] c_state_read, n_state_read;


always @(*) begin
	rready_m_inf = 2'b00;

  if(c_state == READ_INST_MEM) begin // READ_INST_MEM STATE
		case(c_state_read)
			0: ; // AR_VALID STATE
			1: rready_m_inf = 2'b10; // R_VALID STATE
		endcase
	end
  else if(c_state == READ_DATA_MEM) begin // READ_DATA_MEM STATE
		case(c_state_read)
			0: ; // AR_VALID STATE
			1: rready_m_inf = 2'b01; // R_VALID STATE
		endcase
  end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
    arvalid_m_inf <= 0;
    araddr_m_inf <= 0;
  end
	else begin
    if(n_state_read == 1) begin
      arvalid_m_inf <= 0;
      araddr_m_inf <= 0;
    end
    else if(c_state == READ_INST_MEM) begin // READ_INST_MEM STATE
      case(c_state_read)
        0: begin // AR_VALID STATE
					arvalid_m_inf <= 2'b10;
					
          if(inst_PC > 3840) 
              araddr_m_inf <= {20'h00001, 12'd3840, 16'd0, 16'h1000};
          else 
              araddr_m_inf <= {20'h00001,inst_PC,16'd0,16'h1000};
        end
      endcase
    end
    else if(c_state == READ_DATA_MEM) begin // READ_DATA_MEM STATE
      case(c_state_read)
        0: begin // AR_VALID STATE
					arvalid_m_inf <= 2'b01;
					
          if(data_PC > 3840) 
              araddr_m_inf <= {16'd0, 16'h1000, 20'h00001, 12'd3840};
          else 
              araddr_m_inf <= {16'd0, 16'h1000, 20'h00001, data_PC};
        end
      endcase
    end
  end
end


always @(*) begin
	n_state_read = c_state_read;

	if(c_state == READ_INST_MEM) begin // READ_INST_MEM STATE
		case(c_state_read)
			0: begin // AR_VALID STATE
					if(arready_m_inf[1] == 1'b1)
						n_state_read = 1; // R_VALID STATE
			end
			1: begin // R_VALID STATE
				if(rlast_m_inf[1] == 1'b1)
					n_state_read = 0; // AR_VALID STATE
			end
		endcase
	end
  else if(c_state == READ_DATA_MEM) begin // READ_DATA_MEM STATE
		case(c_state_read)
			0: begin // AR_VALID STATE
					if(arready_m_inf[0] == 1'b1)
						n_state_read = 1; // R_VALID STATE
			end
			1: begin // R_VALID STATE
				if(rlast_m_inf[0] == 1'b1)
					n_state_read = 0; // AR_VALID STATE
			end
		endcase
  end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) c_state_read <= 0;  // AR_VALID STATE
	else c_state_read <= n_state_read;
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) 
    inst_start_PC <= 0;
  else begin
    if(c_state == READ_INST_MEM && c_state_read == 0) begin // READ_INST_MEM STATE
      if(inst_PC > 3840) 
          inst_start_PC <= 3840;
      else 
          inst_start_PC <= inst_PC;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    data_start_PC <= 0;
  end
  else begin
    if(c_state == READ_DATA_MEM && c_state_read == 0) begin // READ_DATA_MEM STATE
      if(data_PC > 3840) 
          data_start_PC <= 3840;
      else 
          data_start_PC <= data_PC;
    end
  end
end


////////////////////////////////////////////////////////////
//                        AXI WRITE                       //
////////////////////////////////////////////////////////////

reg [1:0] c_state_write, n_state_write;

 	assign awid_m_inf = 4'b0000;
	assign awburst_m_inf = 2'b01;
	assign awsize_m_inf = 3'b001;
	assign awlen_m_inf = 0;
	assign wdata_m_inf = rt_reg;


	always @(*) begin
		wvalid_m_inf = 0;
		wlast_m_inf = 0;

		if(c_state == STORE) begin // STORE STATE
			case(c_state_write)
				0: begin // AW_VALID STATE
				end
				1: begin  // W_VALID STATE
					wvalid_m_inf = 1;
					wlast_m_inf = 1;
				end
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		  awvalid_m_inf <= 0;
      awaddr_m_inf <= 0;
    end
    else begin
      if(n_state_write == 1) begin
        awvalid_m_inf <= 0;
        awaddr_m_inf <= 0;
      end
      else if(c_state == STORE) begin // STORE STATE
        case(c_state_write)
          0: begin // AW_VALID STATE
            awvalid_m_inf <= 1;
            awaddr_m_inf <= {20'h00001,12'd0,20'h00001,data_PC};
          end
        endcase
      end
    end
	end
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
      bready_m_inf <= 0;
    else begin
      if(n_state_write == 1) 
        bready_m_inf <= 1;
      else if(wlast_m_inf) 
        bready_m_inf <= 0;
    end
  end

	always @(*) begin
		n_state_write = c_state_write;

		if(c_state == STORE) begin // STORE STATE
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

endmodule