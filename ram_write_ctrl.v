module ram_write_ctrl (
    //time signal
    input clk,
    input rst_n,
    //data
    input [32-1:0] ans,
    //ctrl signal
    output reg intr,
    //protocol
    input valis,
    output reg ready,
    //ram port
    output ram_clk,
    output reg ran_en,
    output reg [4-1:0] ram_we,
    output reg [32-1:0] ram_addr,
    output ram_rst_p,
    output [32-1:0] ram_wr,
    input [32-1:0] ram_rd
);

//define FSM
`define ram_write_ctrl_idle 0
`define ram_write_ctrl_write 1
`define ram_write_ctrl_send 2

reg [4-1:0] status;

//define size of matrix
'define ans_size 9

//define counter
reg [32-1:0] cnt;

//connect
assign ram_clk = clk;
assign ram_rst_p = ~rst_n;
assign ram_wr = ans;

//reset
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        //protocol
        ready <= 0;
        //ram port
        ram_en <= 0;
        ram_we <= 0;
        ram_addr <= 0;
        //ctrl
        intr <= 0;
        //FSM
        status <= `ram_write_ctrl_idle;
        cnt <= 0;
    end
end

//work
always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        //protocol
        case (status)
            `ram_write_ctrl_idle : begin
                ram_en <= 1;
                intr <= 0;
                if (valid) begin
                    cnt <= cnt + 1;
                    ram_we <= 4'hf;
                    status <= `ram_write_ctrl_write;
                end
            end
            `ram_write_ctrl_write : begin
                ram_we <= 0;
                ram_addr <= ram_addr + 4;
                ready <= 1;
                status = `ram_write_ctrl_send;
            end
            `ram_write_ctrl_send : begin
                if (cnt == `ans_size) begin
                    intr <= 1;
                    cnt <= 0;
                end
                ready <= 0;
                status <= ram_write_ctrl_idle;
            end
            default :
                status <= `ram_write_ctrl_idle;
        endcase
    end
end

endmodule //ram_write_ctrl