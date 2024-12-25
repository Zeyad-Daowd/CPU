# 0 => "1000000000000000",
filename = "result.mem"
lines = ""
with open(filename, "r") as f:
    i = 0
    for line in f:
        lines += f'{i} => "{line[:-1]}",'+"\n"
        i += 1
with open("hardcoded.txt",'w') as f2:
    f2.write(lines)