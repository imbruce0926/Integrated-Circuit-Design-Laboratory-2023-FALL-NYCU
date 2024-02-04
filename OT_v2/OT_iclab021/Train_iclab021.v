module Train(
    //Input Port
    clk,
    rst_n,
	in_valid,
	data,

    //Output Port
    out_valid,
	result
);

input        clk;
input 	     in_valid;
input        rst_n;
input  [3:0] data;
output   reg out_valid;
output   reg result; 

parameter IDLE = 0;
parameter INPUT = 1;
parameter PUSH = 2;
parameter POP = 3;
parameter CHECK = 4;
parameter OUTPUT = 5;

reg [3:0] input_cnt;
reg [2:0] c_state, n_state;
reg [3:0] carNum;
reg [3:0] car_order [0:9];
reg [3:0] order_ptr;
reg [3:0] car_index;
reg [3:0] stack [0:9];
reg [3:0] top;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
        for(integer i = 0; i < 10; i = i + 1)
            stack[i] <= 0;

        car_index <= 1;
        top <= 0;
        order_ptr <= 0;
    end
    else begin
        if(n_state == IDLE) begin
            for(integer i = 0; i < 10; i = i + 1)
                stack[i] <= 0;

            car_index <= 1;
            top <= 0;
            order_ptr <= 0;
        end
        else if(c_state == PUSH) begin
            // if(car_index != car_order[order_ptr]) begin
                stack[top] <= car_index;
                car_index <= car_index + 1;
                top <= top + 1;
            // end
        end

        else if(c_state == POP) begin
            // if(stack[top] == car_order[order_ptr]) begin
                
                if(top == 0 || (top != 0 && stack[top-1] != car_order[order_ptr])) begin
                    order_ptr <= order_ptr;
                    top <= top;
                end
                else begin
                    order_ptr <= order_ptr + 1;
                    top <= top - 1;
                end
            // end
        end
    end 
        
end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin 
        
//     end
//     else begin
//         if(c_state == POP) begin
            
//         end
//     end 
        
// end

always @(*) begin
    n_state = c_state;
    case (c_state)
        IDLE: begin
            if(in_valid == 1)
                n_state = INPUT;
        end
        INPUT: begin
            if(input_cnt == carNum)
                n_state = PUSH;
        end
        PUSH: begin
            if(car_index == car_order[order_ptr])
                n_state = POP;
            else if(car_index > car_order[order_ptr] || car_index > carNum)
                n_state = OUTPUT;
        end
        POP: begin
            if(top == 0) begin
                n_state = PUSH;
            end
            else begin
                if(stack[top-1] != car_order[order_ptr])
                    n_state = PUSH;
            end
            
        end
        // CHECK: begin

        // end
        OUTPUT: begin
            n_state = IDLE;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        result <= 0;
        out_valid <= 0;
    end
    else begin
        if(n_state != OUTPUT && c_state == OUTPUT) begin
            result <= 0;
            out_valid <= 0;
        end
        else if(n_state == OUTPUT) begin
            out_valid <= 1;
            if(car_index > carNum && top == 0)
                result <= 1;
            else if(car_index > car_order[order_ptr])
                result <= 0;
            else 
                result <= 0;
        end
    end 
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) c_state <= IDLE;
    else c_state <= n_state;
end





always @(posedge clk or negedge rst_n) begin
    if(!rst_n)  
        carNum <= 0;
    else begin
        if(n_state == INPUT)
            if(input_cnt == 0)
                carNum <= data;
    end 
end



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin 
        for(integer i = 0; i < 10; i = i + 1)
            car_order[i] <= 0;
    end
    else begin
        if(n_state == IDLE) begin
            for(integer i = 0; i < 10; i = i + 1)
                car_order[i] <= 0;
        end
        else 
        if(n_state == INPUT || c_state == INPUT)
            car_order[input_cnt-1] <= data;
    end 
end


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) input_cnt <= 0;
    else begin
        if(n_state == IDLE) begin
            input_cnt <= 0;
        end
        else if(n_state == INPUT || c_state == INPUT)
            input_cnt <= input_cnt + 1;
    end 
end



endmodule