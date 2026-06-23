import Foundation

public class Frame {
    public let name: String
    public let retPC: Int
    public let fp: Int
    
    public init(name: String, retPC: Int, fp: Int) {
        self.name = name
        self.retPC = retPC
        self.fp = fp
    }
}

public class VM {
    private var stack: [(ValueType, Any)] = []
    private var frames: [Frame] = []
    private var labels: [String: Int] = [:]
    private var globals: [Int: (ValueType, Any)] = [:]
    private var spSaveTable: [String: Int] = [:]
    private var pc: Int = 0
    private var sp: Int = 0
    private var isRunning: Bool = false
    
    public init() {}
    
    private func createLabelTable(_ instructions: [Instruction]) {
        labels = [:]
        var pc = 0
        for instruction in instructions {
            if case .label(let name) = instruction {
                labels[name] = pc
            }
            pc += 1
        }
    }
    
    public func run(_ instructions: [Instruction]) {
        isRunning = true
        createLabelTable(instructions)
        
        while isRunning {
            let instruction = instructions[pc]
            pc += 1
            
            switch instruction {
            case .halt:
                HALT()
            case .label:
                break
            case .push(let type, let value):
                PUSH(type, value)
            case .pop:
                _ = POP()
            case .add:
                ADD()
            case .sub:
                SUB()
            case .mul:
                MUL()
            case .div:
                DIV()
            case .exp:
                EXP()
            case .mod:
                MOD()
            case .and:
                AND()
            case .or:
                OR()
            case .xor:
                XOR()
            case .neg:
                NEG()
            case .lt:
                LT()
            case .gt:
                GT()
            case .le:
                LE()
            case .ge:
                GE()
            case .eq:
                EQ()
            case .ne:
                NE()
            case .jmp(let name):
                JMP(name)
            case .jmpz(let name):
                JMPZ(name)
            case .jsr(let label):
                JSR(label)
            case .rts:
                RTS()
            case .loadGlobal(let slot):
                LOAD_GLOBAL(slot)
            case .storeGlobal(let slot):
                STORE_GLOBAL(slot)
            case .loadLocal(let slot):
                LOAD_LOCAL(slot)
            case .storeLocal(let slot):
                STORE_LOCAL(slot)
            case .setSlot:
                break
            case .markSlot:
                break
            case .saveSP(let name):
                spSaveTable[name] = sp
            case .restoreSP(let name):
                if let savedSP = spSaveTable[name] {
                    while sp > savedSP && stack.count > 0 {
                        stack.removeLast()
                        sp -= 1
                    }
                }
            case .print:
                PRINT("")
            case .println:
                PRINT("\n")
            }
        }
    }
    
    private func HALT() {
        isRunning = false
    }
    
    private func PUSH(_ type: ValueType, _ value: Any) {
        stack.append((type, value))
        sp += 1
    }
    
    @discardableResult
    private func POP() -> (ValueType, Any) {
        sp -= 1
        return stack.removeLast()
    }
    
