#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"

RECONNECT_FILE := "reconnect.txt"  ; 
global Code := ""
global Pos := ""
global Coord := [171,226,274,321,373,422,473,523,574,624,624]
global CoordY := 234
global RobloxWindows := []
global idx := 1
global DetectInProgress := false
^t::  ; START
{
    InitRobloxWindows()
    DoActions()
    SetTimer CheckReconnectFile, 500
}

^b::  ; STOP
{
    SetTimer DoActions, 0
    SetTimer CheckReconnectFile, 0
}

^y::ExitApp

InitRobloxWindows()
{
    global RobloxWindows, idx
    idx := 1
    RobloxWindows := []

    ; Get all Roblox client windows
    for hwnd in WinGetList("ahk_exe RobloxPlayerBeta.exe")
    {   
        RobloxWindows.Push(hwnd)
    }
}
IsWindowAlive(hwnd)
{
    return hwnd && WinExist("ahk_id " hwnd)
}
DoActions()
{
    Critical
    global RobloxWindows, idx, DetectInProgress

    if DetectInProgress
        return
    Count := 0
    Loop RobloxWindows.Length
    {
        Count++
        hwnd := RobloxWindows[idx]
        if !IsWindowAlive(hwnd) {
            RobloxWindows.RemoveAt(idx)
            continue
        }
        WinActivate "ahk_id " . hwnd
        WinWaitActive "ahk_id " . hwnd, , 1
        Sleep 200
        Send "2"
        Sleep 200
        ; Click "Left"
        Send "e"
        Sleep 1200
        Send "r"
        Sleep 200
    
        if Count = RobloxWindows.Length
            break
        idx++
        if idx > RobloxWindows.Length
            idx := 1
    }
    detectFile := A_ScriptDir "\detect.txt"
    if !FileExist(detectFile)
    {
        FileAppend "1", detectFile
    }
    SetTimer DoActions, -4000
}

Reconnect()
{
    Critical
    global Code
    global DetectInProgress
    SetTimer DoActions, 0
    SetTimer CheckReconnectFile, 0
    DetectInProgress := true

    if !WinExist("Roblox")
        return

    WinActivate "Roblox"
    WinWaitActive "Roblox", , 2
    Sleep 2000

    ; Click the input box directly
    MouseMove 363, 142
    Sleep 1000

    Click 383, 143
    Sleep 1000
    SetTimer CheckReconnectFile2, 500

}
Reconnect2()
{
    Critical
    global Code
    global Pos
    global Coord
    global CoordY
    global DetectInProgress
    SetTimer CheckReconnectFile2, 0

    digitToIndex := Map()

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

    SetTimer CheckReconnectFile, 500
    DetectInProgress := false
    Manafarm()
}
; ================= FILE WATCHER =================

CheckReconnectFile()
{
    global RECONNECT_FILE

    if FileExist(RECONNECT_FILE)
    {
        global Code
        Code := Trim(FileRead(RECONNECT_FILE))
        FileDelete RECONNECT_FILE
        Reconnect()
    }
}
CheckReconnectFile2()
{
    global RECONNECT_FILE

    if FileExist(RECONNECT_FILE)
    {
        global Pos
        Pos := Trim(FileRead(RECONNECT_FILE))
        FileDelete RECONNECT_FILE
        Reconnect2()
    }
}

Move(Key, Second)
{
    Send "{" . Key . " down}"
    Sleep Second
    Send "{" . Key . " up}"
}
^m::
{
    InitRobloxWindows()
    SetTimer CheckReconnectFile, 500
    global DetectInProgress := false
    Manafarm()
}
^n::
{
    global DetectInProgress := true
}


