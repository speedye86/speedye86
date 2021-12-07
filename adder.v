module adder(
    input clk,
    input rst_n,

    input [16-1:0] mult0,

    output reg [32-1:0] ans,

    input mult_valid,
    output reg mult_ready,

    output reg ans_valid,
    input ans_ready
);

//define FSM
`define adder_idle 0;
`define adder_stage 1;
`define adder_wait 2;

reg [4-1:0] status;

//define buffer
reg [16-1:0] ans_store0;

//define size of answer
`define answer_size 8-1;

//define counter (to know whether all data have been read into the module)
reg [32-1:0] cnt;

//tasks
task adder_load;
    begin
        ans_store0 <= mult0;
    end
endtask

task adder_stage;
    begin
        ans <= ans + ans_store0;
    end

task adder_reset;
    begin
        ans_store0 <= 0;
    end
endtask

//reset
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        status <= `adder_idle;
        cnt <= 0;
        ans <= 0;
        mult_ready <= 0;
        ans_valid <= 0;
        adder_reset();
    end
end

always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        case (status)
            `adder_idle: begin
                if (mult_valid) begin
                    adder_load();
                    status <= `adder_stage;
                    mult_ready <= 1;
                    ans_valid <= 0;
                end
            end
            `adder_stage: begin
                mult_ready <= 0;
                adder_step();
                cnt <= cnt + 1;
                status <= `adder_wait;
                ans_valid <= 1;
            end
            `adder_wait: begin
                if (cnt == answer_size && ans_ready == 1) begin
                    ans_valid <= 1;
                    status <= `adder_idle;
                end
                else begin
                    ans_valid <= 0;
                    status <= `adder_idle;
                end
            end
            default: status <= `adder_idle;
        endcase
    end
end

endmodule