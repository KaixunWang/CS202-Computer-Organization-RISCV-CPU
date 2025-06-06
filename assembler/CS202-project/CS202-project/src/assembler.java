import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.*;

import static java.rmi.server.LogStream.log;

class AssemblerGUI extends JFrame {
    private JTextArea asmInputArea;
    private JTextField outputField;
    private JButton browseOutputBtn;
    private JButton assembleBtn;
    private JTextArea logArea;
    private JTextField dataOutputField;
    private JButton browseDataOutputBtn;

    public AssemblerGUI() {
        setTitle("RISC-V Assembler");
        setSize(1600, 900);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        initComponents();
        setLocationRelativeTo(null);
    }

    private JTextField lengthField;

    private void initComponents() {
        JTabbedPane tabbedPane = new JTabbedPane();

        // Main Tab
        JPanel mainPanel = new JPanel(new BorderLayout());
        asmInputArea = new JTextArea();
        outputField = new JTextField();
        dataOutputField = new JTextField();
        lengthField = new JTextField(); // New field for length
        browseOutputBtn = new JButton("Browse...");
        browseDataOutputBtn = new JButton("Browse...");
        assembleBtn = new JButton("Assemble");
        logArea = new JTextArea();
        logArea.setEditable(false);

        JSplitPane splitPane = new JSplitPane(JSplitPane.VERTICAL_SPLIT);
        splitPane.setResizeWeight(0.6);

        // Top panel: ASM input
        JPanel topPanel = new JPanel(new BorderLayout());
        topPanel.add(new JLabel("Enter RISC-V Assembly Code:"), BorderLayout.NORTH);
        topPanel.add(new JScrollPane(asmInputArea), BorderLayout.CENTER);
        splitPane.setTopComponent(topPanel);

        // Bottom panel: output settings and log
        JPanel bottomPanel = new JPanel(new BorderLayout());
        JPanel controlPanel = new JPanel(new GridBagLayout());
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        // Output file row for ins.coe
        gbc.gridx = 0; gbc.gridy = 0; gbc.weightx = 0;
        controlPanel.add(new JLabel("Output ins.coe File:"), gbc);
        gbc.gridx = 1; gbc.weightx = 1;
        controlPanel.add(outputField, gbc);
        gbc.gridx = 2; gbc.weightx = 0;
        controlPanel.add(browseOutputBtn, gbc);

        // Output file row for data.coe
        gbc.gridx = 0; gbc.gridy = 1; gbc.weightx = 0;
        controlPanel.add(new JLabel("Output data.coe File:"), gbc);
        gbc.gridx = 1; gbc.weightx = 1;
        controlPanel.add(dataOutputField, gbc);
        gbc.gridx = 2; gbc.weightx = 0;
        controlPanel.add(browseDataOutputBtn, gbc);

        // Length input row
        gbc.gridx = 0; gbc.gridy = 2; gbc.weightx = 0;
        controlPanel.add(new JLabel("Total Length:"), gbc);
        gbc.gridx = 1; gbc.weightx = 1;
        controlPanel.add(lengthField, gbc);

        // Assemble button
        gbc.gridx = 1; gbc.gridy = 3; gbc.fill = GridBagConstraints.NONE; gbc.anchor = GridBagConstraints.CENTER;
        controlPanel.add(assembleBtn, gbc);

        bottomPanel.add(controlPanel, BorderLayout.NORTH);
        bottomPanel.add(new JScrollPane(logArea), BorderLayout.CENTER);
        splitPane.setBottomComponent(bottomPanel);

        mainPanel.add(splitPane, BorderLayout.CENTER);
        tabbedPane.addTab("Assembler", mainPanel);

        // About Tab
        JPanel aboutPanel = new JPanel(new BorderLayout());
        JTextArea aboutText = new JTextArea(
                "RISC-V Assembler\n" +
                        "Version 1.2\n" +
                        "This software was developed by Kaixun Wang for the CS202 course project at Southern University of Science and Technology (SUSTech).\n\n" +
                        "This assembler is designed for RISC-V *HARVARD* architecture.\n" +
                        "Instruction space initial address: 0x00000000 in IMEM\n" +
                        "Data space initial address: 0x00000000 in DMEM\n\n" +
                        "This assembler translates RISC-V assembly code into machine code.\n" +
                        "It supports basic instructions, pseudo-instructions, and data directives.\n\n" +
                        "Usage:\n" +
                        "1. Enter RISC-V assembly code in the text area.\n" +
                        "2. Specify output file paths for ins.coe and data.coe.\n" +
                        "3. Click 'Assemble' to generate the output files.\n\n" +
                        "Note: Ensure that the output file paths are valid and writable.\n\n" +
                        "For more information, visit the project repository.\n\n" +
                        "© Kaixun Wang – CS202 Project, SUSTech"
        );
        aboutText.setEditable(false);
        aboutText.setFont(new Font("Monospaced", Font.PLAIN, 14));
        aboutPanel.add(new JScrollPane(aboutText), BorderLayout.CENTER);
        tabbedPane.addTab("About", aboutPanel);

        // Add tabbedPane to the frame
        add(tabbedPane);

        // Action listeners
        browseOutputBtn.addActionListener(e -> chooseFile(outputField, "Save ins.coe File", JFileChooser.SAVE_DIALOG));
        browseDataOutputBtn.addActionListener(e -> chooseFile(dataOutputField, "Save data.coe File", JFileChooser.SAVE_DIALOG));
        assembleBtn.addActionListener(e -> {
            try {
                assemble();
            } catch (IOException ex) {
                throw new RuntimeException(ex);
            }
        });
    }