StageOne()
{
    Move("w", 3800)
}
StageTwo()
{
    Move("s", 1200)
    Move("a", 6000)
    Sleep 1000
}
StageThree()
{
    Send "{Space down}"
    Move("a", 4500)
    Send "{Space up}"
}
Manafarm()
{
    global RobloxWindows, idx, DetectInProgress

    if DetectInProgress
        return
    loop 3
    {
        Count := 0
        Loop RobloxWindows.Length
        {
            if DetectInProgress
                return
            Count++
            hwnd := RobloxWindows[idx]
            if !IsWindowAlive(hwnd) {
                RobloxWindows.RemoveAt(idx)
                continue
            }
            WinActivate "ahk_id " . hwnd
            WinWaitActive "ahk_id " . hwnd, , 1
            Sleep 200
            Send "r"
            Sleep 200
            if Count = RobloxWindows.Length
                break
            idx++
            if idx > RobloxWindows.Length
                idx := 1
        }
        detectFile := A_ScriptDir "\detect.txt"
        if !FileExist(detectFile)
        {
            FileAppend "1", detectFile
        }
        Sleep 7600
    }
    loop RobloxWindows.Length
    {
        hwnd := RobloxWindows[idx]

        WinActivate "ahk_id " . hwnd
        WinWaitActive "ahk_id " . hwnd, , 1
        Sleep 200
        StageOne()
        Sleep 200
        idx++
        if idx > RobloxWindows.Length
            idx := 1
    }
    loop 3
    {
        Count := 0
        Loop RobloxWindows.Length
        {
            if DetectInProgress
                return
            Count++
            hwnd := RobloxWindows[idx]
            if !IsWindowAlive(hwnd) {
                RobloxWindows.RemoveAt(idx)
                continue
            }
            WinActivate "ahk_id " . hwnd
            WinWaitActive "ahk_id " . hwnd, , 1
            Sleep 200
            Send "r"
            Sleep 200
            if Count = RobloxWindows.Length
                break
            idx++
            if idx > RobloxWindows.Length
                idx := 1
        }
        detectFile := A_ScriptDir "\detect.txt"
        if !FileExist(detectFile)
        {
            FileAppend "1", detectFile
        }
        Sleep 7600
    }
    idx := 1
    loop RobloxWindows.Length
    {
        hwnd := RobloxWindows[idx]

        WinActivate "ahk_id " . hwnd
        WinWaitActive "ahk_id " . hwnd, , 1
        Sleep 200
        StageTwo()
        Sleep 200
        idx++
        if idx > RobloxWindows.Length
            idx := 1
    }
    loop 3
    {
        Count := 0
        Loop RobloxWindows.Length
        {
            if DetectInProgress
                return
            Count++
            hwnd := RobloxWindows[idx]
            if !IsWindowAlive(hwnd) {
                RobloxWindows.RemoveAt(idx)
                continue
            }
            WinActivate "ahk_id " . hwnd
            WinWaitActive "ahk_id " . hwnd, , 1
            Sleep 200
            Send "r"
            Sleep 200
            if Count = RobloxWindows.Length
                break
            idx++
            if idx > RobloxWindows.Length
                idx := 1
        }
        detectFile := A_ScriptDir "\detect.txt"
        if !FileExist(detectFile)
        {
            FileAppend "1", detectFile
        }
        Sleep 7600
    }
    idx := 1
    loop RobloxWindows.Length
    {
        hwnd := RobloxWindows[idx]

        WinActivate "ahk_id " . hwnd
        WinWaitActive "ahk_id " . hwnd, , 1
        Sleep 200
        StageThree()
        Sleep 200
        idx++
        if idx > RobloxWindows.Length
            idx := 1
    }
    loop 3
    {
        Count := 0
        Loop RobloxWindows.Length
        {
            if DetectInProgress
                return
            Count++
            hwnd := RobloxWindows[idx]
            if !IsWindowAlive(hwnd) {
                RobloxWindows.RemoveAt(idx)
                continue
            }
            WinActivate "ahk_id " . hwnd
            WinWaitActive "ahk_id " . hwnd, , 1
            Sleep 200
            Send "r"
            Sleep 200
            if Count = RobloxWindows.Length
                break
            idx++
            if idx > RobloxWindows.Length
                idx := 1
        }
        detectFile := A_ScriptDir "\detect.txt"
        if !FileExist(detectFile)
        {
            FileAppend "1", detectFile
        }
        Sleep 7600
    }
    idx := 1
    loop RobloxWindows.Length
    {
        hwnd := RobloxWindows[idx]

        WinActivate "ahk_id " . hwnd
        WinWaitActive "ahk_id " . hwnd, , 1
        Sleep 200
        Send "2"
        Sleep 200
        idx++
        if idx > RobloxWindows.Length
            idx := 1
    }
    Manafarm()

}