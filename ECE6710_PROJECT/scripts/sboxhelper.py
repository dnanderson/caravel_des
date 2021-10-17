import os
try:
    os.mkdir('sbox_verilog')
except OSError:
    pass
os.chdir('sbox')

def make_wrap(f, lines):
    modulename = os.path.splitext(os.path.basename(f.name))[0]
    f.write('`timescale 1ns / 100ps\n\n\n')
    f.write(f'module {modulename}(\n')
    f.write(f'    input [5:0] i_data,\n')
    f.write(f'    output reg [3:0] o_data\n')
    f.write(f');\n')
    f.write(f'\n\n\n')
    f.write(f'')
    f.write(f'    always@(i_data) begin\n')
    f.write(f'        case(i_data)\n')
    f.writelines(lines)
    f.write(f'        endcase\n')
    f.write(f'    end\n')
    f.write(f'endmodule\n')

def get_table(f):
    mylines = f.readlines()
    newlines = []
    for line in mylines:
        numlist = [int(x) for x in line.split()]
        newlines.append(numlist)
    return newlines

def case_maker(table):
    caselines = []
    for x in range(2**6):
        lineindex = ((x >> 4) & 0b10) | (x & 0b1)
        colindex = (x >> 1) & 0xF
        lkupnum = table[lineindex][colindex]
        binstring = format(x, '#08b')[2:]
        outputval = format(lkupnum, '#06b')[2:]
        casestr = f"            6'b{binstring}: o_data = 4'b{outputval}; "
        casestr += f"// ({colindex}, {lineindex}) = {lkupnum}\n"
        caselines.append(casestr)
    return caselines

def make_sbox(fileobj):
    dstpath = os.path.join('..', 'sbox_verilog', os.path.splitext(fileobj.name)[0]) + '.v'
    with open(dstpath, 'w+') as f:
        table = get_table(fileobj)
        case_lines = case_maker(table)
        make_wrap(f, case_lines)

for num in range(1, 9):
    with open(f'sbox{num}.txt', 'r') as f:
        make_sbox(f)

