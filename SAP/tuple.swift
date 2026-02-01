import Foundation

struct Tuple: CustomStringConvertible{
    let currentState: Int
    let inputCharacter: Int
    let newState: Int
    let outputCharacter: Int
    let direction: Int
    
    init(cs: Int, ic: Int, ns: Int, oc: Int, dir: Int) {
        self.currentState = cs
        self.inputCharacter = ic
        self.newState = ns
        self.outputCharacter = oc
        self.direction = dir
    }
    
    var description: String{
        var total = "Current State: " + String(currentState)
        total += " Input Character: " + String(inputCharacter) + " New State: "
        total += String(newState) + " Output Character: " + String(outputCharacter) + " Direction: " + String(direction)
        return total
    }
}
