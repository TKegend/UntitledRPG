import time
import os
import cv2
import numpy as np
import mss
import win32gui
import win32con
import pytesseract
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# ================= PATHS =================

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.dirname(_SCRIPT_DIR)          # project root
_IMAGES = os.path.join(_ROOT, "images")

# ================= CONFIG =================
FIFTH_ROW_CHECK = (0.73, 0.40)  # (x %, y %) tweak this
DARK_THRESHOLD = 60         # lower = darker
WINDOW_TITLES = ["Roblox", "Roblox Player"]

TEMPLATE_PATHS = [
    os.path.join(_IMAGES, "popup3.png"),
    os.path.join(_IMAGES, "popup4.png")
]
DETECT_FILE = os.path.join(_ROOT, "detect.txt")
THRESHOLD = 0.85
SIGNAL_FILE = os.path.join(_ROOT, "reconnect.txt")
DELETE_FILE = os.path.join(_ROOT, "reconnect.txt")
CHECK_INTERVAL = 1.0

# ---- Tesseract OCR (ADDED) ----
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
CODE_FILE = os.path.join(_ROOT, "code.txt")

# relative region of the number popup (tweak if needed)
# NUMBER_REGION1 = (0.58, 0.18, 0.64, 0.2125)
NUMBER_REGION_3 = (0.58, 0.18, 0.64, 0.22)
NUMBER_REGION_4 = (0.58, 0.18, 0.637 , 0.22)
# NUMBER_REGION2 = (0.19, 0.33, 0.81, 0.44)
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

    # gray = cv2.convertScaleAbs(gray, alpha=1.2, beta=10)

    cv2.imwrite(os.path.join(_IMAGES, "debug_gray.png"), gray)

    if mode == "single":
        config = "--oem 1 --psm 7 -c tessedit_char_whitelist=0123456789"
    else:
        config = "--oem 1 --psm 6 -c tessedit_char_whitelist=0123456789"
    text = pytesseract.image_to_string(gray, config=config)

    digits = "".join(filter(str.isdigit, text))

    # if len(digits) == 3:
    #     digits = digits[0] + "8" + digits[1:]
    return digits

def is_fifth_player_present(frame):
    h, w, _ = frame.shape

    x = int(w * FIFTH_ROW_CHECK[0])
    y = int(h * FIFTH_ROW_CHECK[1])

    pixel = frame[y, x]
    gray = int(0.299*pixel[2] + 0.587*pixel[1] + 0.114*pixel[0])

    print(f"Pixel check at ({x},{y}) → gray={gray}")

    # ===== DRAW DEBUG POINT =====
    debug = frame.copy()

    # red dot (the pixel)
    cv2.circle(debug, (x, y), 6, (0, 0, 255), -1)

    # optional: draw small box around it
    cv2.rectangle(debug, (x-10, y-10), (x+10, y+10), (0, 255, 0), 2)

    # save image so you can inspect
    cv2.imwrite(os.path.join(_IMAGES, "debug_pixel.png"), debug)

    return gray < DARK_THRESHOLD



def handle_detect(templates):
    hwnd = find_roblox_window()
    if not hwnd:
        print("Roblox window not found")
        return

    rect = get_client_rect(hwnd)
    if rect[2] <= 0 or rect[3] <= 0:
        print("Invalid window size")
        return

    frame = capture_window(rect)
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    for name, template in templates:
        res = cv2.matchTemplate(gray, template, cv2.TM_CCOEFF_NORMED)
        _, max_val, _, _ = cv2.minMaxLoc(res)

        if max_val >= THRESHOLD:
            print(f"Disconnect detected using {name} ({max_val:.2f})")

            h, w, _ = frame.shape
            number_region = NUMBER_REGION_4 if "popup4" in name else NUMBER_REGION_3
            x1 = int(w * number_region[0])
            y1 = int(h * number_region[1])
            x2 = int(w * number_region[2])
            y2 = int(h * number_region[3])

            roi = frame[y1:y2, x1:x2]
            cv2.imwrite(os.path.join(_IMAGES, "debug_roi.png"), roi)

            # ----- Signal AHK (UNCHANGED VARIABLE) -----
            digits = extract_digits(roi, mode="single")

            if digits.isdigit() and len(digits) == 4:
                with open(SIGNAL_FILE, "w") as f:
                    f.write(digits)
                print("Signal file created with digits:", digits)
            else:
                print("OCR failed or incomplete:", digits)

            time.sleep(5)
            break


class DetectHandler(FileSystemEventHandler):
    def __init__(self, templates):
        super().__init__()
        self.templates = templates
        self._processing = False

    def on_created(self, event):
        if event.is_directory:
            return
        if os.path.abspath(event.src_path) != os.path.abspath(DETECT_FILE):
            return
        if self._processing:
            try:
                os.remove(DETECT_FILE)
            except (PermissionError, FileNotFoundError):
                pass
            return
        self._processing = True
        try:
            try:
                os.remove(DETECT_FILE)
            except (PermissionError, FileNotFoundError):
                return
            handle_detect(self.templates)
        finally:
            self._processing = False


def main():
    templates = load_templates()
    if not templates:
        print("ERROR: No valid templates loaded")
        return

    print("Roblox reconnect detector started")
    print("Loaded templates:", [t[0] for t in templates])

    handler = DetectHandler(templates)
    observer = Observer()
    observer.schedule(handler, path=_ROOT, recursive=False)
    observer.start()
    print(f"Watching for {DETECT_FILE} ...")
    try:
        while observer.is_alive():
            observer.join(timeout=1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


if __name__ == "__main__":
    main()
