import java.util.Map;

public class ins_encode {
    /**
     * 将解析好的 Instruction 对象编码为 32 位机器码
     *
     * @param instr           解析得到的指令对象
     * @param symbolTable     标签表，用于分支/跳转偏移计算
     * @param currentAddress  当前指令地址（字节地址），用于计算 PC 相对偏移
     * @return 32 位机器码（int）
     */
    public static int[] encode(ins instr, symbol_table symbolTable,data_table dataTable, int currentAddress) {
        String op = instr.opcode;
        String[] ops = instr.operands;
        switch (op) {
            // R-type
            case "add":  return encodeRType(0b0000000, 0b000, ops);
            case "sub":  return encodeRType(0b0100000, 0b000, ops);
            case "and":  return encodeRType(0b0000000, 0b111, ops);
            case "or":   return encodeRType(0b0000000, 0b110, ops);
            case "xor":  return encodeRType(0b0000000, 0b100, ops);
            case "slt":  return encodeRType(0b0000000, 0b010, ops);
            case "sll":  return encodeRType(0b0000000, 0b001, ops);
            case "srl":  return encodeRType(0b0000000, 0b101, ops);
            case "sltu": return encodeRType(0b0000000, 0b011, ops);
            case "mul":  return encodeRType(0b0000001, 0b000, ops);
            case "div":  return encodeRType(0b0000001, 0b100, ops);

            // I-type1
            case "addi": return encodeIType(0b0010011, 0b000, ops, symbolTable,null);
            case "xori": return encodeIType(0b0010011, 0b100, ops, symbolTable,null);
            case "ori":  return encodeIType(0b0010011, 0b110, ops,  symbolTable,null);
            case "andi": return encodeIType(0b0010011, 0b111, ops, symbolTable,null);
            case "slli": return encodeShiftI(0b0010011, 0b001, ops, 0b0000000);
            case "srli": return encodeShiftI(0b0010011, 0b101, ops, 0b0000000);
            case "slti": return encodeIType(0b0010011, 0b010, ops, symbolTable,null);

            // I-type2 (loads)
            case "lb":   return encodeIType(0b0000011, 0b000, ops, symbolTable,null);
            case "lw":   return encodeIType(0b0000011, 0b010, ops, symbolTable,null);
            case "lbu":  return encodeIType(0b0000011, 0b100, ops, symbolTable,null);

            // S-type
            case "sw":   return encodeSType(0b0100011, 0b010, ops);

            // B-type
            case "beq":  return encodeBType(0b1100011, 0b000, ops, symbolTable, currentAddress);
            case "bne":  return encodeBType(0b1100011, 0b001, ops, symbolTable, currentAddress);
            case "blt":  return encodeBType(0b1100011, 0b100, ops, symbolTable, currentAddress);
            case "bge":  return encodeBType(0b1100011, 0b101, ops, symbolTable, currentAddress);
            case "bltu": return encodeBType(0b1100011, 0b110, ops, symbolTable, currentAddress);
            case "bgeu": return encodeBType(0b1100011, 0b111, ops, symbolTable, currentAddress);

            // JAL-Type
            case "jal":  return encodeJType(0b1101111, ops, symbolTable, currentAddress);

            // JALR-Type
            case "jalr": return encodeJALR(0b1100111, ops, symbolTable, dataTable);

            // U-type
            case "lui":  return encodeLUIType(0b0110111, ops);
            case "auipc":return encodeAUIPCType(0b0010111, ops,false);

            // System
            case "ecall":return encodeEnvCall();

            // additional pseudo-instructions
            case "beqz": return encodeBType(0b1100011, 0b000, new String[]{ops[0], "x0", ops[1]}, symbolTable, currentAddress);
            case "bnez": return encodeBType(0b1100011, 0b001, new String[]{ops[0], "x0", ops[1]}, symbolTable, currentAddress);
            case "mv": return encodeRType(0b0000000, 0b000, new String[]{ops[0], ops[1], "x0"});
            case "bgt": return encodeBType(0b1100011, 0b100, new String[]{ops[1], ops[0], ops[2]}, symbolTable, currentAddress);
            case "li":
                if (ops.length == 2) {//equivalent to addi
                    int rd = regOrLabelToInt(ops[0], null,null);
                    int imm = parseImmediate(ops[1], 12);
                    return new int[]{(imm << 20) | (rd << 7) | 0b0010011};
                } else {
                    throw new IllegalArgumentException("Invalid li instruction: " + instr.lineNumber);
                }
            case "la": //la rd, dataLabel or la rd, label
                if (ops.length == 2) {
                    String label = ops[1];
                    int address = 0;
                    int rd = regOrLabelToInt(ops[0], null,null);
                    if (symbolTable.contains(label)) {
                        address = symbolTable.getAddress(label);
                    } else if (dataTable.contains(label)) {
                        address = dataTable.getAddress(label);
                    } else {
                        throw new IllegalArgumentException("Invalid label: " + label);
                    }
                    //first auipc rd, imm1
                    //then  addi rd, rd, imm2
                    int imm1 = (address - currentAddress) >> 12 & 0xFFFFF;
                    int imm2 = (address - currentAddress) & 0xFFF;
                    int[] res = new int[2];
                    res[0] = encodeAUIPCType(0b0010111, new String[]{ops[0], Integer.toString(imm1)},true)[0];
                    res[1] = encodeIType(0b0010011, 0b000, new String[]{ops[0], ops[0], Integer.toString(imm2)}, symbolTable,dataTable)[0];
                    return res;
                } else {
                    throw new IllegalArgumentException("Invalid la instruction: " + instr.lineNumber);
                }

            case"j": return encodeJType(0b1101111, new String[]{"x0", ops[0]}, symbolTable, currentAddress);
            case"ret": return encodeJALR(0b1100111, new String[]{"x0", "x1","0"}, symbolTable, dataTable);
            default:
                throw new UnsupportedOperationException("Unsupported opcode: " + op + " at line " + instr.lineNumber);
        }
    }

