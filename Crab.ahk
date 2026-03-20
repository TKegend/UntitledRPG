#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"

global RobloxWindows := []
global Running := false
RECONNECT_FILE := "reconnect.txt"  ; 
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

    ; prevent duplicates
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
    global Running
    Running := false
}

; EXIT
^y::ExitApp

; ========================================
; CHECK WINDOW ALIVE
; ========================================
IsWindowAlive(hwnd)
{
    return hwnd && WinExist("ahk_id " hwnd)
}

StartMacro()
{
    Global Running
    OpenGate()
    while Running 
    {
        LoopWindows()
    }
}
OpenGate()
{
    global RobloxWindows

    hwnd := RobloxWindows[RobloxWindows.Length]
    WinActivate "ahk_id " hwnd
    WinWaitActive "ahk_id " hwnd,,1
    Sleep 100

    Send "{e down}"
    Sleep 4000
    Send "{e up}"
}
LoopWindows()
{
    global RobloxWindows, Running, CrabKilled, Code

    if !Running
        return

    if RobloxWindows.Length = 0
        return
    if (CrabKilled = 11)
    {
        CrabKilled := 0
        Sleep 60000
        StartMacro()
        return
    }

    Loop RobloxWindows.Length - 1
    {
        hwnd := RobloxWindows[A_Index]

        WinActivate "ahk_id " hwnd
        WinWaitActive "ahk_id " hwnd,,1
        Sleep 300
        Send "5"
    }
    Sleep 3000
     Loop RobloxWindows.Length - 1
    {
        hwnd := RobloxWindows[A_Index]

        WinActivate "ahk_id " hwnd
        WinWaitActive "ahk_id " hwnd,,1
        Sleep 300
        Send "2"
    }
    Sleep 3000
    ; always start from index 1
    Loop RobloxWindows.Length-1
    {
        if !Running
            return
        Index := RobloxWindows.Length - 1 - A_Index + 1
        hwnd := RobloxWindows[Index]

        if !IsWindowAlive(hwnd)
            continue

        WinActivate "ahk_id " hwnd
        WinWaitActive "ahk_id " hwnd,,1

        if (Index = 1)
        {
            Sleep 100
            Send "t"
            Sleep 1000
            Send "r"
            Break
        }

        Sleep 100
        Send "r"
        Sleep 100
    }
    Sleep 7500
    Loop RobloxWindows.Length-1
    {
        if !Running
            return
        Index := RobloxWindows.Length - 1 - A_Index + 1
        hwnd := RobloxWindows[Index]

        if !IsWindowAlive(hwnd)
            continue

        WinActivate "ahk_id " hwnd
        WinWaitActive "ahk_id " hwnd,,1

        if (Index = 1)
        {
            Sleep 100
            Send "r"
            Sleep 1000
            Send "t"
            Break
        }
        Sleep 100
        Send "r"
        Sleep 100
    }
    CrabKilled++
    TimeElapse := 0
    Loop RobloxWindows.Length
    {
        if !Running
            return
        Index := RobloxWindows.Length - A_Index + 1
        hwnd := RobloxWindows[Index]

        if !IsWindowAlive(hwnd)
            continue

        WinActivate "ahk_id " hwnd
        WinWaitActive "ahk_id " hwnd,,1
        detectFile := A_ScriptDir "\detect.txt"
        if !FileExist(detectFile)
        {
            FileAppend "1", detectFile
        }
        TimeElapse += 3000
        Sleep 3000
        CheckReconnectFile()
        if Code
        {
            TimeElapse += 5000
            Reconnect()
            Code := ""
            Break
        }
    }
    Sleep 34000 - TimeElapse
}
CheckReconnectFile()
{
    global RECONNECT_FILE

    if FileExist(RECONNECT_FILE)
    {
        global Code
        Code := Trim(FileRead(RECONNECT_FILE))
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
    {
        digitToIndex[d] := i
    }

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