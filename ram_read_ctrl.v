module ram_read_ctrl(
    //time signal
    input clk,
    input rst_n,
    //data
    output [8-1:0] data,
    //protocol
    output reg valid,
    input ready,
    //ctrl signal
    input start,
    //ram port
    output ram_clk,
    output ram_en,
    output ram_we,
    output reg [32-1:0] ram_addr,
    output ram_rst_p,
    output reg [8-1:0] ram_wr,
    input [8-1:0] ram_rd
);

//define the FSM
`define ram_read_ctrl_idle 0
`define ram_read_ctrl_read 1
`define ram_read_ctrl_send 2

reg [4-1:0] status;

//define size of matrix
`define matrix_size 25;

//define counter (to know whether all data have been read into the module)
reg [32-1:0] cnt;

//connect to ram port
assign ram_clk = clk;
assign ram_rst_p = ~rst_n;
assign data = ram_read;

//reset
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        //protocol
        valid <= 0;
        //ram port
        ram_en <= 0;
        ram_we <= 0;
        ram_addr <= 0;
        ram_wr <= 0;
        //FSM
        status <= `ram_read_ctrl_idle;
        cnt <= 0;
    end
end

//work
always @(posedge clk or negedge rst_n) begin
    if(rst_n) begin
        //protocol
        case(status)
            `ram_read_ctrl_idle: begin
                ram_en <= 1;
                if(start) begin
                    valid <= 1;
                    status <= `ram_read_ctrl_read;
                end
            end
            `ram_read_ctrl_read: begin
                if(ready) begin
                    valid <= 0;
                    ram_addr <= ram_addr + 1;
                    cnt <= cnt + 1;
                    status <= `ram_read_ctrl_send;
                end
            end
            `ram_read_ctrl_send: begin
                if(cnt == `matrix_size) begin
                    ram_en <= 0;
                    valid <= 0;
                    ram_addr <= 0;
                    status <= `ram_read_strl_idle;
                end
                else begin
                    valid <= 1;
                    stauts <= `ram_read_ctrl_read;
                end
            end
            default: status <= `ram_read_ctrl_idle;
        endcase
    end
end

endmodule