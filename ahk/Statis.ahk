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
    ; SetTimer StatisCheck, 1000
    SetTimer StandStillAFK, 100

}
^l::
{
    SetTimer DoThis, 100
}



DoThis()
{
    Send "e"
    Send "r"
}
; ========================================
; STOP MACRO (CTRL + N)
; ========================================
^n::
{
    global DetectInProgress
    DetectInProgress := true
    SetTimer StatisCheck, 0
    SetTimer StandStillAFK, 0
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
    ; Sleep 100
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
            Sleep 200
        }
    }
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
    ; SetTimer StatisCheck, 1000
    SetTimer StandStillAFK, 1000
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
        Sleep 100
        Send "a"
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
                Sleep 200
            }
        }
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

StandStillAFK()
{
    global RobloxWindows, idx, DetectInProgress, Code

    Loop RobloxWindows.Length
    {
        if DetectInProgress
            return
        hwnd := RobloxWindows[idx]
        Activate(hwnd)
        Send "2"
        Send "r"

        idx++
        if idx > RobloxWindows.Length
            idx := 1
    }
    TimeElapse := 0
    Loop RobloxWindows.Length
    {
        if DetectInProgress
            return

        Index := RobloxWindows.Length - A_Index + 1
        hwnd := RobloxWindows[Index]

        if !IsWindowAlive(hwnd)
            continue

        Activate(hwnd)

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
                Sleep 200
            }
        }

        TimeElapse += 3000
        Sleep 3000

        CheckReconnectFile()
        TimeElapse += 500
        Sleep 500

        if Code
        {
            TimeElapse += 6700
            Reconnect()
            Code := ""
            Break
        }
    }
    Sleep Max(0, 36500 - TimeElapse)
}