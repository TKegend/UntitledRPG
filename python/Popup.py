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
NUMBER_REGION_4 = (0.58, 0.18, 0.637, 0.22)
# NUMBER_REGION2 = (0.19, 0.33, 0.81, 0.44)

# Region used by the per-digit slice OCR function
NUMBER_REGION_SLICE = (0.58, 0.18, 0.637, 0.22)
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
    cv2.imwrite(os.path.join(_IMAGES, "debug_gray.png"), gray)

    if mode == "single":
        config = "--oem 1 --psm 8 -c tessedit_char_whitelist=0123456789"
    else:
        config = "--oem 1 --psm 6 -c tessedit_char_whitelist=0123456789"
    text = pytesseract.image_to_string(gray, config=config)

    digits = "".join(filter(str.isdigit, text))

    if len(digits) < 4:
        wrong_dir = os.path.join(_IMAGES, "wrong_numbers")
        os.makedirs(wrong_dir, exist_ok=True)
        cv2.imwrite(os.path.join(wrong_dir, f"number{digits}.png"), img)

        if digits[0] == "5" or digits[0] == "9":
            digits = "2" + digits
        elif digits[0] == "2":
            digits = "5" + digits

    return digits

def extract_digits_boxed(img, num_digits=4, scale=4):
    """
    Two-step approach:
      1. Use image_to_boxes on the inverted+scaled image to reliably detect
         which slots are occupied (position only — box char value not trusted).
      2. Re-OCR each occupied slot's slice on the original (non-inverted) scaled
         image with PSM 10. Falls back to the box character if the slice fails.
    Missing slots return '?' (e.g. '?241', '2?41').
    """
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    h_orig, w_orig = gray.shape

    digit_w = 12
    stride  = 10
    left_pad = (w_orig - (stride * (num_digits - 1) + digit_w)) / 2

    scaled   = cv2.resize(gray, (w_orig * scale, h_orig * scale), interpolation=cv2.INTER_CUBIC)
    h, w     = scaled.shape
    inverted = cv2.bitwise_not(scaled)

    # Vertical padding helps Tesseract see a clean text line
    pad_h    = h
    padded_inv = cv2.copyMakeBorder(inverted, pad_h, pad_h, 0, 0, cv2.BORDER_CONSTANT, value=255)

    expected_centers = [(left_pad + i * stride + digit_w / 2) * scale for i in range(num_digits)]

    # ── Step 1: detect slot occupancy via boxes on inverted image ──────────────
    boxes_config = '--oem 1 --psm 7 -c tessedit_char_whitelist=0123456789'
    detected = []
    for line in pytesseract.image_to_boxes(padded_inv, config=boxes_config).splitlines():
        parts = line.split()
        if len(parts) < 5 or not parts[0].isdigit():
            continue
        l, r = int(parts[1]), int(parts[3])
        detected.append(((l + r) / 2, parts[0]))

    occupied      = set()
    slot_fallback = {}   # boxes char — used only if slice re-OCR fails
    for x_center, char in sorted(detected, key=lambda t: t[0]):
        best = min(
            (s for s in range(num_digits) if s not in occupied),
            key=lambda s: abs(expected_centers[s] - x_center),
            default=None,
        )
        if best is not None:
            occupied.add(best)
            slot_fallback[best] = char

    # ── Step 2: re-OCR each slot slice on the original (non-inverted) image ───
    slice_config = '--oem 1 --psm 10 -c tessedit_char_whitelist=0123456789'
    pad_s = h // 2
    slots = ['?'] * num_digits
    for slot, fallback_char in slot_fallback.items():
        x1  = max(0, int((left_pad + slot * stride) * scale))
        x2  = min(w, int((left_pad + slot * stride + digit_w) * scale))
        slc = scaled[:, x1:x2]                          # white-on-black slice
        padded_slc = cv2.copyMakeBorder(slc, pad_s, pad_s, pad_s, pad_s,
                                        cv2.BORDER_CONSTANT, value=255)
        text = pytesseract.image_to_string(padded_slc, config=slice_config)
        d = ''.join(filter(str.isdigit, text))
        slots[slot] = d[0] if d else fallback_char      # fallback for e.g. '9'

    return ''.join(slots)


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
            # digits = extract_digits(roi, mode="single")
            digits = extract_digits_boxed(roi)

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
