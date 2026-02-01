# SAP - Simple Assembly Platform

A virtual machine, assembler, and debugger built from scratch in Swift—validated by implementing a fully functional Turing machine simulator in the custom assembly language.

## What I Built

I designed and implemented a complete computing stack: a virtual machine with a 58-instruction architecture, a two-pass assembler that compiles assembly source to binary, and an interactive debugger with breakpoints and single-step execution. To prove the system worked, I wrote a Turing machine simulator entirely in my custom assembly language—effectively running a theoretical model of computation on my own hardware abstraction.

**The execution flow:**
```
Assembly Source (.txt)
        ↓
   Two-Pass Assembler
        ↓
Binary (.bin) + Symbol Table (.sym)
        ↓
   Virtual Machine (Swift)
        ↓
   Program Execution
```

## Why This Project is Interesting

**Multiple layers of abstraction:** This project demonstrates understanding of how computers work at a fundamental level—from instruction encoding to program execution. The Turing machine simulator adds another layer: a theoretical computation model running on a custom assembly language, running on a virtual machine, running on Swift.

**Real compiler/interpreter concepts:** The assembler implements lexical analysis (tokenization), symbol table generation, label resolution across two passes, and binary code generation. The VM implements a fetch-decode-execute cycle, register allocation, memory addressing modes, and stack-based subroutine calls.

**Systems programming without training wheels:** No frameworks, no libraries for the core logic—just data structures, algorithms, and an understanding of how CPUs process instructions.

## Technical Deep-Dive

### The Assembler (Two-Pass Compilation)

**Pass 1 - Symbol Collection:**
- Tokenizes source into registers, labels, immediates, instructions, and directives
- Builds a symbol table mapping label names to memory addresses
- Handles data directives: `.String`, `.Integer`, `.Tuple`

**Pass 2 - Code Generation:**
- Resolves label references using the symbol table
- Encodes each instruction as integers (opcode + operands)
- Outputs binary file with program length, start address, and bytecode

**Why two passes?** Forward references. When the assembler sees `jmp EndLoop`, it might not know where `EndLoop` is yet. Pass 1 finds all labels; Pass 2 resolves them.

### The Virtual Machine

**CPU State:**
- 10 general-purpose registers (`r0`-`r9`)
- Program counter (PC) tracking current instruction
- Comparison register with three states: negative, zero, positive
- Flat memory model (integer array)
- 200-element call stack for subroutine management

**Fetch-Decode-Execute Cycle:**
```swift
while running {
    instruction = memory[PC]      // Fetch
    PC += 1
    switch instruction {          // Decode & Execute
        case .movir: // Move immediate to register
            register[operand1] = operand2
        case .addrr: // Add register to register
            register[operand1] += register[operand2]
        case .jmpz:  // Jump if zero
            if comparison == .zero { PC = operand1 }
        // ... 55 more instructions
    }
}
```

**Addressing Modes:**
- Immediate: value encoded directly (`movir r0 42`)
- Register: value in register (`movrr r0 r1`)
- Direct: value at memory address (`movmr r0 label`)
- Indirect: value at address stored in register (`movxr r0 r1`)

### The Debugger

Integrated debugging without external tools:
- **Breakpoints:** Set/remove at any address; execution pauses when PC hits a breakpoint
- **Single-step:** Execute one instruction at a time
- **State inspection:** View registers, memory, stack, symbol table
- **Disassembler:** Convert binary back to readable assembly with label resolution

### The Turing Machine Simulator

Written entirely in SAP assembly to validate the VM's capabilities:

**How it works:**
1. Stores the tape as an array in memory
2. Defines state-transition rules as tuples: `(currentState, inputChar, newState, outputChar, direction)`
3. Main loop: read tape at head position → find matching rule → write output → move head → update state
4. Halts when no matching rule exists

**Why a Turing machine?** It's the theoretical foundation of computation. If my VM can run a Turing machine simulator, it can (in theory) compute anything computable—a satisfying proof of completeness.

## Project Structure

