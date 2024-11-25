`timescale 1ns/1ns
module TB_singleDatapath_2();

wire [31:0] resultadoTB;
reg clk_TB;

singleDatapath_2 fase2( 
	.CLK(clk_TB),
	.resultadoTotal(resultadoTB)
);

initial begin
	//clk_TB = 0;
    //repeat(50) #25 clk_TB = ~clk_TB;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	
	clk_TB=1;
	#26;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	clk_TB=0;
	#25;
	clk_TB=1;
	#25;
	
	$stop;
end
endmodule