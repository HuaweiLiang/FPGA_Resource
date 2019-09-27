/****************************Copyright**********************************
**                           
**               
**
**------------------------File Infomation-------------------------------
** FileName     :       remap_calc.v
** Author       :       li.shengbo
** Data         :       2017-03-15
** Version      :       v1.0
** Description  :       
**                      
***********************************************************************/
module remap_calcute 
(
    // clk and reset
    input    wire                        wclk                    ,
    input    wire                        arst                    ,    

    // input data
    input    wire                        remap_vsync                ,
    input    wire    [5:0]               remap_calc_xf              ,
    input    wire    [5:0]               remap_calc_yf              ,    
    input    wire    [7:0]               remap_calc_din00           ,
    input    wire    [7:0]               remap_calc_din10           ,
    input    wire    [7:0]               remap_calc_din01           ,
    input    wire    [7:0]               remap_calc_din11           ,
    input    wire                        remap_calc_vld_in          ,
    
    input    wire    [7:0]                MPT_X_NUM            ,
    input    wire    [7:0]                MPT_Y_NUM            , 
    // output data
    output    reg        [7:0]                remap_calc_dout            ,
    output    reg                            remap_calc_vld_out
);

reg        [7 : 0]                    remap_cal_in_A00        ;
reg        [6 : 0]                    remap_cal_in_B00        ;    
wire    [14: 0]                    remap_cal_out_P00_tmp    ;
reg        [6 : 0]                    remap_cal_in_B01        ;
wire    [21: 0]                    remap_cal_out_P01_tmp    ;
reg        [7 : 0]                    remap_cal_in_A10        ;
reg        [6 : 0]                    remap_cal_in_B10        ;
wire    [14: 0]                    remap_cal_out_P10_tmp    ;
reg        [6 : 0]                    remap_cal_in_B11        ;
wire    [21: 0]                    remap_cal_out_P11_tmp    ;

reg        [6 : 0]                    remap_cal_in_B01_tmp0    ;
reg        [6 : 0]                    remap_cal_in_B01_tmp1    ;
reg        [14: 0]                    remap_cal_out_P00         ;    
reg        [21: 0]                    remap_cal_out_P01         ;
reg        [6 : 0]                    remap_cal_in_B11_tmp0    ;
reg        [6 : 0]                    remap_cal_in_B11_tmp1    ;
reg        [14: 0]                    remap_cal_out_P10         ;    
reg        [21: 0]                    remap_cal_out_P11         ;

reg                                remap_calc_vld_in_1d     ;    
reg                                remap_calc_vld_in_2d     ;
reg                                remap_calc_vld_in_3d     ;
reg                                remap_calc_vld_in_4d     ;
reg                                remap_calc_vld_in_5d     ;
reg                                remap_calc_vld_in_6d     ;
reg                                remap_calc_vld_in_7d     ;
reg                                remap_calc_vld_in_8d     ;
reg                                remap_calc_vld_in_9d     ;

reg        [23:0]                    remap_calc_sum         ;

reg        [8:0]                     mpt_X_NUM_Y_NUM        ;
reg        [7:0]                     remap_calc_sum_int     ;
always@(posedge wclk ) mpt_X_NUM_Y_NUM   <=  MPT_X_NUM + MPT_Y_NUM ;
always@(posedge wclk ) 
begin
  case(mpt_X_NUM_Y_NUM)
    9'd32 :  remap_calc_sum_int   <=  remap_calc_sum[15:8 ] ;//16+16,4+4
    9'd48 :  remap_calc_sum_int   <=  remap_calc_sum[16:9 ] ;//16+32,4+5
    9'd80 :  remap_calc_sum_int   <=  remap_calc_sum[17:10] ;//16+64,4+6
    9'd64 :  remap_calc_sum_int   <=  remap_calc_sum[17:10] ;//32+32,5+5
    9'd96 :  remap_calc_sum_int   <=  remap_calc_sum[18:11] ;//32+64,5+6
    9'd128:  remap_calc_sum_int   <=  remap_calc_sum[19:12] ;//64+64,6+6
    default: remap_calc_sum_int   <=  remap_calc_sum[19:12] ;//64+64,6+6
  endcase
