import java.util.*;

public class ins_split {

    /**
     * 解析一行汇编代码为一条 ins 对象，或在不需处理时返回 null
     */
    public static ins parse(String rawLine, int lineNumber) {
        // 1. 去掉首尾空白
        String line = rawLine.trim();

        // 2. 过滤：空行、注释行
        if (line.isEmpty() || line.startsWith("#")) {
            return null;
        }
        // 3. 过滤：段标记 .data / .text
        if (line.equals(".data") || line.equals(".text")) {
            return null;
        }
        // 4. 过滤：所有（以 . 开头），以及 .word/.byte/.half（包括带标签的情况）
        if (line.startsWith(".")
                || line.contains(".word")
                || line.contains(".byte")
                || line.contains(".half")) {
            return null;
        }

        // 5. 去掉行内注释
        int commentIndex = line.indexOf('#');
        if (commentIndex != -1) {
            line = line.substring(0, commentIndex).trim();
        }

        // 6. 若仅剩标签（如 "label:"），跳过
        if (line.isEmpty() || line.endsWith(":")) {
            return null;
        }

        // 7. 若是“标签+指令”（如 "loop: addi x1, x2, 10"），去掉标签部分
        if (line.contains(":")) {
            line = line.substring(line.indexOf(":") + 1).trim();
        }

        // 8. 规范化空白（多个空格合成一个空格）
        line = line.replaceAll("\\s+", " ");

        // 9. 分离 opcode 和 operands
        String[] parts = line.split("\\s+", 2);
        String opcode = parts[0].toLowerCase();
        String[] operands = new String[0];
        if (parts.length > 1) {
            operands = Arrays.stream(parts[1].split(","))
                    .map(String::trim)
                    .toArray(String[]::new);
        }

        // 10. 返回构造好的 ins 实例
        return new ins(opcode, operands, lineNumber);
    }
}
