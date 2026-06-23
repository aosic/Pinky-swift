import Foundation

public class Environment {
    public var vars: [String: (ValueType, Any)] = [:]
    public var funcs: [String: (FuncDecl, Environment)] = [:]
    public var parent: Environment?
    
    public init(parent: Environment? = nil) {
        self.parent = parent
    }
    
    public func getVar(_ name: String) -> (ValueType, Any)? {
        var env: Environment? = self
        while let current = env {
            if let value = current.vars[name] {
                return value
            }
            env = current.parent
        }
        return nil
    }
    
    public func setVar(_ name: String, _ value: (ValueType, Any)) {
        var env: Environment? = self
        while let current = env {
            if current.vars[name] != nil {
                current.vars[name] = value
                return
            }
            env = current.parent
        }
        self.vars[name] = value
    }
    
    public func setLocal(_ name: String, _ value: (ValueType, Any)) {
        self.vars[name] = value
    }
    
    public func getFunc(_ name: String) -> (FuncDecl, Environment)? {
        var env: Environment? = self
        while let current = env {
            if let value = current.funcs[name] {
                return value
            }
            env = current.parent
        }
        return nil
    }
    
    public func setFunc(_ name: String, _ value: (FuncDecl, Environment)) {
        self.funcs[name] = value
    }
    
    public func newEnv() -> Environment {
        return Environment(parent: self)
    }
}
