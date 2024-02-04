/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2023 Autumn IC Design Laboratory 
Lab09: SystemVerilog Design and Verification 
File Name   : PATTERN.sv
Module Name : PATTERN
Release version : v1.0 (Release Date: Nov-2023)
Author : Jui-Huang Tsai (erictsai.10@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/


`include "Usertype_BEV.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";

// real CYCLE = 4;
integer PATNUM = 10000;
integer seed = 231;

integer i, j, k;
integer latency, patCount, total_latency;
integer gap;

//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)]; 
Error_Msg golden_err_msg; 
logic golden_complete;

Bev_Bal in_DRAM;
Action act_id;
Order_Info input_order;
Date input_date;

logic [7:0] box_id;
logic [11:0] sup_black_tea, sup_green_tea, sup_milk, sup_pineapple_juice;


logic [9:0] volume;
logic Black_Tea_ENOUGH, Green_Tea_ENOUGH, Milk_ENOUGH, Pineapple_Juice_ENOUGH;
logic is_NOT_ENOUGH, is_EXPIRED;

logic [12:0] black_tea_total;
logic [12:0] green_tea_total;
logic [12:0] milk_total;
logic [12:0] pineapple_juice_total;

//================================================================
// class random
//================================================================

class c_random_act;
    randc Action act_id;
	function new(int seed); 
		this.srandom(seed); 
	endfunction
    constraint range{
        act_id inside{Make_drink, Supply, Check_Valid_Date};
        // act_id inside{Make_drink, Supply};
        // act_id inside{Make_drink};
        // act_id inside{Supply};
    }
endclass

class C_random_order;
    randc Order_Info input_order;
    function new(int seed); 
		this.srandom(seed); 
	endfunction
    constraint range{
        input_order.Bev_Type_O inside{Black_Tea, Milk_Tea, Extra_Milk_Tea, Green_Tea, Green_Milk_Tea, 
                                   Pineapple_Juice, Super_Pineapple_Tea, Super_Pineapple_Milk_Tea};
        input_order.Bev_Size_O inside{L, M ,S};
    }
endclass

class c_random_date;
    randc Date input_date;
	function new(int seed); 
		this.srandom(seed); 
	endfunction
    constraint range{
        input_date.M inside{[1:12]};
        (input_date.M == 1)  -> input_date.D  inside{[1:31]}; 
        (input_date.M == 2)  -> input_date.D  inside{[1:28]}; 
        (input_date.M == 3)  -> input_date.D  inside{[1:31]};
        (input_date.M == 4)  -> input_date.D  inside{[1:30]}; 
        (input_date.M == 5)  -> input_date.D  inside{[1:31]}; 
        (input_date.M == 6)  -> input_date.D  inside{[1:30]};  
        (input_date.M == 7)  -> input_date.D  inside{[1:31]}; 
        (input_date.M == 8)  -> input_date.D  inside{[1:31]}; 
        (input_date.M == 9)  -> input_date.D  inside{[1:30]}; 
        (input_date.M == 10) -> input_date.D  inside{[1:31]}; 
        (input_date.M == 11) -> input_date.D  inside{[1:30]}; 
        (input_date.M == 12) -> input_date.D  inside{[1:31]}; 
    }
endclass

class c_random_box;
    randc logic [7:0] box_id;
	function new(int seed); 
		this.srandom(seed); 
	endfunction
    constraint range{
        box_id inside{[0:255]};
    }
endclass

class c_random_box_sup;
    randc logic [11:0] sup_black_tea;
    randc logic [11:0] sup_green_tea;
    randc logic [11:0] sup_milk;
    randc logic [11:0] sup_pineapple_juice;
	function new(int seed); 
		this.srandom(seed); 
	endfunction

    constraint range{
        sup_black_tea       inside{[0:4095]};
        sup_green_tea       inside{[0:4095]};
        sup_milk            inside{[0:4095]};
        sup_pineapple_juice inside{[0:4095]};
    }
endclass

c_random_act      random_act      = new(seed);
C_random_order    random_order    = new(seed);
c_random_date     random_date     = new(seed);
c_random_box      random_box      = new(seed);
c_random_box_sup  random_box_sup  = new(seed);


//================================================================
// initial
//================================================================

initial $readmemh(DRAM_p_r, golden_DRAM);

initial begin

    reset_task;

	for(patCount = 0; patCount < PATNUM; patCount = patCount + 1) begin	
        
        get_dram_task;

        action_task;

        wait_out_valid_task;

        check_ans_task;

        store_dram_task;
    
        total_latency = total_latency + latency;
        $display("\033[0;34mPass Pattern No.%4d \033[m \033[0;32mLatency : %3d\033[m",patCount ,latency);

	end

    YOU_PASS_task;

end

// always @(negedge clk) begin
//     if(inf.out_valid === 0 && (inf.err_msg !== No_Err || inf.complete !== 1'b0)) begin
//         $display("*************************************************************************");     
//         $display("*                                 FAIL!                                 *");
//         $display("*    (err_msg, complete) should be (No_Err, 0) when out_valid is 0      *");
//         $display("*************************************************************************");
//         $finish;
//     end
// end

task YOU_PASS_task; begin
    $display("*************************************************************************");
    // $display("Congratulations");
    $display("*                            Congratulations                            *");
    $display("*                   Your execution cycles = %5d cycles               *", total_latency);
    // $display("*                   Your clock period = %.1f ns                         *", CYCLE);
    // $display("*                   Total Latency = %.1f ns                        *", total_latency*CYCLE);
    $display("*************************************************************************");
    $finish;
end endtask

task store_dram_task; begin
    case(act_id)
        Make_drink: store_dram_make_task;
        Supply:     store_dram_supply_task;
    endcase

    {golden_DRAM[(65536 + box_id*8 + 7)]        , golden_DRAM[(65536 + box_id*8 + 6)][7:4]} = in_DRAM.black_tea;
    {golden_DRAM[(65536 + box_id*8 + 6)][3:0]   , golden_DRAM[(65536 + box_id*8 + 5)]}      = in_DRAM.green_tea;
    {golden_DRAM[(65536 + box_id*8 + 4)][3:0]}                                              = in_DRAM.M;
    {golden_DRAM[(65536 + box_id*8 + 3)]        , golden_DRAM[(65536 + box_id*8 + 2)][7:4]} = in_DRAM.milk;
    {golden_DRAM[(65536 + box_id*8 + 2)][3:0]   , golden_DRAM[(65536 + box_id*8 + 1)]}      = in_DRAM.pineapple_juice;
    {golden_DRAM[(65536 + box_id*8 + 0)][4:0]}                                              = in_DRAM.D;
end
endtask

task store_dram_make_task; begin
    if(golden_err_msg === No_Err) begin
        case(input_order.Bev_Type_O)
            Black_Tea: begin
                in_DRAM.black_tea   = in_DRAM.black_tea - volume;
            end
            Milk_Tea: begin
                in_DRAM.black_tea       = in_DRAM.black_tea - volume*3/4;
                in_DRAM.milk            = in_DRAM.milk - volume/4;
            end
            Extra_Milk_Tea: begin
                in_DRAM.black_tea       = in_DRAM.black_tea - volume/2;
                in_DRAM.milk            = in_DRAM.milk - volume/2;
            end
            Green_Tea: begin
                in_DRAM.green_tea       = in_DRAM.green_tea - volume;
            end
            Green_Milk_Tea: begin
                in_DRAM.green_tea       = in_DRAM.green_tea - volume/2;
                in_DRAM.milk            = in_DRAM.milk - volume/2;
            end
            Pineapple_Juice: begin
                in_DRAM.pineapple_juice = in_DRAM.pineapple_juice - volume;
            end
            Super_Pineapple_Tea: begin
                in_DRAM.black_tea       = in_DRAM.black_tea - volume/2;
                in_DRAM.pineapple_juice = in_DRAM.pineapple_juice - volume/2;
            end
            Super_Pineapple_Milk_Tea: begin
                in_DRAM.black_tea       = in_DRAM.black_tea - volume/2;
                in_DRAM.milk            = in_DRAM.milk - volume/4;
                in_DRAM.pineapple_juice = in_DRAM.pineapple_juice - volume/4;
            end
        endcase
    end
end
endtask

task store_dram_supply_task; begin
    in_DRAM.black_tea       = (black_tea_total > 4095)          ? 4095 : black_tea_total[11:0];
    in_DRAM.green_tea       = (green_tea_total > 4095)          ? 4095 : green_tea_total[11:0];
    in_DRAM.milk            = (milk_total > 4095)               ? 4095 : milk_total[11:0];
    in_DRAM.pineapple_juice = (pineapple_juice_total > 4095)    ? 4095 : pineapple_juice_total[11:0];
    in_DRAM.M               = input_date.M;
    in_DRAM.D               = input_date.D;
end
endtask

task check_ans_task; begin

    golden_complete = 1'b0;
    golden_err_msg = No_Err;

    case(act_id)
        Make_drink:         check_ans_make_task;
        Supply:             check_ans_supply_task;
        Check_Valid_Date:   check_ans_check_task;
    endcase

    if(golden_err_msg === No_Err)
        golden_complete = 1'b1;
    else
        golden_complete = 1'b0;

    if(inf.err_msg !== golden_err_msg || inf.complete !== golden_complete) begin
        $display("*************************************************************************");     
        $display("*                            Wrong Answer                               *");
        $display("*                      golden_err_msg: %b  yours: %b                    *", golden_err_msg, inf.err_msg);
        $display("*                      golden_complete: %b  yours: %b                     *", golden_complete, inf.complete);
        $display("*************************************************************************");
        $finish;
    end
end
endtask

task check_ans_make_task; begin


    case(input_order.Bev_Size_O)
        L: volume = 960;
        M: volume = 720;
        S: volume = 480;
    endcase

    Black_Tea_ENOUGH = ((input_order.Bev_Type_O == Black_Tea && in_DRAM.black_tea >= volume) || 
                        (input_order.Bev_Type_O == Milk_Tea && in_DRAM.black_tea >= volume*3/4) ||
                        (input_order.Bev_Type_O == Extra_Milk_Tea && in_DRAM.black_tea >= volume/2) || 
                        (input_order.Bev_Type_O == Green_Tea) || 
                        (input_order.Bev_Type_O == Green_Milk_Tea) || 
                        (input_order.Bev_Type_O == Pineapple_Juice) ||
                        (input_order.Bev_Type_O == Super_Pineapple_Tea && in_DRAM.black_tea >= volume/2) || 
                        (input_order.Bev_Type_O == Super_Pineapple_Milk_Tea && in_DRAM.black_tea >= volume/2));

    Green_Tea_ENOUGH = ((input_order.Bev_Type_O == Black_Tea) || 
                        (input_order.Bev_Type_O == Milk_Tea) || 
                        (input_order.Bev_Type_O == Extra_Milk_Tea) || 
                        (input_order.Bev_Type_O == Green_Tea && in_DRAM.green_tea >= volume) || 
                        (input_order.Bev_Type_O == Green_Milk_Tea && in_DRAM.green_tea >= volume/2) || 
                        (input_order.Bev_Type_O == Pineapple_Juice) || 
                        (input_order.Bev_Type_O == Super_Pineapple_Tea) || 
                        (input_order.Bev_Type_O == Super_Pineapple_Milk_Tea));


    Milk_ENOUGH =  ((input_order.Bev_Type_O == Black_Tea) || 
                    (input_order.Bev_Type_O == Milk_Tea && in_DRAM.milk >= volume/4) || 
                    (input_order.Bev_Type_O == Extra_Milk_Tea && in_DRAM.milk >= volume/2) || 
                    (input_order.Bev_Type_O == Green_Tea) || 
                    (input_order.Bev_Type_O == Green_Milk_Tea && in_DRAM.milk >= volume/2) || 
                    (input_order.Bev_Type_O == Pineapple_Juice) || 
                    (input_order.Bev_Type_O == Super_Pineapple_Tea) || 
                    (input_order.Bev_Type_O == Super_Pineapple_Milk_Tea && in_DRAM.milk >= volume/4));

    Pineapple_Juice_ENOUGH =   ((input_order.Bev_Type_O == Black_Tea) || 
                                (input_order.Bev_Type_O == Milk_Tea) || 
                                (input_order.Bev_Type_O == Extra_Milk_Tea) || 
                                (input_order.Bev_Type_O == Green_Tea) || 
                                (input_order.Bev_Type_O == Green_Milk_Tea) || 
                                (input_order.Bev_Type_O == Pineapple_Juice && in_DRAM.pineapple_juice >= volume) || 
                                (input_order.Bev_Type_O == Super_Pineapple_Tea && in_DRAM.pineapple_juice >= volume/2) || 
                                (input_order.Bev_Type_O == Super_Pineapple_Milk_Tea && in_DRAM.pineapple_juice >= volume/4));


    is_NOT_ENOUGH = !(Black_Tea_ENOUGH & Green_Tea_ENOUGH & Milk_ENOUGH & Pineapple_Juice_ENOUGH);
    is_EXPIRED = (input_date.M > in_DRAM.M) || (input_date.M == in_DRAM.M && input_date.D > in_DRAM.D);

    if(is_NOT_ENOUGH && is_EXPIRED)
        golden_err_msg = No_Exp;
    else if(is_NOT_ENOUGH)
        golden_err_msg = No_Ing;
    else if(is_EXPIRED)
        golden_err_msg = No_Exp;
end
endtask

task check_ans_supply_task; begin
    black_tea_total = in_DRAM.black_tea + sup_black_tea;
    green_tea_total = in_DRAM.green_tea + sup_green_tea;
    milk_total = in_DRAM.milk + sup_milk;
    pineapple_juice_total = in_DRAM.pineapple_juice + sup_pineapple_juice;

    if(black_tea_total > 4095 || green_tea_total > 4095 || milk_total > 4095 || pineapple_juice_total > 4095)
        golden_err_msg = Ing_OF;
end
endtask

task check_ans_check_task; begin
    if((input_date.M > in_DRAM.M) || (input_date.M == in_DRAM.M && input_date.D > in_DRAM.D))
        golden_err_msg = No_Exp;
end
endtask

task action_task; begin
    random_act_task;

    gap = $urandom_range(1, 4);
    repeat(gap) @(negedge clk);
    inf.sel_action_valid = 1;
    inf.D.d_act[0] = act_id;
    @(negedge clk);
    inf.sel_action_valid = 0;
    inf.D = 'dx;

    case(act_id)
        Make_drink:         Make_drink_task;
        Supply:             Supply_task;
        Check_Valid_Date:   Check_Valid_Date_task;
    endcase
end
endtask

task Make_drink_task; begin

    random_order_task;
    random_date_task;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.type_valid = 1;
    inf.D.d_type[0] = input_order.Bev_Type_O;
    @(negedge clk);
    inf.type_valid = 0;
    inf.D = 'dx;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.size_valid = 1;
    inf.D.d_size[0] = input_order.Bev_Size_O;
    @(negedge clk);
    inf.size_valid = 0;
    inf.D = 'dx;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.date_valid = 1;
    inf.D.d_date[0] = input_date;
    @(negedge clk);
    inf.date_valid = 0;
    inf.D = 'dx;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.box_no_valid = 1;
    inf.D.d_box_no[0] = box_id; 
    @(negedge clk);
    inf.box_no_valid = 0;
    inf.D = 'dx;
end
endtask

task Supply_task; begin

    random_date_task;
    random_box_sup_task;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.date_valid = 1;
    inf.D.d_date[0] = input_date;
    @(negedge clk);
    inf.date_valid = 0;
    inf.D = 'dx;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.box_no_valid = 1;
    inf.D.d_box_no[0] = box_id;
    @(negedge clk);
    inf.box_no_valid = 0;
    inf.D = 'dx;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.box_sup_valid = 1;
    inf.D.d_ing[0] = sup_black_tea;
    @(negedge clk);
    inf.box_sup_valid = 0;
    inf.D = 'dx;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.box_sup_valid = 1;
    inf.D.d_ing[0] = sup_green_tea;
    @(negedge clk);
    inf.box_sup_valid = 0;
    inf.D = 'dx;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.box_sup_valid = 1;
    inf.D.d_ing[0] = sup_milk;
    @(negedge clk);
    inf.box_sup_valid = 0;
    inf.D = 'dx;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.box_sup_valid = 1;
    inf.D.d_ing[0] = sup_pineapple_juice;
    @(negedge clk);
    inf.box_sup_valid = 0;
    inf.D = 'dx;
end
endtask

task Check_Valid_Date_task; begin

    random_date_task;
    
    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.date_valid = 1;
    inf.D.d_date[0] = input_date;
    @(negedge clk);
    inf.date_valid = 0;
    inf.D = 'dx;

    gap = $urandom_range(0, 3);
    repeat(gap) @(negedge clk);
    inf.box_no_valid = 1;
    inf.D.d_box_no[0] = box_id;
    @(negedge clk);
    inf.box_no_valid = 0;
    inf.D = 'dx;
end
endtask

task wait_out_valid_task; begin
    latency = 0;
    while(inf.out_valid !== 1) begin
        latency = latency + 1;
        // if(latency === 1000) begin
        //     $display("********************************************************");     
        //     $display("                          FAIL!                              ");
        //     $display("*  The execution latency are over 1000 cycles  at %8t   *",$time);
        //     $display("********************************************************");
        //     $finish;
        // end
        @(negedge clk);
    end
end
endtask

task reset_task; begin
    latency = 0;
    total_latency = 0;

    inf.rst_n               = 1'b1;
    inf.sel_action_valid    = 1'bx;
    inf.type_valid          = 1'bx;
    inf.size_valid          = 1'bx;
    inf.date_valid          = 1'bx;
    inf.box_no_valid        = 1'bx;
    inf.box_sup_valid       = 1'bx;
    inf.D                   =  'dx;

    #(10) inf.rst_n      = 1'b0;
    #(10) inf.rst_n      = 1'b1;

    // if(inf.out_valid !== 1'b0 || inf.err_msg !== No_Err || inf.complete !== 1'b0) begin
    //     $display("************************************************************");  
    //     $display("                          FAIL!                              ");    
    //     $display("*  Output signal should be 0 after initial RESET  at %8t   *",$time);
    //     $display("************************************************************");
    //     $finish;
    // end

    inf.sel_action_valid    = 1'b0;
    inf.type_valid          = 1'b0;
    inf.size_valid          = 1'b0;
    inf.date_valid          = 1'b0;
    inf.box_no_valid        = 1'b0;
    inf.box_sup_valid       = 1'b0;
    inf.D                   =  'd0;

    @(negedge clk);
end 
endtask

task get_dram_task; begin

    random_box_task;

    in_DRAM.black_tea = {golden_DRAM[(65536 + box_id*8 + 7)], golden_DRAM[(65536 + box_id*8 + 6)][7:4]};
    in_DRAM.green_tea = {golden_DRAM[(65536 + box_id*8 + 6)][3:0], golden_DRAM[(65536 + box_id*8 + 5)]};
    in_DRAM.M = golden_DRAM[(65536 + box_id*8 + 4)][3:0];
    in_DRAM.milk = {golden_DRAM[(65536 + box_id*8 + 3)], golden_DRAM[(65536 + box_id*8 + 2)][7:4]};
    in_DRAM.pineapple_juice = {golden_DRAM[(65536 + box_id*8 + 2)][3:0], golden_DRAM[(65536 + box_id*8 + 1)]};
    in_DRAM.D = golden_DRAM[(65536 + box_id*8 + 0)][4:0];
end
endtask

task random_act_task; begin
    random_act.randomize();
    act_id = random_act.act_id;
end
endtask

task random_order_task; begin
    random_order.randomize();
    input_order = random_order.input_order;
end
endtask

task random_date_task; begin
    random_date.randomize();
    input_date = random_date.input_date;
end
endtask

task random_box_task; begin
    random_box.randomize();
    box_id = random_box.box_id;
end
endtask

task random_box_sup_task; begin
    random_box_sup.randomize();
    sup_black_tea       = random_box_sup.sup_black_tea;
    sup_green_tea       = random_box_sup.sup_green_tea;
    sup_milk            = random_box_sup.sup_milk;
    sup_pineapple_juice = random_box_sup.sup_pineapple_juice;
end
endtask

endprogram
