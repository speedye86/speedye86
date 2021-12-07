module mult(
    input clk,
    input rst_n,
    input [8-1:0] data0,
    input [8-1:0] data1,

    output [16-1:0] mult0,

    input data_valid,
    output reg data_ready,

    output reg mult_valid,
    input mult_ready
);

//define FSM
`define mult_working 0
`define mult_wait 1
`define ram_wait 2

reg [4-1:0] status;

//tasks
task mult_reset;
    begin
        mult0 <= 0;
    end
endtask

task mult_compute;
    begin
        mult0 <= data0 * data1;
    end
endtask

//reset
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        mult_reset();
        data_ready <= 0;
        mult_valid <= 0;
        status <= `mult_working;
    end
end

//work
always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        case(status)
            `mult_working: begin
                if (data_valid == 1) begin
                    data_ready <= 1;
                    mult_compute();
                    mult_valid <= 1;
                    status <= `mult_wait;
                end
                else begin
                    mult_reset();
                end
            end
            `mult_wait: begin
                data_ready <= 0;
                if (mult_ready) begin
                    mult_valid <= 0;
                    status <= `ram_wait;
                end
            end
            `ram_wait: begin
                if (data_valid) begin
                    status <= `mult_working;
                end
            end
            default: status <= `mult_wait;
        endcase
    end
end

endmodule