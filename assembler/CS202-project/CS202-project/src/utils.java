import java.util.*;

public class utils {
    private static final Map<String, Integer> REG_MAP = new HashMap<>();
    static {
        // x0–x31
        for (int i = 0; i <= 31; i++) {
            REG_MAP.put("x" + i, i);
        }
        // ABI 别名
        REG_MAP.put("zero", 0);
        REG_MAP.put("ra",   1);
        REG_MAP.put("sp",   2);
        REG_MAP.put("gp",   3);
        REG_MAP.put("tp",   4);
        REG_MAP.put("t0",   5);
        REG_MAP.put("t1",   6);
        REG_MAP.put("t2",   7);
        REG_MAP.put("s0",   8);
        REG_MAP.put("fp",   8);
        REG_MAP.put("s1",   9);
        REG_MAP.put("a0",   10);
        REG_MAP.put("a1",   11);
        REG_MAP.put("a2",   12);
        REG_MAP.put("a3",   13);
        REG_MAP.put("a4",   14);
        REG_MAP.put("a5",   15);
        REG_MAP.put("a6",   16);
        REG_MAP.put("a7",   17);
        REG_MAP.put("s2",   18);
        REG_MAP.put("s3",   19);
        REG_MAP.put("s4",   20);
        REG_MAP.put("s5",   21);
        REG_MAP.put("s6",   22);
        REG_MAP.put("s7",   23);
        REG_MAP.put("s8",   24);
        REG_MAP.put("s9",   25);
        REG_MAP.put("s10",  26);
        REG_MAP.put("s11",  27);
        REG_MAP.put("t3",   28);
        REG_MAP.put("t4",   29);
        REG_MAP.put("t5",   30);
        REG_MAP.put("t6",   31);
    }

    /**
     * 把寄存器名称（如 "t2" 或 "x7"）转换成它的编号（0–31）。
     */
    public static int regToNum(String reg) {
        Integer num = REG_MAP.get(reg);
        if (num == null) {
            throw new IllegalArgumentException("Unknown register: " + reg);
        }
        return num;
    }
}
