#! /bin/bash
foldername="tb_files"
filename="sema"

echo "====================================================================
              LAUNCHING TEST BENCH COMPILATION:
              FOR THE FIRST TIME
====================================================================="

#rm "${foldername}"/$filename
#rm "${foldername}"/"${filename}.vcd"   


iverilog -g2012 -o "${foldername}"/"${filename}" "${filename}.sv"
#vvp "${foldername}"/"${filename}"
#gtkwave "${foldername}"/"${filename}.vcd" --rcvar 'fontname_signals Monospace 17' --rcvar 'fontname_waves Monospace 12'
