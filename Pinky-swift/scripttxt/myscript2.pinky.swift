//
//  myscript2.pinky.swift
//  Pinky-swift
//
//  Created by aosic on 2026/6/15.
//

import Foundation
public let Local_myscript2 = """
--------------------------------------------------------------------------------
-- Simple expressions
--------------------------------------------------------------------------------
-- 2^3                      -- 8.0
-- (22 + 1) % 3             -- 2.0
-- 4 >= 3                   -- true
-- 4 == 2                   -- false
-- 4 ~= 2                   -- true
-- (2.5 > 0) == false       -- false
-- ~(3 < 1 + -6)            -- true
-- 2^3^2                    -- 512.0
-- -3^2                     -- -9.0
-- (-3)^2                   -- 9.0
-- 2 > 1 and 5 > 4          -- true
-- 2 == 3 and 5 > 4         -- false
-- 2 > 1 or 5 > 4           -- true
-- false and false or true  -- true
-- 2 > 1 and 4 > 6 or 7 + 3 >= 6 and 5 == 2 -- false
--------------------------------------------------------------------------------
-- Statements
--------------------------------------------------------------------------------
--print 1 + 2
--print 3 * 2^2
--println("test ln")
--print("test")
--------------------------------------------------------------------------------
-- If statement test
--------------------------------------------------------------------------------
--if 5 > 2 then
--    print("Entered the consequence (then)")
--else
--    print("Entered the alternative (else)")
--end
--------------------------------------------------------------------------------
-- Variable test
--------------------------------------------------------------------------------
x := 0
x := x + 1
y := 0
println("the value of x is " + x)
if 5 ~= 2 then
    y := x + 20
    println("I have access to the local y = " + y)
    println("I have also access to the global x = " +x)
else
    x:= y
    println("Error, no local variable " + y)
end
--------------------------------------------------------------------------------
-- While statement test
--------------------------------------------------------------------------------
i := 1
while i <= 10 do
    println("i = " + i)
    i := i + 1
end
--------------------------------------------------------------------------------
-- For statement test
--------------------------------------------------------------------------------
for num := 1, 30, 2 do
    println("num = " + num)
end
--------------------------------------------------------------------------------
-- Function to print the factorial of a number
--------------------------------------------------------------------------------
func factorial(n)
    mul := 1
    for i := 1, n do
        mul := mul * i
    end
    println("The factorial of " + n + " is " + mul)
end
factorial(5)
--------------------------------------------------------------------------------
-- FizzBuzz
--------------------------------------------------------------------------------
func fizzbuzz(n)
    i := 1
    while i <= n do
        if i % 3 == 0 and i % 5 == 0 then
            println "i = " + i + " -> " + "FizzBuzz"
        else
            if i % 3 == 0 then
                println "i = " + i + " -> " + "Fizz"
            end
            if i % 5 == 0 then
                println "i = " + i + " -> " + "Buzz"
            end
        end
        i := i + 1
    end
end
fizzbuzz(30)
--------------------------------------------------------------------------------
-- Local varaibles
--------------------------------------------------------------------------------
x := 0
func foo(n)
    local x := 999
    i := 1
    while i <= n do
        local x := -1
        println x
        i := i + 1
    end
    println x
end
foo(6)
println x
"""
