/****************************Copyright**********************************
**                           
**               
**
**------------------------File Infomation-------------------------------
** FileName     :       mpt_decode.v
** Author       :       
** Data         :       
** Version      :       
** Description  :       
**                      
***********************************************************************/
`timescale 1ns/1ps 
module mpt_decode_analysis#(                            
   parameter  SEG_X_WIDTH                       = 8'd128     
   ) (     
    input  wire                                 mpt_clk              , 
    input  wire                                 mpt_arst             , 
    input  wire                                 vid_vs_in            , 
    input  wire                                 rmp_readack_pos      , 
    input  wire                                 rmp_readack_LA_pos   , 
                                                                       
    input  wire                                 mpt_sum_vld_int      , 
    input  wire [10:0]                          mpt_sum_lx_int       , 
    input  wire [10:0]                          mpt_sum_ly_int       , 
    input  wire [5:0]                           mpt_sum_lx_float     , 
    input  wire [5:0]                           mpt_sum_ly_float     , 
                                                                      
    output reg  [7:0]                           mpt_sum_lx_LA0_cnt   , 
    output reg  [7:0]                           mpt_sum_lx_LA1_cnt   , 
    output reg  [7:0]                           mpt_sum_lx_LA2_cnt   , 
    output reg  [7:0]                           mpt_sum_lx_LA3_cnt   , 
    output reg  [7:0]                           mpt_sum_lx_LA4_cnt   , 
    output reg  [7:0]                           mpt_sum_lx_LA5_cnt   , 
    output reg  [7:0]                           mpt_sum_lx_LA6_cnt   , 
    output reg  [7:0]                           mpt_sum_lx_LA7_cnt   , 
    output reg  [7:0]                           mpt_sum_lx_LA8_cnt   , 
    output reg  [7:0]                           mpt_sum_lx_LA9_cnt   , 
    output reg  [10:0]                          mpt_sum_ly_LA0_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA1_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA2_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA3_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA4_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA5_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA6_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA7_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA8_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA9_min   , 
    output reg  [10:0]                          mpt_sum_ly_LA0_max   , 
    output reg  [10:0]                          mpt_sum_ly_LA1_max   , 
    output reg  [10:0]                          mpt_sum_ly_LA2_max   , 
    output reg  [10:0]                          mpt_sum_ly_LA3_max   , 
    output reg  [10:0]                          mpt_sum_ly_LA4_max   , 
    output reg  [10:0]                          mpt_sum_ly_LA5_max   , 
    output reg  [10:0]                          mpt_sum_ly_LA6_max   , 
    output reg  [10:0]                          mpt_sum_ly_LA7_max   , 
    output reg  [10:0]                          mpt_sum_ly_LA8_max   , 
    output reg  [10:0]                          mpt_sum_ly_LA9_max     
    );                                                                 
                                                              
  wire                                          mpt_sum_ly_vld0 ;
  wire                                          mpt_sum_ly_vld1 ;
  wire                                          mpt_sum_ly_vld2 ;
  wire                                          mpt_sum_ly_vld3 ;
  wire                                          mpt_sum_ly_vld4 ;
  wire                                          mpt_sum_ly_vld5 ;
  wire                                          mpt_sum_ly_vld6 ;
  wire                                          mpt_sum_ly_vld7 ;
  wire                                          mpt_sum_ly_vld8 ;
  wire                                          mpt_sum_ly_vld9 ;

  reg  [10:0]                                   mpt_sum_ly_min0 ;
  reg  [10:0]                                   mpt_sum_ly_min1 ;
  reg  [10:0]                                   mpt_sum_ly_min2 ;
  reg  [10:0]                                   mpt_sum_ly_min3 ;
  reg  [10:0]                                   mpt_sum_ly_min4 ;
  reg  [10:0]                                   mpt_sum_ly_min5 ;
  reg  [10:0]                                   mpt_sum_ly_min6 ;
  reg  [10:0]                                   mpt_sum_ly_min7 ;
  reg  [10:0]                                   mpt_sum_ly_min8 ;
  reg  [10:0]                                   mpt_sum_ly_min9 ;
                                                
  assign mpt_sum_ly_vld0  = (mpt_sum_vld_int && mpt_sum_lx_int < SEG_X_WIDTH                                       ) ? 1'b1 : 1'b0 ;
  assign mpt_sum_ly_vld1  = (mpt_sum_vld_int && mpt_sum_lx_int > SEG_X_WIDTH-1   && mpt_sum_lx_int < SEG_X_WIDTH*2 ) ? 1'b1 : 1'b0 ;
  assign mpt_sum_ly_vld2  = (mpt_sum_vld_int && mpt_sum_lx_int > SEG_X_WIDTH*2-1 && mpt_sum_lx_int < SEG_X_WIDTH*3 ) ? 1'b1 : 1'b0 ;
  assign mpt_sum_ly_vld3  = (mpt_sum_vld_int && mpt_sum_lx_int > SEG_X_WIDTH*3-1 && mpt_sum_lx_int < SEG_X_WIDTH*4 ) ? 1'b1 : 1'b0 ;
  assign mpt_sum_ly_vld4  = (mpt_sum_vld_int && mpt_sum_lx_int > SEG_X_WIDTH*4-1 && mpt_sum_lx_int < SEG_X_WIDTH*5 ) ? 1'b1 : 1'b0 ;
  assign mpt_sum_ly_vld5  = (mpt_sum_vld_int && mpt_sum_lx_int > SEG_X_WIDTH*5-1 && mpt_sum_lx_int < SEG_X_WIDTH*6 ) ? 1'b1 : 1'b0 ;
  assign mpt_sum_ly_vld6  = (mpt_sum_vld_int && mpt_sum_lx_int > SEG_X_WIDTH*6-1 && mpt_sum_lx_int < SEG_X_WIDTH*7 ) ? 1'b1 : 1'b0 ;
  assign mpt_sum_ly_vld7  = (mpt_sum_vld_int && mpt_sum_lx_int > SEG_X_WIDTH*7-1 && mpt_sum_lx_int < SEG_X_WIDTH*8 ) ? 1'b1 : 1'b0 ;
  assign mpt_sum_ly_vld8  = (mpt_sum_vld_int && mpt_sum_lx_int > SEG_X_WIDTH*8-1 && mpt_sum_lx_int < SEG_X_WIDTH*9 ) ? 1'b1 : 1'b0 ;
  assign mpt_sum_ly_vld9  = (mpt_sum_vld_int && mpt_sum_lx_int > SEG_X_WIDTH*9-1 && mpt_sum_lx_int < SEG_X_WIDTH*10) ? 1'b1 : 1'b0 ; 
                                                          
  always@(posedge mpt_clk or posedge mpt_arst)            
    if(mpt_arst) begin                                    
        mpt_sum_ly_min0                         <= 11'd0 ;
        mpt_sum_ly_min1                         <= 11'd0 ;
        mpt_sum_ly_min2                         <= 11'd0 ;
        mpt_sum_ly_min3                         <= 11'd0 ;
        mpt_sum_ly_min4                         <= 11'd0 ;
        mpt_sum_ly_min5                         <= 11'd0 ;
        mpt_sum_ly_min6                         <= 11'd0 ;
        mpt_sum_ly_min7                         <= 11'd0 ;
        mpt_sum_ly_min8                         <= 11'd0 ;
        mpt_sum_ly_min9                         <= 11'd0 ; 
    end else begin 
      if(vid_vs_in || rmp_readack_pos)
        mpt_sum_ly_min0                         <= 11'h7ff  ;        
      else if(mpt_sum_ly_vld0 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min0                         <= 11'h0    ;   
      else if(mpt_sum_ly_vld0 && mpt_sum_ly_min0 > mpt_sum_ly_int -4'd2 )
        mpt_sum_ly_min0                         <= mpt_sum_ly_int -4'd2;                 
      if(vid_vs_in || rmp_readack_pos)                                               
        mpt_sum_ly_min1                         <= 11'h7ff  ;        
      else if(mpt_sum_ly_vld1 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min1                         <= 11'h0    ;                    
      else if(mpt_sum_ly_vld1 && mpt_sum_ly_min1 > mpt_sum_ly_int -4'd2 )  
        mpt_sum_ly_min1                         <= mpt_sum_ly_int -4'd2;                 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_min2                         <= 11'h7ff  ;       
      else if(mpt_sum_ly_vld2 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min2                         <= 11'h0    ;  
      else if(mpt_sum_ly_vld2 && mpt_sum_ly_min2 > mpt_sum_ly_int -4'd2 )
        mpt_sum_ly_min2                         <= mpt_sum_ly_int -4'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_min3                         <= 11'h7ff  ;     
      else if(mpt_sum_ly_vld3 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min3                         <= 11'h0    ;  
      else if(mpt_sum_ly_vld3 && mpt_sum_ly_min3 > mpt_sum_ly_int -4'd2 )
        mpt_sum_ly_min3                         <= mpt_sum_ly_int -4'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_min4                         <= 11'h7ff  ;     
      else if(mpt_sum_ly_vld4 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min4                         <= 11'h0    ;  
      else if(mpt_sum_ly_vld4 && mpt_sum_ly_min4 > mpt_sum_ly_int -4'd2 )
        mpt_sum_ly_min4                         <= mpt_sum_ly_int -4'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_min5                         <= 11'h7ff  ;     
      else if(mpt_sum_ly_vld5 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min5                         <= 11'h0    ;  
      else if(mpt_sum_ly_vld5 && mpt_sum_ly_min5 > mpt_sum_ly_int -4'd2 )
        mpt_sum_ly_min5                         <= mpt_sum_ly_int -4'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_min6                         <= 11'h7ff  ;     
      else if(mpt_sum_ly_vld6 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min6                         <= 11'h0    ;  
      else if(mpt_sum_ly_vld6 && mpt_sum_ly_min6 > mpt_sum_ly_int -4'd2 )
        mpt_sum_ly_min6                         <= mpt_sum_ly_int -4'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_min7                         <= 11'h7ff  ;     
      else if(mpt_sum_ly_vld7 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min7                         <= 11'h0    ;  
      else if(mpt_sum_ly_vld7 && mpt_sum_ly_min7 > mpt_sum_ly_int -4'd2 )
        mpt_sum_ly_min7                         <= mpt_sum_ly_int -4'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_min8                         <= 11'h7ff  ;     
      else if(mpt_sum_ly_vld8 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min8                         <= 11'h0    ;  
      else if(mpt_sum_ly_vld8 && mpt_sum_ly_min8 > mpt_sum_ly_int -4'd2 )
        mpt_sum_ly_min8                         <= mpt_sum_ly_int -4'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_min9                         <= 11'h7ff  ;     
      else if(mpt_sum_ly_vld9 && mpt_sum_ly_int < 11'h2 )
        mpt_sum_ly_min9                         <= 11'h0    ;  
      else if(mpt_sum_ly_vld9 && mpt_sum_ly_min9 > mpt_sum_ly_int -4'd2 )
        mpt_sum_ly_min9                         <= mpt_sum_ly_int -4'd2;   
    end   
  
  reg  [10:0]                                   mpt_sum_ly_max0 ;
  reg  [10:0]                                   mpt_sum_ly_max1 ;
  reg  [10:0]                                   mpt_sum_ly_max2 ;
  reg  [10:0]                                   mpt_sum_ly_max3 ;
  reg  [10:0]                                   mpt_sum_ly_max4 ;
  reg  [10:0]                                   mpt_sum_ly_max5 ;
  reg  [10:0]                                   mpt_sum_ly_max6 ;
  reg  [10:0]                                   mpt_sum_ly_max7 ;
  reg  [10:0]                                   mpt_sum_ly_max8 ;
  reg  [10:0]                                   mpt_sum_ly_max9 ; 

   always@(posedge mpt_clk or posedge mpt_arst)
    if(mpt_arst) begin 
        mpt_sum_ly_max0                         <= 11'd0 ;
        mpt_sum_ly_max1                         <= 11'd0 ;
        mpt_sum_ly_max2                         <= 11'd0 ;
        mpt_sum_ly_max3                         <= 11'd0 ;
        mpt_sum_ly_max4                         <= 11'd0 ;
        mpt_sum_ly_max5                         <= 11'd0 ;
        mpt_sum_ly_max6                         <= 11'd0 ;
        mpt_sum_ly_max7                         <= 11'd0 ;
        mpt_sum_ly_max8                         <= 11'd0 ;
        mpt_sum_ly_max9                         <= 11'd0 ;
    end else begin  
      if(vid_vs_in || rmp_readack_pos)
        mpt_sum_ly_max0                         <= 11'h0  ;        
      else if(mpt_sum_ly_vld0 && mpt_sum_ly_max0 <mpt_sum_ly_int + 2'd2 )
        mpt_sum_ly_max0                         <= mpt_sum_ly_int + 2'd2; 
      if(vid_vs_in || rmp_readack_pos)
        mpt_sum_ly_max1                         <= 11'h0  ;        
      else if(mpt_sum_ly_vld1 && mpt_sum_ly_max1 <mpt_sum_ly_int + 2'd2 )  
        mpt_sum_ly_max1                         <= mpt_sum_ly_int + 2'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_max2                         <= 11'h0  ; 
      else if(mpt_sum_ly_vld2 && mpt_sum_ly_max2 <mpt_sum_ly_int + 2'd2 )
        mpt_sum_ly_max2                         <= mpt_sum_ly_int + 2'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_max3                         <= 11'h0  ; 
      else if(mpt_sum_ly_vld3 && mpt_sum_ly_max3 <mpt_sum_ly_int + 2'd2 )
        mpt_sum_ly_max3                         <= mpt_sum_ly_int + 2'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_max4                         <= 11'h0  ; 
      else if(mpt_sum_ly_vld4 && mpt_sum_ly_max4 <mpt_sum_ly_int + 2'd2 )
        mpt_sum_ly_max4                         <= mpt_sum_ly_int + 2'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_max5                         <= 11'h0  ; 
      else if(mpt_sum_ly_vld5 && mpt_sum_ly_max5 <mpt_sum_ly_int + 2'd2 )
        mpt_sum_ly_max5                         <= mpt_sum_ly_int + 2'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_max6                         <= 11'h0  ; 
      else if(mpt_sum_ly_vld6 && mpt_sum_ly_max6 <mpt_sum_ly_int + 2'd2 )
        mpt_sum_ly_max6                         <= mpt_sum_ly_int + 2'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_max7                         <= 11'h0  ; 
      else if(mpt_sum_ly_vld7 && mpt_sum_ly_max7 <mpt_sum_ly_int + 2'd2 )
        mpt_sum_ly_max7                         <= mpt_sum_ly_int + 2'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_max8                         <= 11'h0  ; 
      else if(mpt_sum_ly_vld8 && mpt_sum_ly_max8 <mpt_sum_ly_int + 2'd2 )
        mpt_sum_ly_max8                         <= mpt_sum_ly_int + 2'd2; 
      if(vid_vs_in || rmp_readack_pos) 
        mpt_sum_ly_max9                         <= 11'h0  ; 
      else if(mpt_sum_ly_vld9 &&  mpt_sum_ly_max9 < mpt_sum_ly_int + 2'd2 )
        mpt_sum_ly_max9                         <= mpt_sum_ly_int + 2'd2; 
    end    

`ifdef SIM
  wire [10:0]                                   mpt_sum_ly_diff0 ;
  wire [10:0]                                   mpt_sum_ly_diff1 ;
  wire [10:0]                                   mpt_sum_ly_diff2 ;
  wire [10:0]                                   mpt_sum_ly_diff3 ;
  wire [10:0]                                   mpt_sum_ly_diff4 ;
  wire [10:0]                                   mpt_sum_ly_diff5 ;
  wire [10:0]                                   mpt_sum_ly_diff6 ;
  wire [10:0]                                   mpt_sum_ly_diff7 ;
  wire [10:0]                                   mpt_sum_ly_diff8 ;
  wire [10:0]                                   mpt_sum_ly_diff9 ; 
  assign mpt_sum_ly_diff0   = rmp_readack_pos ? (mpt_sum_ly_max0 - mpt_sum_ly_min0) : mpt_sum_ly_diff0 ;
  assign mpt_sum_ly_diff1   = rmp_readack_pos ? (mpt_sum_ly_max1 - mpt_sum_ly_min1) : mpt_sum_ly_diff1 ;
  assign mpt_sum_ly_diff2   = rmp_readack_pos ? (mpt_sum_ly_max2 - mpt_sum_ly_min2) : mpt_sum_ly_diff2 ;
  assign mpt_sum_ly_diff3   = rmp_readack_pos ? (mpt_sum_ly_max3 - mpt_sum_ly_min3) : mpt_sum_ly_diff3 ;
  assign mpt_sum_ly_diff4   = rmp_readack_pos ? (mpt_sum_ly_max4 - mpt_sum_ly_min4) : mpt_sum_ly_diff4 ;
  assign mpt_sum_ly_diff5   = rmp_readack_pos ? (mpt_sum_ly_max5 - mpt_sum_ly_min5) : mpt_sum_ly_diff5 ;
  assign mpt_sum_ly_diff6   = rmp_readack_pos ? (mpt_sum_ly_max6 - mpt_sum_ly_min6) : mpt_sum_ly_diff6 ;
  assign mpt_sum_ly_diff7   = rmp_readack_pos ? (mpt_sum_ly_max7 - mpt_sum_ly_min7) : mpt_sum_ly_diff7 ;
  assign mpt_sum_ly_diff8   = rmp_readack_pos ? (mpt_sum_ly_max8 - mpt_sum_ly_min8) : mpt_sum_ly_diff8 ;
  assign mpt_sum_ly_diff9   = rmp_readack_pos ? (mpt_sum_ly_max9 - mpt_sum_ly_min9) : mpt_sum_ly_diff9 ; 
