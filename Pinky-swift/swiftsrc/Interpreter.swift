import Foundation

public class ReturnError: Error {
    public let value: (ValueType, Any)
    
    public init(value: (ValueType, Any)) {
        self.value = value
    }
}

public class Interpreter {
    public init() {}
    
    public func interpret(_ node: Node, _ env: Environment) -> (ValueType, Any)? {
        if let node = node as? IntegerNode {
            return (.number, Double(node.value))
        } else if let node = node as? FloatNode {
            return (.number, node.value)
        } else if let node = node as? BoolNode {
            return (.bool, node.value)
        } else if let node = node as? StringNode {
            return (.string, node.value)
        } else if let node = node as? Grouping {
            return interpret(node.value, env)
        } else if let node = node as? Identifier {
            guard let value = env.getVar(node.name) else {
                runtimeError("Undeclared identifier '\(node.name)'", node.line)
            }
            if value.1 is NSNull {
                runtimeError("Uninitialized identifier '\(node.name)'", node.line)
            }
            return value
        } else if let node = node as? Assignment {
            let (rightType, rightVal) = interpret(node.right, env)!
            let leftId = node.left as! Identifier
            env.setVar(leftId.name, (rightType, rightVal))
            return nil
        } else if let node = node as? LocalAssignment {
            let (rightType, rightVal) = interpret(node.right, env)!
            let leftId = node.left as! Identifier
            env.setLocal(leftId.name, (rightType, rightVal))
            return nil
        } else if let node = node as? BinOp {
            let (leftType, leftVal) = interpret(node.left, env)!
            let (rightType, rightVal) = interpret(node.right, env)!
            
            if node.op.tokenType == .plus {
                if leftType == .number && rightType == .number {
                    return (.number, (leftVal as! Double) + (rightVal as! Double))
                } else if leftType == .string || rightType == .string {
                    return (.string, stringify(leftVal) + stringify(rightVal))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .minus {
                if leftType == .number && rightType == .number {
                    return (.number, (leftVal as! Double) - (rightVal as! Double))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .star {
                if leftType == .number && rightType == .number {
                    return (.number, (leftVal as! Double) * (rightVal as! Double))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .slash {
                if (rightVal as! Double) == 0 {
                    runtimeError("Division by zero.", node.line)
                }
                if leftType == .number && rightType == .number {
                    return (.number, (leftVal as! Double) / (rightVal as! Double))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .mod {
                if leftType == .number && rightType == .number {
                    let a = leftVal as! Double
                    let b = rightVal as! Double
                    // Python-style modulo: result has same sign as divisor
                    let result = a - floor(a / b) * b
                    return (.number, result)
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .caret {
                if leftType == .number && rightType == .number {
                    return (.number, pow(leftVal as! Double, rightVal as! Double))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .gt {
                if leftType == .number && rightType == .number {
                    return (.bool, (leftVal as! Double) > (rightVal as! Double))
                } else if leftType == .string && rightType == .string {
                    return (.bool, (leftVal as! String) > (rightVal as! String))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .ge {
                if leftType == .number && rightType == .number {
                    return (.bool, (leftVal as! Double) >= (rightVal as! Double))
                } else if leftType == .string && rightType == .string {
                    return (.bool, (leftVal as! String) >= (rightVal as! String))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .lt {
                if leftType == .number && rightType == .number {
                    return (.bool, (leftVal as! Double) < (rightVal as! Double))
                } else if leftType == .string && rightType == .string {
                    return (.bool, (leftVal as! String) < (rightVal as! String))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .le {
                if leftType == .number && rightType == .number {
                    return (.bool, (leftVal as! Double) <= (rightVal as! Double))
                } else if leftType == .string && rightType == .string {
                    return (.bool, (leftVal as! String) <= (rightVal as! String))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .eqeq {
                if leftType == .number && rightType == .number {
                    return (.bool, (leftVal as! Double) == (rightVal as! Double))
                } else if leftType == .string && rightType == .string {
                    return (.bool, (leftVal as! String) == (rightVal as! String))
                } else if leftType == .bool && rightType == .bool {
                    return (.bool, (leftVal as! Bool) == (rightVal as! Bool))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            } else if node.op.tokenType == .ne {
                if leftType == .number && rightType == .number {
                    return (.bool, (leftVal as! Double) != (rightVal as! Double))
                } else if leftType == .string && rightType == .string {
                    return (.bool, (leftVal as! String) != (rightVal as! String))
                } else if leftType == .bool && rightType == .bool {
                    return (.bool, (leftVal as! Bool) != (rightVal as! Bool))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' between \(leftType) and \(rightType).", node.op.line)
                }
            }
        } else if let node = node as? LogicalOp {
            let (leftType, leftVal) = interpret(node.left, env)!
            if node.op.tokenType == .or {
                if (leftVal as! Bool) {
                    return (leftType, leftVal)
                }
            } else if node.op.tokenType == .and {
                if !(leftVal as! Bool) {
                    return (leftType, leftVal)
                }
            }
            return interpret(node.right, env)
        } else if let node = node as? UnOp {
            let (operandType, operandVal) = interpret(node.operand, env)!
            
            if node.op.tokenType == .plus {
                if operandType == .number {
                    return (.number, operandVal)
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' with \(operandType).", node.op.line)
                }
            } else if node.op.tokenType == .minus {
                if operandType == .number {
                    return (.number, -(operandVal as! Double))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' with \(operandType).", node.op.line)
                }
            } else if node.op.tokenType == .not {
                if operandType == .bool {
                    return (.bool, !(operandVal as! Bool))
                } else {
                    runtimeError("Unsupported operator '\(node.op.lexeme)' with \(operandType).", node.op.line)
                }
            }
        } else if let node = node as? Stmts {
            for stmt in node.stmts {
                _ = interpret(stmt, env)
            }
        } else if let node = node as? PrintStmt {
            let (_, exprVal) = interpret(node.value, env)!
            let str = stringify(exprVal)
            let unescaped = str.replacingOccurrences(of: "\\n", with: "\n")
                                .replacingOccurrences(of: "\\t", with: "\t")
            print(unescaped, terminator: node.end)
        } else if let node = node as? IfStmt {
            let (testType, testVal) = interpret(node.test, env)!
            if testType != .bool {
                runtimeError("Condition test is not a boolean expression.", node.line)
            }
            if (testVal as! Bool) {
                _ = interpret(node.thenStmts, env.newEnv())
            } else if let elseStmts = node.elseStmts {
                _ = interpret(elseStmts, env.newEnv())
            }
        } else if let node = node as? WhileStmt {
            let newEnv = env.newEnv()
            while true {
                let (testType, testVal) = interpret(node.test, env)!
                if testType != .bool {
                    runtimeError("Condition test is not a boolean expression.", node.line)
                }
                if !(testVal as! Bool) {
                    break
                }
                _ = interpret(node.stmts, newEnv)
            }
        } else if let node = node as? ForStmt {
            let varname = node.ident.name
            let (_, iVal) = interpret(node.start, env)!
            let (_, endVal) = interpret(node.end, env)!
            var i = iVal as! Double
            let end = endVal as! Double
            let newEnv = env.newEnv()
            if i < end {
                var step = 1.0
                if let stepExpr = node.step {
                    let (_, stepVal) = interpret(stepExpr, env)!
                    step = stepVal as! Double
                }
                while i <= end {
                    env.setVar(varname, (.number, i))
                    _ = interpret(node.stmts, newEnv)
                    i += step
                }
            } else {
                var step = -1.0
                if let stepExpr = node.step {
                    let (_, stepVal) = interpret(stepExpr, env)!
                    step = stepVal as! Double
                }
                while i >= end {
                    env.setVar(varname, (.number, i))
                    _ = interpret(node.stmts, newEnv)
                    i += step
                }
            }
        } else if let node = node as? FuncDecl {
            env.setFunc(node.name, (node, env))
        } else if let node = node as? FuncCall {
            guard let funcData = env.getFunc(node.name) else {
                runtimeError("Function '\(node.name)' not declared.", node.line)
            }
            let funcDecl = funcData.0
            let funcEnv = funcData.1
            
            if node.args.count != funcDecl.params.count {
                runtimeError("Function '\(funcDecl.name)' expected \(funcDecl.params.count) param(s) but \(node.args.count) arg(s) were passed.", node.line)
            }
            
            var args: [(ValueType, Any)] = []
            for arg in node.args {
                args.append(interpret(arg, env)!)
            }
            
            let newFuncEnv = funcEnv.newEnv()
            for (param, argVal) in zip(funcDecl.params, args) {
                newFuncEnv.setLocal(param.name, argVal)
            }
            
            do {
                _ = try interpretThrows(funcDecl.stmts, newFuncEnv)
                return (.number, 0.0)
            } catch let error as ReturnError {
                return error.value
            } catch {
                return nil
            }
        } else if let node = node as? RetStmt {
            do {
                throw ReturnError(value: interpret(node.value, env)!)
            } catch {
                return nil
            }
        } else if let node = node as? FuncCallStmt {
            _ = interpret(node.expr, env)
        }
        return nil
    }
    
    private func interpretThrows(_ node: Node, _ env: Environment) throws -> (ValueType, Any)? {
        if let node = node as? RetStmt {
            throw ReturnError(value: interpret(node.value, env)!)
        } else if let node = node as? Stmts {
            for stmt in node.stmts {
                _ = try interpretThrows(stmt, env)
            }
        } else if let node = node as? IfStmt {
            let (testType, testVal) = interpret(node.test, env)!
            if testType != .bool {
                runtimeError("Condition test is not a boolean expression.", node.line)
            }
            if (testVal as! Bool) {
                _ = try interpretThrows(node.thenStmts, env.newEnv())
            } else if let elseStmts = node.elseStmts {
                _ = try interpretThrows(elseStmts, env.newEnv())
            }
        } else if let node = node as? WhileStmt {
            let newEnv = env.newEnv()
            while true {
                let (testType, testVal) = interpret(node.test, env)!
                if testType != .bool {
                    runtimeError("Condition test is not a boolean expression.", node.line)
                }
                if !(testVal as! Bool) {
                    break
                }
                _ = try interpretThrows(node.stmts, newEnv)
            }
        } else if let node = node as? FuncCall {
            guard let funcData = env.getFunc(node.name) else {
                runtimeError("Function '\(node.name)' not declared.", node.line)
            }
            let funcDecl = funcData.0
            let funcEnv = funcData.1
            
            if node.args.count != funcDecl.params.count {
                runtimeError("Function '\(funcDecl.name)' expected \(funcDecl.params.count) param(s) but \(node.args.count) arg(s) were passed.", node.line)
            }
            
            var args: [(ValueType, Any)] = []
            for arg in node.args {
                args.append(interpret(arg, env)!)
            }
            
            let newFuncEnv = funcEnv.newEnv()
            for (param, argVal) in zip(funcDecl.params, args) {
                newFuncEnv.setLocal(param.name, argVal)
            }
            
            do {
                _ = try interpretThrows(funcDecl.stmts, newFuncEnv)
                return (.number, 0.0)
            } catch let error as ReturnError {
                return error.value
            }
        } else {
            return interpret(node, env)
        }
        return nil
    }
    
    public func interpretAST(_ node: Node) {
        let env = Environment()
        _ = interpret(node, env)
    }
}
