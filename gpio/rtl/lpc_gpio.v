/////////////////////////////////////////////////////////////////////
////                                                             ////
////  LPC(Low Pin Count) GPIO(General Purpose Input Output)      ////
////                                                             ////
////                                                             ////
////  Author: Junbing Liang                                      ////
////          Junbing.Liang@googlemail.com                       ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2007 Junbing Liang                            ////
////                                                             ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////


module lpc_gpio(LAD,LFRAME,LRESET,LCLK, gpio_addr_i,gpio_i,gpio_o);

output   [7:0]  gpio_o;
input    [7:0]  gpio_i;
input   [15:0]  gpio_addr_i;

//bus interface
inout   [3:0]   LAD;
input           LFRAME;   //low active
input           LRESET;   //low activate
input           LCLK;      //


reg      [7:0]   gpio_out_reg;     //output register
reg      [7:0]   gpio_out_reg1;    //use second reg to control the output time
reg      [7:0]   gpio_in_reg;      //input register
reg      [3:0]   lpc_state;
reg      [3:0]   lpc_state_next;
reg      [15:0]  gpio_addr_reg;    //address register

reg               write_flag;



//lpc_state_next
always @(LFRAME or lpc_state or LAD)
begin
    if (!LFRAME)
       if (LAD == 4'b0000)
          lpc_state_next <= 1;
       else
          lpc_state_next <= 0;
    else
    begin
       //if address is not match, state will be set to 0
       if (  ((lpc_state == 2) && (LAD != gpio_addr_i[15:12]) )
          || ((lpc_state == 3) && (LAD != gpio_addr_i[11:8]) )
          || ((lpc_state == 4) && (LAD != gpio_addr_i[7:4]) )
          || ((lpc_state == 5) && (LAD != gpio_addr_i[3:0]) )
          || (lpc_state ==4'hc)   //last state
          || (lpc_state ==4'b0000)
          )
          lpc_state_next <= 0;
       else
          lpc_state_next <= lpc_state+4'b0001;          
    end
    
end

//lpc_state
always @(posedge LCLK)
begin
    if (!LRESET)
       lpc_state <= 0;
    else
      lpc_state <= lpc_state_next;
    
end

//write_flag
always @(negedge LCLK)
begin
    if ( (!LRESET)||(!LFRAME)|| (lpc_state==0) )
       write_flag <= 0;   //default is read
    else
    begin
       if (lpc_state ==1)
       begin
           if (LAD==4'b0010) 
              write_flag <=1;
           else 
              write_flag <=0;   //read for all others
       end
       else
          write_flag <= write_flag;
    end
  end

//gpio_addr_reg
always @(negedge LCLK)
begin
    if ( (!LRESET)||(!LFRAME) )
       gpio_addr_reg <= 0;
    else
    begin
        case (lpc_state)
            2: gpio_addr_reg[15:12] <= LAD;
            3: gpio_addr_reg[11:8]  <= LAD;
            4: gpio_addr_reg[7:4]   <= LAD;
            5: gpio_addr_reg[3:0]   <= LAD;
            default:
               gpio_addr_reg <= gpio_addr_reg;
       endcase; 
    end
end

//gpio_out_reg
always @(negedge LCLK)
begin
    if (!LRESET)
       gpio_out_reg <= 0;
    else
    begin
       if ((write_flag) && (gpio_addr_reg == gpio_addr_i))
            case (lpc_state)
               6:gpio_out_reg[7:4] <= LAD;
               7:gpio_out_reg[3:0] <= LAD;
               default:
                  gpio_out_reg <= gpio_out_reg;
            endcase
       else
          gpio_out_reg <= gpio_out_reg;
    end
end



//gpio_out_reg1
//use second output register to control the output time
always @ (posedge LCLK)
begin
   if (!LRESET)
      gpio_out_reg1 <= 0;
   else
      if (lpc_state == 4'hc)
         gpio_out_reg1 <= gpio_out_reg;
      else
         gpio_out_reg1 <= gpio_out_reg1;
end
    
    



assign gpio_o = LRESET?gpio_out_reg1:8'hzz;
assign LAD[3:0] = //bus read data from gpio input
                  (!write_flag && lpc_state==8)  ? 4'b1111 :      //sync
                  (!write_flag && lpc_state==9)  ? gpio_i[7:4] :
                  (!write_flag && lpc_state==10) ? gpio_i[3:0] : 
                  (!write_flag && lpc_state==11) ? 4'b1111:       //first TAR
                  
                  //bus write to gpio output
                  (write_flag && lpc_state==10)  ?  4'b0000:     //sync
                  (write_flag && lpc_state==11)  ?  4'b1111:     //first TAR
                  4'bzzzz;

               



endmodule