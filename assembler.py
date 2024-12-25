import re, os
from collections import OrderedDict
class Assembler:
    Registers = dict()
    for i in range(8):
        Registers[f"r{i}"] = f"{i:03b}"
    noOperands = {
        "nop": 0,
        "hlt": 1,
        "setc": 2,
        "ret": 29,
        "rti": 31,
    }
    dstSrc = {
        "not": 3,
        "inc": 4,
        "mov": 8
    }
    dstSrcSrc = {
        "add": 9,
        "sub": 10,
        "and": 11
    }
    dst = {
        "in": 6,
        "pop": 17
    }
    src = {
        "out": 5,
        "push": 16,
        "jz": 24,
        "jn": 25,
        "jc": 26,
        "jmp": 27,
        "call": 28
    }
    @staticmethod
    def toBinary(value, bits=16):
            return f"{int(value):0{bits}b}"
    
    @staticmethod
    def assemble(line, printErrors=True):
        line = line.strip().lower()
        line = line.replace("  ", " ")
        instruction = line.split(" ")[0]
        
        if instruction in Assembler.noOperands:
            return Assembler.toBinary(Assembler.noOperands[instruction], 5) + "0"*11
        if instruction in Assembler.dstSrc:
            line = line.replace(",", " ").replace("  ", " ")
            dst = line.split(" ")[1]
            src = line.split(" ")[2]
            return Assembler.toBinary(Assembler.dstSrc[instruction], 5) + Assembler.Registers[dst] + Assembler.Registers[src] + "0" * 5
        if instruction in Assembler.dstSrcSrc:
            line = line.replace(",", " ").replace("  ", " ")
            dst = line.split(" ")[1]
            src1 = line.split(" ")[2]
            src2 = line.split(" ")[3]
            return Assembler.toBinary(Assembler.dstSrcSrc[instruction], 5) + Assembler.Registers[dst] + Assembler.Registers[src1] + Assembler.Registers[src2] + "0" * 2
        if instruction in Assembler.dst:
            dst = line.split(" ")[1]
            return Assembler.toBinary(Assembler.dst[instruction], 5) + Assembler.Registers[dst] + "0"*8
        if instruction == "int":
            index = (line.split(" ")[1])
            if index == "0":
                char = "0"
            else:
                char = "1"
            return Assembler.toBinary(30, 5)+ "0" * 3 + char + "0" * 7
        if instruction in Assembler.src:
            src = line.split(" ")[1]
            return Assembler.toBinary(Assembler.src[instruction], 5) + "0" * 3 + Assembler.Registers[src] + "0"*5
        if instruction == "iadd":
            line = line.replace(",", " ").replace("  ", " ")
            dst, src, imm = line.split(" ")[1:4]
            line1 = Assembler.toBinary(12, 5) + Assembler.Registers[dst] + Assembler.Registers[src] + "0" * 4 + "1"
            line2 = Assembler.toBinary(int(imm, 16), 16)
            return line1 + "\n" + line2
        if instruction == "ldm":
            line = line.replace(",", "")
            dst, imm = line.split(" ")[1:3]
            line1 = Assembler.toBinary(18, 5) + Assembler.Registers[dst] + "0"*7 + "1"
            line2 = Assembler.toBinary(int(imm, 16), 16)
            return line1 + "\n" + line2
        if instruction == "ldd":
            line = line.replace(" (", "(")
            offset = re.search(r"[0-9]+\(", line).group()
            dst = re.search(r"r[0-7]\,", line).group()
            src = re.search(r"r[0-7]\)", line).group()
            offset = int(offset[:-1], 16)
            src = src[:-1]
            dst = dst[:-1]
            line1 = Assembler.toBinary(19, 5) + Assembler.Registers[dst] + Assembler.Registers[src] + "0" * 4 + "1"
            line2 = Assembler.toBinary(offset, 16)
            return line1 + "\n" + line2
        if instruction == "std":
            line = line.replace(" (", "(")
            offset = re.search(r"[0-9]+\(", line).group()
            src1 = re.search(r"r[0-7]\,", line).group()
            src2 = re.search(r"r[0-7]\)", line).group()
            offset = int(offset[:-1], 16)
            src1 = src1[:-1]
            src2 = src2[:-1]
            line1 = Assembler.toBinary(20, 5) + "000" + Assembler.Registers[src1] + Assembler.Registers[src2] + "0" * 1 + "1"
            line2 = Assembler.toBinary(offset, 16)
            return line1 + "\n" + line2
        if (printErrors):
            print(f"Error: {instruction} not found")
            print("line: ", line)
        return -1
def is_hexadecimal(s):
    try:
        int(s, 16)
        return True
    except ValueError:
        return False
filename = "input.txt"
outFile = "result.txt"
if os.path.exists(outFile):
    os.remove(outFile)
dictionary = OrderedDict()
initial = 0
with open(filename, "r") as f:
    for line in f:
        line = line.strip()
        line = line.replace("\t", " ")
        if (not line or line == "\n" or line[0] == "#"):
            continue
        if (line.lower().split() and line.lower().split()[0] == ".org"):
            hexa = line.lower().split()[1]
            initial = int(hexa, 16)
            continue
        temp = Assembler.assemble(line, False)
        if (temp == -1 and line.strip().split() and is_hexadecimal(line.strip().split()[0])):
            dictionary[initial] = Assembler.toBinary(int(line.strip().split()[0], 16), 16)
            initial += 1
            continue
            
        assembled = Assembler.assemble(line)
        for x in assembled.split("\n"):
            dictionary[initial] = x
            initial += 1
        # with open(outFile, "a") as f:
        #     f.write(assembled + "\n")
maxKey = max(dictionary.keys())
with open(outFile, "w") as f:
    for i in range(maxKey+1):
        if i in dictionary:
            f.write(dictionary[i] + "\n")  
        else:
            f.write("0"*16 + "\n")