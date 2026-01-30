import time
import os
import cv2
import numpy as np
import mss
import win32gui
import win32con
import pytesseract

# ================= CONFIG =================

WINDOW_TITLES = ["Roblox", "Roblox Player"]

TEMPLATE_PATHS = [
    "popup3.png",
    "popup2.png"
]

THRESHOLD = 0.75
SIGNAL_FILE = "reconnect.txt"
CHECK_INTERVAL = 1.0

# ---- Tesseract OCR (ADDED) ----
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
CODE_FILE = "code.txt"

# relative region of the number popup (tweak if needed)
NUMBER_REGION1 = (0.57, 0.18, 0.65, 0.23)
NUMBER_REGION2 = (0.19, 0.33, 0.81, 0.44)
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


def extract_digits(img, mode = "single"):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    gray = cv2.convertScaleAbs(gray, alpha=1.2, beta=10)

    cv2.imwrite("debug_gray.png", gray)

    if mode == "single":
        config = "--oem 1 --psm 7 -c tessedit_char_whitelist=0123456789"
    else:
        config = "--oem 1 --psm 6 -c tessedit_char_whitelist=0123456789"
    text = pytesseract.image_to_string(gray, config=config)

    digits = "".join(filter(str.isdigit, text))

    if len(digits) == 3:
        digits = digits[0] + "8" + digits[1:]
    return digits




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

                # ----- OCR number (ADDED) -----
                h, w, _ = frame.shape
                x1 = int(w * NUMBER_REGION1[0])
                y1 = int(h * NUMBER_REGION1[1])
                x2 = int(w * NUMBER_REGION1[2])
                y2 = int(h * NUMBER_REGION1[3])

                roi = frame[y1:y2, x1:x2]
                cv2.imwrite("debug_roi.png", roi)
                
                # ----- Signal AHK (UNCHANGED VARIABLE) -----
                digits = extract_digits(roi, mode="single")

                if digits.isdigit() and len(digits) == 4:
                    with open(SIGNAL_FILE, "w") as f:
                        f.write(digits)
                    print("Signal file created with digits:", digits)
                else:
                    print("OCR failed or incomplete:", digits)
  
                time.sleep(10)
                frame = capture_window(rect)

                h, w, _ = frame.shape
                x1 = int(w * NUMBER_REGION2[0])
                y1 = int(h * NUMBER_REGION2[1])
                x2 = int(w * NUMBER_REGION2[2])
                y2 = int(h * NUMBER_REGION2[3])

                roi = frame[y1:y2, x1:x2]
                cv2.imwrite("debug_input.png", roi)
                digits = extract_digits(roi , mode="multiple")
                if digits.isdigit():
                    with open(SIGNAL_FILE, "w") as f:
                        f.write(digits)
                    print("Signal file created with digits:", digits)
                else:
                    print("OCR failed or incomplete:", digits)
                time.sleep(2*60)
                break

        time.sleep(CHECK_INTERVAL)


if __name__ == "__main__":
    main()
