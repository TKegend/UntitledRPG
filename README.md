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

---

## New User Setup Guide (No Git, No CLI, No pip)

If you've never used Git, a terminal, or Python before, follow these steps from scratch.

### Step 1 — Download the project

1. Go to the GitHub repository page in your browser
2. Click the green **Code** button
3. Click **Download ZIP**
4. Extract the ZIP anywhere on your PC (e.g. `C:\Users\You\Desktop\UntitledRPG`)

### Step 2 — Install AutoHotkey v2

1. Go to https://www.autohotkey.com/download/
2. Download and run the **AutoHotkey v2.x** installer
3. Follow the installer — default options are fine

### Step 3 — Install Python

1. Go to https://www.python.org/downloads/
2. Download the latest **Python 3.x** installer for Windows
3. Run the installer — **check the box "Add Python to PATH"** before clicking Install
4. Complete the install

### Step 4 — Set up a Python virtual environment and install libraries

A virtual environment keeps the project's packages separate from the rest of your PC.

1. Press `Win + R`, type `cmd`, press Enter — this opens Command Prompt
2. Navigate to the project folder (replace the path with wherever you extracted it):
   ```
   cd C:\Users\You\Desktop\UntitledRPG
   ```
3. Create the virtual environment:
   ```
   python -m venv .venv
   ```
4. Activate it:
   ```
   .venv\Scripts\activate
   ```
   You should see `(.venv)` appear at the start of the line — this means it's active.
5. Install the required libraries:
   ```
   pip install opencv-python numpy mss pywin32 pytesseract
   ```
6. Wait for it to finish

> **Note:** Every time you open a new Command Prompt to run `Popup.py`, you need to repeat steps 2 and 4 to activate the environment first before running the script.

### Step 5 — Install Tesseract OCR

1. Go to https://github.com/UB-Mannheim/tesseract/wiki
2. Download and run the Windows installer
3. Install to the default path: `C:\Program Files\Tesseract-OCR\`
4. During install, check **"Add to PATH"** if prompted. If not go into the file, right click the bin and copy path then put into enviroments.

### Step 6 — Run the scripts

1. Navigate to the extracted project folder
2. Double-click `python/Popup.py` — if Python is installed correctly it will open, otherwise right-click → **Open with → Python**
3. Double-click any `.ahk` file to run it with AutoHotkey v2