import Foundation
let ellaPath = "/Users/ella/Desktop/sapProject/"
let izzyPath = "/Users/ishaw/Desktop/sapProject/"

func testSapVM(){
    let dvm : sapVM = sapVM(filePath: ellaPath, programName: "turing") //movxrTest
    dvm.run()
}
testSapVM()

//func testAssm(){
//    var projectName = "turing"
//    var assembler = Assembler(path: ellaPath + projectName + ".txt")
//    assembler.splitChunks()
//    print(assembler.programChunks)
//    assembler.tokenize()
//    print(assembler.tokens)
//}
//testAssm()
