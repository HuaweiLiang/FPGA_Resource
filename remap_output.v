/****************************Copyright**********************************
**                           
**               
**
**------------------------File Infomation-------------------------------
** FileName     :       remap_out.v
** Author       :       huawei.liang
** Data         :       2018-12-17
** Version      :       v1.0
** Description  :       
**                      
***********************************************************************/
`timescale 1ns/1ps 
module remap_output#(                            
   parameter  VID_VACT                          = 16'd720    , 
   parameter  VID_HACT                          = 16'd1280   , 
   parameter  REMAP_OUT_HACT                    = 16'd6000    
   ) (           
    input  wire                                 mpt_clk             , 
    input  wire                                 mpt_arst            , 
    input  wire                                 vid_vs_in           , 
    input  wire                                 rmp_L_read_ack      ,  
    input  wire                                 rmp_R_read_ack      ,  
    output reg                                  rmp_out_ready       , 
                                                                      
    input  wire                                 rmp_L_vs            , 
    input  wire                                 rmp_L_first_line    , 
    output wire                                 rmp_L_in_fifo_full  , 
    input  wire  [7:0]                          rmp_L_in_data       , 
    input  wire                                 rmp_L_in_vld        , 
    input  wire                                 rmp_R_vs            , 
    input  wire                                 rmp_R_first_line    , 
    output wire                                 rmp_R_in_fifo_full  , 
    input  wire  [7:0]                          rmp_R_in_data       , 
    input  wire                                 rmp_R_in_vld        , 
                                                                      
    output reg                                  remap_out_vs        , 
    output reg                                  remap_out_hvld      , 
    output reg                                  remap_out_dvld      , 
    output reg   [7:0]                          remap_L_out_data    , 
    output reg   [7:0]                          remap_R_out_data      
    );                                                                

   parameter  FIFO_READ_HACT                    = (VID_HACT+1)*4 ;
  (*mark_debug = "true"*)reg    [15:0]                                 v_xcnt                  ; 
  (*mark_debug = "true"*)reg    [11:0]                                 v_ycnt                  ; 
  reg    [1:0]                                  div_cnt                 ; 
  reg                                           fifo_read_en            ;
  wire   [7:0]                                  fifo_L_read_data        ;
  wire                                          fifo_L_read_valid       ;
  wire   [7:0]                                  fifo_R_read_data        ;
  wire                                          fifo_R_read_valid       ;
  wire   [11:0]                                 fifo_L_wr_data_count    ;
  wire   [11:0]                                 fifo_R_wr_data_count    ;
  reg                                           rmp_L_first_line_1d     ; 
  reg                                           rmp_R_first_line_1d     ; 
  reg                                           rmp_LR_first_line       ;  
  reg                                           rmp_LR_first_line_1d    ;  
  reg                                           fifo_read_en_1d         ; 
  reg                                           rmp_L_vs_1d             ; 
  reg                                           rmp_R_vs_1d             ; 
  wire                                          fifo_L_empty            ;
  wire                                          fifo_R_empty            ;

  always@(posedge mpt_clk) rmp_L_vs_1d          <= rmp_L_vs             ; 
  always@(posedge mpt_clk) rmp_R_vs_1d          <= rmp_R_vs             ; 
  always@(posedge mpt_clk) remap_out_vs         <= rmp_L_vs_1d          ; 
  always@(posedge mpt_clk) rmp_L_first_line_1d  <= rmp_L_first_line     ; 
  always@(posedge mpt_clk) rmp_R_first_line_1d  <= rmp_R_first_line     ; 
  always@(posedge mpt_clk) fifo_read_en_1d      <= fifo_read_en         ; 
  always@(posedge mpt_clk) remap_out_dvld       <= fifo_read_en_1d      ; 
  always@(posedge mpt_clk) remap_L_out_data     <= fifo_L_read_data     ; 
  always@(posedge mpt_clk) remap_R_out_data     <= fifo_R_read_data     ; 
  always@(posedge mpt_clk) rmp_LR_first_line    <= rmp_R_first_line_1d | rmp_L_first_line_1d ;
  always@(posedge mpt_clk) rmp_LR_first_line_1d <= rmp_LR_first_line    ;
                                                                        
  always@(posedge mpt_clk or posedge mpt_arst)                           
    if(mpt_arst) begin                                                   
        div_cnt                                 <= 2'b0  ;
        v_xcnt                                  <= 16'b0 ;                    
        v_ycnt                                  <= 12'b0 ;           
    end else begin                                                        
      if(rmp_LR_first_line)     
        div_cnt                                 <= 2'b0     ;  
      else 
        div_cnt                                 <= div_cnt + 1'b1 ; 

      if(rmp_LR_first_line)  
        v_xcnt                                  <= 16'hffff ;
      else if(v_xcnt == REMAP_OUT_HACT/4 - 1'b1 && div_cnt == 2'b11) 
        v_xcnt                                  <= 16'b0 ;
      else if(div_cnt == 2'b11)
        v_xcnt                                  <= v_xcnt  + 1'b1 ;  

      if(rmp_LR_first_line)   
        v_ycnt                                  <= 12'b0 ;
      else if(v_xcnt == REMAP_OUT_HACT/4 - 1'b1 && div_cnt == 2'b11)                             
        v_ycnt                                  <= v_ycnt + 1'b1;
    end                                                                  
                                                               
  always@(posedge mpt_clk or posedge mpt_arst)                           
    if(mpt_arst) begin                                                   
        rmp_out_ready                           <= 1'b0 ;          
    end else begin                                                        
      if({rmp_LR_first_line_1d,rmp_LR_first_line} == 2'b10 || (v_xcnt == REMAP_OUT_HACT/4 - 1'b1 && div_cnt == 2'b11))     
        rmp_out_ready                           <= 1'b1 ;  
      else if(rmp_L_read_ack && rmp_R_read_ack)
        rmp_out_ready                           <= 1'b0 ; 
    end

  always@(posedge mpt_clk or posedge mpt_arst)                           
    if(mpt_arst) begin                                           
        remap_out_hvld                          <= 1'b0  ;      
        fifo_read_en                            <= 1'b0  ;         
    end else begin                                                       
      if(v_xcnt <= VID_HACT + 1'b1 && v_ycnt < VID_VACT )       
        remap_out_hvld                          <= 1'b1  ; 
      else                           
        remap_out_hvld                          <= 1'b0  ; 
      if(v_xcnt < VID_HACT && v_ycnt < VID_VACT && div_cnt == 2'b11 && !fifo_L_empty && !fifo_R_empty)       
        fifo_read_en                            <= 1'b1  ; 
      else                           
        fifo_read_en                            <= 1'b0  ; 
    end  

  fifo_remapdata_out  uL_fifo_remapdata_out (                   
    .wr_clk                                     ( mpt_clk              ), 
    .rst                                        (rmp_L_vs            ), 
    .wr_en                                      (rmp_L_in_vld          ), 
    .din                                        (rmp_L_in_data         ), 
    .full                                       (                      ), 
    .prog_full                                  (rmp_L_in_fifo_full    ), 
    .wr_data_count                              (fifo_L_wr_data_count  ),
    .rd_clk                                     (mpt_clk               ), 
    .rd_en                                      (fifo_read_en          ), 
    .dout                                       (fifo_L_read_data      ), 
    .valid                                      (fifo_L_read_valid     ), 
    .empty                                      (fifo_L_empty          )  
    );                                                          
  fifo_remapdata_out  uR_fifo_remapdata_out (                   
    .wr_clk                                     ( mpt_clk              ), 
    .rst                                        (rmp_R_vs              ), 
    .wr_en                                      (rmp_R_in_vld          ), 
    .din                                        (rmp_R_in_data         ), 
    .full                                       (                      ), 
    .prog_full                                  (rmp_R_in_fifo_full    ), 
    .wr_data_count                              (fifo_R_wr_data_count  ),
    .rd_clk                                     (mpt_clk               ), 
    .rd_en                                      (fifo_read_en          ), 
    .dout                                       (fifo_R_read_data      ), 
    .valid                                      (fifo_R_read_valid     ), 
    .empty                                      (fifo_R_empty          )  
    );  

  // (*mark_debug = "true"*)reg   [11:0]                                  remap_L_xcnt;
  // (*mark_debug = "true"*)reg   [11:0]                                  remap_L_ycnt;
  // (*mark_debug = "true"*)reg   [11:0]                                  remap_R_xcnt;
  // (*mark_debug = "true"*)reg   [11:0]                                  remap_R_ycnt;
  // always@(posedge mpt_clk or posedge mpt_arst)                           
  //   if(mpt_arst) begin                                           
  //       remap_L_xcnt                            <= 12'b0  ;          
  //       remap_L_ycnt                            <= 12'b0  ;      
  //       remap_R_xcnt                            <= 12'b0  ;  
  //       remap_R_ycnt                            <= 12'b0  ;         
  //   end else begin                                                       
  //     if((rmp_L_in_vld && remap_L_xcnt == VID_HACT - 1'b1) ||  rmp_L_vs)       
  //       remap_L_xcnt                            <= 12'd0  ; 
  //     else if(rmp_L_in_vld)                          
  //       remap_L_xcnt                            <= remap_L_xcnt + 1'b1  ;  
  //     if(rmp_L_vs)       
  //       remap_L_ycnt                            <= 12'd0  ; 
  //     else if(rmp_L_in_vld && remap_L_xcnt == VID_HACT - 1'b1 )                          
  //       remap_L_ycnt                            <= remap_L_ycnt + 1'b1  ; 
      
  //     if((rmp_R_in_vld && remap_R_xcnt == VID_HACT - 1'b1) ||  rmp_R_vs)       
  //       remap_R_xcnt                            <= 12'd0  ; 
  //     else if(rmp_R_in_vld)                          
  //       remap_R_xcnt                            <= remap_R_xcnt + 1'b1  ;  
  //     if(rmp_R_vs)       
  //       remap_R_ycnt                            <= 12'd0  ; 
  //     else if(rmp_R_in_vld && remap_R_xcnt == VID_HACT - 1'b1 )                          
  //       remap_R_ycnt                            <= remap_R_ycnt + 1'b1  ;  
  //   end  



endmodule
