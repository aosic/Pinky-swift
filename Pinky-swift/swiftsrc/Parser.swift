import Foundation

public class Parser {
    private let tokens: [Token]
    private var curr: Int = 0
    
    public init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    private func advance() -> Token {
        let token = tokens[curr]
        curr += 1
        return token
    }
    
    private func peek() -> Token {
        return tokens[curr]
    }
    
    private func isNext(_ expectedType: TokenType) -> Bool {
        if curr >= tokens.count {
            return false
        }
        return peek().tokenType == expectedType
    }
    
    @discardableResult
    private func expect(_ expectedType: TokenType) -> Token {
        if curr >= tokens.count {
            parseError("Found \(previousToken().lexeme) at the end of parsing", previousToken().line)
        } else if peek().tokenType == expectedType {
            return advance()
        } else {
            parseError("Expected \(expectedType.rawValue), found '\(peek().lexeme)'.", peek().line)
        }
    }
    
    private func previousToken() -> Token {
        return tokens[curr - 1]
    }
    
    private func match(_ expectedType: TokenType) -> Bool {
        if curr >= tokens.count {
            return false
        }
        if peek().tokenType != expectedType {
            return false
        }
        curr += 1
        return true
    }
    
    private func primary() -> Expr {
        if match(.integer) {
            return IntegerNode(value: Int(previousToken().lexeme)!, line: previousToken().line)
        } else if match(.float) {
            return FloatNode(value: Double(previousToken().lexeme)!, line: previousToken().line)
        } else if match(.true) {
            return BoolNode(value: true, line: previousToken().line)
        } else if match(.false) {
            return BoolNode(value: false, line: previousToken().line)
        } else if match(.string) {
            let lexeme = previousToken().lexeme
            let str = String(lexeme.dropFirst().dropLast())
            return StringNode(value: str, line: previousToken().line)
        } else if match(.lparen) {
            let expr = self.expr()
            if !match(.rparen) {
                parseError("Error: \")\" expected.", previousToken().line)
            }
            return Grouping(value: expr, line: previousToken().line)
        } else {
            let identifier = expect(.identifier)
            if match(.lparen) {
                let args = self.args()
                expect(.rparen)
                return FuncCall(name: identifier.lexeme, args: args, line: previousToken().line)
            } else {
                return Identifier(name: identifier.lexeme, line: previousToken().line)
            }
        }
    }
    
    private func exponent() -> Expr {
        var expr = primary()
        while match(.caret) {
            let op = previousToken()
            let right = exponent()
            expr = BinOp(op: op, left: expr, right: right, line: op.line)
        }
        return expr
    }
    
    private func unary() -> Expr {
        if match(.plus) || match(.minus) || match(.not) {
            let op = previousToken()
            let operand = unary()
            return UnOp(op: op, operand: operand, line: op.line)
        }
        return exponent()
    }
    
    private func modulo() -> Expr {
        var expr = unary()
        if match(.mod) {
            let op = previousToken()
            let right = unary()
            expr = BinOp(op: op, left: expr, right: right, line: op.line)
        }
        return expr
    }
    
    private func multiplication() -> Expr {
        var expr = modulo()
        while match(.star) || match(.slash) {
            let op = previousToken()
            let right = modulo()
            expr = BinOp(op: op, left: expr, right: right, line: op.line)
        }
        return expr
    }
    
    private func addition() -> Expr {
        var expr = multiplication()
        while match(.plus) || match(.minus) {
            let op = previousToken()
            let right = multiplication()
            expr = BinOp(op: op, left: expr, right: right, line: op.line)
        }
        return expr
    }
    
    private func comparison() -> Expr {
        var expr = addition()
        while match(.gt) || match(.ge) || match(.lt) || match(.le) {
            let op = previousToken()
            let right = addition()
            expr = BinOp(op: op, left: expr, right: right, line: op.line)
        }
        return expr
    }
    
    private func equality() -> Expr {
        var expr = comparison()
        while match(.ne) || match(.eqeq) {
            let op = previousToken()
            let right = comparison()
            expr = BinOp(op: op, left: expr, right: right, line: op.line)
        }
        return expr
    }
    
    private func logicalAnd() -> Expr {
        var expr = equality()
        while match(.and) {
            let op = previousToken()
            let right = equality()
            expr = LogicalOp(op: op, left: expr, right: right, line: op.line)
        }
        return expr
    }
    
