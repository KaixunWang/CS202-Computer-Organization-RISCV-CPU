# RISCV Instruction Based CPU

## Instruction Set

| R-Type | opcode  | rs1  | rs2  | rd   | funct7  | funct3 | usage                     | example           |
| ------ | ------- | ---- | ---- | ---- | ------- | ------ | ------------------------- | ----------------- |
| add    | 0110011 | rs1  | rs2  | rd   | 0000000 | 000    | rd <- rs1 + rs2           | `add t0, x0, t1`  |
| sub    | 0110011 | rs1  | rs2  | rd   | 0100000 | 000    | rd <- rs1 - rs2           | `sub t0, x0, t1`  |
| and    | 0110011 | rs1  | rs2  | rd   | 0000000 | 111    | rd <- rs1 & rs2           | `and t0, x0, t1`  |
| or     | 0110011 | rs1  | rs2  | rd   | 0000000 | 110    | rd <- rs1 \| rs2          | `or t0, x0, t1`   |
| xor    | 0110011 | rs1  | rs2  | rd   | 0000000 | 100    | rd <- rs1 ^ rs2           | `xor t0, x0, t1`  |
| slt    | 0110011 | rs1  | rs2  | rd   | 0000000 | 010    | rd <- (rs1 < rs2) ? 1 : 0 | `slt t0, x0, t1`  |
| sll    | 0110011 | rs1  | rs2  | rd   | 0000000 | 001    | rd <- rs1 << rs2          | `sll t0, x0, t1`  |
| srl    | 0110011 | rs1  | rs2  | rd   | 0000000 | 101    | rd <- rs1 >> rs2          | `srl t0, x0, t1`  |
| sra    | 0110011 | rs1  | rs2  | rd   | 0100000 | 101    | rd <- rs1 >> rs2(arith*)  | `sra t0, x0, t1`  |
| sltu   | 0110011 | rs1  | rs2  | rd   | 0000000 | 011    | rd <- (rs1 < rs2) ? 1 : 0 | `sltu t0, x0, t1` |

| I-Type1 | opcode  | rs1  | rs2  | rd   | funct7         | funct3 | usage                          | example          |
| ------- | ------- | ---- | ---- | ---- | -------------- | ------ | ------------------------------ | ---------------- |
| addi    | 0010011 | rs1  | imm  | rd   | NULL           | 000    | rd <- rs1 + imm                | `addi t0, t1, 2` |
| xori    | 0010011 | rs1  | imm  | rd   | NULL           | 100    | rd <- rs1 ^ imm                | `xori t0, t1, 3` |
| ori     | 0010011 | rs1  | imm  | rd   | NULL           | 110    | rd <- rs1 \| imm               | `ori t0, t1, 4`  |
| andi    | 0010011 | rs1  | imm  | rd   | NULL           | 111    | rd <- rs1 & rs2                | `andi t0, t1, 5` |
| slli    | 0010011 | rs1  | imm  | rd   | imm[11:5]=0x00 | 001    | rd <- rs1 << imm[4:0]          | `slli t0, t1, 6` |
| srli    | 0010011 | rs1  | imm  | rd   | imm[11:5]=0x00 | 101    | rd <- rs1 >> imm[4:0]          | `srli t0, t1, 7` |
| srai    | 0010011 | rs1  | imm  | rd   | imm[11:5]=0x20 | 101    | rd <- rs1 >> imm[4:0] (arith*) | `srai t0, t1, 8` |
| slti    | 0010011 | rs1  | imm  | rd   | NULL           | 010    | rd <- (rs1 < imm) ? 1 : 0      | `slti t0, t1, 9` |

