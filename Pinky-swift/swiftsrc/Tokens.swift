import Foundation

public enum TokenType: String {
    case lparen = "TOK_LPAREN"
    case rparen = "TOK_RPAREN"
    case lcurly = "TOK_LCURLY"
    case rcurly = "TOK_RCURLY"
    case lsquar = "TOK_LSQUAR"
    case rsquar = "TOK_RSQUAR"
    case comma = "TOK_COMMA"
    case dot = "TOK_DOT"
    case plus = "TOK_PLUS"
    case minus = "TOK_MINUS"
    case star = "TOK_STAR"
    case slash = "TOK_SLASH"
    case caret = "TOK_CARET"
    case mod = "TOK_MOD"
    case colon = "TOK_COLON"
    case semicolon = "TOK_SEMICOLON"
    case question = "TOK_QUESTION"
    case not = "TOK_NOT"
    case gt = "TOK_GT"
    case lt = "TOK_LT"
    case eq = "TOK_EQ"
    case ge = "TOK_GE"
    case le = "TOK_LE"
    case ne = "TOK_NE"
    case eqeq = "TOK_EQEQ"
    case assign = "TOK_ASSIGN"
    case gtgt = "TOK_GTGT"
    case ltlt = "TOK_LTLT"
    case identifier = "TOK_IDENTIFIER"
    case string = "TOK_STRING"
    case integer = "TOK_INTEGER"
    case float = "TOK_FLOAT"
    case `if` = "TOK_IF"
    case then = "TOK_THEN"
    case `else` = "TOK_ELSE"
    case `true` = "TOK_TRUE"
    case `false` = "TOK_FALSE"
    case and = "TOK_AND"
    case or = "TOK_OR"
    case local = "TOK_LOCAL"
    case `while` = "TOK_WHILE"
    case `do` = "TOK_DO"
    case `for` = "TOK_FOR"
    case func_ = "TOK_FUNC"
    case null = "TOK_NULL"
    case end = "TOK_END"
    case print = "TOK_PRINT"
    case println = "TOK_PRINTLN"
    case ret = "TOK_RET"
}

public let keywords: [String: TokenType] = [
    "if": .if,
    "else": .else,
    "then": .then,
    "true": .true,
    "false": .false,
    "and": .and,
    "or": .or,
    "local": .local,
    "while": .while,
    "do": .do,
    "for": .for,
    "func": .func_,
    "null": .null,
    "end": .end,
    "print": .print,
    "println": .println,
    "ret": .ret,
]

public struct Token {
    public let tokenType: TokenType
    public let lexeme: String
    public let line: Int
    
    public init(tokenType: TokenType, lexeme: String, line: Int) {
        self.tokenType = tokenType
        self.lexeme = lexeme
        self.line = line
    }
}

extension Token: CustomStringConvertible {
    public var description: String {
        return "(\(tokenType.rawValue), \(lexeme), \(line))"
    }
}
