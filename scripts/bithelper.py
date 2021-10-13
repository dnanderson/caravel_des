# This script takes an input of a file in which a space seperated list of numbers exists
# The script reverses the order of the numbers and puts them into a verilog
# concatenation expression, with each number having been rebased to zero index rather than
# 1 index

import argparse


parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument('integers', nargs='+', help='a file of integers to use')
parser.add_argument('--wrap', dest='wrap', type=int, help='A wrap count')                 

args = parser.parse_args()

filename = args.integers[0]
wrapcnt = args.wrap

descript = ''
with open(filename, 'r') as f:
    descript = f.read()

splitdescript = descript.split()
splitdescript.reverse()
newdescript = []
for item in splitdescript:
    newdescript.append(int(item) - 1)


outputstr = '{ '

outputcnt = 0
for num in newdescript:
    outputstr = outputstr + f'jjj[{num}],'
    outputcnt += 1
    if (outputcnt % wrapcnt) == 0:
        outputstr = outputstr + '\n'

outputstr += '};'

print(outputstr)