    private func ADD() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.number, (leftVal as! Double) + (rightVal as! Double))
        } else if leftType == .string || rightType == .string {
            PUSH(.string, stringify(leftVal) + stringify(rightVal))
        } else {
            vmError("Error on ADD between \(leftType) and \(rightType).", pc - 1)
        }
    }
    
    private func SUB() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.number, (leftVal as! Double) - (rightVal as! Double))
        } else {
            vmError("Error on SUB between \(leftType) and \(rightType).", pc - 1)
        }
    }
    
    private func MUL() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.number, (leftVal as! Double) * (rightVal as! Double))
        } else {
            vmError("Error on MUL between \(leftType) and \(rightType).", pc - 1)
        }
    }
    
    private func DIV() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.number, (leftVal as! Double) / (rightVal as! Double))
        } else {
            vmError("Error on DIV between \(leftType) and \(rightType).", pc - 1)
        }
    }
    
    private func EXP() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.number, pow(leftVal as! Double, rightVal as! Double))
        } else {
            vmError("Error on EXP between \(leftType) and \(rightType).", pc - 1)
        }
    }
    
    private func MOD() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            let a = leftVal as! Double
            let b = rightVal as! Double
            // Python-style modulo: result has same sign as divisor
            let result = a - floor(a / b) * b
            PUSH(.number, result)
        } else {
            vmError("Error on MOD between \(leftType) and \(rightType).", pc - 1)
        }
    }
    
    private func AND() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.number, Double(Int(leftVal as! Double) & Int(rightVal as! Double)))
        } else if leftType == .bool && rightType == .bool {
            PUSH(.bool, (leftVal as! Bool) && (rightVal as! Bool))
        } else {
            vmError("Error on AND between \(leftType) and \(rightType)", pc - 1)
        }
    }
    
    private func OR() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.number, Double(Int(leftVal as! Double) | Int(rightVal as! Double)))
        } else if leftType == .bool && rightType == .bool {
            PUSH(.bool, (leftVal as! Bool) || (rightVal as! Bool))
        } else {
            vmError("Error on OR between \(leftType) and \(rightType)", pc - 1)
        }
    }
    
    private func XOR() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.number, Double(Int(leftVal as! Double) ^ Int(rightVal as! Double)))
        } else if leftType == .bool && rightType == .bool {
            PUSH(.bool, (leftVal as! Bool) != (rightVal as! Bool))
        } else {
            vmError("Error on XOR between \(leftType) and \(rightType)", pc - 1)
        }
    }
    
    private func NEG() {
        let (operandType, operand) = POP()
        if operandType == .number {
            PUSH(.number, -(operand as! Double))
        } else {
            vmError("Error on NEG between \(operandType)", pc - 1)
        }
    }
    
    private func LT() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.bool, (leftVal as! Double) < (rightVal as! Double))
        } else if leftType == .string && rightType == .string {
            PUSH(.bool, (leftVal as! String) < (rightVal as! String))
        } else {
            vmError("Error on LT between \(leftType) and \(rightType)", pc - 1)
        }
    }
    
    private func GT() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.bool, (leftVal as! Double) > (rightVal as! Double))
        } else if leftType == .string && rightType == .string {
            PUSH(.bool, (leftVal as! String) > (rightVal as! String))
        } else {
            vmError("Error on GT between \(leftType) and \(rightType)", pc - 1)
        }
    }
    
    private func LE() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.bool, (leftVal as! Double) <= (rightVal as! Double))
        } else if leftType == .string && rightType == .string {
            PUSH(.bool, (leftVal as! String) <= (rightVal as! String))
        } else {
            vmError("Error on LE between \(leftType) and \(rightType)", pc - 1)
        }
    }
    
    private func GE() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.bool, (leftVal as! Double) >= (rightVal as! Double))
        } else if leftType == .string && rightType == .string {
            PUSH(.bool, (leftVal as! String) >= (rightVal as! String))
        } else {
            vmError("Error on GE between \(leftType) and \(rightType)", pc - 1)
        }
    }
    
    private func EQ() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.bool, (leftVal as! Double) == (rightVal as! Double))
        } else if leftType == .string && rightType == .string {
            PUSH(.bool, (leftVal as! String) == (rightVal as! String))
        } else if leftType == .bool && rightType == .bool {
            PUSH(.bool, (leftVal as! Bool) == (rightVal as! Bool))
        } else {
            vmError("Error on EQ between \(leftType) and \(rightType)", pc - 1)
        }
    }
    
    private func NE() {
        let (rightType, rightVal) = POP()
        let (leftType, leftVal) = POP()
        if leftType == .number && rightType == .number {
            PUSH(.bool, (leftVal as! Double) != (rightVal as! Double))
        } else if leftType == .string && rightType == .string {
            PUSH(.bool, (leftVal as! String) != (rightVal as! String))
        } else if leftType == .bool && rightType == .bool {
            PUSH(.bool, (leftVal as! Bool) != (rightVal as! Bool))
        } else {
            vmError("Error on NE between \(leftType) and \(rightType)", pc - 1)
        }
    }
    
    private func JMP(_ name: String) {
        pc = labels[name]!
    }
    
    private func JMPZ(_ name: String) {
        let (_, val) = POP()
        if let numVal = val as? Double, numVal == 0 {
            JMP(name)
        } else if let boolVal = val as? Bool, !boolVal {
            JMP(name)
        }
    }
    
    private func JSR(_ label: String) {
        let (_, numargs) = POP()
        let numArgs = Int(numargs as! Double)
        let basePointer = sp - numArgs
        let newFrame = Frame(name: label, retPC: pc, fp: basePointer)
        frames.append(newFrame)
        pc = labels[label]!
    }
    
    private func RTS() {
        let result = stack[sp - 1]
        while sp > frames.last!.fp {
            _ = POP()
        }
        PUSH(result.0, result.1)
        pc = frames.last!.retPC
        frames.removeLast()
    }
    
    private func LOAD_GLOBAL(_ slot: Int) {
        if let value = globals[slot] {
            PUSH(value.0, value.1)
        }
    }
    
    private func STORE_GLOBAL(_ slot: Int) {
        globals[slot] = POP()
    }
    
    private func LOAD_LOCAL(_ slot: Int) {
        var actualSlot = slot
        if frames.count > 0 {
            actualSlot += frames.last!.fp
        }
        if actualSlot < stack.count {
            let value = stack[actualSlot]
            PUSH(value.0, value.1)
        }
    }
    
    private func STORE_LOCAL(_ slot: Int) {
        var actualSlot = slot
        if frames.count > 0 {
            actualSlot += frames.last!.fp
        }
        if actualSlot < stack.count {
            stack[actualSlot] = POP()
        }
    }
    
    private func PRINT(_ end: String) {
        let (_, val) = POP()
        let str = stringify(val)
        let unescaped = str.replacingOccurrences(of: "\\n", with: "\n")
                            .replacingOccurrences(of: "\\t", with: "\t")
        print(unescaped, terminator: end)
    }
}
