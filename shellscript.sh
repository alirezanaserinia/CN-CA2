#!/bin/bash
echo "Run TCL file ..."
echo "-----------------------------"
ns Main.tcl
echo "-----------------------------"
echo "Calculating parameters ... "
python3 AvgThroughput.py
python3 PDR.py
python3 AvgE2EDelay.py
python3 AvgGoodput.py
python3 AveragRTT.py

