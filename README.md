# UntitledRPG

Automation scripts for UntitledRPG on Roblox. Uses AutoHotkey v2 macros paired with a Python popup/reconnect detector.

---

## Prerequisites

### 1. AutoHotkey v2
The `.ahk` scripts require **AutoHotkey v2** (not v1).

- Download: https://www.autohotkey.com/download/
- Pick **AutoHotkey v2.x** installer
- After install, `.ahk` files will run with AHK v2 by default

---

### 2. Python 3.x
The `Popup.py` script requires **Python 3.8+**.

- Download: https://www.python.org/downloads/
- During install, check **"Add Python to PATH"**

#### Python Libraries
Install all required libraries with:

```bash
pip install opencv-python numpy mss pywin32 pytesseract
```

| Library | Install name | Purpose |
|---|---|---|
| `cv2` | `opencv-python` | Template matching & image processing |
| `numpy` | `numpy` | Array operations for image data |
| `mss` | `mss` | Fast screen capture |
| `win32gui` / `win32con` | `pywin32` | Windows API (find/resize Roblox window) |
| `pytesseract` | `pytesseract` | OCR wrapper for reading the reconnect code |

---

### 3. Tesseract OCR
`pytesseract` is only a Python wrapper — you must also install the **Tesseract OCR engine** separately.

- Download: https://github.com/UB-Mannheim/tesseract/wiki
- Install to the default path: `C:\Program Files\Tesseract-OCR\tesseract.exe`
- If you install elsewhere, update this line in `python/Popup.py`:
  ```python
  pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
  ```
- Make sure to add `Tesseract-OCR\bin` to enviroment 

---

## Project Structure

```
UntitledRPG/
├── ahk/
│   ├── ManaFarm.ahk      # Mana farming automation
│   ├── Crab.ahk          # Crab killing loop
│   └── SwordFlare.ahk    # SwordFlare skill loop
├── python/
│   └── Popup.py          # Disconnect detector + OCR reconnect code reader
├── images/
│   ├── popup3.png        # Disconnect popup templates
│   ├── popup4.png
│   └── ...               # Debug output images
├── Coords.txt
└── Korean.txt
```

---

## How to Run

1. Start Roblox and log into the game
2. Run `python/Popup.py` in a terminal:
   ```bash
   python python/Popup.py
   ```
3. Run the desired AHK script (double-click or right-click → Run as AHK v2)
4. Use the hotkeys inside the script to start/stop the macro