import os
import re

funct_codes = {
    'add': '100000',
    'addu': '100001',
    'sub': '100010',
    'subu': '100011',
    'and': '001000',
    'or': '001001',
    'xor': '001010',
    'nor': '001011',
    'sll': '000100',
    'srl': '000101',
    'slt': '000010'
}

opcodes = {
    'addiu': '100001',
    'andi': '001000',
    'ori': '001001',
    'xori': '001010',
    'slti': '000010',
    'sw': '010000',
    'lw': '010001',
    'beq': '011000',
    'bne': '011001',
    'bltz': '011010',
    'j': '011100',
    'jr': '011101',
    'jal': '011110',
    'halt': '111111'
}

def register_to_bin(register):
    return bin(int(register[1:]))[2:].zfill(5)

def immediate_to_bin(immediate):
    return bin(int(immediate) & 0xFFFF)[2:].zfill(16)

def address_to_bin(address):
    # 转换16进制地址为二进制，并去掉末尾两位
    bin_address = bin(int(address, 16))[2:].zfill(28)  # 转换为28位二进制
    return bin_address[:-2].zfill(26)  # 去掉末尾两位并填充为26位

def assemble_instruction(instruction):
    parts = re.split(r'\s|,|\(|\)', instruction)
    parts = [p for p in parts if p]

    opcode = parts[0]

    if opcode in funct_codes:
        if opcode in ['sll', 'srl']:
            rt = register_to_bin(parts[2])
            rd = register_to_bin(parts[1])
            sa = bin(int(parts[3]))[2:].zfill(5)
            funct = funct_codes[opcode]
            return f'000000{"00000"}{rt}{rd}{sa}{funct}'
        else:
            rs = register_to_bin(parts[2])
            rt = register_to_bin(parts[3])
            rd = register_to_bin(parts[1])
            funct = funct_codes[opcode]
            return f'000000{rs}{rt}{rd}{"00000"}{funct}'

    elif opcode in opcodes:
        op_bin = opcodes[opcode]

        if opcode in ['j', 'jal']:
            address = address_to_bin(parts[1])
            return f'{op_bin}{address}'

        elif opcode == 'jr':
            rs = register_to_bin(parts[1])
            return f'{op_bin}{rs}{"0" * 21}'

        elif opcode in ['beq', 'bne', 'bltz']:
            rs = register_to_bin(parts[1])

            if opcode == 'bltz':
                imm = immediate_to_bin(parts[2])
                return f'{op_bin}{rs}{"00000"}{imm}'

            rt = register_to_bin(parts[2])
            imm = immediate_to_bin(parts[3])
            return f'{op_bin}{rs}{rt}{imm}'

        elif opcode in ['sw', 'lw']:
            rt = register_to_bin(parts[1])
            imm = immediate_to_bin(parts[2])
            rs = register_to_bin(parts[3])
            return f'{op_bin}{rs}{rt}{imm}'

        elif opcode == 'halt':
            return f'{op_bin}{"0" * 26}'

        else:
            rt = register_to_bin(parts[1])
            rs = register_to_bin(parts[2])
            imm = immediate_to_bin(parts[3])
            return f'{op_bin}{rs}{rt}{imm}'

    else:
        raise ValueError(f"Syntax Error: {instruction}")


if __name__ == "__main__":
    # 获取当前脚本所在的目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 拼接相对路径
    assembly_path = os.path.join(script_dir, 'assembly_code.asm')
    binary_path = os.path.join(script_dir, 'machine_code.txt')

    # 打开文件，显式指定编码为UTF-8
    with open(assembly_path, 'r', encoding='utf-8') as file:
        assembly_code = file.readlines()

    # 忽略注释
    assembly_code = [
        line.split('#')[0].strip() 
        for line in assembly_code 
        if line.strip() and not line.strip().startswith('#')
    ]

    # 写入文件
    with open(binary_path, 'w') as outfile:
        for instruction in assembly_code:
            binary_code = assemble_instruction(instruction)
            formatted_binary_code = ' '.join([binary_code[i:i + 8] for i in range(0, 32, 8)])
            outfile.write(f"{formatted_binary_code}\n")
            print(f"{instruction} -> {binary_code}")
            