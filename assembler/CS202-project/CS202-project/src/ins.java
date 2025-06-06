public class ins {
    public String opcode;       // 操作符，如 addi, beq
    public String[] operands;   // 操作数，如 ["x1", "x2", "10"]
    public int lineNumber;      // 行号（用于报错定位）

    public ins(String opcode, String[] operands, int lineNumber) {
        this.opcode = opcode;
        this.operands = operands;
        this.lineNumber = lineNumber;
    }

    @Override
    public String toString() {
        return opcode + " " + String.join(", ", operands);
    }
}