    private void chooseFile(JTextField field, String title, int dialogType) {
        JFileChooser chooser = new JFileChooser();
        chooser.setDialogTitle(title);
        int ret = (dialogType == JFileChooser.OPEN_DIALOG)
                ? chooser.showOpenDialog(this)
                : chooser.showSaveDialog(this);
        if (ret == JFileChooser.APPROVE_OPTION) {
            field.setText(chooser.getSelectedFile().getAbsolutePath());
        }
    }

    private void assemble() throws IOException {
        String asmText = asmInputArea.getText().trim();
        String insOutputFile = outputField.getText().trim();
        String dataOutputFile = dataOutputField.getText().trim();
        int totalLength;
        try {
            totalLength = Integer.parseInt(lengthField.getText().trim());
        } catch (NumberFormatException e) {
            log("Invalid total length. Please enter a valid number.");
            return;
        }

        if (asmText.isEmpty() || insOutputFile.isEmpty() || dataOutputFile.isEmpty()) {
            log("Please enter assembly code and specify both output files.");
            return;
        }

        try {
            log("Parsing assembly input...");
            List<String> lines = new ArrayList<>();
            for (String line : asmText.split("\\r?\\n")) {
                lines.add(line);
            }

            // Scan labels using symbol_table
            symbol_table st = new symbol_table();
            st.scanLabels(lines);
            log("Labels scanned: " + st.getLabelMap().size());

            // Scan data using data_table
            data_table dt = new data_table();
            dt.scanDatas(lines);
            log("Data scanned: " + dt.getDataMap().size());

            // Parse and encode instructions
            List<String> encodedHex = new ArrayList<>();
            int address = 0;
            for (int i = 0; i < lines.size(); i++) {
                ins instruction = ins_split.parse(lines.get(i), i + 1);
                if (instruction == null) continue;
                int[] machineCode = ins_encode.encode(instruction, st, dt, address);
                for (int code : machineCode) {
                    encodedHex.add(String.format("%08x", code));
                    address += 4;
                }
            }

            // Write ins.coe
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(insOutputFile))) {
                writer.write("memory_initialization_radix = 16;\n");
                writer.write("memory_initialization_vector =\n");
                for (int j = 0; j < totalLength; j++) {
                    String hex = (j < encodedHex.size()) ? encodedHex.get(j) : "00000000";
                    String end = (j < totalLength - 1) ? "," : ";";
                    writer.write(hex + end + "\n");
                }
            }
            log("ins.coe file generated: " + insOutputFile);

            // Write data.coe
            try (BufferedWriter writer = new BufferedWriter(new FileWriter(dataOutputFile))) {
                writer.write("memory_initialization_radix = 16;\n");
                writer.write("memory_initialization_vector =\n");

                List< Map.Entry<String, data_table.DataEntry>> entries = new ArrayList<>(dt.getDataMap().entrySet());
                entries.sort(Comparator.comparingInt(e -> e.getValue().address));  // 可选排序

                for (int j = 0; j < totalLength; j++) {
                    int currentAddr = j * 4;

                    Optional<Map.Entry<String, data_table.DataEntry>> match = entries.stream()
                            .filter(e -> e.getValue().address == currentAddr)
                            .findFirst();

                    String hex = match.isPresent()
                            ? String.format("%08x", match.get().getValue().value)
                            : "00000000";

                    String end = (j < totalLength - 1) ? "," : ";";
                    writer.write(hex + end + "\n");
                }
            }
            log("data.coe file generated: " + dataOutputFile);

        } catch (Exception e) {
            log("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
    private void log(String message) {
        SwingUtilities.invokeLater(() -> {
            logArea.append(message + "\n");
            logArea.setCaretPosition(logArea.getDocument().getLength()); // 自动滚动到最后
        });
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            AssemblerGUI gui = new AssemblerGUI();
            gui.setVisible(true);
        });
    }
}
