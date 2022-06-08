from microbit import *

a = False
b = False
while True:
    ap = button_a.is_pressed()
    bp = button_b.is_pressed()
    if a != ap:
        a = ap
        print('A' if ap else 'a', end='')
    if b != bp:
        b = bp
        print('B' if bp else 'b', end='')
