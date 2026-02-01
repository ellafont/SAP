import Foundation

func charToUnicode(_ c: Character)->Int{
    let s = String(c)
    return Int(s.unicodeScalars[s.unicodeScalars.startIndex].value)
}

func unicodeToChar(_ n: Int)->Character{
    return Character(UnicodeScalar(n)!)
}

//path Users/yourName/Desktop/sapProject/  dont put file name
func readBinaryFile(path: String, fileName: String)->[Int]{
    let filePath = "\(path)\(fileName)"
    var binary : [Int] = []
    if let fileText = readTextFile(filePath).fileText{
        //print(fileText)
        binary = splitStringIntoLines(expression: fileText).map{Int($0) ?? 0}
    } else {
        print(readTextFile(filePath).message!)
        binary.append(2)
        binary.append(0)
        binary.append(0)
    }
    return binary
}

func readSymbolTable(path: String, fileName: String)->[String:Int]{
    let filePath = "\(path)\(fileName)"
    var table : [String:Int] = [:]
    if let fileText = readTextFile(filePath).fileText{
        let lines : [String] = splitStringIntoLines(expression: fileText)
        for l in lines{
            var parts = splitStringIntoParts(expression: l)
            table[parts[0]] = Int(parts[1]) ?? 0
        }
    } else {
        print(readTextFile(filePath).message!)
    }
    print(table)
    return table
}

func splitStringIntoParts(expression: String)->[String]{
    return expression.split{$0 == " "}.map{ String($0) }
}

func splitStringIntoLines(expression: String)->[String]{
    return expression.split{$0 == "\n"}.map{ String($0) }
}

//Functions to perform actual i/o from console and filesystem

func readTextFile(_ path: String)->(message: String?, fileText: String?){
    let text: String
    do {
        text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
    }
    catch {
        return ("\(error)", nil)
    }
    return (nil, text)
}

func writeTextFile(_ path: String, data: String)->String? {
    let url = NSURL.fileURL(withPath: path)
    do {
        try data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
    } catch let error as NSError {
        return "Failed writing to URL: \(url), Error: " + error.localizedDescription
    }
    return nil
}

struct Stack<Element> : CustomStringConvertible, Sequence{
    let size: Int
    let initial: Element
    var stack = [Element]()
    var totalItems : Int
    
    init(size: Int, initial: Element){
        self.size = size
        self.initial = initial
        self.stack = Array(repeating: initial, count: size)
        self.totalItems = 0
    }
    
    func isEmpty()->Bool{
        if totalItems == 0{
            return true
        }
        return false
    }
    func isFull()->Bool{
        if totalItems == size{
            return true
        }
        return false
    }
    mutating func push(_ element: Element){
        if isFull() == false{
            stack[totalItems] = element
            totalItems += 1
        }
    }
    mutating func pop()->Element?{
        if isEmpty() == false{
            totalItems -= 1
            return stack[totalItems];
        }
        else{return nil}
    }
    
    var description: String{
        var s = "Stack:\n"
        for element in self{
            s += "\(element) "
        }
        if isEmpty() == true{
            s += "*empty stack*"
        }
        else{
            s += "<-Top"
        }
        s += "\n"
        return s
    }
    
    func makeIterator() -> StackIterator<Element> {
        return StackIterator(self)
    }
}

struct StackIterator<Element>: IteratorProtocol{
    var count = -1
    var data: [Element]
    init(_ stack: Stack<Element>){
        data = Array(repeating: stack.initial, count: stack.totalItems) //no empty spots
        for i in 0..<stack.totalItems{
            data[i] = stack.stack[i]
        }
    }
    mutating func next() -> Element? {
        count += 1
        if count < data.count{
            return data[count]
        }
        return nil
    }
}

extension Collection where Element: Equatable {
    func indexDistance(of element: Element) -> Int? {
        guard let index = firstIndex(of: element) else { return nil }
        return distance(from: startIndex, to: index)
    }
}
//extension StringProtocol {
//    func indexDistance(of string: Self) -> Int? {
//        guard let index = range(of: string)?.lowerBound else { return nil }
//        return distance(from: startIndex, to: index)
//    }
//}

extension String {
    subscript(index: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return self[charIndex]
    }
    
    subscript(range: Range<Int>) -> Substring {
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
        return self[startIndex..<stopIndex]
    }
    
    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {return self}
        return String(self.dropFirst(prefix.count))
    }
}

extension String {
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
}

func fitI(_ i: Int, _ size: Int, right: Bool = false)-> String{
    let iAsString = "\(i)"
    let newLength = iAsString.count
    return fit(iAsString, newLength > size ? newLength : size, right: right)
}

func fit(_ s: String, _ size: Int, right: Bool = true)-> String{
    var result = ""
    let sSize = s.count
    if sSize == size{return s}
    var count = 0
    if size < sSize{
        for c in s{
            if count < size {result.append(c)}
            count += 1
        }
        return result
    }
    result = s
    var addon = ""
    let num = size - sSize
    for _ in 0..<num {addon.append(" ")}
    if right {return result + addon}
    return addon + result
}



