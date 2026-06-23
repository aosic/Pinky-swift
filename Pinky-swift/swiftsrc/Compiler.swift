import Foundation

public enum SymbolType: String {
    case variable = "SYM_VAR"
    case function = "SYM_FUNC"
}

public class Symbol {
    public let name: String
    public let symtype: SymbolType
    public let depth: Int
    public let arity: Int
    
    public init(name: String, symtype: SymbolType = .variable, depth: Int = 0, arity: Int = 0) {
        self.name = name
        self.symtype = symtype
        self.depth = depth
        self.arity = arity
    }
}

public enum Instruction {
    case push(ValueType, Any)
    case pop
    case add
    case sub
    case mul
    case div
    case exp
    case mod
    case lt
    case gt
    case le
    case ge
    case eq
    case ne
    case and
    case or
    case xor
    case neg
    case label(String)
    case jmp(String)
    case jmpz(String)
    case jsr(String)
    case rts
    case loadGlobal(Int)
    case storeGlobal(Int)
    case loadLocal(Int)
    case storeLocal(Int)
    case setSlot(Int, String)
    case markSlot(Int, String)
    case saveSP(String)
    case restoreSP(String)
    case print
    case println
    case halt
}

public class Compiler {
    private let debugMode: Bool
    private var code: [Instruction] = []
    private var globals: [Symbol] = []
    private var locals: [Symbol] = []
    private var functions: [Symbol] = []
    private var scopeDepth: Int = 0
    private var labelCounter: Int = 0
    
    public init(debugMode: Bool) {
        self.debugMode = debugMode
    }
    
    private func makeLabel() -> String {
        labelCounter += 1
        return "LBL\(labelCounter)"
    }
    
    private func emit(_ instruction: Instruction) {
        code.append(instruction)
    }
    
    private func getFuncSymbol(_ name: String) -> Symbol? {
        for symbol in functions.reversed() {
            if symbol.name == name {
                return symbol
            }
        }
        return nil
    }
    
    private func getVarSymbol(_ name: String) -> (Symbol, Int)? {
        for (index, symbol) in locals.enumerated().reversed() {
            if symbol.name == name {
                return (symbol, index)
            }
        }
        for (index, symbol) in globals.enumerated().reversed() {
            if symbol.name == name {
                return (symbol, index)
            }
        }
        return nil
    }
    
    private func beginBlock() {
        scopeDepth += 1
    }
    
    private func endBlock() {
        scopeDepth -= 1
        var popCount = 0
        while locals.count > 0 && locals.last!.depth > scopeDepth {
            popCount += 1
            locals.removeLast()
        }
        for _ in 0..<popCount {
            emit(.pop)
        }
    }
    
