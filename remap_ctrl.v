/****************************Copyright**********************************
**                           
**               
**
**------------------------File Infomation-------------------------------
** FileName     :       remap_ctrl.v 
** Author       :       huawei.liang 
** Data         :       2018-12-17   
** Version      :       v1.0         
** Description  :                    
**                                   
***********************************************************************/
`timescale 1ns/1ps 
module remap_ctrl#(                                                   
   parameter  VID_HACT_SHIFT                    = 8'd200              
   ) (                                                                
    input  wire                                 mpt_clk             , 
    input  wire                                 mpt_arst            , 
    input  wire                                 vid_vs_in           , 
    input  wire                                 vid_de_in           , 
    input  wire                                 vid_locked          , 
    input  wire  [15:0]                         MPT_ONELINE_Y_MAX   , 
     (*mark_debug = "true"*)output reg                                  vid_vs_out            
    );                                                                
                                                                      
   (*mark_debug = "true"*)reg                                           vid_vs_in_1d           ; 
  reg                                           vid_vs_in_2d           ; 
   (*mark_debug = "true"*)reg                                           vid_de_in_1d           ; 
  reg                                           vid_de_in_2d           ;  
  reg   [11:0]                                  v_ycnt                 ;  
  always@(posedge mpt_clk)  vid_vs_in_1d        <= vid_vs_in           ; 
  always@(posedge mpt_clk)  vid_vs_in_2d        <= vid_vs_in_1d        ; 
  always@(posedge mpt_clk)  vid_de_in_1d        <= vid_de_in           ; 
  always@(posedge mpt_clk)  vid_de_in_2d        <= vid_de_in_1d        ; 
                                                                         
  always@(posedge mpt_clk or posedge mpt_arst)                           
    if(mpt_arst) begin                                                   
        v_ycnt                                  <= 12'b0;                
    end else begin                                                       
      if({vid_vs_in_2d,vid_vs_in_1d} == 2'b01 || !vid_locked)   
        v_ycnt                                  <= 12'b0;
      else if({vid_de_in_2d,vid_de_in_1d} == 2'b01)                      
        v_ycnt                                  <= v_ycnt + 1'b1;
    end                                                                  

  always@(posedge mpt_clk or posedge mpt_arst)                           
    if(mpt_arst) begin                                                   
        vid_vs_out                              <= 1'b0;                
    end else begin                                         
`ifdef SIM              
      if(v_ycnt == 12'd50)   
`else 
      if(v_ycnt == MPT_ONELINE_Y_MAX + VID_HACT_SHIFT)   
`endif
        vid_vs_out                              <= 1'b1;
      else                       
        vid_vs_out                              <= 1'b0;
    end                                                                  
 

endmodule
