#Requires AutoHotkey v2.0
#UseHook
SendMode "Event"

global RobloxWindows := []
RECONNECT_FILE := A_ScriptDir "\..\.\reconnect.txt"
global Code := ""
global Pos := ""
global Coord := [171,226,274,321,373,422,473,523,574,624,624]
global CoordY := 234
global idx := 1
global DetectInProgress := false


; ========================================
; START MACRO (CTRL + M)
; ========================================
^m::
{
    global DetectInProgress
    DetectInProgress := false
    InitRobloxWindows()
    SetTimer StatisCheck, 1000

}

; ========================================
; STOP MACRO (CTRL + N)
; ========================================
^n::
{
    global DetectInProgress
    DetectInProgress := true
    SetTimer StatisCheck, 0
}

; ^x::
; {
;     InitRobloxWindows()
;     TestCheck()
; }

; ^b::
; {
;     InitRobloxWindows()
; }

^k::
{
    hwnd := WinActive("A")
    MsgBox WinGetProcessName("ahk_id " hwnd)
}

; ========================================
IsWindowAlive(hwnd)
{
    return hwnd && WinExist("ahk_id " hwnd)
}

Activate(hwnd)
{
    DllCall("SetForegroundWindow", "ptr", hwnd)
    Sleep 200
}

InitRobloxWindows()
{
    global RobloxWindows, idx
    idx := 1
    RobloxWindows := []

    for hwnd in WinGetList("ahk_exe RobloxPlayerBeta.exe")
    {
        RobloxWindows.Push(hwnd)
    }
}

Move(Key, Second)
{
    SendEvent "{" . Key . " down}"
    Sleep Second
    SendEvent "{" . Key . " up}"
}

TestCheck()
{
    detectFile := A_ScriptDir "\\..\detect.txt"
    if !FileExist(detectFile)
        FileAppend "1", detectFile
}

CheckReconnectFile()
{
    global RECONNECT_FILE

    if FileExist(RECONNECT_FILE)
    {
        global Code
        Code := Trim(FileRead(RECONNECT_FILE))
        Sleep 500
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
    SetTimer StatisCheck, 1000
}

StatisCheck()
{
    global RobloxWindows, idx, DetectInProgress, Code
    Loop RobloxWindows.Length
    {
        if DetectInProgress
            return
        hwnd := RobloxWindows[idx]
        Activate(hwnd)
        detectFile := A_ScriptDir "\\..\detect.txt"
        if !FileExist(detectFile)
            FileAppend "1", detectFile
        Sleep 3000            
        CheckReconnectFile()
        if Code
        {
            Reconnect()
            Code := ""
            return
        }   
        Sleep 4600
        idx++
        if idx > RobloxWindows.Length
            idx := 1
    }
}