    public func compile(_ node: Node) {
        if let node = node as? IntegerNode {
            let value = Double(node.value)
            emit(.push(.number, value))
        } else if let node = node as? FloatNode {
            emit(.push(.number, node.value))
        } else if let node = node as? BoolNode {
            emit(.push(.bool, node.value))
        } else if let node = node as? StringNode {
            emit(.push(.string, stringify(node.value)))
        } else if let node = node as? BinOp {
            compile(node.left)
            compile(node.right)
            switch node.op.tokenType {
            case .plus: emit(.add)
            case .minus: emit(.sub)
            case .star: emit(.mul)
            case .slash: emit(.div)
            case .caret: emit(.exp)
            case .mod: emit(.mod)
            case .lt: emit(.lt)
            case .gt: emit(.gt)
            case .le: emit(.le)
            case .ge: emit(.ge)
            case .eqeq: emit(.eq)
            case .ne: emit(.ne)
            default: break
            }
        } else if let node = node as? UnOp {
            compile(node.operand)
            if node.op.tokenType == .minus {
                emit(.neg)
            } else if node.op.tokenType == .not {
                emit(.push(.bool, true))
                emit(.xor)
            }
        } else if let node = node as? LogicalOp {
            compile(node.left)
            compile(node.right)
            if node.op.tokenType == .and {
                emit(.and)
            } else if node.op.tokenType == .or {
                emit(.or)
            }
        } else if let node = node as? Grouping {
            compile(node.value)
        } else if let node = node as? PrintStmt {
            compile(node.value)
            if node.end == "" {
                emit(.print)
            } else {
                emit(.println)
            }
        } else if let node = node as? IfStmt {
            compile(node.test)
            let thenLabel = makeLabel()
            let elseLabel = makeLabel()
            let exitLabel = makeLabel()
            emit(.jmpz(elseLabel))
            emit(.label(thenLabel))
            beginBlock()
            compile(node.thenStmts)
            endBlock()
            emit(.jmp(exitLabel))
            emit(.label(elseLabel))
            if let elseStmts = node.elseStmts {
                beginBlock()
                compile(elseStmts)
                endBlock()
            }
            emit(.label(exitLabel))
        } else if let node = node as? WhileStmt {
            let testLabel = makeLabel()
            let bodyLabel = makeLabel()
            let exitLabel = makeLabel()
            emit(.label(testLabel))
            compile(node.test)
            emit(.jmpz(exitLabel))
            emit(.label(bodyLabel))
            beginBlock()
            compile(node.stmts)
            endBlock()
            emit(.jmp(testLabel))
            emit(.label(exitLabel))
        } else if let node = node as? ForStmt {
            // Compile for loop: for i := start, end [, step] do stmts end
            // Supports both ascending (step > 0) and descending (step < 0) loops
            // Python interpreter logic:
            //   if start < end: while i <= end (ascending)
            //   else: while i >= end (descending)
            
            let testLabel = makeLabel()
            let exitLabel = makeLabel()
            
            beginBlock()
            
            // Compile step first and store in local variable
            if let stepExpr = node.step {
                compile(stepExpr)
            } else {
                emit(.push(.number, 1.0))
            }
            let stepSymbol = Symbol(name: "__step_\(node.ident.name)", symtype: .variable, depth: scopeDepth)
            locals.append(stepSymbol)
            let stepSlot = locals.count - 1
            emit(.setSlot(stepSlot, stepSymbol.name))
            
            // Compile start value and store in counter
            compile(node.start)
            let counterSymbol = Symbol(name: node.ident.name, symtype: .variable, depth: scopeDepth)
            locals.append(counterSymbol)
            let counterSlot = locals.count - 1
            emit(.setSlot(counterSlot, counterSymbol.name))
            
            // Test label
            emit(.label(testLabel))
            
            // Check direction: start < end?
            // We need to compare start and end to determine direction
            // But at runtime, we use step sign to determine direction
            // If step > 0: ascending, use counter <= end
            // If step <= 0: descending, use counter >= end
            emit(.loadLocal(stepSlot))
            emit(.push(.number, 0.0))
            emit(.gt)
            
            // If step > 0 (ascending), jump to ascending path
            let ascendLabel = makeLabel()
            emit(.jmpz(ascendLabel))
            
            // Ascending: step > 0, use counter <= end
            emit(.loadLocal(counterSlot))
            compile(node.end)
            emit(.le)
            let bodyLabel = makeLabel()
            emit(.jmp(bodyLabel))
            
            // Descending: step <= 0, use counter >= end
            emit(.label(ascendLabel))
            emit(.loadLocal(counterSlot))
            compile(node.end)
            emit(.ge)
            
            // Body: check condition
            emit(.label(bodyLabel))
            emit(.jmpz(exitLabel))
            
            // Save SP and locals count before body
            let spLabel = "SP_\(bodyLabel)"
            emit(.saveSP(spLabel))
            let localsCountBeforeBody = locals.count
            
            // Compile body
            compile(node.stmts)
            
            // Restore SP after body (clean up body's locals from stack)
            emit(.restoreSP(spLabel))
            // Remove body locals from locals array
            while locals.count > localsCountBeforeBody {
                locals.removeLast()
            }
            
            // Increment/decrement counter: counter = counter + step
            emit(.loadLocal(counterSlot))
            emit(.loadLocal(stepSlot))
            emit(.add)
            emit(.storeLocal(counterSlot))
            
            // Jump back to test
            emit(.jmp(testLabel))
            
            // Exit label
            emit(.label(exitLabel))
            
            // Pop step and counter
            emit(.pop)
            emit(.pop)
            // Remove step and counter from locals
            locals.removeLast()
            locals.removeLast()
            // Match the beginBlock at the start of for loop
            scopeDepth -= 1
        } else if let node = node as? Stmts {
            for stmt in node.stmts {
                compile(stmt)
            }
        } else if let node = node as? Assignment {
            compile(node.right)
            let leftId = node.left as! Identifier
            if let symbol = getVarSymbol(leftId.name) {
                let sym = symbol.0
                let slot = symbol.1
                if sym.depth == 0 {
                    emit(.storeGlobal(slot))
                } else {
                    emit(.storeLocal(slot))
                }
            } else {
                let newSymbol = Symbol(name: leftId.name, symtype: .variable, depth: scopeDepth)
                if scopeDepth == 0 {
                    globals.append(newSymbol)
                    let newGlobalSlot = globals.count - 1
                    emit(.storeGlobal(newGlobalSlot))
                } else {
                    locals.append(newSymbol)
                    let slot = locals.count - 1
                    emit(.setSlot(slot, newSymbol.name))
                }
            }
        } else if let node = node as? LocalAssignment {
            compile(node.right)
            let leftId = node.left as! Identifier
            let newSymbol = Symbol(name: leftId.name, symtype: .variable, depth: scopeDepth)
            locals.append(newSymbol)
            let slot = locals.count - 1
            emit(.setSlot(slot, newSymbol.name))
        } else if let node = node as? Identifier {
            guard let symbol = getVarSymbol(node.name) else {
                compileError("Variable \(node.name) is not defined.", node.line)
            }
            let sym = symbol.0
            let slot = symbol.1
            if sym.depth == 0 {
                emit(.loadGlobal(slot))
            } else {
                emit(.loadLocal(slot))
            }
        } else if let node = node as? FuncDecl {
            if getVarSymbol(node.name) != nil {
                compileError("A variable with the name \(node.name) was already defined in the scope.", node.line)
            }
            if getFuncSymbol(node.name) != nil {
                compileError("A function with the name \(node.name) was already declared.", node.line)
            }
            let newFunc = Symbol(name: node.name, symtype: .function, depth: scopeDepth, arity: node.params.count)
            functions.append(newFunc)
            let endLabel = makeLabel()
            emit(.jmp(endLabel))
            emit(.label(newFunc.name))
            beginBlock()
            for param in node.params {
                let newSymbol = Symbol(name: param.name, symtype: .variable, depth: scopeDepth)
                locals.append(newSymbol)
                let slot = locals.count - 1
                emit(.markSlot(slot, newSymbol.name))
            }
            compile(node.stmts)
            endBlock()
            emit(.push(.number, 0.0))
            emit(.rts)
            emit(.label(endLabel))
        } else if let node = node as? FuncCall {
            guard let funcSymbol = getFuncSymbol(node.name) else {
                compileError("Not found declaration for function \(node.name).", node.line)
            }
            if funcSymbol.arity != node.args.count {
                compileError("Function expected \(funcSymbol.arity) but \(node.args.count) args were passed.", node.line)
            }
            for arg in node.args {
                compile(arg)
            }
            emit(.push(.number, Double(node.args.count)))
            emit(.jsr(node.name))
        } else if let node = node as? RetStmt {
            compile(node.value)
            emit(.rts)
        } else if let node = node as? FuncCallStmt {
            compile(node.expr)
            emit(.pop)
        }
    }
    
