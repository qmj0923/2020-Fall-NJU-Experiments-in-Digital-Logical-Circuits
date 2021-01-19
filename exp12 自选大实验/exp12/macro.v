
// instruction
`define INST_RAM_SIZE      256
`define INST_RAM_WIDTH     8
`define INST_TYPE_WIDTH    1
`define R_TYPE             0
`define I_TYPE             1

`define LED_RAM_SIZE			84
`define FIB_RAM_SIZE			64

`define PC_END_LED			84
`define PC_END_FIB			64

// reg
//`define REG_SIZE           32
//`define REG_RAM_SIZE       32
//`define REG_RAM_WIDTH      5


// dst_type
`define DST_TYPE_WIDTH     3
`define DST_RD             0
`define DST_RT             1
`define DST_MEM_L          2
`define DST_MEM_S          3
`define DST_PC             4


// memory
`define MEM_RAM_SIZE       380
`define MEM_RAM_WIDTH      9


// R-Type function
`define FUNCT_ADD          6'b100000 // rd = rs+rt (signed)
`define FUNCT_ADDU         6'b100001 // rd = rs+rt (unsigned)
`define FUNCT_SUB          6'b100010 // rd = rs-rt (signed)
`define FUNCT_SUBU         6'b100011 // rd = rs-rt (unsigned)
`define FUNCT_AND          6'b100100 // rd = rs&rt
`define FUNCT_OR           6'b100101 // rd = rs|rt
`define FUNCT_XOR          6'b100110 // rd = rs^rt
`define FUNCT_NOR          6'b100111 // rd = !(rs|rt)
`define FUNCT_SLT          6'b101010 // rd = rs<rt (signed)
`define FUNCT_SLTU         6'b101011 // rd = rs<rt (unsigned)

`define FUNCT_SLL          6'b000000 // rd = rt<<shamt
`define FUNCT_SRL          6'b000010 // rd = rt>>shamt (logical)
`define FUNCT_SRA          6'b000011 // rd = rt>>shamt (arithmetic)
`define FUNCT_SLLV         6'b000100 // rd = rt<<rs
`define FUNCT_SRLV         6'b000110 // rd = rt>>rs (logical)
`define FUNCT_SRAV         6'b000111 // rd = rt>>rs (arithmetic)


// I-Type op
`define OP_ADDI            6'b001000 // rt = rs+imm (signed)
`define OP_ADDIU           6'b001001 // rt = rs+imm (unsigned)
`define OP_SLTI            6'b001010 // rt = rs<imm (signed)
`define OP_SLTIU           6'b001011 // rt = rs<imm (unsigned)
`define OP_ANDI            6'b001100 // rt = rs&imm
`define OP_ORI             6'b001101 // rt = rs|imm
`define OP_XORI            6'b001110 // rt = rs xor imm

`define OP_BEQ             6'b000100 // if (rs == rt) PC = PC+4+imm*4
`define OP_BNE             6'b000101 // if (rs != rt) PC = PC+4+imm*4
`define OP_BLEZ            6'b000110 // if (rs <= 0)  PC = PC+4+imm*4
`define OP_BGTZ            6'b000111 // if (rs > 0)   PC = PC+4+imm*4

`define OP_LW              6'b100011 // rt = M[rs+imm]
`define OP_SW              6'b101011 // M[rs+imm] = rt

//program
`define PROG_TYPE_WIDTH    3

`define PROG_UNKNOWN 		0
`define PROG_FIB 			   1
`define PROG_LED_OFF		   2
`define PROG_LED_ON 			3
`define PROG_HELLO    		4

//load
`define LOC_FIB 				300
`define LOC_LED_NUM 			308
`define LOC_LED_SW			312

`define LOC_FIB_RES 			316
`define LOC_LED_SIGN 		348

