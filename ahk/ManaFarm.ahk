#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"

RECONNECT_FILE := A_ScriptDir "\..\.\reconnect.txt"  ; 
global Code := ""
global Pos := ""
global Coord := [171,226,274,321,373,422,473,523,574,624,624]
global CoordY := 234
global RobloxWindows := []
global idx := 1
global DetectInProgress := false
global ManaStage := 0

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

Reconnect()
{
    Critical
    global Code
    global Coord
    global CoordY
    SetTimer CheckReconnectFile, 0
    SetTimer Manafarm, 0

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
    SetTimer CheckReconnectFile, 500
    SetTimer Manafarm, 1000   ; repeat every 500 ms
}
; ================= FILE WATCHER =================

LogoutAndClose()
{
    SetTimer CheckReconnectFile, 0
    SetTimer Manafarm, 0

    for hwnd in WinGetList("ahk_exe RobloxPlayerBeta.exe")
    {
        ; WinClose "ahk_id " hwnd
        ; Sleep 1000
        ; MouseMove 250, 550
        Sleep 500
        ; Click 300 , 550
    }
    SetTimer CheckReconnectFile, 500
    SetTimer Manafarm, 1000 
}

CheckReconnectFile()
{
    global RECONNECT_FILE

    if FileExist(RECONNECT_FILE)
    {
        global Code
        Code := Trim(FileRead(RECONNECT_FILE))
        FileDelete RECONNECT_FILE

        if (Code = "delete")
        {
            LogoutAndClose()
            return
        }

        Reconnect()
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
    global DetectInProgress, ManaStage
    ManaStage := 0
    DetectInProgress := false
    InitRobloxWindows()
    SetTimer CheckReconnectFile, 500
    SetTimer Manafarm, 1000   ; repeat every 500 ms
}

^n::
{
    global DetectInProgress, ManaStage
    ManaStage := 0
    DetectInProgress := true
    SetTimer Manafarm, 0
    SetTimer CheckReconnectFile, 0
}

StageOne()
{
    Move("w", 3600)
}
StageTwo()
{
    Move("s", 900)
    Move("a", 6000)
    Sleep 1000
}
StageThree()
{
    Send "{Space down}"
    Move("a", 4800)
    Send "{Space up}"
}
Manafarm()
{
    global RobloxWindows, idx, DetectInProgress, ManaStage

    if DetectInProgress
        return

    ; --- Stage 0: starting spot ---------------------------------------------------
    if (ManaStage = 0)
    {
        idx := 1
        loop RobloxWindows.Length
        {
            if DetectInProgress
                return
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
            Send "{Tab}"
            Sleep 1000
            TestCheck()
            Sleep 3000
            Send "{Tab}"
            detectFile := A_ScriptDir "\\..\detect.txt"
            if !FileExist(detectFile)
                FileAppend "1", detectFile
            Sleep 3500
        }
        idx := 1
        loop RobloxWindows.Length
        {
            if DetectInProgress
                return
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
        ManaStage := 1
    }

    ; --- Stage 1: after StageOne --------------------------------------------------
    if (ManaStage = 1)
    {
        idx := 1
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
            Send "{Tab}"
            Sleep 1000
            TestCheck()
            Sleep 3000
            Send "{Tab}"
            detectFile := A_ScriptDir "\\..\detect.txt"
            if !FileExist(detectFile)
                FileAppend "1", detectFile
            Sleep 3500
        }
        idx := 1
        loop RobloxWindows.Length
        {
            if DetectInProgress
                return
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
        ManaStage := 2
    }

    ; --- Stage 2: after StageTwo --------------------------------------------------
    if (ManaStage = 2)
    {
        idx := 1
        loop 1
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
            Send "{Tab}"
            Sleep 1000
            TestCheck()
            Sleep 3000
            Send "{Tab}"
            detectFile := A_ScriptDir "\\..\detect.txt"
            if !FileExist(detectFile)
                FileAppend "1", detectFile
            Sleep 3500
        }
        idx := 1
        loop RobloxWindows.Length
        {
            if DetectInProgress
                return
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
        ManaStage := 3
    }

    ; --- Stage 3: after StageThree ------------------------------------------------
    if (ManaStage = 3)
    {
        idx := 1
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
            Send "{Tab}"
            Sleep 1000
            TestCheck()
            Sleep 3000
            Send "{Tab}"
            detectFile := A_ScriptDir "\\..\detect.txt"
            if !FileExist(detectFile)
                FileAppend "1", detectFile
            Sleep 3500
        }
        ManaStage := 0
    }
}

^r::
{
  DoThis()
}
^e::{
    StageTwo()
}
^y::
{
    StageThree()
}
DoThis()
{
    StageOne()
}
^x::
{
    InitRobloxWindows()
    TestCheck()
}
^b::
{
    InitRobloxWindows()
    LogoutAndClose()
}
TestCheck()
{
    detectFile := A_ScriptDir "\\..\detect.txt"
        if !FileExist(detectFile)
            FileAppend "1", detectFile
}