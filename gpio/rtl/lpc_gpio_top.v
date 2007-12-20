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

module  lpc_gpio_top;


reg    [3:0]   LAD;
reg            LFRAME;
reg            LRESET;
reg            LCLK;

wire   [7:0]   gpio_out;

wire    [3:0]   LAD_w;


//LCLK
initial
begin
       LCLK=1;
end

//LRESET
initial
begin
    

//write date to gpio    
       LRESET = 0;
#50   LRESET = 1; 
#10    LFRAME = 0;
       LAD = 4'b0000;   //1-start
#10    LFRAME = 1;
       LAD = 4'b0010;   //2- CT-DIR, 0010- IO WRITE
#10    LFRAME = 1;
       LAD = 4'b0000;   //3- address A15-A12
#10    LFRAME = 1;
       LAD = 4'b0100;   //4- A11-A8
#10    LFRAME = 1;
       LAD = 4'b0010;   //5- A7-A4
#10    LFRAME = 1;
       LAD = 4'b0001;   //6- A3-A0
#10    LFRAME = 1;
       LAD = 4'b0101;   //7- D3-D0
#10    LFRAME = 1;
       LAD = 4'b1010;   //8- D7-D4
#10    LFRAME = 1;
       LAD = 4'b1111;   //9- TAR
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //10- TAR       
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //11- SYNC
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //12- TAR
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //13- TAR
#50   LFRAME = 1;
       LAD = 4'bzzzz;   //13- TAR
       
       
#20    LFRAME = 0;
       LAD = 4'b0000;   //start
#10    LFRAME = 1;
       LAD = 4'b0010;   //CT-DIR, 0010- IO WRITE
#10    LFRAME = 1;
       LAD = 4'b0000;   //address A15-A12
#10    LFRAME = 1;
       LAD = 4'b0100;   //A11-A8
#10    LFRAME = 1;
       LAD = 4'b0010;   //A7-A4
#10    LFRAME = 1;
       LAD = 4'b0101;   //A3-A0
#10    LFRAME = 1;
       LAD = 4'b1011;   //D3-D0
#10    LFRAME = 1;
       LAD = 4'b0010;   //D7-D4
#10    LFRAME = 1;
       LAD = 4'b1111;   //TAR
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //TAR
#50    LFRAME = 1;
       LAD = 4'bzzzz;   //SYNC
       

//read data from LPC GPIO       
       
       LRESET = 0;
#50   LRESET = 1; 
#10    LFRAME = 0;
       LAD = 4'b0000;   //1-start
#10    LFRAME = 1;
       LAD = 4'b0000;   //2- CT-DIR, 0000- IO READ
#10    LFRAME = 1;
       LAD = 4'b0000;   //3- address A15-A12
#10    LFRAME = 1;
       LAD = 4'b0100;   //4- A11-A8
#10    LFRAME = 1;
       LAD = 4'b0010;   //5- A7-A4
#10    LFRAME = 1;
       LAD = 4'b0001;   //6- A3-A0
#10    LFRAME = 1;
       LAD = 4'b1111;   //7- TAR
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //8- TAR       
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //9- SYNC
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //10 D3-D0
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //11 D7-D4       
#10    LFRAME = 1;
       LAD = 4'bzzzz;   //12- TAR
#100   LFRAME = 1;
       LAD = 4'bzzzz;   //13- TAR       
    
       

end

//LFRAME, LAD
initial
begin
    LFRAME = 0;
    LAD = 0;
end

//LCLK
always
begin
	#5 LCLK = !LCLK;
end

//hookup the gpip module
lpc_gpio gpio1(
   .LAD(LAD_w),
   .LFRAME(LFRAME),
   .LRESET(LRESET),
   .LCLK(LCLK),
   .gpio_addr_i(16'h0421),
   .gpio_i(8'ha5),
   .gpio_o(gpio_out)
   );
   
assign LAD_w = LAD;




endmodule
