module ram(
    input ram_clk,
    output reg [32-1:0] ram_rd,
    input ram_en,
    input [32-1:0] ram_addr,
    input [4-1:0] ram_we,
    input [32-1:0] ram_wr,
    input ram_rst_p
);

integer i;
reg [32-1:0] store [2048-1:0];

//reset
always @(posedge ram_clk or posedge ram_rst_p) begin
    if(ram_rst_p) begin
        for( i = 0 ; i < 1024 ; i = i + 1 ) begin
            store[i] <= 32'd0;
        end
    end
end

//work
always @(posedge ram_clk or posedge ram_rst_p) begin
    if(!ram_rst_p && ram_en) begin
        if(ram_we == 0) begin
            ram_rd <= store[ram_addr];
        end
        else if(ram_we == 4'hF) begin
            store[ram_addr] <= ram_wr;
        end
    end
    else if(ram_en == 0) begin
        ram_rd <= 0;
    end
end

endmodule