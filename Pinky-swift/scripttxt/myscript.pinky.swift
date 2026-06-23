//
//  myscript.pinky.swift
//  Pinky-swift
//
//  Created by aosic on 2026/6/15.
//

import Foundation
public let Local_myscript = """
println("Hello!")
x := 5
func func_3(x, y)
    result := x * y
    println result
end
func func_2(x, y)
    result := x + y
    func_3(7, 9 + y)
    println result
end
func func_1(a, b, c)
    println a
    println b
    func_2(2, 3)
    println c
end
func_1(1 + 2, 2 + 3, 3 + x)
println("Goodbye!")
func mul(a, b)
    ret a * b
end
x := 20
y := 30
l := 100
func say(msg)
    local arrowtext := "-> " + msg
    println(arrowtext)
end
func add(a, b)
    local result := a + b
    ret result
end
func bar(a)
    local x := 1
    say (x)
    while x <= 10 do
        local l := x + 2
        if x > 0 then
            local val := l + add(x, 5) + x
            say(val)
        end
        say(l)
        x := x + 1
    end
end
func foo(a)
    local x := 5
    bar(a)
    say(x)
end
say(foo(7))
"""
