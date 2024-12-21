import re, os
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
        "jz": 22,
        "jn": 23,
        "jc": 24,
        "jmp": 25,
        "call": 26
    }
    @staticmethod
    def toBinary(value, bits=16):
            return f"{int(value):0{bits}b}"
    
    @staticmethod
    def assemble(line):
        line = line.strip().lower()
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
            return Assembler.toBinary(Assembler.src[instruction], 5) + Assembler.Registers[src] + "0"*8
        if instruction == "iadd":
            line = line.replace(",", " ").replace("  ", " ")
            dst, src, imm = line.split(" ")[1:]
            line1 = Assembler.toBinary(12, 5) + Assembler.Registers[dst] + Assembler.Registers[src] + "0" * 4 + "1"
            line2 = Assembler.toBinary(int(imm), 16)
            return line1 + "\n" + line2
        if instruction == "ldm":
            line = line.replace(",", "")
            dst, imm = line.split(" ")[1:]
            line1 = Assembler.toBinary(18, 5) + Assembler.Registers[dst] + "0"*7 + "1"
            line2 = Assembler.toBinary(int(imm), 16)
            return line1 + "\n" + line2
        if instruction == "ldd":
            line = line.replace(" (", "(")
            offset = re.search(r"[0-9]+\(", line).group()
            src = re.search(r"r[0-7]\,", line).group()
            dst = re.search(r"r[0-7]\)", line).group()
            offset = int(offset[:-1])
            src = src[:-1]
            dst = dst[:-1]
            line1 = Assembler.toBinary(19, 5) + Assembler.Registers[dst] + Assembler.Registers[src] + "0" * 4 + "1"
            line2 = Assembler.toBinary(offset, 16)
            return line1 + "\n" + line2
        if instruction == "std":
            line = line.replace(" (", "(")
            offset = re.search(r"[0-9]+\(", line).group()
            src2 = re.search(r"r[0-7]\,", line).group()
            src1 = re.search(r"r[0-7]\)", line).group()
            offset = int(offset[:-1])
            src1 = src1[:-1]
            src2 = src2[:-1]
            line1 = Assembler.toBinary(20, 5) + "000" + Assembler.Registers[src1] + Assembler.Registers[src2] + "0" * 1 + "1"
            line2 = Assembler.toBinary(offset, 16)
            return line1 + "\n" + line2
        print(f"Error: {instruction} not found")
        print("line: ", line)
        return ""
filename = "input.txt"
outFile = "result.txt"
if os.path.exists(outFile):
    os.remove(outFile)
with open(filename, "r") as f:
    for line in f:
        assembled = Assembler.assemble(line)
        with open(outFile, "a") as f:
            f.write(assembled + "\n")