```
SAP/
├── main.swift          # Entry point
├── sapVM.swift         # Virtual machine (fetch-decode-execute, 58 instructions)
├── assembler.swift     # Two-pass assembler (tokenizer, symbol table, codegen)
├── debugger.swift      # Breakpoints, single-step, disassembler
├── commands.swift      # Instruction opcodes and comparison flags
├── support.swift       # Stack implementation, file I/O, utilities
├── token.swift         # Token struct for lexical analysis
├── tokentypes.swift    # Token type enum (Register, Label, Instruction, etc.)
├── tuple.swift         # Turing machine state-transition representation
├── turing.txt          # Turing machine simulator (assembly source)
├── turing.bin          # Compiled binary
└── turing.sym          # Symbol table (56 labels → addresses)
```

## Instruction Set Architecture (58 Instructions)

### Data Movement
| Instruction | Description |
|------------|-------------|
| `movir` | Move immediate to register |
| `movrr` | Move register to register |
| `movrm` | Move register to memory |
| `movmr` | Move memory to register |
| `movxr` | Move indirect (address in register) to register |
| `movar` | Move address of label to register |
| `movb` | Move block of memory |
| `clrr`, `clrx`, `clrm`, `clrb` | Clear register/memory |

### Arithmetic
| Instruction | Description |
|------------|-------------|
| `addir`, `addrr`, `addmr`, `addxr` | Addition (immediate/register/memory/indirect) |
| `subir`, `subrr`, `submr`, `subxr` | Subtraction |
| `mulir`, `mulrr`, `mulmr`, `mulxr` | Multiplication |
| `divir`, `divrr`, `divmr`, `divxr` | Division |

### Control Flow
| Instruction | Description |
|------------|-------------|
| `jmp` | Unconditional jump |
| `jmpn`, `jmpz`, `jmpp`, `jmpne` | Jump if negative/zero/positive/not-equal |
| `jsr`, `ret` | Jump to subroutine (pushes return address), return |
| `sojz`, `sojnz` | Subtract one and jump if zero/not-zero |
| `aojz`, `aojnz` | Add one and jump if zero/not-zero |

### Comparison
| Instruction | Description |
|------------|-------------|
| `cmpir` | Compare immediate to register → sets comparison flag |
| `cmprr` | Compare register to register |
| `cmpmr` | Compare memory to register |

### I/O
| Instruction | Description |
|------------|-------------|
| `outci`, `outcr`, `outcx`, `outcb` | Output character (immediate/register/indirect/block) |
| `printi` | Print integer value |
| `readi`, `readc`, `readln` | Read integer/character/line from input |
| `outs` | Output null-terminated string |

### Stack & Control
| Instruction | Description |
|------------|-------------|
| `push`, `pop` | Stack operations |
| `stackc` | Check stack count |
| `halt` | Terminate execution |
| `brk` | Debugger breakpoint |
| `nop` | No operation |

## Debugger Commands

| Command | Description |
|---------|-------------|
| `setbk <addr>` | Set breakpoint at address |
| `rmbk <addr>` | Remove breakpoint |
| `clrbk` | Clear all breakpoints |
| `disbk` / `enbk` | Disable/enable breakpoints |
| `preg` | Print all register values |
| `wreg <n> <val>` | Write value to register n |
| `wmem <addr> <val>` | Write value to memory address |
| `wpc <val>` | Set program counter |
| `pst` | Print symbol table |
| `deas <start> <end>` | Disassemble memory range |
| `g` | Continue execution |
| `s` | Single-step one instruction |

## Skills Demonstrated

- **Systems programming:** Low-level memory management, instruction encoding, CPU simulation
- **Compiler construction:** Lexical analysis, parsing, symbol tables, code generation
- **Computer architecture:** Register files, addressing modes, instruction set design
- **Debugging tools:** Breakpoint implementation, state inspection, disassembly
- **Theoretical CS:** Turing machine implementation, understanding of computational completeness

## Technologies

| Technology | Role |
|-----------|------|
| Swift | Implementation language |
| Custom ISA | 58-instruction assembly language |
| macOS/Darwin | Platform and file I/O |

---

*Built during high school as part of NSHS Advanced Computer Science.*
