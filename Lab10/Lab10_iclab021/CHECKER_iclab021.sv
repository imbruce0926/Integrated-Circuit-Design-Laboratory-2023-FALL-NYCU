/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2023 Autumn IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: Nov-2023)
Author : Jui-Huang Tsai (erictsai.10@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype_BEV.sv"
module Checker(input clk, INF.CHECKER inf);
import usertype::*;

/*
    Coverage Part
*/
class BEV;
    Bev_Type bev_type;
    Bev_Size bev_size;
endclass

Action act;
logic [1:0] cnt_4;

BEV bev_info = new();

always_ff @(posedge clk) begin
    if (inf.type_valid) begin
        bev_info.bev_type = inf.D.d_type[0];
    end
end

always_ff @(posedge clk) begin
    if (inf.size_valid) begin
        bev_info.bev_size = inf.D.d_size[0];
    end
end

always_ff @(posedge clk) begin
    if (inf.sel_action_valid) begin
        act = inf.D.d_act[0];
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        cnt_4 <= 0;
    else begin
        if(inf.box_sup_valid)
            cnt_4 <= cnt_4 + 1;
    end
end


/*
1. Each case of Beverage_Type should be select at least 100 times.
*/


covergroup Spec1 @(posedge clk iff (inf.type_valid));
    option.per_instance = 1;
    option.at_least = 100;
    btype: coverpoint bev_info.bev_type{
        bins b_bev_type [] = {[Black_Tea:Super_Pineapple_Milk_Tea]};
    }
endgroup


/*
2.	Each case of Bererage_Size should be select at least 100 times.
*/

covergroup Spec2 @(posedge clk iff (inf.size_valid));
    option.per_instance = 1;
    option.at_least = 100;
    bsize: coverpoint bev_info.bev_size{
        bins b_bev_size [] = {L, M, S};
    }
endgroup


/*
3.	Create a cross bin for the SPEC1 and SPEC2. Each combination should be selected at least 100 times. 
(Black Tea, Milk Tea, Extra Milk Tea, Green Tea, Green Milk Tea, Pineapple Juice, Super Pineapple Tea, Super Pineapple Tea) x (L, M, S)
*/

covergroup Spec3 @(posedge clk iff (inf.size_valid));
    option.per_instance = 1;
    option.at_least = 100;
    btype: coverpoint bev_info.bev_type;
    bsize: coverpoint bev_info.bev_size;
    btype_bsize: cross bev_info.bev_type, bev_info.bev_size;
endgroup

/*
4.	Output signal inf.err_msg should be No_Err, No_Exp, No_Ing and Ing_OF, each at least 20 times. (Sample the value when inf.out_valid is high)
*/

covergroup Spec4 @(posedge clk iff (inf.out_valid));
    option.per_instance = 1;
    option.at_least = 20;
    err_msg: coverpoint inf.err_msg{
        bins err_msg [] = {No_Err, No_Exp, No_Ing, Ing_OF};
    }
endgroup

/*
5.	Create the transitions bin for the inf.D.act[0] signal from [0:2] to [0:2]. Each transition should be hit at least 200 times. (sample the value at posedge clk iff inf.sel_action_valid)
*/

covergroup Spec5 @(posedge clk iff (inf.sel_action_valid));
    option.per_instance = 1;
    option.at_least = 200;
    act_trans: coverpoint inf.D.d_act[0]{
        bins act [] = ([Make_drink:Check_Valid_Date] => [Make_drink:Check_Valid_Date]);
    }
endgroup

/*
6.	Create a covergroup for material of supply action with auto_bin_max = 32, and each bin have to hit at least one time.
*/

covergroup Spec6 @(posedge clk iff (inf.box_sup_valid));
    option.per_instance = 1;
    option.at_least = 1;
    d_ing: coverpoint inf.D.d_ing[0]{
        option.auto_bin_max = 32;
    }
endgroup

/*
    Create instances of Spec1, Spec2, Spec3, Spec4, Spec5, and Spec6
*/
Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();
Spec6 cov_inst_6 = new();

/*
    Asseration
*/

/*
    If you need, you can declare some FSM, logic, flag, and etc. here.
*/

/*
    1. All outputs signals (including BEV.sv and bridge.sv) should be zero after reset.
*/
wire #(1) rst_reg = inf.rst_n;

assert_reset : assert property ( @(negedge rst_reg) (inf.out_valid === 'd0      && inf.err_msg === 'd0  && inf.complete === 'd0     && 
													 inf.C_addr === 'd0         && inf.C_data_w ==='d0  && inf.C_in_valid === 'd0   && inf.C_r_wb === 'd0   &&
													 inf.C_out_valid === 'd0    && inf.C_data_r === 'd0 && inf.AR_VALID === 'd0     && inf.AR_ADDR === 'd0  && 
													 inf.R_READY === 'd0        && inf.AW_VALID === 'd0 && inf.AW_ADDR === 'd0      && inf.W_VALID === 'd0  && 
                                                     inf.W_DATA === 'd0         && inf.B_READY === 'd0))
else begin
    $display("************************************************************");  
    $display("*               Assertion 1 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end
/*
    2.	Latency should be less than 1000 cycles for each operation.
*/
assert_latency : assert property ( op_latency )
else begin	
    $display("************************************************************");  
    $display("*               Assertion 2 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end

property op_latency;
	@(posedge clk) (make_latency or supply_latency or check_latency);
endproperty

property make_latency;
	@(posedge clk)	(inf.box_no_valid && act === Make_drink) |-> (##[1:1000] inf.out_valid);
endproperty

property supply_latency; 
	@(posedge clk)	(inf.box_sup_valid && cnt_4 === 3 && act === Supply ) |-> ( ##[1:1000] inf.out_valid);
endproperty

property check_latency; 
	@(posedge clk)	(inf.box_no_valid && act === Check_Valid_Date) |-> ( ##[1:1000] inf.out_valid);
endproperty

/*
    3. If out_valid does not pull up, complete should be 0.
    3. If action is completed (complete=1), err_msg should be 2’b0 (no_err).
*/

assert_complete : assert property (@(negedge clk) (inf.out_valid === 1 && inf.complete === 1) |-> (inf.err_msg === No_Err) )
else begin	
    $display("************************************************************");  
    $display("*               Assertion 3 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end

/*
    4. Next input valid will be valid 1-4 cycles after previous input valid fall.
*/
assert_gap_make1 : assert property (@(posedge clk) ((inf.D.d_act[0] === Make_drink && inf.sel_action_valid) |-> ##[1:4](inf.type_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end
assert_gap_make2 : assert property (@(posedge clk) ((act === Make_drink && inf.type_valid) |-> ##[1:4](inf.size_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end
assert_gap_make3 : assert property (@(posedge clk) ((act === Make_drink && inf.size_valid) |-> ##[1:4](inf.date_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end
assert_gap_make4 : assert property (@(posedge clk) ((act === Make_drink && inf.date_valid) |-> ##[1:4](inf.box_no_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end

assert_gap_supply1 : assert property (@(posedge clk) ((inf.D.d_act[0] === Supply && inf.sel_action_valid) |-> ##[1:4](inf.date_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end
assert_gap_supply2 : assert property (@(posedge clk) ((act === Supply && inf.date_valid) |-> ##[1:4](inf.box_no_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end
assert_gap_supply3 : assert property (@(posedge clk) ((act === Supply && inf.box_no_valid) |-> ##[1:4](inf.box_sup_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end
assert_gap_supply4 : assert property (@(posedge clk) ((act === Supply && inf.box_sup_valid && cnt_4 != 3) |-> ##[1:4](inf.box_sup_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end

assert_gap_check1 : assert property (@(posedge clk) ((inf.D.d_act[0] === Check_Valid_Date && inf.sel_action_valid) |-> ##[1:4](inf.date_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end
assert_gap_check2 : assert property (@(posedge clk) ((act === Check_Valid_Date && inf.date_valid) |-> ##[1:4](inf.box_no_valid)))
else begin
    $display("************************************************************");  
    $display("*               Assertion 4 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end

/*
    5. All input valid signals won't overlap with each other. 
*/
logic [2:0] overlap;

assign overlap = inf.sel_action_valid + inf.type_valid + inf.size_valid + inf.date_valid + inf.box_no_valid + inf.box_sup_valid;

// always_ff@(negedge clk) begin
//     $display(overlap);
// end

assert_overlap : assert property (@(posedge clk) (overlap <= 1))
else begin
    $display("************************************************************");  
    $display("*               Assertion 5 is violated !                  *");    
    $display("************************************************************");
    $display(overlap);
	$fatal; 
end

/*
    6. Out_valid can only be high for exactly one cycle.
*/

assert_out_valid : assert property (@(negedge clk) (inf.out_valid === 1) |=> (inf.out_valid === 0))
else begin
    $display("************************************************************");  
    $display("*               Assertion 6 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end

/*
    7. Next operation will be valid 1-4 cycles after out_valid fall.
*/

assert_out_in : assert property (@(posedge clk) (inf.out_valid === 1) |-> ##[1:4](inf.sel_action_valid != 0))
else begin
    $display("************************************************************");  
    $display("*               Assertion 7 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end

/*
    8. The input date from pattern should adhere to the real calendar. (ex: 2/29, 3/0, 4/31, 13/1 are illegal cases)
*/

assert_date : assert property ( date_check )
else begin	
    $display("************************************************************");  
    $display("*               Assertion 8 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end

property date_check;
	@(posedge clk) (M_1 or M_2 or M_3 or M_4 or M_5 or M_6 or M_7 or M_8 or M_9 or M_10 or M_11 or M_12);
endproperty

property M_1;
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 1 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 31);
endproperty

property M_2; 
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 2 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 28);
endproperty

property M_3; 
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 3 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 31);
endproperty

property M_4;
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 4 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 30);
endproperty

property M_5; 
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 5 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 31);
endproperty

property M_6; 
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 6 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 30);
endproperty

property M_7;
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 7 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 31);
endproperty

property M_8; 
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 8 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 31);
endproperty

property M_9; 
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 9 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 30);
endproperty

property M_10;
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 10 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 31);
endproperty

property M_11; 
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 11 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 30);
endproperty

property M_12; 
	@(posedge clk)	(inf.date_valid) |-> (inf.D.d_date[0].M == 12 and inf.D.d_date[0].D >= 1 and inf.D.d_date[0].D <= 31);
endproperty

/*
    9. C_in_valid can only be high for one cycle and can't be pulled high again before C_out_valid
*/
assert_C_in_valid_1 : assert property ( @(negedge clk) (inf.C_in_valid === 1) |=> (inf.C_in_valid ===0))
else begin	
    $display("************************************************************");  
    $display("*               Assertion 9 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end
logic flag;
always_ff @(posedge clk) begin
    if(!inf.rst_n)
        flag <= 0;
    else begin
        if(inf.C_in_valid)
            flag <= 1;
        else if(inf.C_out_valid)
            flag <= 0;
    end
end

assert_C_in_valid_2 : assert property ( @(negedge clk) (flag === 1) |-> (inf.C_in_valid ===0) )
else begin	
    $display("************************************************************");  
    $display("*               Assertion 9 is violated !                  *");    
    $display("************************************************************");
	$fatal; 
end


endmodule