`endif

  reg                                           mpt_sum_ly_vld0_1d,mpt_sum_ly_vld0_2d ;
  reg                                           mpt_sum_ly_vld1_1d,mpt_sum_ly_vld1_2d ;
  reg                                           mpt_sum_ly_vld2_1d,mpt_sum_ly_vld2_2d ;
  reg                                           mpt_sum_ly_vld3_1d,mpt_sum_ly_vld3_2d ;
  reg                                           mpt_sum_ly_vld4_1d,mpt_sum_ly_vld4_2d ;
  reg                                           mpt_sum_ly_vld5_1d,mpt_sum_ly_vld5_2d ;
  reg                                           mpt_sum_ly_vld6_1d,mpt_sum_ly_vld6_2d ;
  reg                                           mpt_sum_ly_vld7_1d,mpt_sum_ly_vld7_2d ;
  reg                                           mpt_sum_ly_vld8_1d,mpt_sum_ly_vld8_2d ;
  reg                                           mpt_sum_ly_vld9_1d,mpt_sum_ly_vld9_2d ; 

  reg                                           mpt_sum_ly_vld0_neg  ;
  reg                                           mpt_sum_ly_vld1_neg  ;
  reg                                           mpt_sum_ly_vld2_neg  ;
  reg                                           mpt_sum_ly_vld3_neg  ;
  reg                                           mpt_sum_ly_vld4_neg  ;
  reg                                           mpt_sum_ly_vld5_neg  ;
  reg                                           mpt_sum_ly_vld6_neg  ;
  reg                                           mpt_sum_ly_vld7_neg  ;
  reg                                           mpt_sum_ly_vld8_neg  ;
  reg                                           mpt_sum_ly_vld9_neg  ; 
  reg    [7:0]                                  mpt_sum_ly_vld0_xcnt  ;
  reg    [7:0]                                  mpt_sum_ly_vld1_xcnt  ;
  reg    [7:0]                                  mpt_sum_ly_vld2_xcnt  ;
  reg    [7:0]                                  mpt_sum_ly_vld3_xcnt  ;
  reg    [7:0]                                  mpt_sum_ly_vld4_xcnt  ;
  reg    [7:0]                                  mpt_sum_ly_vld5_xcnt  ;
  reg    [7:0]                                  mpt_sum_ly_vld6_xcnt  ;
  reg    [7:0]                                  mpt_sum_ly_vld7_xcnt  ;
  reg    [7:0]                                  mpt_sum_ly_vld8_xcnt  ;
  reg    [7:0]                                  mpt_sum_ly_vld9_xcnt  ; 

  always@(posedge mpt_clk) mpt_sum_ly_vld0_1d   <= mpt_sum_ly_vld0    ;
  always@(posedge mpt_clk) mpt_sum_ly_vld1_1d   <= mpt_sum_ly_vld1    ;
  always@(posedge mpt_clk) mpt_sum_ly_vld2_1d   <= mpt_sum_ly_vld2    ;
  always@(posedge mpt_clk) mpt_sum_ly_vld3_1d   <= mpt_sum_ly_vld3    ;
  always@(posedge mpt_clk) mpt_sum_ly_vld4_1d   <= mpt_sum_ly_vld4    ;
  always@(posedge mpt_clk) mpt_sum_ly_vld5_1d   <= mpt_sum_ly_vld5    ;
  always@(posedge mpt_clk) mpt_sum_ly_vld6_1d   <= mpt_sum_ly_vld6    ;
  always@(posedge mpt_clk) mpt_sum_ly_vld7_1d   <= mpt_sum_ly_vld7    ;
  always@(posedge mpt_clk) mpt_sum_ly_vld8_1d   <= mpt_sum_ly_vld8    ;
  always@(posedge mpt_clk) mpt_sum_ly_vld9_1d   <= mpt_sum_ly_vld9    ;  
  always@(posedge mpt_clk) mpt_sum_ly_vld0_2d   <= mpt_sum_ly_vld0_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld1_2d   <= mpt_sum_ly_vld1_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld2_2d   <= mpt_sum_ly_vld2_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld3_2d   <= mpt_sum_ly_vld3_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld4_2d   <= mpt_sum_ly_vld4_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld5_2d   <= mpt_sum_ly_vld5_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld6_2d   <= mpt_sum_ly_vld6_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld7_2d   <= mpt_sum_ly_vld7_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld8_2d   <= mpt_sum_ly_vld8_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld9_2d   <= mpt_sum_ly_vld9_1d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld0_neg  <= !mpt_sum_ly_vld0_1d & mpt_sum_ly_vld0_2d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld1_neg  <= !mpt_sum_ly_vld1_1d & mpt_sum_ly_vld1_2d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld2_neg  <= !mpt_sum_ly_vld2_1d & mpt_sum_ly_vld2_2d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld3_neg  <= !mpt_sum_ly_vld3_1d & mpt_sum_ly_vld3_2d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld4_neg  <= !mpt_sum_ly_vld4_1d & mpt_sum_ly_vld4_2d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld5_neg  <= !mpt_sum_ly_vld5_1d & mpt_sum_ly_vld5_2d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld6_neg  <= !mpt_sum_ly_vld6_1d & mpt_sum_ly_vld6_2d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld7_neg  <= !mpt_sum_ly_vld7_1d & mpt_sum_ly_vld7_2d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld8_neg  <= !mpt_sum_ly_vld8_1d & mpt_sum_ly_vld8_2d ;
  always@(posedge mpt_clk) mpt_sum_ly_vld9_neg  <= !mpt_sum_ly_vld9_1d & mpt_sum_ly_vld9_2d ;
        
always@(posedge mpt_clk or posedge mpt_arst)                     
    if(mpt_arst)  begin                                            
        mpt_sum_ly_vld0_xcnt                    <= 8'b0 ;  
        mpt_sum_ly_vld1_xcnt                    <= 8'b0 ;  
        mpt_sum_ly_vld2_xcnt                    <= 8'b0 ;  
        mpt_sum_ly_vld3_xcnt                    <= 8'b0 ;  
        mpt_sum_ly_vld4_xcnt                    <= 8'b0 ;  
        mpt_sum_ly_vld5_xcnt                    <= 8'b0 ;  
        mpt_sum_ly_vld6_xcnt                    <= 8'b0 ;  
        mpt_sum_ly_vld7_xcnt                    <= 8'b0 ;  
        mpt_sum_ly_vld8_xcnt                    <= 8'b0 ;  
        mpt_sum_ly_vld9_xcnt                    <= 8'b0 ; 
    end else begin
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld0_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld0)             mpt_sum_ly_vld0_xcnt  <= mpt_sum_ly_vld0_xcnt + 1'b1; 
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld1_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld1)             mpt_sum_ly_vld1_xcnt  <= mpt_sum_ly_vld1_xcnt + 1'b1; 
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld2_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld2)             mpt_sum_ly_vld2_xcnt  <= mpt_sum_ly_vld2_xcnt + 1'b1; 
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld3_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld3)             mpt_sum_ly_vld3_xcnt  <= mpt_sum_ly_vld3_xcnt + 1'b1; 
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld4_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld4)             mpt_sum_ly_vld4_xcnt  <= mpt_sum_ly_vld4_xcnt + 1'b1; 
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld5_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld5)             mpt_sum_ly_vld5_xcnt  <= mpt_sum_ly_vld5_xcnt + 1'b1; 
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld6_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld6)             mpt_sum_ly_vld6_xcnt  <= mpt_sum_ly_vld6_xcnt + 1'b1; 
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld7_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld7)             mpt_sum_ly_vld7_xcnt  <= mpt_sum_ly_vld7_xcnt + 1'b1; 
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld8_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld8)             mpt_sum_ly_vld8_xcnt  <= mpt_sum_ly_vld8_xcnt + 1'b1; 
      if(vid_vs_in || rmp_readack_pos)  mpt_sum_ly_vld9_xcnt  <= 8'b0 ; 
      else if(mpt_sum_ly_vld9)             mpt_sum_ly_vld9_xcnt  <= mpt_sum_ly_vld9_xcnt + 1'b1; 
    end
                     
always@(posedge mpt_clk or posedge mpt_arst)                                 
    if(mpt_arst) begin                                        
        mpt_sum_ly_LA0_min                      <= 11'b0 ; 
        mpt_sum_ly_LA1_min                      <= 11'b0 ; 
        mpt_sum_ly_LA2_min                      <= 11'b0 ; 
        mpt_sum_ly_LA3_min                      <= 11'b0 ; 
        mpt_sum_ly_LA4_min                      <= 11'b0 ; 
        mpt_sum_ly_LA5_min                      <= 11'b0 ; 
        mpt_sum_ly_LA6_min                      <= 11'b0 ; 
        mpt_sum_ly_LA7_min                      <= 11'b0 ; 
        mpt_sum_ly_LA8_min                      <= 11'b0 ; 
        mpt_sum_ly_LA9_min                      <= 11'b0 ; 
        mpt_sum_ly_LA0_max                      <= 11'b0 ; 
        mpt_sum_ly_LA1_max                      <= 11'b0 ; 
        mpt_sum_ly_LA2_max                      <= 11'b0 ; 
        mpt_sum_ly_LA3_max                      <= 11'b0 ; 
        mpt_sum_ly_LA4_max                      <= 11'b0 ; 
        mpt_sum_ly_LA5_max                      <= 11'b0 ; 
        mpt_sum_ly_LA6_max                      <= 11'b0 ; 
        mpt_sum_ly_LA7_max                      <= 11'b0 ; 
        mpt_sum_ly_LA8_max                      <= 11'b0 ; 
        mpt_sum_ly_LA9_max                      <= 11'b0 ; 
        mpt_sum_lx_LA0_cnt                      <= 8'd0  ; 
        mpt_sum_lx_LA1_cnt                      <= 8'd0  ; 
        mpt_sum_lx_LA2_cnt                      <= 8'd0  ; 
        mpt_sum_lx_LA3_cnt                      <= 8'd0  ; 
        mpt_sum_lx_LA4_cnt                      <= 8'd0  ; 
        mpt_sum_lx_LA5_cnt                      <= 8'd0  ; 
        mpt_sum_lx_LA6_cnt                      <= 8'd0  ; 
        mpt_sum_lx_LA7_cnt                      <= 8'd0  ; 
        mpt_sum_lx_LA8_cnt                      <= 8'd0  ; 
        mpt_sum_lx_LA9_cnt                      <= 8'd0  ; 
    end else begin                                                 
      if(rmp_readack_LA_pos) begin 
        mpt_sum_ly_LA0_min                      <= mpt_sum_ly_min0 ; 
        mpt_sum_ly_LA1_min                      <= mpt_sum_ly_min1 ; 
        mpt_sum_ly_LA2_min                      <= mpt_sum_ly_min2 ; 
        mpt_sum_ly_LA3_min                      <= mpt_sum_ly_min3 ; 
        mpt_sum_ly_LA4_min                      <= mpt_sum_ly_min4 ; 
        mpt_sum_ly_LA5_min                      <= mpt_sum_ly_min5 ; 
        mpt_sum_ly_LA6_min                      <= mpt_sum_ly_min6 ; 
        mpt_sum_ly_LA7_min                      <= mpt_sum_ly_min7 ; 
        mpt_sum_ly_LA8_min                      <= mpt_sum_ly_min8 ; 
        mpt_sum_ly_LA9_min                      <= mpt_sum_ly_min9 ; 
        mpt_sum_ly_LA0_max                      <= mpt_sum_ly_max0 ; 
        mpt_sum_ly_LA1_max                      <= mpt_sum_ly_max1 ; 
        mpt_sum_ly_LA2_max                      <= mpt_sum_ly_max2 ; 
        mpt_sum_ly_LA3_max                      <= mpt_sum_ly_max3 ; 
        mpt_sum_ly_LA4_max                      <= mpt_sum_ly_max4 ; 
        mpt_sum_ly_LA5_max                      <= mpt_sum_ly_max5 ; 
        mpt_sum_ly_LA6_max                      <= mpt_sum_ly_max6 ; 
        mpt_sum_ly_LA7_max                      <= mpt_sum_ly_max7 ; 
        mpt_sum_ly_LA8_max                      <= mpt_sum_ly_max8 ; 
        mpt_sum_ly_LA9_max                      <= mpt_sum_ly_max9 ; 
        mpt_sum_lx_LA0_cnt                      <= mpt_sum_ly_vld0_xcnt  ; 
        mpt_sum_lx_LA1_cnt                      <= mpt_sum_ly_vld1_xcnt  ; 
        mpt_sum_lx_LA2_cnt                      <= mpt_sum_ly_vld2_xcnt  ; 
        mpt_sum_lx_LA3_cnt                      <= mpt_sum_ly_vld3_xcnt  ; 
        mpt_sum_lx_LA4_cnt                      <= mpt_sum_ly_vld4_xcnt  ; 
        mpt_sum_lx_LA5_cnt                      <= mpt_sum_ly_vld5_xcnt  ; 
        mpt_sum_lx_LA6_cnt                      <= mpt_sum_ly_vld6_xcnt  ; 
        mpt_sum_lx_LA7_cnt                      <= mpt_sum_ly_vld7_xcnt  ; 
        mpt_sum_lx_LA8_cnt                      <= mpt_sum_ly_vld8_xcnt  ; 
        mpt_sum_lx_LA9_cnt                      <= mpt_sum_ly_vld9_xcnt  ; 
      end  
    end
            
  
endmodule