    private func logicalOr() -> Expr {
        var expr = logicalAnd()
        while match(.or) {
            let op = previousToken()
            let right = logicalAnd()
            expr = LogicalOp(op: op, left: expr, right: right, line: op.line)
        }
        return expr
    }
    
    private func expr() -> Expr {
        return logicalOr()
    }
    
    private func printStmt(_ end: String) -> PrintStmt? {
        if match(.print) || match(.println) {
            let val = expr()
            return PrintStmt(value: val, end: end, line: previousToken().line)
        }
        return nil
    }
    
    private func ifStmt() -> IfStmt {
        expect(.if)
        let test = expr()
        expect(.then)
        let thenStmts = stmts()
        var elseStmts: Stmts? = nil
        if isNext(.else) {
            _ = advance()
            elseStmts = stmts()
        }
        expect(.end)
        return IfStmt(test: test, thenStmts: thenStmts, elseStmts: elseStmts, line: previousToken().line)
    }
    
    private func whileStmt() -> WhileStmt {
        expect(.while)
        let test = expr()
        expect(.do)
        let stmts = stmts()
        expect(.end)
        return WhileStmt(test: test, stmts: stmts, line: previousToken().line)
    }
    
    private func forStmt() -> ForStmt {
        expect(.for)
        let identifier = primary() as! Identifier
        expect(.assign)
        let start = expr()
        expect(.comma)
        let end = expr()
        var step: Expr? = nil
        if isNext(.comma) {
            _ = advance()
            step = expr()
        }
        expect(.do)
        let stmts = stmts()
        expect(.end)
        return ForStmt(ident: identifier, start: start, end: end, step: step, stmts: stmts, line: previousToken().line)
    }
    
    private func params() -> [Param] {
        var params: [Param] = []
        var num = 0
        while !isNext(.rparen) {
            let name = expect(.identifier)
            num += 1
            if num > 255 {
                parseError("Functions cannot have more than 255 parameters.", name.line)
            }
            params.append(Param(name: name.lexeme, line: previousToken().line))
            if !isNext(.rparen) {
                expect(.comma)
            }
        }
        return params
    }
    
    private func args() -> [Expr] {
        var args: [Expr] = []
        while !isNext(.rparen) {
            args.append(expr())
            if !isNext(.rparen) {
                expect(.comma)
            }
        }
        return args
    }
    
    private func funcDecl() -> FuncDecl {
        expect(.func_)
        let name = expect(.identifier)
        expect(.lparen)
        let params = self.params()
        expect(.rparen)
        let stmts = self.stmts()
        expect(.end)
        return FuncDecl(name: name.lexeme, params: params, stmts: stmts, line: previousToken().line)
    }
    
    private func localAssign() -> LocalAssignment {
        expect(.local)
        let left = expr()
        expect(.assign)
        let right = expr()
        return LocalAssignment(left: left, right: right, line: previousToken().line)
    }
    
    private func retStmt() -> RetStmt {
        expect(.ret)
        let value = expr()
        return RetStmt(value: value, line: previousToken().line)
    }
    
    private func stmt() -> Stmt {
        if peek().tokenType == .print {
            return printStmt("")!
        } else if peek().tokenType == .println {
            return printStmt("\n")!
        } else if peek().tokenType == .if {
            return ifStmt()
        } else if peek().tokenType == .while {
            return whileStmt()
        } else if peek().tokenType == .for {
            return forStmt()
        } else if peek().tokenType == .func_ {
            return funcDecl()
        } else if peek().tokenType == .ret {
            return retStmt()
        } else if peek().tokenType == .local {
            return localAssign()
        } else {
            let left = expr()
            if match(.assign) {
                let right = expr()
                return Assignment(left: left, right: right, line: previousToken().line)
            } else {
                return FuncCallStmt(expr: left as! FuncCall)
            }
        }
    }
    
    private func stmts() -> Stmts {
        var stmts: [Stmt] = []
        while curr < tokens.count && !isNext(.else) && !isNext(.end) {
            let stmt = self.stmt()
            stmts.append(stmt)
        }
        return Stmts(stmts: stmts, line: previousToken().line)
    }
    
    private func program() -> Stmts {
        return stmts()
    }
    
    public func parse() -> Stmts {
        return program()
    }
}
