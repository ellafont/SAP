import Foundation

extension sapVM{
    private func getInput() -> String{
        let line = readLine()
        if line == nil{
            return "inputErr"
        }
        if splitStringIntoParts(expression: line!).count == 0{
            return "inputErr"
        }
        return line!
    }
    private func getAddressFromLabel(label: String) -> Int?{
        if let address = symbolTable[label] {
            return address
        } else {
            return Int(label)
        }
    }
    
    func runDebugger(){
        print("Sdb(\(PC),\(memory[PC]))> ", terminator: "")
        var input = splitStringIntoParts(expression: getInput())
        var command = input[0]
        while command != "g" || command != "s"{
            switch command {
            case "exit":
                exit(0)
            case "g":
                inSingleStep = false
                return
            case "s":
                inSingleStep = true
                return
            case "help":
                print(help)
            case "pst":
                print("Symbol Table:")
                for symbol in symbolTable.keys{
                    print("\(symbol): \(symbolTable[symbol]!)")
                }
            case "pbk":
                print("Break Points:")
                for key in breakpoints.keys{
                    print("\(key)  (\(reverseSymbolTable[key] ?? "not a label address"))")
                }
            case "preg":
                print("Registers: ")
                for reg in 0..<generalRegisters.count{
                    print(" r\(reg): \(generalRegisters[reg])")
                }
                print("PC: \(PC)")
            case "pmem":
                print("Memory dump:")
                if input.count != 3{print("please give a start address and an end address"); break}
                if getAddressFromLabel(label: input[1]) == nil || getAddressFromLabel(label: input[2]) == nil{
                    print("addresses must be ints"); break
                }
                for i in getAddressFromLabel(label: input[1])!..<getAddressFromLabel(label: input[2])!{
                    print(  "\(i): \(memory[i])")
                }
            case "setbk": //can have label addresses (add that) (symbol table)
                if input.count == 1 {print("setbk <address>"); break}
                if let address = getAddressFromLabel(label: input[1]){
                    breakpoints[address] = true
                } else {print("not a valid address"); break}
            case "rmbk": //can have label addresses (add that) (symbol table)
                if input.count != 2 {print("rmbk <address>"); break}
                if let address = getAddressFromLabel(label: input[1]){
                    breakpoints.removeValue(forKey: address)
                }else{
                    print("not a valid address"); break
                }
            case "disbk":
                for bk in breakpoints.keys{
                    breakpoints[bk] = false
                }
            case "enbk":
                for bk in breakpoints.keys{
                    breakpoints[bk] = true
                }
            case "clrbk":
                for bk in breakpoints.keys{
                    breakpoints.removeValue(forKey: bk)
                }
            case "wreg":
                if input.count != 3 || Int(input[1]) == nil || Int(input[2]) == nil{print("bad parameters for wreg"); break}
                let reg = Int(input[1])!
                if reg < 0 || reg > 9 {print("register number must be 0 to 9"); break}
                generalRegisters[reg] = Int(input[2])!
            case "wmem":
                if input.count != 3 || Int(input[2]) == nil{print("bad parameters for wmem"); break}
                if let address = getAddressFromLabel(label: input[1]){
                    memory[address] = Int(input[2])!
                }
            case "wpc":
                if input.count != 2 {print("bad parameters for wpc"); break}
                if let value = Int(input[1]) {
                    if value < 0 || value > memory.count{print("invalid PC location"); break}
                    PC = value
                }
            //debugger:
            case "deas":
                if input.count != 3{print("bad parameters for deas"); break}
                if getAddressFromLabel(label: input[1]) == nil || getAddressFromLabel(label: input[2]) == nil{
                    print("addresses not valid"); break
                }
                let startAddress = getAddressFromLabel(label: input[1])!
                let endAddress = getAddressFromLabel(label: input[2])!
                print("Disassembly:")
                var loc = startAddress
                while loc <= endAddress{
                    if reverseSymbolTable[loc] != nil{
                        print("\(reverseSymbolTable[loc]!): ", terminator: "")
                    } else { print("      ", terminator: "") }
                    if let command = deassemblerDictionary[memory[loc]]{
                        print("\(command) ", terminator: "")
                        let param = deassemblerCommandParamsDictionary[command]
                        switch param{
                        case "r":
                            print("r\(memory[loc+1])")
                            loc += 2
                        case "rr":
                            print("r\(memory[loc+1]) r\(memory[loc+2])")
                            loc += 3
                        case "rrr":
                            print("r\(memory[loc+1]) r\(memory[loc+2]) r\(memory[loc+3])")
                            loc += 4
                        case "rm":
                            print("r\(memory[loc+1]) \(reverseSymbolTable[memory[loc+2]]!)")
                            loc += 3
                        case "m":
                            print(reverseSymbolTable[memory[loc+1]]!)
                            loc += 2
                        case "mr":
                            print("\(reverseSymbolTable[memory[loc+1]]!) r\(memory[loc+2])")
                            loc += 3
                        case "mm":
                            print("\(reverseSymbolTable[memory[loc+1]]!) \(reverseSymbolTable[memory[loc+2]]!)")
                            loc += 3
                        case "ir":
                            print("#\(memory[loc+1]) r\(memory[loc+2])")
                            loc += 3
                        case "h":
                            print("")
                            loc += 1
                            //runDebugger()
                        case "":
                            loc += 1
                        default:
                            loc += 1
                        }
                    }
                }
            case "inputErr":
                print("please enter a command")
            default:
                print("not a valid command")
            }
            print("Sdb(\(PC),\(memory[PC])> ", terminator: "")
            input = splitStringIntoParts(expression: getInput())
            command = input[0]
        }
    }
    
}
