import java.util.*;

public class data_table {
    /**
    .data
     a: .word 0x1111
     b: .word 0x5555
     生成一个单独的data.coe文件，记录每个data的地址和值，在la等指令中使用
    **/
    public final Map<String, DataEntry> dataMap;

    public data_table() {
        dataMap = new HashMap<>();
    }

    /**
     * 第一遍扫描汇编代码行，收集所有data标签和它们的地址。
     * @param lines 汇编代码行列表
     */

    public void scanDatas(List<String> lines) {
        int address = 0;
        for (String rawLine : lines) {
            String line = rawLine.trim();
            // Remove comments
            int commentIndex = line.indexOf('#');
            if (commentIndex != -1) {
                line = line.substring(0, commentIndex).trim();
            }
            // Skip empty lines
            if (line.isEmpty()) continue;
            //skip instruction lines, 判断是否是指令
            if(!line.contains(".")){
                continue;
            }
            if (line.contains(".text") || line.contains(".data")) {
                continue;
            }
            // Process .data section
            if (line.contains(":")) {
                String[] parts = line.split(":");
                String label = parts[0].trim();
                if (parts.length > 1 && !parts[1].trim().isEmpty()) {
                    String dataType = parts[1].trim();
                    if (dataType.startsWith(".word")) {
                        String valueStr = dataType.substring(5).trim();
                        int value = valueStr.startsWith("0x")
                                ? Integer.parseInt(valueStr.substring(2), 16)
                                : Integer.parseInt(valueStr);
                        dataMap.put(label, new DataEntry(address, value));
                    }
                }
                address += 4;
            }
        }
    }

    public static class DataEntry {
        public final int address;
        public final int value;

        public DataEntry(int address, int value) {
            this.address = address;
            this.value = value;
        }
    }

    public Map<String, DataEntry> getDataMap() {
        return dataMap;
    }

    public int getAddress(String label) {
        if (!dataMap.containsKey(label)) {
            throw new IllegalArgumentException("undefined data label: " + label);
        }
        return dataMap.get(label).address;
    }

    public int getValue(String label) {
        if (!dataMap.containsKey(label)) {
            throw new IllegalArgumentException("undefined data label: " + label);
        }
        return dataMap.get(label).value;
    }

    public boolean contains(String label) {
        return dataMap.containsKey(label);
    }
}
