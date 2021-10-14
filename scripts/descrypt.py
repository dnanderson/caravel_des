import des
from binascii import hexlify

key0 = des.DesKey(b'12345678')
print(key0.is_single())
print(hexlify(bytearray(key0.encrypt(b'12345678'))))