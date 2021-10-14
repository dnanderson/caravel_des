# This script takes an input of a file in which a space seperated list of numbers exists
# The script reverses the order of the numbers and puts them into a verilog
# concatenation expression, with each number having been rebased to zero index rather than
# 1 index

import argparse


parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('integers', nargs='+', help='a file of integers to use')
parser.add_argument('--wrap', dest='wrap', type=int, help='A wrap count')                 
parser.add_argument('--bits', dest='bits', type=int, help='Input bits')                 

args = parser.parse_args()

filename = args.integers[0]
wrapcnt = args.wrap
bits = args.bits

descript = ''
with open(filename, 'r') as f:
    descript = f.read()

splitdescript = descript.split()
newdescript = []
for item in splitdescript:
    newdescript.append(int(item) - 1)

map_length = len(newdescript) # This is the output length
newnums = []
for v in newdescript:
    newnums.append(bits - 1 - v)

outputstr = '{ '

outputcnt = 0
for num in newnums:
    outputstr = outputstr + f'jjj[{num}],'
    outputcnt += 1
    if (outputcnt % wrapcnt) == 0:
        outputstr = outputstr + '\n'

outputstr += '};'

print(outputstr)
