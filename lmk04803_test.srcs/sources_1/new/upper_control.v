`timescale 1ns / 1ps
// Create Date: 2024/08/12 10:47:36
// Design Name: 
// Module Name: upper_control
module upper_control(
input              clk                ,
input              rst                ,
input [31:0]       cbus_addr          ,//上位机给的地址
input [31:0]       cbus_data          ,//上位机给的数据，该数据包含寄存器的（数据+地址）
input              cbus_we            ,//上位机使能信号
input              cbus_clk           , 
output reg[4:0]    rdback_addr        , 
output [31:0]      upper_data_reg                             
    );

reg [31:0] cbus_addr_d  ;
reg [31:0] cbus_data_d  ;
reg cbus_we_d           ;
wire debug_04803_en     ;
wire read_04803_en      ;

always @(posedge cbus_clk) begin
		cbus_addr_d <= cbus_addr  ;
		cbus_data_d <= cbus_data  ;
		cbus_we_d <= cbus_we    ;
	end

assign debug_04803_en = cbus_we_d & cbus_addr_d == 32'h0002_0000;
assign read_04803_en = cbus_we_d & cbus_addr_d == 32'h0002_0004;
// 寄存器地址和数据寄存器  
reg [31:5]debug_04803_data  ;  
reg [4:0] debug_04803_addr  ;  
  
always @(posedge cbus_clk or negedge rst) begin
	if(~rst) begin
		debug_04803_data <= 27'd0;
		debug_04803_addr <= 5'b0;
	end else if(debug_04803_en) begin
		debug_04803_data <= cbus_data_d[31:5];
		debug_04803_addr <= cbus_data_d[4:0];
	end
end
//wr_(data+addr)  
assign upper_data_reg = {debug_04803_data,debug_04803_addr};

//rd_addr
always @(posedge cbus_clk or negedge rst) begin
	if(~rst) begin
		rdback_addr <= 5'b0;
	end else if(read_04803_en) begin
		rdback_addr <= cbus_data_d[4:0];
	end
end





endmodule
