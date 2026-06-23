//
//  myscript3.pinky.swift
//  Pinky-swift
//
//  Created by aosic on 2026/6/15.
//

import Foundation
public let Local_myscript3 = """
--println 2 + 3 * 4.45 - 2.8 - -1 and false
--println ~true
--println 3 + 5 - 6 * 2 - -3
--println 2 + 3 * 5 - 1
--println (2 + 3) * 5 - 1
--println true
--println 1 == 2
--println ~(3 > 2) or ~true
--if 3 >= 0 then
--    println "Entered the consequence block."
--else
--    println "Entered the alternative block."
--end
--println "Goodbye!"
--x := 100
--y := 200
--z := 300
--a := x + 1
--println(x)
--println(y)
--println(z)
--println(a)
pi  :=  3.141592
tau :=  6.283184
g   := -9.8
x := 5
if x > 0 then
    a := 1
    b := 2
    if x > 1 then 
        c := 3
        if x > 2 then
            d := 4
        else
            e := 5
            b := 6
        end
    end
else
    a := 7
    x := 8
end
i := 1
while i <= 10 do
    x := 2 * i
    println(x)
    i := i + 1
end
func sum(num1, num2)
    res := num1 + num2
    ret res
end
println("abc")
"""
