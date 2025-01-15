#! /bin/bash
foldername="tb_files"

filename="top_tb"
#filename="ALU_tb"
#filename="RegisterFile_tb"
#filename="PM_ID_BFM_tb"
#filename="PC_tb"

clear
echo "====================================================================
              LAUNCHING TEST BENCH COMPILATION:
====================================================================="

rm "${foldername}"/$filename
rm "${foldername}"/"${filename}.vcd"   


iverilog -g2012 -o "${foldername}"/"${filename}" "${filename}.sv"
vvp "${foldername}"/"${filename}"
gtkwave "${foldername}"/"${filename}.gtkw" --rcvar 'fontname_signals Monospace 15' --rcvar 'fontname_waves Monospace 12'
