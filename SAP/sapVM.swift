import Foundation
import Darwin

class sapVM{
    var memory: [Int] = []
    var symbolTable: [String:Int] = [:]
    var reverseSymbolTable: [Int:String] = [:]
    var breakpoints: [Int:Bool] = [:] //array of addresses in memory to stop and go to debugger
    var generalRegisters = Array(repeating: 0, count: 10)
    let length: Int
    let start: Int
    var comparisonRegister: Comparison = Comparison.zero
    var returnTo: Int = 0
    var stack = Stack<Int>(size: 200, initial: 0)
    var PC : Int
    var inDebugger: Bool = true
    var inSingleStep: Bool = false
    var onBreakpoint = false
    var help : String = """
        setbk <address>         set breakpoint at <address>
        rmbk <address>          remove breakpoint at <address>
        clrbk                   clear all breakpoints
        disbk                   temporarily disable all breakpoints
        enbk                    enable breakpoints
        pbk                     print breakpoint table
        preg                    print the registers
        wreg <number><value>    write value of register <number> to <value>
        wpc <value>             change value of PC to <value>
        wmem <address><value>   change value of memory at <address> to <value>
        pst                     prinr symbol table
        g                       continue program execution
        s                       single step
        exit                    terminate virtual machine
        help                    print this help table
    """
    //commmand and string 
    var deassemblerDictionary: [Int:String] = [
        0 : "halt",
        1 : "clrr",
        2: "clrx",
        3: "clrm",
        4: "clrb",
        5: "movir",
        6: "movrr",
        7: "movrm",
        8: "movmr",
        9: "movxr",
        10: "movar",
        11: "movb",
        12: "addir",
        13: "addrr",
        14: "addmr",
        15: "addxr",
        16: "subir",
        17: "subrr",
        18: "submr",
        19: "subxr",
        20: "mulir",
        21: "mulrr",
        22: "mulmr",
        23: "mulxr",
        24: "divir",
        25: "divrr",
        26: "divmr",
        27: "divxr",
        28: "jmp",
        29: "sojz",
        30: "sojnz",
        31: "aojz",
        32: "aojnz",
        33: "cmpir",
        34: "cmprr",
        35: "cmpmr",
        36: "jmpn",
        37: "jmpz",
        38: "jmpp",
        39: "jsr",
        40: "ret",
        41: "push",
        42: "pop",
        43: "stackc",
        44: "outci",
        45: "outcr",
        46: "outcx",
        47: "outcb",
        48: "readi",
        49: "printi",
        50: "readc",
        51: "readln",
        52: "brk",
        53: "movrx",
        54: "movxx",
        55: "outs",
        56: "nop",
        57: "jmpne",
    ]
    
    //m is always a label
    var deassemblerCommandParamsDictionary : [String:String] = [
        "halt": "h",
        "clrr": "r",
        "clrx": "r",
        "clrm": "m",
        "clrb": "rr",
        "movir": "ir",
        "movrr": "rr",
        "movrm": "rm",
        "movmr": "mr",
        "movxr": "rr",
        "movar": "mr",
        "movb": "rrr",
        "addir": "ir",
        "addrr": "rr",
        "addmr": "mr",
        "addxr": "rr",
        "subir": "ir",
        "subrr": "rr",
        "submr": "mr",
        "subxr": "rr",
        "mulir": "ir",
        "mulrr": "rr",
        "mulmr": "mr",
        "mulxr": "rr",
        "divir": "ir",
        "divrr": "rr",
        "divmr": "mr",
        "divxr": "rr",
        "jmp": "m",
        "sojz": "rm",
        "sojnz": "rm",
        "aojz": "rm",
        "aojnz": "rm",
        "cmpir": "ir",
        "cmprr": "rr",
        "cmpmr": "mr",
        "jmpn": "m",
        "jmpz": "m",
        "jmpp": "m",
        "jsr": "m",
        "ret": "",
        "push": "r",
        "pop": "r",
        "stackc": "r",
        "outci": "i",
        "outcr": "r",
        "outcx": "r",
        "outcb": "rr",
        "readi": "rr",
        "printi": "r",
        "readc": "r",
        "readln": "mr",
        "brk": "",
        "movrx": "rr",
        "movxx": "rr",
        "outs": "m",
        "nop": "",
        "jmpne": "m"
    ]
    
    init(filePath: String, programName: String){
        memory = readBinaryFile(path: filePath, fileName: programName + ".bin")
        symbolTable = readSymbolTable(path: filePath, fileName: programName + ".sym")
        for key in symbolTable.keys{
            reverseSymbolTable[symbolTable[key]!] = key
        }
        length = memory[0]
        start = memory[1]
        PC = start
        memory.remove(at: 0)
        memory.remove(at: 0)
    }
    