    private static int[] encodeRType(int funct7, int funct3, String[] ops) {
        int rd  = regOrLabelToInt(ops[0],null,null);
        int rs1 = regOrLabelToInt(ops[1],null,null);
        int rs2 = regOrLabelToInt(ops[2],null,null);
        int opcode = 0b0110011;
        return new int[]{(funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode};
    }

    // I-Type
    private static int[] encodeIType(int opcode, int funct3, String[] ops, symbol_table st, data_table dt) {
        int rd  = regOrLabelToInt(ops[0], st,null);

        String addrPart = ops[1];
        int rs1, imm;
        if (addrPart.contains("(")) {
            // 拆 "imm(base)" 或 "(base)"
            String[] parts = addrPart.split("[()]");
            // split 结果： parts[0]=immStr（可能为空）; parts[1]=base; parts[2]=""
            String immStr = parts[0].trim();
            if (immStr.isEmpty()) {
                immStr = "0";       // 关键：空的立即数当 0 处理
            }
            String base = parts[1].trim();
            rs1  = regOrLabelToInt(base, st, null);
            imm  = parseImmediateOrLabel(immStr, st, dt);
        } else {
            // 普通三操作数形式： rd, rs1, imm
            rs1 = regOrLabelToInt(ops[1], st, null);
            imm = parseImmediateOrLabel(ops[2], st,dt);
        }

        int imm12 = imm & 0xFFF;
        return new int[]{(imm12 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode};
    }

    // S-Type （store 指令）
    private static int[] encodeSType(int opcode, int funct3, String[] ops) {
        // ops[1] 可能是 "imm(base)" 或 "(base)"
        String addrPart = ops[1];
        String[] parts = addrPart.split("[()]");
        // parts[0]=immStr（可能为空）; parts[1]=base
        String immStr = parts[0].trim();
        if (immStr.isEmpty()) {
            immStr = "0";
        }
        int imm = parseImmediateOrLabel(immStr, null,null);
        int rs1 = regOrLabelToInt(parts[1].trim(), null,null);
        int rs2 = regOrLabelToInt(ops[0], null,null);

        int immLow  = imm & 0x1F;
        int immHigh = (imm >> 5) & 0x7F;
        return new int[]{(immHigh << 25) | (rs2 << 20) | (rs1 << 15)
                | (funct3 << 12) | (immLow << 7) | opcode};
    }

    // 辅助：解析立即数或标签（无偏移计算）
    private static int parseImmediateOrLabel(String tok, symbol_table st, data_table dt) {
        tok = tok.trim();
        if (tok.matches("^-?\\d+$") || tok.startsWith("0x")) {
            return tok.startsWith("0x")
                    ? Integer.parseInt(tok.substring(2), 16)
                    : Integer.parseInt(tok);
        }
        // 这里不做 PC 相对偏移，直接取标签绝对地址
        if (st != null && st.contains(tok)) {
            return st.getAddress(tok);
        }
        if (dt != null && dt.contains(tok)) {
            return dt.getAddress(tok);
        }
        throw new IllegalArgumentException("Invalid immediate or label: " + tok);
    }

    private static int[] encodeShiftI(int opcode, int funct3, String[] ops, int funct7) {
        int rd  = regOrLabelToInt(ops[0],null,null);
        int rs1 = regOrLabelToInt(ops[1],null,null);
        int shamt = parseImmediate(ops[2], 5);
        return new int[]{(funct7 << 25) | (shamt << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode};
    }



    public static int[] encodeBType(int opcode, int funct3, String[] ops,
                                  symbol_table st, int currentAddress) {
        // 1. 取出寄存器编号
        int rs1    = regOrLabelToInt(ops[0], st,null);
        int rs2    = regOrLabelToInt(ops[1], st,null);
        // 2. 目标地址（字节地址）
        int target = st.getAddress(ops[2]);

        // 3. 计算分支偏移（字节差），然后右移一位：因为 B-type 中只存 imm[12:1]，最低 bit0 恒为 0
        int offsetBytes = target - currentAddress  ;
        int imm        = offsetBytes ;

        // 4. 限定 imm 为 13 位有符号数（imm[12:0]）
        imm &= 0x1FFF;
        if ((imm & 0x1000) != 0) {  // 如果第 12 位是 1，要做符号扩展
            imm |= ~0x1FFF;
        }

        // 5. 拆分各片段
        int bit12   = (imm >> 12) & 0x1;    // imm[12]
        int bit10_5 = (imm >> 5)  & 0x3F;   // imm[10:5]
        int bit4_1  = (imm >> 1)  & 0xF;    // imm[4:1]
        int bit11   = (imm >> 11) & 0x1;    // imm[11]

        // 6. 组装
        return new int[]{(bit12   << 31) |
                (bit10_5 << 25) |
                (rs2     << 20) |
                (rs1     << 15) |
                (funct3  << 12) |
                (bit4_1  << 8)  |
                (bit11   << 7)  |
                opcode};
    }



    private static int[] encodeLUIType(int opcode, String[] ops) {
        int rd = regOrLabelToInt(ops[0],null,null);
        int imm = parseImmediate(ops[1], 20);
        return new int[]{(imm << 12) | (rd << 7) | opcode};
    }
    private static int[] encodeAUIPCType(int opcode, String[] ops, boolean if_la) {
        if(if_la){
            int rd = regOrLabelToInt(ops[0],null,null);
            int imm = parseImmediate(ops[1], 20);
            //如果原本32bit的imm的第12bit为1，那么前20bit需要+1
            if((imm & 0x800) != 0){
                imm = (imm & 0xFFFFF000) + 0x1000;
            }
            return new int[]{(imm << 12) | (rd << 7) | opcode};

        }else{
            int rd = regOrLabelToInt(ops[0],null,null);
            int imm = parseImmediate(ops[1], 20);
            return new int[]{(imm << 12) | (rd << 7) | opcode};
        }
    }

    private static int[] encodeJType(int opcode, String[] ops, symbol_table st, int addr) {
        int rd = 0;
        int target =0;
        if(ops.length == 1){
            rd = 1;
            target = st.getAddress(ops[0]);
        }else{
            rd = regOrLabelToInt(ops[0], st,null);
            target = st.getAddress(ops[1]);
        }
        int offset =  target - addr  ;
        int imm = offset;
        int bit20    = (imm >> 20) & 0x1;
        int bit10_1  = (imm >> 1)  & 0x3FF;
        int bit11    = (imm >> 11) & 0x1;
        int bit19_12 = (imm >> 12) & 0xFF;
        return new int[]{(bit20 << 31) | (bit19_12 << 12) | (bit11 << 20) |
                (bit10_1 << 21) | (rd << 7) | opcode};
    }

    private static int[] encodeJALR(int opcode, String[] ops, symbol_table st, data_table dt) {
        int rd = 0;
        int rs1 = 0;
        int imm = 0;
        if(ops.length == 1){
            rd = 1;
            rs1 = regOrLabelToInt(ops[0], st,dt);
            imm = 0;
        }else if(ops.length == 2){
            //jalr rd, imm(rs1) or
            //jalr rd, imm
            rd = regOrLabelToInt(ops[0], st,dt);
            String addrPart = ops[1];
            String[] parts = addrPart.split("[()]");
            // parts[0]=immStr（可能为空）; parts[1]=base
            String immStr = parts[0].trim();
            if (immStr.isEmpty()) {
                immStr = "0";
            }
            imm = parseImmediateOrLabel(immStr, st,dt);
            if(parts.length == 1){
                rs1= 1;
            }else{
                rs1 = regOrLabelToInt(parts[1].trim(), st,dt);
            }
        }else if(ops.length == 3){
            //jalr rd, rs1, imm
            rd = regOrLabelToInt(ops[0], st,dt);
            rs1 = regOrLabelToInt(ops[1], st,dt);
            imm = parseImmediateOrLabel(ops[2], st,dt);
        }
        int imm12 = imm & 0xFFF;
        return new int[]{(imm12 << 20) | (rs1 << 15) | (rd << 7) | opcode};
    }

    private static int[] encodeEnvCall() {
        int opcode = 0b1110011;
        int funct3 = 0b000;
        int funct7 = 0b0000000;
        return new int[]{(funct7 << 25) | (funct3 << 12) | opcode};
    }

    private static int regOrLabelToInt(String token, symbol_table st, data_table dt) {
        // 先试寄存器
        try {
            return utils.regToNum(token);
        } catch (IllegalArgumentException e) {
            // 不是寄存器，继续下面
        }
        // 如果有符号表，且标签存在，返回标签地址
        if (st != null && st.contains(token)) {
            return st.getAddress(token);
        }
        if (dt != null && dt.contains(token)) {
            return dt.getAddress(token);
        }
        throw new IllegalArgumentException("Neither register nor label: " + token);
    }

    private static int parseImmediate(String immStr, int bits) {
        int value;
        if (immStr.startsWith("0x")) {
            value = Integer.parseInt(immStr.substring(2), 16);
        } else {
            value = Integer.parseInt(immStr);
        }
        int mask = (1 << bits) - 1;
        value &= mask;
        if ((value & (1 << (bits - 1))) != 0) {
            value |= ~mask;
        }
        return value;
    }

}
