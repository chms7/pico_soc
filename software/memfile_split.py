#!/usr/bin/env python

import sys
import re

# input .srec file
with open(sys.argv[1], "r+") as verilog_file:
  verilog_line = verilog_file.readlines()

# output .verilog file
verilog_file_1 = []
verilog_file_2 = []
verilog_file_3 = []
verilog_file_4 = []


verilog_file_1.append("@0\n")
verilog_file_2.append("@0\n")
verilog_file_3.append("@0\n")
verilog_file_4.append("@0\n")
for line in verilog_line:
  # if re.match('[@]', line) != None:
  #   verilog_file_1 = verilog_file_1 + list(line)
  #   verilog_file_2 = verilog_file_2 + list(line)
  #   verilog_file_3 = verilog_file_3 + list(line)
  #   verilog_file_4 = verilog_file_4 + list(line)
  # elif re.match('[^@]', line) != None:
  if re.match('[^@]', line) != None:
    count = 0
    data1 = str()
    data2 = str()
    data3 = str()
    data4 = str()
    for char in line.split():
      if count == 0:
        data1 = data1 + char + ' '
        count = count + 1
      elif count == 1:
        data2 = data2 + char + ' '
        count = count + 1
      elif count == 2:
        data3 = data3 + char + ' '
        count = count + 1
      elif count == 3:
        data4 = data4 + char + ' '
        count = 0 
    verilog_file_1.append(data1 + '\n')
    verilog_file_2.append(data2 + '\n')
    verilog_file_3.append(data3 + '\n')
    verilog_file_4.append(data4 + '\n')

# output .verilog file
with open("obj/firmware1.verilog", "w") as verilog_file_o_1:
  verilog_file_o_1.writelines(verilog_file_1)
with open("obj/firmware2.verilog", "w") as verilog_file_o_2:
  verilog_file_o_2.writelines(verilog_file_2)
with open("obj/firmware3.verilog", "w") as verilog_file_o_3:
  verilog_file_o_3.writelines(verilog_file_3)
with open("obj/firmware4.verilog", "w") as verilog_file_o_4:
  verilog_file_o_4.writelines(verilog_file_4)