| I-Type2 | opcode  | rs1  | rs2  | rd   | funct7 | funct3 | usage                                           | example         |
| ------- | ------- | ---- | ---- | ---- | ------ | ------ | ----------------------------------------------- | --------------- |
| lb      | 0000011 | rs1  | imm  | rd   | NULL   | 000    | rd = {{24{M[rs1+imm]\[7\]}}, M[rs1+imm]\[7:0]}; | `lb t0, 0(t1)`  |
| lw      | 0000011 | rs1  | imm  | rd   | NULL   | 010    | rd = M[rs1+imm]\[31:0\]                         | `lw t0, 0(t1)`  |
| lbu     | 0000011 | rs1  | imm  | rd   | NULL   | 100    | rd = {24'b0, M[rs1+imm]\[7:0\]}                 | `lbu t0, 0(t1)` |

| S-Type | opcode    | rs1  | rs2  | rd   | funct7 | funct3 | usage                         | example        |
| ------ | --------- | ---- | ---- | ---- | ------ | ------ | ----------------------------- | -------------- |
| sw     | `0100011` | rs1  | imm  | rd   | NULL   | `010`  | M\[rs1+imm][31:0] = rs2[31:0] | `sw t0, 0(t1)` |

| B-Type | opcode    | rs1  | rs2  | rd   | funct7 | funct3 | usage                                                   | example              |
| ------ | --------- | ---- | ---- | ---- | ------ | ------ | ------------------------------------------------------- | -------------------- |
| beq    | `1100011` | rs1  | rs2  | rd   | NULL   | `000`  | PC += (rs1 == rs2) ? {imm,1’b0} : 4                     | `beq t0, t1, label`  |
| bne    | `1100011` | rs1  | rs2  | rd   | NULL   | `001`  | PC += (rs1 != rs2) ? {imm,1’b0} : 4                     | `bne t0, t1, label`  |
| blt    | `1100011` | rs1  | rs2  | rd   | NULL   | `100`  | PC += (rs1 < rs2) ? {imm,1’b0} : 4                      | `blt t0, t1, label`  |
| bge    | `1100011` | rs1  | rs2  | rd   | NULL   | `101`  | PC += (rs1 >= rs2) ? {imm,1’b0} : 4                     | `bge t0, t1, label`  |
| bltu   | `1100011` | rs1  | rs2  | rd   | NULL   | `110`  | PC += (rs1(unsigned) < rs2(unsigned)) ? {imm,1’b0} : 4  | `bltu t0, t1, label` |
| bgeu   | `1100011` | rs1  | rs2  | rd   | NULL   | `111`  | PC += (rs1(unsigned) >= rs2(unsigned)) ? {imm,1’b0} : 4 | `bgeu t0, t1, label` |

| JAL-Type | opcode    | rs1  | rs2  | rd   | funct7 | funct3 | usage                  | example         |
| -------- | --------- | ---- | ---- | ---- | ------ | ------ | ---------------------- | --------------- |
| jal      | `1101111` | NULL | imm  | rd   | NULL   | NULL   | rd = PC + 4; PC += imm | `jal t0, label` |

| JALR-Type | opcode    | rs1  | rs2  | rd   | funct7 | funct3 | usage                       | example          |
| --------- | --------- | ---- | ---- | ---- | ------ | ------ | --------------------------- | ---------------- |
| jalr      | `1100111` | rs1  | imm  | rd   | NULL   | NULL   | rd = PC + 4; PC = rs1 + imm | `jalr t0, 0(t1)` |

| U-Type | opcode    | rs1  | rs2  | rd   | funct7 | funct3 | usage               | example             |
| ------ | --------- | ---- | ---- | ---- | ------ | ------ | ------------------- | ------------------- |
| lui    | `0110111` | NULL | NULL | rd   | NULL   | NULL   | rd = imm << 12      | `lui t0, 0x80000`   |
| auipc  | `0010111` | NULL | NULL | rd   | NULL   | NULL   | rd = PC + imm << 12 | `auipc t0, 0x80000` |

| System | opcode    | rs1  | rs2  | rd   | funct7    | funct3 | usage                                                        | example |
| ------ | --------- | ---- | ---- | ---- | --------- | ------ | ------------------------------------------------------------ | ------- |
| ecall  | `1110011` | NULL | NULL | NULL | `0000000` | `000`  | a7 = 0 output register a0 to led <br />a7 = 1 store swtich data to a0 | `ecall` |

## IO Address

Leds:

Left 8 bit : FFFF_FE00

Right 8 bit : FFFF_FE04

Switch 16bit : FFFF_FE10
