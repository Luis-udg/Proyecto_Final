`timescale 1ns/1ns

module Mux2_1(
	input sel,
	input [31:0] A,//0
	input [31:0] B,//1
	output reg[31:0] C
);
always @*
begin 
	if(sel)begin
		C=B;
	end
	else begin
		C=A;
	end
end
endmodule
module Mux2_1_5bits(
	input sel,
	input [4:0] A,//0
	input [4:0] B,//1
	output reg[4:0] C
);
always @*
begin 
	if(sel)begin
		C=B;
	end
	else begin
		C=A;
	end
end
endmodule

module MemDatos(
	input wire [31:0]Direccion,
	input wire [31:0]datosEntrada,
	input WE, //0 en tipo R escribir
	input RE, //0 en tipo R leer
	input clk,
	output reg [31:0]Q
);
reg [31:0] MemDatos [0:31];
initial begin
	$readmemh("datos_MD.txt",MemDatos);
	#10;
end
 always @(posedge clk) begin
        if (WE) begin
            MemDatos[Direccion] = datosEntrada;  // Escritura
        end
end
assign Q=32'd0;////////////////////cambio para obtener salida en utimo buffer
always @(*) begin 
	if(RE) begin
		Q = MemDatos[Direccion]; // Lectura de la memoria
	end
end
endmodule 

module BancoRegistros(
	input [4:0]Dir1Lec,
	input [4:0]Dir2Lec,
	input [31:0]DatosEntrada,
	input WE,
	output reg [31:0]Dato1,
	output reg [31:0]Dato2,
	input [4:0]DirEsc,
	input clk_BR
);
reg [31:0] BancoRegistros [0:62];
initial begin
	$readmemh("datos_BR.txt",BancoRegistros);
	#10;
end
 always @(*)begin
        if (WE) begin
			#100;
            BancoRegistros[DirEsc] = DatosEntrada;  // Escritura
        end
end
always @(*) begin
	Dato1 = BancoRegistros[Dir1Lec]; // Lectura de la memoria
	Dato2 = BancoRegistros[Dir2Lec];
end
endmodule

module PC(
	input clk, //nuevo
	output reg[31:0] dirInstruccion,
	input [31:0] dirInstruccionNueva
);
assign dirInstruccion= 32'b0;
always @(posedge clk)
begin 
	#70;
	dirInstruccion = dirInstruccionNueva;
	//#100;
end

endmodule

module Add_1in(
	input [31:0] A,
	output [31:0] C
);
assign C=A+32'd4;
endmodule

module InstructionMemory(
	input [31:0] readAddress,
	output reg [31:0]instruction
);
reg [7:0] InstructionMemory [0:62];
initial begin
	$readmemb("instrucciones_B.txt",InstructionMemory);
	#100; 
end
assign instruction={InstructionMemory[readAddress],
					InstructionMemory[readAddress+1],
					InstructionMemory[readAddress+2],
					InstructionMemory[readAddress+3]};
endmodule 

module ALU(
	input [3:0]SEL,
	input [31:0]op1,
	input [31:0]op2,
	output reg [31:0]resultado,
	output zf
);
always @(*) begin
    case (SEL)
        4'b0000: begin
            resultado=op1&op2;
        end
		4'b0001: begin
            resultado=op1|op2;
        end
		4'b0010: begin
            resultado=op1+op2;
        end
		4'b0110: begin
            resultado=op1-op2;
        end
		4'b0111: begin
            resultado=(op1 < op2) ? 32'b1 : 32'b0;
        end
		4'b1100: begin
            resultado=~(op1|op2);//nor
        end
        default: begin
            
        end
    endcase
end
assign zf= resultado==32'd0 ? 32'd1 : 32'd0;
endmodule

module unidadControl(
	input [5:0]opCode, //tipo r 000000
	output reg BRdesti,//mux BR
	output reg branch,//directo and
	output reg aluSrc,//sel segundo operando ALU
	output reg bancoRegEn,//señal escribir BR
	output reg[2:0]AluControl,//indica si escucha a funct
	output reg EnW,//memoria de datos write
	output reg EnR,//memoria de datos read
	output reg mux1 //sel mux ALU o MemDatos a banco de registro
);
always @(*) begin
    case (opCode)
		6'b000000: 
		begin //tipo R 6
			BRdesti=1;
			branch=0;
			EnR=0;
			mux1=1;
			AluControl=3'b010;
			EnW=0;
			aluSrc=0;
			bancoRegEn=1;
		end 
		6'b001000:
		begin //ADDI
			BRdesti=0;
			branch=0;
			EnR=0;
			mux1=1;
			AluControl=3'b000;
			EnW=0;
			aluSrc=1;
			bancoRegEn=1;
		end
		6'b001010:
		begin //SLTI
			BRdesti=0;
			branch=0;
			EnR=0;
			mux1=1;
			AluControl=3'b011;
			EnW=0;
			aluSrc=1;
			bancoRegEn=1;
		end
		6'b001101:
		begin //ORI
			BRdesti=0;
			branch=0;
			EnR=0;
			mux1=1;
			AluControl=3'b100;
			EnW=0;
			aluSrc=1;
			bancoRegEn=1;
		end
		6'b001100:
		begin //ANDI
			BRdesti=0;
			branch=0;
			EnR=0;
			mux1=1;
			AluControl=3'b101;
			EnW=0;
			aluSrc=1;
			bancoRegEn=1;
		end
		6'b100011: 
		begin //LW memdatos a BR
			BRdesti=0;
			branch=0;
			EnR=1;
			mux1=0;////////////////////////////////
			//mux1=1;
			AluControl=3'b000;
			EnW=0;
			aluSrc=1;
			bancoRegEn=1;
		end
		
		6'b101011 :
		begin //SW BR A MEMDATOS
			BRdesti=0; //no importa
			branch=0;
			EnR=0;
			mux1=1;//no importa
			AluControl=3'b000;
			EnW=1;
			aluSrc=1;
			bancoRegEn=0;
		end
		
		6'b000100:
		begin //BEQ
			BRdesti=0; //no importa
			branch=1;
			EnR=0;
			mux1=1;//no importa
			AluControl=3'b001;
			EnW=0;
			aluSrc=0;
			bancoRegEn=0;
		end
		
		default: begin
            
        end
	endcase
end
	 
endmodule

module ALUcontrol (
	input [2:0] unidadControl,
	input [5:0] funct,
	output reg[3:0] aluCode
);

always @* begin
	case(unidadControl)
		3'b000: begin //tipo I ADDI, LW, SW
			aluCode=4'b0010;
		end
		3'b001: begin //tipo I BEQ
			aluCode=4'b0110;
		end
		3'b011: begin //tipo I SLTI
			aluCode=4'b0111;
		end
		3'b100: begin //tipo I ORI
			aluCode=4'b0001;
		end
		3'b101: begin //tipo I ANDI
			aluCode=4'b0000;
		end
		3'b010: begin //se escucha al funct
			case(funct)
				6'b100100: begin//and
					aluCode=4'b0000;
				end
				6'b100101: begin//OR
					aluCode=4'b0001;
				end
				6'b100000: begin //+
					aluCode=4'b0010;
				end
				6'b100010: begin //-
					aluCode=4'b0110;//6
				end
				6'b101010: begin // <
					aluCode=4'b0111;//7
				end
				6'b100111: begin
					aluCode=4'b1100;//nor12
				end
				default: begin
					aluCode=4'b1111;
				end
			endcase
		end
	endcase
end

endmodule
module SignExtend(
	input reg [15:0] inmediato_16bits,
	output reg [31:0] inmediato_32bits
);
always @(*) begin
	if (inmediato_16bits[15] == 0) begin
		inmediato_32bits={16'b0, inmediato_16bits};
	end
	else begin 
		inmediato_32bits={16'b1111111111111111, inmediato_16bits};
	end
end

endmodule
/////////////////////////////////////////////////////////////////////
module ShiftLeft_2(
	input [31:0]Y,
	output [31:0]X
);
assign X=Y<<2;
endmodule

module Add_2in(
	input [31:0] A,
	input [31:0] B,
	output [31:0] C
);
assign C=A+B;
endmodule

module AND(
	input a,
	input b,
	output c
);
assign c=a&b;
endmodule 

module Buffer_IF_ID(
	input clk_if_id,
	input [31:0] in_add4,
	input [31:0] in_instruccion,
	output reg [63:0] out_if_id
);
always @(clk_if_id) begin 
	//if (clk_if_id==1)begin
		out_if_id={in_add4,in_instruccion};
	//end
end
endmodule

module Buffer_ID_EX(
	input clk_id_ex,
	input [31:0] add4,
	input [31:0] in_op1_BR,
	input [31:0] in_op2_BR,
	input [31:0] in_signoExtend,
	input [4:0] in_instr20_16,
	input [4:0] in_instr15_11,
	output reg [137:0] out_id_ex
);
always @(clk_id_ex) begin 
	out_id_ex={add4,in_op1_BR,in_op2_BR,
			in_instr20_16,in_instr15_11,
			in_signoExtend};
end
endmodule
module Buffer_ex_mem(
	input clk_ex_mem,
	input [31:0] add2entradas,
	input in_zf_alu,
	input [31:0] in_alu_result,
	input [31:0] op2_o_Wdatos,
	input [4:0] dirEscBR,
	output reg [101:0] out_ex_mem
);
always @(clk_ex_mem) begin 
	out_ex_mem={add2entradas,in_alu_result,
				op2_o_Wdatos,dirEscBR,
				in_zf_alu};
end
endmodule
module Buffer_mem_wb(
	input clk_mem_wb,
	input [31:0] in_datosMD,
	input [31:0] in_result_alu,
	input [4:0] dirEscBR_,
	output reg [68:0] out_mem_web
);
always @(clk_mem_wb) begin 
	out_mem_web={in_datosMD,in_result_alu,dirEscBR_};
end
endmodule


module singleDatapath_2(
	input CLK,
	output reg[31:0]resultadoTotal
);
//cables de banco de registro
wire [31:0] dir1BR_Operando1Alu;
wire [31:0] dir2BR_Operando2Alu;
//cable mux1SEldatoaBR
wire [31:0] ALUoMDD_to_BR;
//cable alu
wire [31:0] resultadoAlu;
wire ZF;
//cables para la unidad de control
wire bancoR_Wenable;//BR 
wire [2:0]aluControl; //alucontrol
wire memDatosW;//ram
wire memDatosR;//ram
wire unidadContr_to_mux1;//mux
wire muxBRdesti;//a mux sel dirW BR
//cables mem datos
wire[31:0] salidaMemDatos;
//alu control
wire[3:0] aluCodeOperacion;
//mux DIR escritura en BR
wire [4:0]wireWriteRegister;
//PC
wire [31:0]readAddress_PC;
wire [31:0]dirNuevaInstruccion_add;
wire [31:0]dirNuevaInstruccion;
//instruction memory
wire [31:0]instruccion_mem;
//mux sel de dato 2
wire muxSelDato2;

wire [31:0]operando2Alu;

//inmediato extendido
wire [31:0] inmediatoExtendido;
//shift left 2
wire [31:0] corrimientoDe2;
wire result_branch_and_z;
wire[31:0]result_add2entradas;
wire branchToAnd;

//cables de buffer1
wire [63:0]c_out_if_id;
//cables buffer2
wire [137:0]c_out_id_ex;
//cables buffer3
wire [101:0]c_out_ex_mem;
//cables buffer4
wire[68:0]c_out_mem_web;


unidadControl Ucontrol(
	.opCode(c_out_if_id[31:26]),
	.BRdesti(muxBRdesti),
	.branch(branchToAnd),//directo and
	.EnR(memDatosR),//ram
	.mux1(unidadContr_to_mux1),//mux
	.AluControl(aluControl),//alucontro*
	.EnW(memDatosW),//ram
	.aluSrc(muxSelDato2),
	.bancoRegEn(bancoR_Wenable)//BR
);
ALUcontrol alu_control(
	.unidadControl(aluControl),
	.funct(c_out_id_ex[5:0]),
	.aluCode(aluCodeOperacion)
);

BancoRegistros bancoRegistros(
//problema detectado del borrado de dato, cuando la 
//DirEsc la conecto con el cable ocuurre el error
	//.DirEsc(instruccion_mem[15:11]),//wireWriteRegister),
	.clk_BR(CLK),
	.DirEsc(c_out_mem_web[4:0]),
	.Dir1Lec(c_out_if_id[25:21]),
	.Dir2Lec(c_out_if_id[20:16]),
	.Dato1(dir1BR_Operando1Alu),
	.Dato2(dir2BR_Operando2Alu),
	.WE(bancoR_Wenable),//unidad de control
	.DatosEntrada(ALUoMDD_to_BR)
);

SignExtend signExtend(
	.inmediato_16bits(c_out_if_id[15:0]),
	.inmediato_32bits(inmediatoExtendido)
);

Mux2_1 SelDato2(
	.sel(muxSelDato2),
	.A(c_out_id_ex[73:42]),
	.B(c_out_id_ex[31:0]),
	.C(operando2Alu)
);
ShiftLeft_2 shiftLeft_2(
	.Y(c_out_id_ex[31:0]),
	.X(corrimientoDe2)
);
Add_2in add2In(
	.A(c_out_id_ex[137:106]),
	.B(corrimientoDe2),
	.C(result_add2entradas)
);
ALU alu(
	.SEL(aluCodeOperacion),
	.op1(c_out_id_ex[105:74]),
	.op2(operando2Alu),
	.resultado(resultadoAlu),
	.zf(ZF)
);
AND and_(
	.a(branchToAnd),
	.b(c_out_ex_mem[0]),
	.c(result_branch_and_z)
);
Mux2_1_5bits selDirWriteBR(
	.sel(muxBRdesti),
	.A(c_out_id_ex[41:37]),
	.B(c_out_id_ex[36:32]),
	.C(wireWriteRegister)
);
MemDatos memdatos(
	.clk(CLK),
	.Direccion(c_out_ex_mem[69:38]),
	.datosEntrada(c_out_ex_mem[37:6]),
	.WE(memDatosW),
	.RE(memDatosR),
	.Q(salidaMemDatos)
);
PC pc(
	.clk(CLK),
	.dirInstruccion(readAddress_PC),
	.dirInstruccionNueva(dirNuevaInstruccion)
); 
InstructionMemory instructionMem(
	.readAddress(readAddress_PC),
	.instruction(instruccion_mem)
);
Buffer_IF_ID buffer_if_id(
	.clk_if_id(CLK),
	.in_add4(dirNuevaInstruccion_add),
	.in_instruccion(instruccion_mem),
	.out_if_id(c_out_if_id)
);
Buffer_ID_EX buffer_id_ex(
	.clk_id_ex(CLK),
	.add4(c_out_if_id[63:32]),
	.in_op1_BR(dir1BR_Operando1Alu),
	.in_op2_BR(dir2BR_Operando2Alu),
	.in_signoExtend(inmediatoExtendido),
	.in_instr20_16(c_out_if_id[20:16]),
	.in_instr15_11(c_out_if_id[15:11]),
	.out_id_ex(c_out_id_ex)
);
Buffer_ex_mem buffer_ex_mem(
	.clk_ex_mem(CLK),
	.add2entradas(result_add2entradas),
	.in_zf_alu(ZF),
	.in_alu_result(resultadoAlu),
	.op2_o_Wdatos(c_out_id_ex[73:42]),
	.dirEscBR(wireWriteRegister),
	.out_ex_mem(c_out_ex_mem)
);
/////////////////////////////////////////////////
Buffer_mem_wb b_mem_wb(
	.clk_mem_wb(CLK),
	.in_datosMD(salidaMemDatos),
	.in_result_alu(c_out_ex_mem[69:38]),
	.dirEscBR_(c_out_ex_mem[5:1]),
	.out_mem_web(c_out_mem_web)
);
Mux2_1 mux1(
	.sel(unidadContr_to_mux1),
	.A(c_out_mem_web[68:37]),//0
	.B(c_out_mem_web[36:5]),//1
	.C(ALUoMDD_to_BR)
);
Add Add_1in(
	.A(readAddress_PC),
	.C(dirNuevaInstruccion_add)
);

Mux2_1 selNuevaDirInstruccionIMem(
	.sel(result_branch_and_z),
	.A(dirNuevaInstruccion_add),
	.B(c_out_ex_mem[101:70]),
	.C(dirNuevaInstruccion)
);
  
  
  
  //clskm
assign resultadoTotal=ALUoMDD_to_BR;

endmodule