end
//remap_cal_in_A00
always@(posedge wclk or posedge arst)
    if(arst)
        remap_cal_in_A00 <= 8'b0;
    else if(remap_calc_vld_in)
        remap_cal_in_A00 <= remap_calc_din00;
    else 
        remap_cal_in_A00 <= remap_calc_din01;        
        
//remap_cal_in_B00
always@(posedge wclk or posedge arst)
    if(arst)
        remap_cal_in_B00 <= 7'b0;
    else 
        remap_cal_in_B00 <= MPT_X_NUM - {1'b0,remap_calc_xf}; // 1-x
        
//remap_cal_in_B01/_tmp0/1
always@(posedge wclk or posedge arst)
    if(arst) begin
        remap_cal_in_B01_tmp0    <= 7'd0;
        remap_cal_in_B01_tmp1    <= 7'd0;
        remap_cal_in_B01         <= 7'd0;
    end
    else if(remap_calc_vld_in) begin
        remap_cal_in_B01_tmp0    <= MPT_Y_NUM - {1'b0,remap_calc_yf};
        remap_cal_in_B01_tmp1    <= remap_cal_in_B01_tmp0;
        remap_cal_in_B01         <= remap_cal_in_B01_tmp1;    
    end
    else begin
        remap_cal_in_B01_tmp0    <= {1'b0,remap_calc_yf};
        remap_cal_in_B01_tmp1    <= remap_cal_in_B01_tmp0;
        remap_cal_in_B01         <= remap_cal_in_B01_tmp1;    
    end    
    
//remap_cal_out_P00
always@(posedge wclk or posedge arst)
    if(arst)
        remap_cal_out_P00 <= 15'b0;
    else 
        remap_cal_out_P00 <= remap_cal_out_P00_tmp;
        
//remap_cal_out_P01
always@(posedge wclk or posedge arst)
    if(arst)
        remap_cal_out_P01 <= 22'b0;
    else 
        remap_cal_out_P01 <= remap_cal_out_P01_tmp;        
        
//remap_cal_in_A10
always@(posedge wclk or posedge arst)
    if(arst)
        remap_cal_in_A10 <= 8'b0;
    else if(remap_calc_vld_in)
        remap_cal_in_A10 <= remap_calc_din10;
    else 
        remap_cal_in_A10 <= remap_calc_din11;        
        
//remap_cal_in_B10
always@(posedge wclk or posedge arst)
    if(arst)
        remap_cal_in_B10 <= 7'b0;
    else 
        remap_cal_in_B10 <= {1'b0,remap_calc_xf}; // x
        
//remap_cal_in_B11/_tmp0/1
always@(posedge wclk or posedge arst)
    if(arst) begin
        remap_cal_in_B11_tmp0    <= 7'd0;
        remap_cal_in_B11_tmp1    <= 7'd0;
        remap_cal_in_B11        <= 7'd0;
    end
    else if(remap_calc_vld_in) begin
        remap_cal_in_B11_tmp0    <= MPT_Y_NUM - remap_calc_yf;
        remap_cal_in_B11_tmp1    <= remap_cal_in_B11_tmp0;
        remap_cal_in_B11        <= remap_cal_in_B11_tmp1;    
    end
    else begin
        remap_cal_in_B11_tmp0    <= {1'b0,remap_calc_yf};
        remap_cal_in_B11_tmp1    <= remap_cal_in_B11_tmp0;
        remap_cal_in_B11        <= remap_cal_in_B11_tmp1;    
    end
    
//remap_cal_out_P10
always@(posedge wclk or posedge arst)
    if(arst)
        remap_cal_out_P10 <= 15'b0;
    else 
        remap_cal_out_P10 <= remap_cal_out_P10_tmp;
        
//remap_cal_out_P11
always@(posedge wclk or posedge arst)
    if(arst)
        remap_cal_out_P11 <= 22'b0;
    else 
        remap_cal_out_P11 <= remap_cal_out_P11_tmp;        
        
//remap_calc_vld_in_1d/2d/3d/4d/5d
always@(posedge wclk or posedge arst)
    if(arst) begin
        remap_calc_vld_in_1d <= 1'b0;
        remap_calc_vld_in_2d <= 1'b0;        
        remap_calc_vld_in_3d <= 1'b0;        
        remap_calc_vld_in_4d <= 1'b0;        
        remap_calc_vld_in_5d <=    1'b0;
        remap_calc_vld_in_6d <=    1'b0;
        remap_calc_vld_in_7d <=    1'b0;    
        remap_calc_vld_in_8d <=    1'b0;  
        remap_calc_vld_in_9d <=    1'b0;      
    end
    else if(remap_vsync) begin
        remap_calc_vld_in_1d <= 1'b0;
        remap_calc_vld_in_2d <= 1'b0;        
        remap_calc_vld_in_3d <= 1'b0;        
        remap_calc_vld_in_4d <= 1'b0;        
        remap_calc_vld_in_5d <=    1'b0;
        remap_calc_vld_in_6d <=    1'b0;
        remap_calc_vld_in_7d <=    1'b0;  
        remap_calc_vld_in_8d <=    1'b0;  
        remap_calc_vld_in_9d <=    1'b0;    
    end
    else begin
        remap_calc_vld_in_1d <= remap_calc_vld_in;
        remap_calc_vld_in_2d <= remap_calc_vld_in_1d;        
        remap_calc_vld_in_3d <= remap_calc_vld_in_2d;        
        remap_calc_vld_in_4d <= remap_calc_vld_in_3d;        
        remap_calc_vld_in_5d <= remap_calc_vld_in_4d;
        remap_calc_vld_in_6d <= remap_calc_vld_in_5d;    
        remap_calc_vld_in_7d <= remap_calc_vld_in_6d;    
        remap_calc_vld_in_8d <= remap_calc_vld_in_7d;    
        remap_calc_vld_in_9d <= remap_calc_vld_in_8d;        
    end 
        
//remap_calc_sum
always@(posedge wclk or posedge arst)
    if(arst)
        remap_calc_sum <= 24'b0;
    else if(remap_calc_vld_in_5d)
        remap_calc_sum <= {2'b0,remap_cal_out_P01} + {2'b0,remap_cal_out_P11};
    else
        remap_calc_sum <= remap_calc_sum + {2'b0,remap_cal_out_P01} + {2'b0,remap_cal_out_P11};
        
//remap_calc_dout
always@(posedge wclk or posedge arst)
    if(arst)
        remap_calc_dout <= 8'b0;
    else if(remap_calc_vld_in_8d) 
        // remap_calc_dout <= remap_calc_sum[(MPT_X_BITS+MPT_Y_BITS+7):(MPT_X_BITS+MPT_Y_BITS)]; 
        remap_calc_dout <= remap_calc_sum_int ; 
         
//remap_calc_vld_out
always@(posedge wclk or posedge arst)
    if(arst)
        remap_calc_vld_out <= 1'b0;
    else if(remap_vsync)
        remap_calc_vld_out <= 1'b0;
    else
        remap_calc_vld_out <= remap_calc_vld_in_9d;        
    
/************************ instance***************************/
remap_mult_s0 remap_mult_s00 (
  .CLK(wclk),                      // input wire CLK
  .A(remap_cal_in_A00),          // input wire [7 : 0] A
  .B(remap_cal_in_B00),          // input wire [6 : 0] B
  .P(remap_cal_out_P00_tmp)      // output wire[14 : 0] P
);

remap_mult_s1 remap_mult_s01 (
  .CLK(wclk),                      // input wire CLK
  .A(remap_cal_out_P00),          // input wire [14 : 0] A
  .B(remap_cal_in_B01),          // input wire [6 : 0 ] B
  .P(remap_cal_out_P01_tmp)      // output wire[21 : 0] P
);

remap_mult_s0 remap_mult_s10 (
  .CLK(wclk),                      // input wire CLK
  .A(remap_cal_in_A10),          // input wire [7 : 0 ] A
  .B(remap_cal_in_B10),          // input wire [6 : 0 ] B
  .P(remap_cal_out_P10_tmp)      // output wire[14 : 0] P
);

remap_mult_s1 remap_mult_s11 (
  .CLK(wclk),                      // input wire CLK
  .A(remap_cal_out_P10),          // input wire [14 : 0] A
  .B(remap_cal_in_B11),          // input wire [6 : 0 ] B
  .P(remap_cal_out_P11_tmp)      // output wire[21 : 0] P
);
endmodule