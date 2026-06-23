import Foundation

let VERBOSE = true
let PRINT_SOURCE = true
let PRINT_LEXER = true
let PRINT_PARSER = true
let PRINT_COMPILER = true
let DEBUG_MODE_COMPILER = true

//@main
struct PinkyMain {
    static func main() {
    let args = CommandLine.arguments
    if args.count != 2 {
        print("Usage: PinkyCompiler <filename>")
        exit(1)
    }
    
    let filename = args[1]
    
    do {
        let source = try String(contentsOfFile: filename, encoding: .utf8)
        
        print()
        print("\(Colors.green)* * * PINKY COMPILER * * *\(Colors.white)")
        print("\(Colors.green)Running \(filename)\(Colors.white)")
        
        if PRINT_SOURCE {
            print()
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print("\(Colors.green)SOURCE:\(Colors.white)")
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print(source)
        }
        
        let tokens = Lexer(source: source).tokenize()
        if PRINT_LEXER {
            print()
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print("\(Colors.green)LEXER OUTPUT:\(Colors.white)")
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            for tok in tokens {
                print(tok)
            }
        }
        
        let ast = Parser(tokens: tokens).parse()
        if PRINT_PARSER {
            print()
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print("\(Colors.green)PARSER OUTPUT:\(Colors.white)")
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            printAST(ast)
        }
        
        let interpreter = Interpreter()
        print()
        print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
        print("\(Colors.green)INTERPRETER OUTPUT:\(Colors.white)")
        print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
        interpreter.interpretAST(ast)
        
        let compiler = Compiler(debugMode: DEBUG_MODE_COMPILER)
        let code = compiler.generateCode(ast)
        if PRINT_COMPILER {
            print()
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print("\(Colors.green)COMPILER OUTPUT:\(Colors.white)")
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            compiler.printCode()
        }
        
        let vm = VM()
        print()
        print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
        print("\(Colors.green)RUNNING VIRTUAL MACHINE:\(Colors.white)")
        print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
        vm.run(code)
    } catch {
        print("Error reading file: \(error)")
        exit(1)
    }
    }
}

struct PinkyCodeMain {
    static func execute(txt: String, file: String) {
//    let args = CommandLine.arguments
//    if args.count != 2 {
//        print("Usage: PinkyCompiler <filename>")
//        exit(1)
//    }
    let source = txt
    let filename = file
    
    do {
        //let source = try String(contentsOfFile: filename, encoding: .utf8)
        
        print()
        print("\(Colors.green)* * * PINKY COMPILER * * *\(Colors.white)")
        print("\(Colors.green)Running \(filename)\(Colors.white)")
        
        if PRINT_SOURCE {
            print()
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print("\(Colors.green)SOURCE:\(Colors.white)")
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print(source)
        }
        let startLexer = DispatchTime.now() // 记录开始时间

        let tokens = Lexer(source: source).tokenize()
        if PRINT_LEXER {
            print()
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print("\(Colors.green)LEXER OUTPUT:\(Colors.white)")
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            for tok in tokens {
                print(tok)
            }
        }
        let endLexer = DispatchTime.now()
        let intervalLexer = Double(endLexer.uptimeNanoseconds - startLexer.uptimeNanoseconds) / 1_000_000_000.0 // 转换为秒
        print("词法分析耗时: \(String(format: "%.6f", intervalLexer)) 秒")
        
        let ast = Parser(tokens: tokens).parse()
        if PRINT_PARSER {
            print()
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print("\(Colors.green)PARSER OUTPUT:\(Colors.white)")
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            printAST(ast)
        }
        
        let endParse = DispatchTime.now()
        let intervalParse = Double(endParse.uptimeNanoseconds - endLexer.uptimeNanoseconds) / 1_000_000_000.0 // 转换为秒
        print("语法分析耗时: \(String(format: "%.6f", intervalParse)) 秒")

        let interpreter = Interpreter()
        print()
        print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
        print("\(Colors.green)INTERPRETER OUTPUT:\(Colors.white)")
        print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
        
        interpreter.interpretAST(ast)
        
        let endInterpreter = DispatchTime.now()
        let intervalInterpreter = Double(endInterpreter.uptimeNanoseconds - endParse.uptimeNanoseconds) / 1_000_000_000.0 // 转换为秒
        print("解释执行耗时: \(String(format: "%.6f", intervalInterpreter)) 秒")
        
        let compiler = Compiler(debugMode: DEBUG_MODE_COMPILER)
        let code = compiler.generateCode(ast)
        if PRINT_COMPILER {
            print()
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            print("\(Colors.green)COMPILER OUTPUT:\(Colors.white)")
            print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
            compiler.printCode()
        }
        
        let endCompiler = DispatchTime.now()
        let intervalCompiler = Double(endCompiler.uptimeNanoseconds - endInterpreter.uptimeNanoseconds) / 1_000_000_000.0 // 转换为秒
        print("编译耗时: \(String(format: "%.6f", intervalCompiler)) 秒")
        
        let vm = VM()
        print()
        print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
        print("\(Colors.green)RUNNING VIRTUAL MACHINE:\(Colors.white)")
        print("\(Colors.green)--------------------------------------------------------------------------------\(Colors.white)")
        vm.run(code)
        
        let endVM = DispatchTime.now()
        let intervalVM = Double(endVM.uptimeNanoseconds - endCompiler.uptimeNanoseconds) / 1_000_000_000.0 // 转换为秒
        print("虚拟机执行耗时: \(String(format: "%.6f", intervalVM)) 秒")
    } catch {
        print("Error reading file: \(error)")
        exit(1)
    }
    }
}
