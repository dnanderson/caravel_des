# ECE- 6710

# September 26th, 2021 Dr. Gaillardon

# Project Proposal: Low Power Hardware Implementation of DES encryption/decryption

Group: Alec Adair, Derek Anderson, Preston Balfour, Behdad Jamadi

Motivation
Many products are reliant on sensitive data that is shared around the globe. To ensure that data is transferred securely across many
different types of channels, encryption algorithms and engines have become ubiquitous in almost all sensitive data transfer. These
products may also rely on remote sensors that are not easily accessible by humans and are also powered by batteries, solar panels, and
other power supplies that have very limited power production capabilities. This combination of sensitive reliable data transfer and the
need for low power consumption is the main motivation for developing an Encryption Engine Application Specific Integrated Circuit
(ASIC). Although Encryption algorithms can be done using microcontrollers, the power cost of running modern encryption algorithms
on a microcontroller exceeds what many IoT and edge processing projects can budget for power in data transfer. Not only does running
an encryption algorithm on a microcontroller cost a lot of power, encryption is very resource intensive for low power microcontrollers.

High Level Description:
This project is a hardware implementation of the Data Encryption Standard (DES). The encryption and decryption cores will have
selectable inputs to allow for plaintext input from either the RISC-V processor or direct input form the 8 - bit wide parallel input pins
allowing for integration with external devices. This core will also allow external or internal clocks to drive the logic. Key management
will be handled by a memory backed interface via Wishbone (for RISC-V support), or serial input for external devices. This accelerator
block will support an 8 - bit parallel input/output, and 16 layers of Kn. The block’s input and output buses are located on separate
interfaces. Output becomes ready to read after 16 clock cycles. Our project aims to implement both an encryption and decryption block
with independent input/output interfaces.

Functional Block Diagram


DES specifies a 64 - bit block of cleartext used as an input, and a 64 - bit key, of which only 56 bits are used in the algorithm with the rest
used as parity. Each invocation of DES has an output of 64 bits of ciphertext. The input is initially permuted, which simply swaps the
input bits into predefined output bit positions. Following this permutation, the algorithm performs 16 rounds of encryption using a
Feistel cipher. Each round divides its input into a left half and a right half. The right half is used as an input to a Feistel cipher as well
as copied to become the next round's left half. The Feistel cipher combines its input 32 bits with a 48 - bit round key to produce an output
32 bits that is XORed with the left half of the round. The result is then passed along to the next rounds right half.

The DES Feistel cipher expands its 32 - bit input R into 48 bits, XORs this with the round key (K), and then uses this as an input into 8
different substitution boxes. The output of the substitution is 32 bits, which are then permuted. After the permutation the Feistel cipher
is complete. This initial permutation is reversed as a final step with the output being the final ciphertext.

Concurrent with the DES encryption steps, a key schedule calculation is done. DES uses a 64-bit key as input to this key schedule
calculation, with 1 bit of each 8-bit byte of the key being used as error detection. This means only 56 bits of the 64-bit input key are
used in DES.

The input key is permuted with two outputs C 0 and D 0 , each containing a subset of the key’s bits. C and D are left shifted (rotated) either
once or twice, depending on the round iteration. Bits that are shifted out the most significant bit are shifted in the least significant bit.
After this shift, both C and D are permuted into a single 48-bit key output that becomes that iterations round key.

Decryption with DES is a simple reverse of the encryption steps, this is a common feature of Feistel ciphers. Encryption and decryption
are identical except for the ordering of the round keys.

Testing
To test the functionality of the DES encryption engine first an ideal model of the encryption engine will be written/found in a
programming language such as C++, Python, C etc. Since DES is a well-known, widely used algorithm, finding an ideal model is a
trivial step in test setup. This model will serve as “The Golden Standard" throughout the rest of the testing process for each design stage
of the chip. The same test vectors that are used in the golden standard will also be used with our Verilog testbench. This will ensure that
both our Verilog testbench and ASIC designs do not have any bugs.

The functionality of the chip will be validated at different points in the ASIC design flow. The first point at which the chip will be
validated is upon completion of The Hardware Description Language (HDL) Verilog Modeling. Two top level testbenches will be
written in Verilog to test the HDL and gate level Verilog (post synthesis). The first testbench to be created will only test the algorithm
portion of the Encyrption Engine, not the outside world interfacing circuitry. This testbench will have a one-to-one correspondence with
our golden standard algorithm testbench. A second testbench will be written to test the interface circuitry to the DES engine. When both
the HDL is complete and our testbenches are verified according to our golden standard, the same testbenches and test vectors will be
used to test our post synthesis gate level Verilog. Once the gate level Verilog has been verified, placement and routing of the gates can
be performed. After timing has been met in place and route, we will create another SPICE testbench that will simulate our same test
vectors as the golden standard. The final SPICE testbench must produce the same output as all other models and testbenches. Once
timing has been met and functionality is verified the chip will be ready for tape out.

All bits at each of the K 1 through K 16 stages will be able to be probed using the logic probes from the RISC-V processor. All 128 logic
probes will need to be used since there are 16 encryption stages with an 8 bit wide data path (8*16 = 128). The final output for test will
include 8 input pins for data input, 8 output pins for data output, 1 input clock pin, 1 external clock pin for data synchronization, 2 pins
for I2C communication, 1 pin for output data ready, 1 input data ready pin, 8 output pins for error vectors, and 1 input reset pin. In total
this leads to 31 pins needed for test and functionality with 7 pins available for future planning and function.

Roles:
Input/Output and Wishbone Interface: Preston Balfour

Algorithm and Functional Modeling: Derek Anderson and Behdad Jamadi

Test Bench and Automated Verification: Alec Adair

Do you plan on fabricating your design: Yes


