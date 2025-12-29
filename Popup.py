import time
import os
import cv2
import numpy as np
import mss
import win32gui
import win32con

# ================= CONFIG =================

WINDOW_TITLES = ["Roblox", "Roblox Player"]

TEMPLATE_PATHS = [
    "kick.png",
    "kick2.png",
    "fail.png"
]

THRESHOLD = 0.75
SIGNAL_FILE = "reconnect.txt"
CHECK_INTERVAL = 1.0

# ==========================================


def find_roblox_window():
    for title in WINDOW_TITLES:
        hwnd = win32gui.FindWindow(None, title)
        if hwnd:
            return hwnd
    return None


def get_client_rect(hwnd):
    win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)

    left, top, right, bottom = win32gui.GetClientRect(hwnd)
    x1, y1 = win32gui.ClientToScreen(hwnd, (left, top))
    x2, y2 = win32gui.ClientToScreen(hwnd, (right, bottom))

    return (x1, y1, x2 - x1, y2 - y1)


def capture_window(rect):
    with mss.mss() as sct:
        img = sct.grab({
            "left": rect[0],
            "top": rect[1],
            "width": rect[2],
            "height": rect[3]
        })
    return cv2.cvtColor(np.array(img), cv2.COLOR_BGRA2BGR)


def load_templates():
    templates = []
    for path in TEMPLATE_PATHS:
        img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
        if img is None:
            print(f"WARNING: Template not found -> {path}")
        else:
            templates.append((path, img))
    return templates


def main():
    templates = load_templates()
    if not templates:
        print("ERROR: No valid templates loaded")
        return

    print("Roblox reconnect detector started")
    print("Loaded templates:", [t[0] for t in templates])

    while True:
        hwnd = find_roblox_window()
        if not hwnd:
            time.sleep(2)
            continue

        rect = get_client_rect(hwnd)
        if rect[2] <= 0 or rect[3] <= 0:
            time.sleep(2)
            continue

        frame = capture_window(rect)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        for name, template in templates:
            res = cv2.matchTemplate(gray, template, cv2.TM_CCOEFF_NORMED)
            _, max_val, _, _ = cv2.minMaxLoc(res)

            if max_val >= THRESHOLD:
                print(f"Disconnect detected using {name} ({max_val:.2f})")

                with open(SIGNAL_FILE, "w") as f:
                    f.write("reconnect")

                print("Signal file created")
                print("Waiting 2 minutes before resuming detection...")
                time.sleep(2 * 60)
                break  # stop checking other templates this cycle

        time.sleep(CHECK_INTERVAL)


if __name__ == "__main__":
    main()
