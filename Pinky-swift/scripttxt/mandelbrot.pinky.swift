//
//  mandelbrot.pinky.swift
//  Pinky-swift
//
//  Created by aosic on 2026/6/15.
//

import Foundation
public let Local_mandelbrot = """
println("MANDELBROT SET:")
left_edge   := -420
right_edge  :=  300
top_edge    :=  300
bottom_edge := -300
x_step      :=    7
y_step      :=   15
max_iter    :=  200
for y0 := top_edge, bottom_edge, -y_step do
    for x0 := left_edge, right_edge, x_step do
        y := 0
        x := 0
        char := " "
        i := 0
        while i < max_iter do
            x_x := (x * x) / 200
            y_y := (y * y) / 200
            if x_x + y_y > 800 then
                char := "" + i
                if i > 9 then
                    char := "@"
                end
                i := max_iter
            end
            y := x * y / 100 + y0
            x := x_x - y_y + x0
            i := i + 1
        end
        print(char)
    end
    print('\n')
end
"""
