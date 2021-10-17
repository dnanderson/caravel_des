import des
from binascii import hexlify
import os

# key0 = des.DesKey(bytes.fromhex('ca404e1b3f4f9230'))
# print(key0.is_single())
# result = key0.encrypt(bytes.fromhex('921a72b60268a21a'))
# print(result.hex())

    # reg[63:0] teststring = 64'h921a72b60268a21a;
    # reg[63:0] testkey = 64'hca404e1b3f4f9230;
abspath = os.path.abspath(__file__)
os.chdir(os.path.dirname(abspath))
vdir = os.path.join('..', 'verilog', 'rtl')
os.chdir(vdir)

# Create a input data file, an input key file, and an output comparison file
# These are used in the testbench
keys = []
for x in range(1000):
    keys.append(os.urandom(8))

blocks = []
for x in range(1000):
    blocks.append(os.urandom(8))

encrypts = []
for block, key in zip(blocks, keys):
    keyobj = des.DesKey(key)
    encrypted_block = keyobj.encrypt(block)
    encrypts.append(encrypted_block)

with open('key_input.txt', 'w+') as f:
    for key in keys:
        f.write(key.hex() + '\n')

with open('block_input.txt', 'w+') as f:
    for block in blocks:
        f.write(block.hex() + '\n')

with open('expected.txt', 'w+') as f:
    for encrypted in encrypts:
        f.write(encrypted.hex() + '\n')