    func run(){
        self.runDebugger()
        while PC <= length{
            if inSingleStep {runDebugger()}
            if breakpoints.keys.contains(PC) && breakpoints[PC] == true{ //checks if at a breakpoint
                //true and false used as pointers for when they are hit.
                runDebugger()
            }
            switch memory[PC]{
            case 0: //halt
                exit(0)
            case 1: //clrr
                generalRegisters[memory[PC+1]] = 0
                PC += 2
                continue
            case 2: //clrx
                memory[generalRegisters[memory[PC+1]]] = 0
                PC += 2
                continue
            case 3: //clrm
                memory[PC+1] = 0
                PC += 2
                continue
            case 4: //clrb
                for j in memory[PC+1]...memory[PC+2]{
                    memory[j] = 0
                }
                PC += 3
                continue
            case 5: //movir
                generalRegisters[memory[PC+2]] = memory[PC+1]
                PC += 3
                continue
            case 6: //movrr
                generalRegisters[memory[PC+2]] = generalRegisters[memory[PC+1]]
                PC += 3
                continue
            case 7: //movrm
                memory[memory[PC+2]] = generalRegisters[memory[PC+1]]
                PC += 3
                continue
            case 8: //movmr
                generalRegisters[memory[PC+2]] = memory[memory[PC+1]] //memory in memory location of the "label"
                PC += 3
                continue
            case 9: //movxr
                generalRegisters[memory[PC+2]] = memory[generalRegisters[memory[PC+1]]]
                PC += 3
                continue
            case 10: //movar
                generalRegisters[memory[PC+2]] = memory[PC+1]
                PC += 3
                continue
            case 11: //movb
                for j in memory[PC+1]...memory[PC+1] + memory[PC+3]{
                    memory[memory[PC+2]+j] = memory[j]
                }
                PC += 4
                continue
            case 12: //addir
                generalRegisters[memory[PC+2]] += memory[PC+1]
                PC += 3
                continue
            case 13: //addrr
                generalRegisters[memory[PC+2]] += generalRegisters[memory[PC+1]]
                PC += 3
                continue
            case 14: //addmr
                generalRegisters[memory[PC+2]] += memory[memory[PC+1]]
                PC += 3
                continue
            case 15: //addxr :)
                generalRegisters[memory[PC+2]] += memory[generalRegisters[memory[PC+1]]]
                PC += 3
                continue
            case 16: //subir
                generalRegisters[memory[PC+2]] -= memory[PC+1]
                PC += 3
                continue
            case 17: //subrr
                generalRegisters[memory[PC+2]] += generalRegisters[memory[PC+1]]
                PC += 3
                continue
            case 18: //submr
                generalRegisters[memory[PC+2]] -= memory[memory[PC+1]]
                PC += 3
                continue
            case 19: //subxr
                memory[generalRegisters[PC+2]] -= generalRegisters[memory[PC+1]]
                PC += 3
                continue
            case 20: //mulir
                generalRegisters[memory[PC+2]] = generalRegisters[memory[PC+2]] * memory[PC+1]
                PC += 3
                continue
            case 21: //mulrr
                generalRegisters[memory[PC+2]] = generalRegisters[memory[PC+2]] * generalRegisters[memory[PC+1]]
                PC += 3
                continue
            case 22: //mulmr
                generalRegisters[memory[PC+2]] = generalRegisters[memory[PC+2]] * memory[memory[PC+1]]
                PC += 3
                continue
            case 23: //mulxr
                generalRegisters[memory[PC+2]] = generalRegisters[memory[PC+2]] * memory[generalRegisters[memory[PC+1]]]
                PC += 3
                continue
            case 24: //divir
                generalRegisters[memory[PC+2]] = generalRegisters[memory[PC+2]] / memory[PC+1]
                PC += 3
                continue
            case 25: //divrr
                generalRegisters[memory[PC+2]] = generalRegisters[memory[PC+2]] / generalRegisters[memory[PC+1]]
                PC += 3
                continue
            case 26: //divmr
                generalRegisters[memory[PC+2]] = generalRegisters[memory[PC+2]] / memory[memory[PC+1]]
                PC += 3
                continue
            case 27: //divxr
                generalRegisters[memory[PC+2]] = generalRegisters[memory[PC+2]] / memory[generalRegisters[memory[PC+1]]]
                PC += 3
                continue
            case 28: //jmp
                PC = memory[PC+1]
                continue
            case 29: //sojz
                generalRegisters[memory[PC+1]] -= 1
                if generalRegisters[memory[PC+1]] == 0{PC = memory[PC+2]}
                else{PC += 3}
                continue
            case 30: //sojnz
                generalRegisters[memory[PC+1]] -= 1
                if generalRegisters[memory[PC+1]] != 0{PC = memory[PC+2]} //is something wrong here
                else{PC += 3}
                continue
            case 31: //aojz
                generalRegisters[memory[PC+1]] += 1
                if generalRegisters[memory[PC+1]] == 0{PC = memory[PC+2]}
                else{PC += 3}
                continue
            case 32: //aojnz
                generalRegisters[memory[PC+1]] += 1
                if generalRegisters[memory[PC+1]] != 0{PC = memory[PC+2]}
                else{PC += 3}
                continue
            case 33: //cmpir
                compare(memory[PC+1], generalRegisters[memory[PC+2]])
                PC += 3
                continue
            case 34: //cmprr
                compare(generalRegisters[memory[PC+1]], generalRegisters[memory[PC+2]])
                PC += 3
                continue
            case 35: //cmpmr
                compare(memory[memory[PC+1]], generalRegisters[memory[PC+2]])
                PC += 3
                continue
            case 36: //jmpn
                if comparisonRegister == Comparison.negative{PC = memory[PC+1]}
                else{PC += 2}
                continue
            case 37: //jmpz
                if comparisonRegister == Comparison.zero{PC = memory[PC+1]}
                else{PC += 2}
                continue
            case 38: //jmpp
                if comparisonRegister == Comparison.positive{PC = memory[PC+1]}
                else{PC += 2}
                continue
            case 39: //jsr
                returnTo = PC+2
                PC = memory[PC+1] //memory[memory[i+1]]
                for j in 5...9{
                    stack.push(generalRegisters[j]) //check saving the registers
                }
                //print(i, returnTo)
                continue
            case 40: //ret
                PC = returnTo
                //                for j in 9...5{ //5...9
                //                    generalRegisters[j] = stack.pop()!
                //                }
                for index in stride(from: 9, to: 5, by: -1){
                    generalRegisters[index] = stack.pop()!
                }
                //i += 1
                continue
            case 41: //push
                stack.push(generalRegisters[memory[PC+1]])
                PC += 2
                continue
            case 42: //pop (r)
                //print(memory[i+1])
                generalRegisters[memory[PC+1]] = stack.pop()!
                PC += 2
                continue
            case 43: //stackc
                if stack.isEmpty(){generalRegisters[memory[PC+1]] = 2}
                else{generalRegisters[memory[PC+1]] = 0}
                PC += 2
                continue
            case 44: //outci
                print(unicodeToChar(memory[PC+1]), terminator: "")
                PC += 2
                continue
            case 45: //outcr
                print(unicodeToChar(generalRegisters[memory[PC+1]]), terminator: "")
                PC += 2
                continue
            case 46: //outcx
                print(unicodeToChar(memory[generalRegisters[memory[PC+1]]]), terminator: "")
                PC += 2
                continue
            case 47: //outcb
                for j in memory[PC+1]...memory[PC+1]+memory[PC+2]{
                    print(memory[j], terminator: " ")
                }
                PC += 3
                continue
            case 48: //readi
                generalRegisters[memory[PC+1]] = Int(readLine()!) ?? 0
                PC += 2
                continue
            case 49: //printi
                print(generalRegisters[memory[PC+1]], terminator: "")
                PC += 2
                continue
            case 50: //readc
                generalRegisters[memory[PC+1]] = charToUnicode(Character(readLine()!))
                PC += 2
                continue
            case 51: //readln
                continue
            case 52: //brk
                runDebugger()
                continue
            case 53: //movrx
                memory[generalRegisters[memory[PC+2]]] = generalRegisters[memory[PC+1]]
                PC += 3
                continue
            case 54: //movxx
                memory[generalRegisters[memory[PC+2]]] = memory[generalRegisters[memory[PC+1]]]
                PC += 3
                continue
            case 55: //outs
                //do memory[i+1] to get the start / length of string -- then get the memory from i+1 to memory[i+1] (the number of spots after the the spot in data the "label" is stored\
                let labelLength = memory[memory[PC+1]]
                let location = memory[PC+1]
                var outs = ""
                for index in (location+1)...(location+labelLength){
                    outs += String(unicodeToChar(memory[index]))
                }
                print(outs, terminator: "")
                PC += 2
                continue
            case 56: //nop
                PC += 1
                continue
            case 57: //jmpne
                if comparisonRegister != Comparison.zero{
                    PC = memory[PC+1]
                    continue
                }
                PC += 2
                continue
            default:
                PC += 1
                continue
            }
        }
    }
    
    private func compare(_ a: Int, _ b: Int){
        if a < b{comparisonRegister = Comparison.negative}
        if a == b{comparisonRegister = Comparison.zero}
        else {comparisonRegister = Comparison.positive}
    }
}

