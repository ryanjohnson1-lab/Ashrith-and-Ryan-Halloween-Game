import time
import usb_hid
from adafruit_hid.keyboard import Keyboard
from adafruit_hid.keycode import Keycode
from adafruit_circuitplayground import cp

keyboard = Keyboard(usb_hid.devices)

tilt_on = 2.2
tilt_off = 1.0
direction = 0
left_down = False
right_down = False
shoot_down = False
controller_enabled = False
neutral_x = 0.0
shown_direction = None

cp.pixels.brightness = 0.2

def show_direction(value):
    cp.pixels.fill((0, 0, 0))
    if value < 0:
        for pixel in range(5, 10):
            cp.pixels[pixel] = (64, 0, 0)
    elif value > 0:
        for pixel in range(5):
            cp.pixels[pixel] = (0, 64, 0)

def update_key(key, wanted, is_down):
    if wanted and not is_down:
        keyboard.press(key)
    elif is_down and not wanted:
        keyboard.release(key)
    return wanted

def calibrate_neutral_x():
    total = 0.0
    samples = 50
    for _ in range(samples):
        total += cp.acceleration[0]
        time.sleep(0.01)
    return total / samples

while True:
    if not cp.switch:
        if controller_enabled:
            keyboard.release_all()
            controller_enabled = False
        direction = 0
        left_down = False
        right_down = False
        shoot_down = False
        if shown_direction != 0:
            show_direction(0)
            shown_direction = 0
        time.sleep(0.005)
        continue

    if not controller_enabled:
        keyboard.release_all()
        neutral_x = calibrate_neutral_x()
        controller_enabled = True

    x = cp.acceleration[0] - neutral_x

    if x <= -tilt_on:
        direction = -1
    elif x >= tilt_on:
        direction = 1
    elif direction == -1 and x >= -tilt_off:
        direction = 0
    elif direction == 1 and x <= tilt_off:
        direction = 0

    if direction != shown_direction:
        show_direction(direction)
        shown_direction = direction

    left_down = update_key(Keycode.A, direction == -1, left_down)
    right_down = update_key(Keycode.D, direction == 1, right_down)
    shoot_down = update_key(Keycode.SPACE, cp.button_a or cp.button_b, shoot_down)

    time.sleep(0.005)
