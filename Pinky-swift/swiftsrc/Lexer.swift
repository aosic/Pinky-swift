import Foundation

public class Lexer {
    private let source: String
    private var tokens: [Token] = []
    private var start: String.Index
    private var curr: String.Index
    private var line: Int = 1
    
    public init(source: String) {
        self.source = source
        self.start = source.startIndex
        self.curr = source.startIndex
    }
    
    private func advance() -> Character {
        let ch = source[curr]
        curr = source.index(after: curr)
        return ch
    }
    
    private func peek() -> Character {
        if curr >= source.endIndex {
            return "\0"
        }
        return source[curr]
    }
    
    private func lookahead(_ n: Int = 1) -> Character {
        let idx = source.index(curr, offsetBy: n)
        if idx >= source.endIndex {
            return "\0"
        }
        return source[idx]
    }
    
    private func match(_ expected: Character) -> Bool {
        if curr >= source.endIndex {
            return false
        }
        if source[curr] != expected {
            return false
        }
        curr = source.index(after: curr)
        return true
    }
    
    private func addToken(_ tokenType: TokenType) {
        let lexeme = String(source[start..<curr])
        tokens.append(Token(tokenType: tokenType, lexeme: lexeme, line: line))
    }
    
    private func handleNumber() {
        while peek().isNumber {
            _ = advance()
        }
        if peek() == "." && lookahead().isNumber {
            _ = advance()
            while peek().isNumber {
                _ = advance()
            }
            addToken(.float)
        } else {
            addToken(.integer)
        }
    }
    
    private func handleString(_ quotation: Character) {
        while peek() != quotation && curr < source.endIndex {
            _ = advance()
        }
        if curr >= source.endIndex {
            lexingError("Unterminated string.", line)
        }
        _ = advance()
        addToken(.string)
    }
    
    private func handleIdentifier() {
        while peek().isLetter || peek().isNumber || peek() == "_" {
            _ = advance()
        }
        let text = String(source[start..<curr])
        if let keywordType = keywords[text] {
            addToken(keywordType)
        } else {
            addToken(.identifier)
        }
    }
    
    public func tokenize() -> [Token] {
        while curr < source.endIndex {
            start = curr
            let ch = advance()
            
            if ch == "\n" {
                line += 1
            } else if ch == " " || ch == "\t" || ch == "\r" {
                // skip whitespace
            } else if ch == "(" {
                addToken(.lparen)
            } else if ch == ")" {
                addToken(.rparen)
            } else if ch == "{" {
                addToken(.lcurly)
            } else if ch == "}" {
                addToken(.rcurly)
            } else if ch == "[" {
                addToken(.lsquar)
            } else if ch == "]" {
                addToken(.rsquar)
            } else if ch == "." {
                addToken(.dot)
            } else if ch == "," {
                addToken(.comma)
            } else if ch == "+" {
                addToken(.plus)
            } else if ch == "-" {
                if match("-") {
                    while peek() != "\n" && curr < source.endIndex {
                        _ = advance()
                    }
                } else {
                    addToken(.minus)
                }
            } else if ch == "*" {
                addToken(.star)
            } else if ch == "^" {
                addToken(.caret)
            } else if ch == "/" {
                addToken(.slash)
            } else if ch == ";" {
                addToken(.semicolon)
            } else if ch == "?" {
                addToken(.question)
            } else if ch == "%" {
                addToken(.mod)
            } else if ch == "=" {
                if match("=") {
                    addToken(.eqeq)
                } else {
                    addToken(.eq)
                }
            } else if ch == "~" {
                if match("=") {
                    addToken(.ne)
                } else {
                    addToken(.not)
                }
            } else if ch == "<" {
                if match("=") {
                    addToken(.le)
                } else {
                    addToken(.lt)
                }
            } else if ch == ">" {
                if match("=") {
                    addToken(.ge)
                } else {
                    addToken(.gt)
                }
            } else if ch == ":" {
                if match("=") {
                    addToken(.assign)
                } else {
                    addToken(.colon)
                }
            } else if ch.isNumber {
                handleNumber()
            } else if ch == "\"" || ch == "'" {
                handleString(ch)
            } else if ch.isLetter || ch == "_" {
                handleIdentifier()
            } else {
                lexingError("Error at '\(ch)': Unexpected character.", line)
            }
        }
        return tokens
    }
}
