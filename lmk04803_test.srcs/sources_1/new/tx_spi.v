`timescale 1ns / 1ps

// Create Date: 2024/09/23 17:13:55
// Design Name: 
// Module Name: tx_spi
module tx_spi(
input                clk            ,
input                rst            ,
input    [31:0]      data_in        ,
output   reg         init_spi_end   ,
output               init_done       ,
output   reg   [5:0] cnt_reg        ,
output   reg         cs             ,
output   reg         sck            ,
output   reg         mosi           ,
output   reg         sync
    );
     
parameter     SYS_CLK               = 100_000_000 ,
               SPI_CLK               = 5_000_000  ;
localparam     delay = SYS_CLK/SPI_CLK-1; //sys_clk divide parameter 
    
reg [5:0] cnt,cnt_sck,spi_bit_next;
//wire init_done;
reg cs_reg,cs_reg_i;
//reg [31:0] data_in_reg;
reg [31:0] spi_rddata;

//reg  init_spi_start;
always@(posedge clk or negedge rst)
    if(~rst)
        cnt <= 0;
    else if(cnt == delay)
        cnt <= 0;
    else
        cnt <= cnt + 1;
//spi_sck
always@(posedge clk or negedge rst)
    if(~rst)
        sck <= 0;
    else if(cnt_sck == 32 || init_done)
        sck <= 0;
    else if(cnt==delay/2||cnt==delay)
        sck <= ~sck;
    else
        sck <= sck;
         
always@(posedge clk or negedge rst)
   if(~rst)  
    cnt_sck <= 0;
   else if(cnt == delay)
    cnt_sck <= cnt_sck + 1;
   else if(cnt_sck == 36)
    cnt_sck <= 0;
   else
    cnt_sck <= cnt_sck;
          
 //spi_cs
always@(posedge clk or negedge rst)
    if(~rst)
       cs_reg <= 1;
	else if(init_spi_end  ||cnt_sck == 36)
	   cs_reg <= 1;
	 else
	   cs_reg <= 0;

always@(posedge clk or negedge rst)
    if(~rst)
       sync <= 1;
	else 
	   sync <= cs;



always@(posedge clk or negedge rst)
    if(~rst)
       cs_reg_i <= 1;
	else 
	   cs_reg_i <= cs_reg;

always@(posedge clk or negedge rst)
    if(~rst)begin
        cs  <= 1;
end
else begin
	   cs <= cs_reg || cs_reg_i;
end



always@(posedge clk or negedge rst)
   if(~rst) 
    spi_bit_next <= 0;
   else if(cnt == delay/2 )
    spi_bit_next <= spi_bit_next + 1;
   else if(spi_bit_next == 36)
    spi_bit_next <= 0;
   else
    spi_bit_next <= spi_bit_next;
    
    
//assign data_in = (spi_bit_next)?data_in<<1:data_in; 
    
 always@(posedge clk or negedge rst)
    if(~rst)
        mosi <= 0;
    else if(cnt == 0 & cnt_sck <= 31)
        mosi <= data_in[31-spi_bit_next];  
    else if(cnt == 0 & cnt_sck > 31 & cnt_sck <=35)
        mosi <= 0;    
    else
        mosi <= mosi;   

always@(posedge clk or negedge rst)
   if(~rst) 
    init_spi_end <= 0;
   else if(cnt_sck == 31 & cnt == delay)
    init_spi_end <= 1;
   else
    init_spi_end <= 0;
    
always@(posedge clk or negedge rst)
   if(~rst) 
    cnt_reg <= 0;
   else if(init_spi_end)
    cnt_reg <= cnt_reg + 1;
   else
    cnt_reg <= cnt_reg;
    
  
always@(posedge clk or negedge rst)
   if(~rst) 
    spi_rddata <= 0;
   else if(cnt == delay & spi_bit_next <= 32)
    spi_rddata <= {spi_rddata[30:0],mosi};
   else 
    spi_rddata <= spi_rddata;
    
    
assign  init_done = (cnt_reg == 26)?1:0;   
    
endmodule
