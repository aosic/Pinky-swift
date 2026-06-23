import Foundation

public struct Colors {
    public static let white = "\u{001B}[0m"
    public static let blue = "\u{001B}[94m"
    public static let cyan = "\u{001B}[96m"
    public static let green = "\u{001B}[92m"
    public static let yellow = "\u{001B}[93m"
    public static let red = "\u{001B}[91m"
}

public func stringify(_ val: Any) -> String {
    if let boolVal = val as? Bool {
        return boolVal ? "true" : "false"
    }
    if let doubleVal = val as? Double {
        if doubleVal == Double(Int(doubleVal)) {
            return String(Int(doubleVal))
        }
    }
    return String(describing: val)
}

public func printAST(_ astText: Stmts) {
    var i = 0
    var newline = false
    let text = String(describing: astText)
    for ch in text {
        if ch == "(" {
            if !newline {
                print("", terminator: "")
            }
            print(ch)
            i += 2
            newline = true
        } else if ch == ")" {
            if !newline {
                print()
            }
            i -= 2
            newline = true
            print(String(repeating: " ", count: i) + String(ch))
        } else {
            if newline {
                print(String(repeating: " ", count: i), terminator: "")
            }
            print(ch, terminator: "")
            newline = false
        }
    }
}

public func lexingError(_ message: String, _ lineno: Int) -> Never {
    print("\(Colors.red)LEXING ERR! [Line \(lineno)]: \(message)\(Colors.white)")
    exit(1)
}

public func parseError(_ message: String, _ lineno: Int) -> Never {
    print("\(Colors.red)PARSE ERR! [Line \(lineno)]: \(message)\(Colors.white)")
    exit(1)
}

public func runtimeError(_ message: String, _ lineno: Int) -> Never {
    print("\(Colors.red)RUNTIME ERR! [Line \(lineno)]: \(message)\(Colors.white)")
    exit(1)
}

public func compileError(_ message: String, _ lineno: Int) -> Never {
    print("\(Colors.red)COMPILE ERR! [Line \(lineno)]: \(message)\(Colors.white)")
    exit(1)
}

public func vmError(_ message: String, _ pc: Int) -> Never {
    print("\(Colors.red)VM ERR! [PC: \(pc)]: \(message)\(Colors.white)")
    exit(1)
}