    public func generateCode(_ node: Node) -> [Instruction] {
        emit(.label("START"))
        compile(node)
        emit(.halt)
        return code
    }
    
    public func printCode() {
        for instruction in code {
            switch instruction {
            case .label(let name):
                print("\(name):")
            case .push(_, let value):
                print("    PUSH \(stringify(value))")
            case .pop:
                print("    POP")
            case .add:
                print("    ADD")
            case .sub:
                print("    SUB")
            case .mul:
                print("    MUL")
            case .div:
                print("    DIV")
            case .exp:
                print("    EXP")
            case .mod:
                print("    MOD")
            case .lt:
                print("    LT")
            case .gt:
                print("    GT")
            case .le:
                print("    LE")
            case .ge:
                print("    GE")
            case .eq:
                print("    EQ")
            case .ne:
                print("    NE")
            case .and:
                print("    AND")
            case .or:
                print("    OR")
            case .xor:
                print("    XOR")
            case .neg:
                print("    NEG")
            case .jmp(let name):
                print("    JMP \(name)")
            case .jmpz(let name):
                print("    JMPZ \(name)")
            case .jsr(let name):
                print("    JSR \(name)")
            case .rts:
                print("    RTS")
            case .loadGlobal(let slot):
                print("    LOAD_GLOBAL \(slot)")
            case .storeGlobal(let slot):
                print("    STORE_GLOBAL \(slot)")
            case .loadLocal(let slot):
                print("    LOAD_LOCAL \(slot)")
            case .storeLocal(let slot):
                print("    STORE_LOCAL \(slot)")
            case .setSlot(let slot, let name):
                print("    SET_SLOT \(slot) (\(name))")
            case .markSlot(let slot, let name):
                print("    MARK_SLOT \(slot) (\(name))")
            case .saveSP(let name):
                print("    SAVE_SP \(name)")
            case .restoreSP(let name):
                print("    RESTORE_SP \(name)")
            case .print:
                print("    PRINT")
            case .println:
                print("    PRINTLN")
            case .halt:
                print("    HALT")
            }
        }
    }
}
