import java.util.*;

public class symbol_table {

        private final Map<String, Integer> labelMap;

        public symbol_table() {
            labelMap = new HashMap<>();
        }

        /**
         * 第一遍扫描汇编代码行，收集所有标签和它们的地址。
         * @param lines 汇编代码行列表
         */
        public void scanLabels(List<String> lines) {
            int address = 0;
            for (String rawLine : lines) {
                String line = rawLine.trim();
                // 去掉注释
                int commentIndex = line.indexOf('#');
                if (commentIndex != -1) {
                    line = line.substring(0, commentIndex).trim();
                }
                // 跳过空行
                if (line.isEmpty()) continue;
                if (line.contains(".word")) continue;
                if (line.contains(":")) {
                    String[] parts = line.split(":");
                    String label = parts[0].trim();
                    labelMap.put(label, address);
                    // 如果冒号后还有指令，比如 "loop: addi x1, x1, 1"
                    if (parts.length > 1 && !parts[1].trim().isEmpty()) {
                        address += 4;
                    }
                } else {
                    if(line.contains(".text") || line.contains(".data")) {
                        continue;
                    }
                    //如果是代表两条指令的伪指令，比如 "la", address +8, unless +4
                    if (line.contains("la ")&& line.contains(",")) {
                        address += 8;
                    } else {
                        address += 4;
                    }
                }
            }
        }

        /**
         * 获取某个标签的地址
         * @param label 标签名
         * @return 地址（单位：字节）
         */
        public int getAddress(String label) {
            if (!labelMap.containsKey(label)) {
                return 0;
            }
            return labelMap.get(label);
        }

        /**
         * 判断标签是否存在
         * @param label 标签名
         * @return 是否存在
         */
        public boolean contains(String label) {
            return labelMap.containsKey(label);
        }

        /**
         * 返回标签映射表
         */
        public Map<String, Integer> getLabelMap() {
            return Collections.unmodifiableMap(labelMap);
        }
    }
