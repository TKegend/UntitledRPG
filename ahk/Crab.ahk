#Requires AutoHotkey v2.0
#UseHook
SendMode "Event"

global RobloxWindows := []
global Running := false
RECONNECT_FILE := A_ScriptDir "\..\.\reconnect.txt"
global Code := ""
global Pos := ""
global Coord := [171,226,274,321,373,422,473,523,574,624,624]
global CoordY := 234
global idx := 1
global CrabKilled := 0

; ========================================
; ADD CURRENT ROBLOX WINDOW (CTRL + P)
; ========================================
^p::
{
    global RobloxWindows

    hwnd := WinActive("ahk_exe RobloxPlayerBeta.exe")

    if !hwnd
    {
        MsgBox "Focused window is not Roblox."
        return
    }

    for w in RobloxWindows
    {
        if (w = hwnd)
        {
            ToolTip "Roblox window already added."
            SetTimer () => ToolTip(), -1000
            return
        }
    }

    RobloxWindows.Push(hwnd)

    ToolTip "Added Roblox window index: " RobloxWindows.Length
    SetTimer () => ToolTip(), -1000
}

; ========================================
; START LOOP (CTRL + T)
; ========================================
^t::
{
    global Running

    if Running
        return

    Running := true
    StartMacro()
}

; ========================================
; STOP LOOP (CTRL + B)
; ========================================
^b::
{
    global Running, CrabKilled
    CrabKilled := 0
    Running := false
}

^y::ExitApp

; ========================================
IsWindowAlive(hwnd)
{
    return hwnd && WinExist("ahk_id " hwnd)
}

Activate(hwnd,time)
{
    DllCall("SetForegroundWindow", "ptr", hwnd)
    Sleep time
}

SendKey(key)
{
    SendEvent "6"
    Sleep 30
    SendEvent key
}

StartMacro()
{
    Global Running
    OpenGate()
    SetTimer LoopWindows, 10
}

OpenGate()
{
    global RobloxWindows

    hwnd := RobloxWindows[RobloxWindows.Length]

    Activate(hwnd, 200)
    SendKey("2")
    Sleep 1000
    SendEvent "{e down}"
    Sleep 4000
    SendEvent "{e up}"
}

LoopWindows()
{
    global RobloxWindows, Running, CrabKilled, Code

    if !Running
    {
        SetTimer LoopWindows, 0
        return
    }

    if RobloxWindows.Length = 0
        return

    TimeElapse := 0
    ; ========================================
    ; SEND 5
    ; ========================================
    Loop RobloxWindows.Length - 1
    {
        Index := RobloxWindows.Length - 1 - A_Index + 1
        hwnd := RobloxWindows[Index]

        Activate(hwnd, 250)
        SendKey("5")
        Sleep 200
        TimeElapse += 450
    }

    Sleep 3000

    ; ========================================
    ; SEND 2
    ; ========================================
    Loop RobloxWindows.Length - 1
    {
        Index := RobloxWindows.Length - 1 - A_Index + 1
        hwnd := RobloxWindows[Index]

        Activate(hwnd, 250)
        SendKey("2")
        Sleep 150
    }

    Sleep 8000

    ; ========================================
    ; R / T LOGIC
    ; ========================================
    Loop RobloxWindows.Length-1
    {
        if !Running
            return

        Index := RobloxWindows.Length - 1 - A_Index + 1
        hwnd := RobloxWindows[Index]

        if !IsWindowAlive(hwnd)
            continue

        Activate(hwnd, 250)

        if (Index = 1)
        {
            SendKey("r")
            Sleep 1000
            SendKey("t")
            Sleep 200
            Break
        }

  
        SendKey("r")
        Sleep 200
    }

    Sleep 6000
    Loop RobloxWindows.Length-1
    {
        if !Running
            return

        Index := RobloxWindows.Length - 1 - A_Index + 1
        hwnd := RobloxWindows[Index]

        if !IsWindowAlive(hwnd)
            continue

        Activate(hwnd, 250)

        if (Index = 1)
        {

            SendKey("r")
            Sleep 200
            ; Sleep 1000
            ; SendKey("t")
            Break
        }

        SendKey("r")
        Sleep 200
    }

    CrabKilled++
    if (CrabKilled = 11)
    {
        CrabKilled := 0
        Terminate()
        Sleep 1000
        Terminate()
        Sleep 30000
        OpenGate()
        return
    }

    Loop RobloxWindows.Length-1
    {
        if !Running
            return

        Index := RobloxWindows.Length - 1 - A_Index + 1
        hwnd := RobloxWindows[Index]

        if !IsWindowAlive(hwnd)
            continue

        Activate(hwnd, 250)
        Sleep 200
        TimeElapse += 450

        if (Index = 1)
        {
            SendEvent "{s down}"
            Sleep 200
            SendEvent "{s up}"
            TimeElapse += 200
            Break
        }

        SendEvent "{d down}"
        Sleep 400
        SendEvent "{d up}"
        Sleep 200
        SendEvent "{w down}"
        Sleep 300
        SendEvent "{w up}"
        TimeElapse += 900
    }

    
    Loop RobloxWindows.Length
    {
        if !Running
            return

        Index := RobloxWindows.Length - A_Index + 1
        hwnd := RobloxWindows[Index]

        if !IsWindowAlive(hwnd)
            continue

        Activate(hwnd, 250)
        TimeElapse += 250

        detectFile := A_ScriptDir "\\..\detect.txt"

        Loop 5
        {
            try
            {
                if FileExist(detectFile)
                    FileDelete detectFile
                FileAppend "1", detectFile
                break
            }
            catch
            {
                TimeElapse += 200
                Sleep 200
            }
        }

        TimeElapse += 3000
        Sleep 3000

        CheckReconnectFile()
        TimeElapse += 200
        Sleep 200

        if Code
        {
            TimeElapse += 6700
            Reconnect()
            Code := ""
            Break
        }
    }

    Sleep Max(0, 32500 - TimeElapse)
}

CheckReconnectFile()
{
    global RECONNECT_FILE

    if FileExist(RECONNECT_FILE)
    {
        global Code
        Code := Trim(FileRead(RECONNECT_FILE))
        Sleep 200
        FileDelete RECONNECT_FILE
    }
}

Reconnect()
{
    Critical
    global Code
    global Coord
    global CoordY

    MouseMove 363, 142
    Sleep 1000

    Click 383, 143
    Sleep 1000

    digitToIndex := Map()
    Pos := "2346789015"

    Position := StrSplit(Pos)

    for i, d in Position
        digitToIndex[d] := i

    Codes := StrSplit(Code)

    for c in Codes
    {
        idx := digitToIndex[c]

        if idx
        {
            MouseMove Coord[idx], CoordY
            Sleep 500
            Click Coord[idx], CoordY+10
            Sleep 500
        }
    }
}

^k::
{
    hwnd := WinActive("A")
    MsgBox WinGetProcessName("ahk_id " hwnd)
}
Terminate()
{
    Loop RobloxWindows.Length
    {
      
        Index := RobloxWindows.Length - A_Index + 1
        hwnd := RobloxWindows[Index]

        if !IsWindowAlive(hwnd)
            continue

        Activate(hwnd, 200)
        Sleep 200
        SendKey("{Escape}")
        Sleep 500
        SendKey("r")
        Sleep 500

        Click 290 , 365 
        Sleep 500
        Click 290 , 270
        Sleep 500

      
    }
}
^m::
{
    SendEvent "{s down}"
    Sleep 500
    SendEvent "{s up}"
}