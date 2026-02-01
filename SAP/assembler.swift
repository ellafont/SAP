////
////  assembler.swift
////  sap
////
////  Created by Isabella Shaw on 5/7/19.
////  Copyright © 2019 Allie Smith. All rights reserved.
////
//
//import Foundation
//
//struct Assembler{
//    var inputProgram: String = ""
//    var programLines: [String] = []
//    var programChunks: [[String]] = [[]]
//    var tokens: [[Token]] = [[]]
//    var binaryCode: [Int] = []
//    var symbols: [String:Int] = [:]
//    var listing: String = ""
//    var hasError = false
//    var path = ""
//    var file = ""
//    let uiHelp = "SAP Help:\n  asm <program name> - assemble the specified program \n  run <program name> - run the specified program \n  path <path specification> - set the path for the SAP program directory \n    include final / but not name of file. SAP file must have an extension of .txt \n  printlst <program name> - print listing file for the specified program \n  printsym <program name> - print symbol table for the specified program \n  quit  - terminate SAP program \n  help  - print help table"
//    
//    let directives = [".String" : "String",
//                      ".Integer" : "Integer",
//                      ".allocate" : "Integer",
//                      ".tuple" : "Tuple",
//                      ".start" : "Label",
//                      ".end" : ""]
//    
//    let commands = ["halt" : "",
//                    "clrr" : "r",
//                    "clrx" : "r",
//                    "clrm" : "m",
//                    "clrb" : "rr",
//                    "movir" : "ir",
//                    "movrr" : "rr",
//                    "movrm" : "rm",
//                    "movmr" : "mr",
//                    "movxr" : "rr",
//                    "movar" : "mr",
//                    "movb" : "rrr",
//                    "addir" : "ir",
//                    "addrr" : "rr",
//                    "addmr" : "mr",
//                    "addxr" : "rr",
//                    "subir" : "ir",
//                    "subrr" : "rr",
//                    "submr" : "mr",
//                    "subxr" : "rr",
//                    "mulir" : "ir",
//                    "mulrr" : "rr",
//                    "mulmr" : "mr",
//                    "mulxr" : "rr",
//                    "divir" : "ir",
//                    "divrr" : "rr",
//                    "divmr" : "mr",
//                    "divxr" : "rr",
//                    "jmp" : "m",
//                    "sojz" : "rm",
//                    "sojnz" : "rm",
//                    "aojz" : "rm",
//                    "aojnz" : "rm",
//                    "cmpir" : "ir",
//                    "cmprr" : "rr",
//                    "cmpmr" : "mr",
//                    "jmpn" : "m",
//                    "jmpz" : "m",
//                    "jmpp" : "m",
//                    "jsr" : "m",
//                    "ret" : "",
//                    "push" : "r",
//                    "pop" : "r",
//                    "stackc" : "r",
//                    "outci" : "i",
//                    "outcr" : "r",
//                    "outcx" : "r",
//                    "outcb" : "rr",
//                    "readi" : "rr",
//                    "printi" : "r",
//                    "readc" : "r",
//                    "readln" : "mr",
//                    "brk" : "",
//                    "movrx" : "rr",
//                    "movxx" : "rr",
//                    "outs" : "m",
//                    "nop" : "",
//                    "jmpne" : "m"]
//    
//    let commands = ["halt" : 0,
//                    "clrr" : 1,
//                    "clrx" : "r",
//                    "clrm" : "m",
//                    "clrb" : "rr",
//                    "movir" : "ir",
//                    "movrr" : "rr",
//                    "movrm" : "rm",
//                    "movmr" : "mr",
//                    "movxr" : "rr",
//                    "movar" : "mr",
//                    "movb" : "rrr",
//                    "addir" : "ir",
//                    "addrr" : "rr",
//                    "addmr" : "mr",
//                    "addxr" : "rr",
//                    "subir" : "ir",
//                    "subrr" : "rr",
//                    "submr" : "mr",
//                    "subxr" : "rr",
//                    "mulir" : "ir",
//                    "mulrr" : "rr",
//                    "mulmr" : "mr",
//                    "mulxr" : "rr",
//                    "divir" : "ir",
//                    "divrr" : "rr",
//                    "divmr" : "mr",
//                    "divxr" : "rr",
//                    "jmp" : "m",
//                    "sojz" : "rm",
//                    "sojnz" : "rm",
//                    "aojz" : "rm",
//                    "aojnz" : "rm",
//                    "cmpir" : "ir",
//                    "cmprr" : "rr",
//                    "cmpmr" : "mr",
//                    "jmpn" : "m",
//                    "jmpz" : "m",
//                    "jmpp" : "m",
//                    "jsr" : "m",
//                    "ret" : "",
//                    "push" : "r",
//                    "pop" : "r",
//                    "stackc" : "r",
//                    "outci" : "i",
//                    "outcr" : "r",
//                    "outcx" : "r",
//                    "outcb" : "rr",
//                    "readi" : "rr",
//                    "printi" : "r",
//                    "readc" : "r",
//                    "readln" : "mr",
//                    "brk" : "",
//                    "movrx" : "rr",
//                    "movxx" : "rr",
//                    "outs" : "m",
//                    "nop" : "",
//                    "jmpne" : "m"]
//    
//    func getChunk(_ line: String, _ from: Int, _ to: Int)->String{
//        let start = line.index(line.startIndex, offsetBy: from)
//        let end = line.index(line.startIndex, offsetBy: to)
//        let range = start...end
//        let str = String(line[range])
//        return str
//    }
//    
//    mutating func splitChunks(){
//        inputProgram = readTextFile(path + file + ".txt").fileText!
//        programLines = inputProgram.lines
//        var row = 0
//        var from = 0
//        var isString = false
//        var isTuple = false
//        for line in programLines{
//            programChunks.append([])
//            if line == ""  || line[0] == ";"{
//                row += 1
//                continue
//            }
//            from = 0
//            isString = false
//            isTuple = false
//            
//            var end = line.indexDistance(of: ";") ?? line.count
//            while end > 0 && line[end - 1] == " "{end -= 1}
//            
//            for to in 0..<end{
//                if line[to] == "\"" && isString == false{
//                    from = to
//                    isString = true
//                    continue
//                }
//                if line[to] == "\"" && isString == true{
//                    programChunks[row].append(getChunk(line, from, to))
//                    from = to
//                    isString = false
//                    continue
//                }
//                else if line[to] == "\\" && isTuple == false{
//                    from = to
//                    isTuple = true
//                    continue
//                }
//                if line[to] == "\\" && isTuple == true{
//                    programChunks[row].append(getChunk(line, from, to))
//                    from = to
//                    isTuple = false
//                    continue
//                }
//                else if line[to] == " " && isString == false && isTuple == false{
//                    programChunks[row].append(getChunk(line, from, to - 1))
//                    from = to + 1
//                    continue
//                }
//            }
//            if from != end - 1{
//                programChunks[row].append(getChunk(line, from, line.count - 1))
//            }
//            row += 1
//        }
//    }
//    
//    mutating func tokenize(){
//        var row = 0
//        for line in programChunks{
//            tokens.append([])
//            for chunk in line{
//                if chunk.count == 2 && chunk[0] == "r", let reg = Int(String(chunk[1])){
//                    let temp = Token(type: TokenType.Register, intValue: reg, stringValue: nil, tupleValue: nil)
//                    tokens[row].append(temp)
//                }
//                else if chunk[chunk.count - 1] == ":"{
//                    let temp = Token(type: TokenType.LabelDefinition, intValue: nil, stringValue: String(chunk.prefix(chunk.count - 1)), tupleValue: nil)
//                    tokens[row].append(temp)
//                }
//                else if chunk[0] == "\"" && chunk[chunk.count - 1] == "\""{
//                    let temp = Token(type: TokenType.ImmediateString, intValue: nil, stringValue: chunk, tupleValue: nil)
//                    tokens[row].append(temp)
//                }
//                else if chunk[0] == "\\" && chunk[chunk.count - 1] == "\\", let cs = Int(String(chunk[1])), let ns = Int(String(chunk[5])){
//                    let temp = Token(type: TokenType.ImmediateTuple, intValue: nil, stringValue: nil, tupleValue: Tuple(cs: cs, ic: charToUnicode(chunk[3]), ns: ns, oc: charToUnicode(chunk[7]), dir: String(chunk[9])))
//                    tokens[row].append(temp)
//                }
//                else if chunk[0] == ".", let _ = directives[chunk]{
//                    let temp = Token(type: TokenType.Directive, intValue: nil, stringValue: chunk, tupleValue: nil)
//                    tokens[row].append(temp)
//                }
//                else if let _ = commands[chunk]{
//                    let temp = Token(type: TokenType.Instruction, intValue: nil, stringValue: chunk, tupleValue: nil)
//                    tokens[row].append(temp)
//                }
//                else if chunk[0] == "#", let num = Int(String(chunk.suffix(chunk.count - 1))){
//                    let temp = Token(type: TokenType.ImmediateInteger, intValue: num, stringValue: nil, tupleValue: nil)
//                    tokens[row].append(temp)
//                }
//                else if let _ = Int(String(chunk[0])){
//                    let temp = Token(type: TokenType.BadToken, intValue: nil, stringValue: chunk, tupleValue: nil)
//                    tokens[row].append(temp)
//                }
//                else{
//                    let temp = Token(type: TokenType.Label, intValue: nil, stringValue: chunk, tupleValue: nil)
//                    tokens[row].append(temp)
//                }
//            }
//            row += 1
//        }
//    }
//    
//    func findPointer(token: Token)->Int{
//        let temp = Array(tokens.joined())
//        return temp.firstIndex(where: {$0.stringValue ?? "N/A" == token.stringValue!})!
//    }
//    
//    func createBinary()->String{
//        var test = ""
//        for i in binaryCode{test.append(String(i) + "\n")}
//        return test
//    }
//    
//    func createSymbolFile()->String{
//        var test = ""
//        for (key, value) in symbols{test.append(key + " " + String(value) + "\n")}
//        return test
//    }
//    
//    func makeListingLine(_ codeLine: Int, _ binaryLength: Int)->String{
//        var temp = ""
//        for i in binaryCode.suffix(binaryLength){temp.append(String(i) + " ")}
//        return String(codeLine) + ": " + temp
//    }
//    
//    func isInstructionValid(tokens: [Token])->Bool{
//        let instructionSet = commands[tokens[0].stringValue!]!
//        if instructionSet == "" && tokens.count == 1{return true}
//        if tokens.count - 1 != instructionSet.count{return false}
//        for i in 0..<instructionSet.count{
//            if instructionSet[i] == "r" && tokens[i+1].type != TokenType.Register{return false}
//            else if instructionSet[i] == "i" && tokens[i+1].type != TokenType.ImmediateInteger{return false}
//            else if instructionSet[i] == "m" && tokens[i+1].type != TokenType.Label{return false}
//        }
//        return true
//    }
//    
//    func isDirectiveValid(tokens: [Token])->Bool{
//        let directive = directives[tokens[0].stringValue!]!
//        if directive == "" && tokens.count == 1{return true}
//        if tokens.count != 2{return false}
//        if directive == "String" && tokens[1].type != TokenType.ImmediateString{return false}
//        else if directive == "Integer" && tokens[1].type != TokenType.ImmediateInteger{return false}
//        else if directive == "Label" && tokens[1].type != TokenType.Label{return false}
//        else if directive == "Tuple" && tokens[1].type != TokenType.ImmediateTuple{return false}
//        return true
//    }
//    
//    mutating func handleInstructionLine(tokens: [Token]){
//        if isInstructionValid(tokens: tokens){
//            binaryCode.append(Command.commandFromString(tokens[0].stringValue!)!)
//            if tokens.count > 1{
//                for i in 1..<tokens.count{
//                    if tokens[i].type == TokenType.Register || tokens[i].type == TokenType.ImmediateInteger{binaryCode.append(tokens[i].intValue!)}
//                    if tokens[i].type == TokenType.Label{binaryCode.append(symbols[tokens[i].stringValue!] ?? -1)}
//                }
//            }
//        }
//        else{
//            hasError = true
//            listing.append("........Incorrect usage of instruction\n")
//        }
//    }
//    
//    mutating func handleDirectiveLine(tokens: [Token]){
//        if isDirectiveValid(tokens: tokens){
//            let directive = tokens[0].stringValue!
//            if directive == ".String"{
//                binaryCode.append(tokens[1].stringValue!.count)
//                for char in tokens[1].stringValue!{binaryCode.append(charToUnicode(char))}
//            }
//            if directive == ".Integer"{
//                binaryCode.append(tokens[1].intValue!)
//            }
//            if directive == ".allocate"{
//                for _ in 0..<tokens[1].intValue!{binaryCode.append(0)}
//            }
//            if directive == ".tuple"{
//                binaryCode.append(tokens[1].tupleValue!.currentState)
//                binaryCode.append(tokens[1].tupleValue!.inputCharacter)
//                binaryCode.append(tokens[1].tupleValue!.newState)
//                binaryCode.append(tokens[1].tupleValue!.outputCharacter)
//                binaryCode.append(tokens[1].tupleValue!.direction)
//            }
//            if directive == ".start"{
//                if let test = symbols[tokens[1].stringValue!], test != -1{binaryCode.insert(symbols[tokens[1].stringValue!]!, at: 0)}
//                else{
//                    symbols[tokens[1].stringValue!] = -1
//                    binaryCode.insert(-1, at: 0)
//                }
//            }
//        }else{
//            hasError = true
//            listing.append("........Incorrect usage of directive\n")
//        }
//    }
//    
//    mutating func assemble(){
//        splitChunks()
//        tokenize()
//        if pass1(){
//            print("Code failed to assemble, see .lst file for errors")
//            return
//        }else{
//            pass2()
//            print("Assembled successfully")
//        }
//    }
//    
//    mutating func pass1()->Bool{
//        var codeLine = 0
//        for line in tokens{
//            if codeLine >= programLines.count{continue}
//            listing.append(programLines[codeLine] + "\n")
//            if line.isEmpty{
//                codeLine += 1
//                continue
//            }
//            if line[0].type == TokenType.Instruction{handleInstructionLine(tokens: line)}
//            else if line[0].type == TokenType.Directive{handleDirectiveLine(tokens: line)}
//            else if line[0].type == TokenType.LabelDefinition && line[1].type == TokenType.Instruction{
//                symbols[line[0].stringValue!] = binaryCode.count - 1
//                handleInstructionLine(tokens: Array(line.suffix(from: 1)))
//            }
//            else if line[0].type == TokenType.LabelDefinition && line[1].type == TokenType.Directive{
//                symbols[line[0].stringValue!] = binaryCode.count - 1
//                handleDirectiveLine(tokens: Array(line.suffix(from: 1)))
//            }
//            else{
//                hasError = true
//                listing.append("........No instruction or directive on this line\n")
//            }
//            codeLine += 1
//        }
//        for (key, value) in symbols{
//            if value == -1{
//                hasError = true
//                listing.append("........Label " + key + " was never defined\n")
//            }
//        }
//        writeTextFile(path + file + ".lst", data: listing)
//        return hasError
//    }
//    
//    mutating func pass2(){
//        binaryCode = []
//        listing = ""
//        var codeLine = 0
//        for line in tokens{
//            if codeLine >= programLines.count{continue}
//            if line.isEmpty{
//                listing.append(String(codeLine) + ": \n")
//                codeLine += 1
//                continue
//            }
//            if line[0].type == TokenType.Instruction{
//                handleInstructionLine(tokens: line)
//                listing.append(fit(makeListingLine(codeLine, line.count), 12))
//            }
//            else if line[0].type == TokenType.Directive{
//                handleDirectiveLine(tokens: line)
//                listing.append(fit(makeListingLine(codeLine, 1), 12))
//            }
//            else if line[0].type == TokenType.LabelDefinition && line[1].type == TokenType.Instruction{
//                handleInstructionLine(tokens: Array(line.suffix(from: 1)))
//                listing.append(fit(makeListingLine(codeLine, line.count - 1), 12))
//            }
//            else if line[0].type == TokenType.LabelDefinition && line[1].type == TokenType.Directive{
//                handleDirectiveLine(tokens: Array(line.suffix(from: 1)))
//                listing.append(fit(makeListingLine(codeLine, 1), 12))
//                
//            }
//            listing.append(programLines[codeLine] + "\n")
//            codeLine += 1
//        }
//        binaryCode.insert(binaryCode.count - 1, at: 0)
//        writeTextFile(path + file + ".lst", data: listing)
//        writeTextFile(path + file + ".bin", data: createBinary())
//        writeTextFile(path + file + ".sym", data: createSymbolFile())
//    }
//    
//    mutating func run(){
//        print(uiHelp)
//        while true{
//            print("Enter option...")
//            let input = readLine()
//            if input == "quit"{exit(0)}
//            else if input == "help"{print(uiHelp)}
//            let inputArray = splitStringIntoParts(expression: input!)
//            if inputArray[0] == "path"{path = inputArray[1]}
//            else if inputArray[0] == "asm"{
//                file = inputArray[1]
//                assemble()
//            }
//            else if inputArray[0] == "run"{
//                file = inputArray[1]
//                let vm = sapVM(filePath: path, programName: file)
//                vm.run()
//            }
//            else if inputArray[0] == "printlst"{
//                file = inputArray[1]
//                print(readTextFile(path + file + ".lst").fileText!)
//            }
//            else if inputArray[0] == "printbin"{
//                file = inputArray[1]
//                print(readTextFile(path + file + ".bin").fileText!)
//            }
//            else if inputArray[0] == "printsym"{
//                file = inputArray[1]
//                print(readTextFile(path + file + ".sym").fileText!)
//            }
//            else{print("Unrecognized command. Enter 'help' for a list of commands.")}
//        }
//    }
//}
//
//
//
//
