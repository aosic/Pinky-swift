import Foundation

public class Node: CustomStringConvertible {
    public init() {}
    public var description: String {
        return "Node"
    }
}

public class Expr: Node {
    public override init() { super.init() }
}

public class Stmt: Node {
    public override init() { super.init() }
}

public class Decl: Stmt {
    public override init() { super.init() }
}

public class IntegerNode: Expr {
    public let value: Int
    public let line: Int
    
    public init(value: Int, line: Int) {
        self.value = value
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "Integer[\(value)]"
    }
}

public class FloatNode: Expr {
    public let value: Double
    public let line: Int
    
    public init(value: Double, line: Int) {
        self.value = value
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "Float[\(value)]"
    }
}

public class BoolNode: Expr {
    public let value: Bool
    public let line: Int
    
    public init(value: Bool, line: Int) {
        self.value = value
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "Bool[\(value)]"
    }
}

public class StringNode: Expr {
    public let value: String
    public let line: Int
    
    public init(value: String, line: Int) {
        self.value = value
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "String[\(value)]"
    }
}

public class UnOp: Expr {
    public let op: Token
    public let operand: Expr
    public let line: Int
    
    public init(op: Token, operand: Expr, line: Int) {
        self.op = op
        self.operand = operand
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "UnOp(\(op.lexeme), \(operand))"
    }
}

public class LogicalOp: Expr {
    public let op: Token
    public let left: Expr
    public let right: Expr
    public let line: Int
    
    public init(op: Token, left: Expr, right: Expr, line: Int) {
        self.op = op
        self.left = left
        self.right = right
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "LogicalOp(\(op.lexeme), \(left), \(right))"
    }
}

public class Grouping: Expr {
    public let value: Expr
    public let line: Int
    
    public init(value: Expr, line: Int) {
        self.value = value
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "Grouping(\(value))"
    }
}

public class BinOp: Expr {
    public let op: Token
    public let left: Expr
    public let right: Expr
    public let line: Int
    
    public init(op: Token, left: Expr, right: Expr, line: Int) {
        self.op = op
        self.left = left
        self.right = right
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "BinOp(\(op.lexeme), \(left), \(right))"
    }
}

public class Identifier: Expr {
    public let name: String
    public let line: Int
    
    public init(name: String, line: Int) {
        self.name = name
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "Identifier[\(name)]"
    }
}

public class Stmts: Node {
    public let stmts: [Stmt]
    public let line: Int
    
    public init(stmts: [Stmt], line: Int) {
        self.stmts = stmts
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "Stmts(\(stmts))"
    }
}

public class Assignment: Stmt {
    public let left: Expr
    public let right: Expr
    public let line: Int
    
    public init(left: Expr, right: Expr, line: Int) {
        self.left = left
        self.right = right
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "Assignment(\(left), \(right))"
    }
}

public class LocalAssignment: Stmt {
    public let left: Expr
    public let right: Expr
    public let line: Int
    
    public init(left: Expr, right: Expr, line: Int) {
        self.left = left
        self.right = right
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "LocalAssignment(\(left), \(right))"
    }
}

public class IfStmt: Stmt {
    public let test: Expr
    public let thenStmts: Stmts
    public let elseStmts: Stmts?
    public let line: Int
    
    public init(test: Expr, thenStmts: Stmts, elseStmts: Stmts?, line: Int) {
        self.test = test
        self.thenStmts = thenStmts
        self.elseStmts = elseStmts
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "IfStmt(\(test), then:\(thenStmts), else:\(String(describing: elseStmts)))"
    }
}

public class WhileStmt: Stmt {
    public let test: Expr
    public let stmts: Stmts
    public let line: Int
    
    public init(test: Expr, stmts: Stmts, line: Int) {
        self.test = test
        self.stmts = stmts
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "WhileStmt(\(test), do:\(stmts))"
    }
}

public class ForStmt: Stmt {
    public let ident: Identifier
    public let start: Expr
    public let end: Expr
    public let step: Expr?
    public let stmts: Stmts
    public let line: Int
    
    public init(ident: Identifier, start: Expr, end: Expr, step: Expr?, stmts: Stmts, line: Int) {
        self.ident = ident
        self.start = start
        self.end = end
        self.step = step
        self.stmts = stmts
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "ForStmt(\(ident), start:\(start), end:\(end), step:\(String(describing: step)), stmts:\(stmts))"
    }
}

public class PrintStmt: Stmt {
    public let value: Expr
    public let end: String
    public let line: Int
    
    public init(value: Expr, end: String, line: Int) {
        self.value = value
        self.end = end
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "PrintStmt(\(value), end=\(end))"
    }
}

public class FuncDecl: Decl {
    public let name: String
    public let params: [Param]
    public let stmts: Stmts
    public let line: Int
    
    public init(name: String, params: [Param], stmts: Stmts, line: Int) {
        self.name = name
        self.params = params
        self.stmts = stmts
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "FuncDecl(\(name), params:\(params), stmts:\(stmts))"
    }
}

public class Param: Decl {
    public let name: String
    public let line: Int
    
    public init(name: String, line: Int) {
        self.name = name
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "Param[\(name)]"
    }
}

public class FuncCall: Expr {
    public let name: String
    public let args: [Expr]
    public let line: Int
    
    public init(name: String, args: [Expr], line: Int) {
        self.name = name
        self.args = args
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "FuncCall(\(name), args:\(args))"
    }
}

public class FuncCallStmt: Stmt {
    public let expr: FuncCall
    
    public init(expr: FuncCall) {
        self.expr = expr
        super.init()
    }
    
    public override var description: String {
        return "FuncCallStmt(\(expr))"
    }
}

public class RetStmt: Stmt {
    public let value: Expr
    public let line: Int
    
    public init(value: Expr, line: Int) {
        self.value = value
        self.line = line
        super.init()
    }
    
    public override var description: String {
        return "RetStmt[\(value)]"
    }
}
