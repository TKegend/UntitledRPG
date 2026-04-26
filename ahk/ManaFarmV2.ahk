#Requires AutoHotkey v2.0
#UseHook
SendMode "Event"

global RobloxWindows := []
RECONNECT_FILE := A_ScriptDir "\..\.\reconnect.txt"
global Code := ""
global Pos := ""
global Coord := [171,226,274,321,373,422,473,523,574,624,624]
global Cycle := [1,1,1,1]
global CoordY := 234
global idx := 1
global DetectInProgress := false
global ManaStage := 0

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
; START MACRO (CTRL + M)
; ========================================
^m::
{
    global DetectInProgress, ManaStage
    ManaStage := 0
    DetectInProgress := false
    SetTimer Manafarm, 1000
}

; ========================================
; STOP MACRO (CTRL + N)
; ========================================
^n::
{
    global DetectInProgress, ManaStage
    DetectInProgress := true
    SetTimer Manafarm, 0
}

^e::
{
    StageTwo()
}

^y::
{
    StageThree()
}

^x::
{
    TestCheck()
}

^b::
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

Activate(hwnd, time)
{
    DllCall("SetForegroundWindow", "ptr", hwnd)
    Sleep time
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

StageOne()
{
    Move("w", 3300)
}

StageTwo()
{
    Move("a", 1500)
    Sleep 200
    Move("s", 1900)
    Sleep 200
    Move("a", 4000)
}

StageThree()
{
    SendEvent "{Space down}"
    Sleep 200
    Move("a", 4800)
    Sleep 200
    SendEvent "{Space up}"
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
    global Code, Coord, CoordY
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
    SetTimer Manafarm, 1000
}

Manafarm()
{
    global RobloxWindows, idx, DetectInProgress, ManaStage, Code, Cycle

    if DetectInProgress
        return

    ; --- Stage 0: starting spot ---------------------------------------------------
    if (ManaStage = 0)
    {
        loop RobloxWindows.Length
        {
            if DetectInProgress
                return
            hwnd := RobloxWindows[A_Index]
            Activate(hwnd, 200)
            SendEvent "2"
            Sleep 200
        }
        loop Cycle[1]
        {
            Loop RobloxWindows.Length
            {
                if DetectInProgress
                    return
                hwnd := RobloxWindows[A_Index]
                if !IsWindowAlive(hwnd)
                {
                    RobloxWindows.RemoveAt(A_Index)
                    continue
                }
                Activate(hwnd, 200)
                SendEvent "t"
                Sleep 200
            }
            Sleep 1000 - (400*(RobloxWindows.Length-1))
            Loop RobloxWindows.Length
            {
                if DetectInProgress
                    return
                hwnd := RobloxWindows[A_Index]
                if !IsWindowAlive(hwnd)
                {
                    RobloxWindows.RemoveAt(A_Index)
                    continue
                }
                Activate(hwnd, 200)
                SendEvent "r"
                Sleep 200
            }
            idx++
            if idx > RobloxWindows.Length
                idx := 1
            hwnd := RobloxWindows[idx]
            Activate(hwnd, 200)
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
            if ( A_Index = Cycle[1] )
            {   
                Sleep 200
                break
            }
            Sleep 5000
        }
        loop RobloxWindows.Length
        {
            if DetectInProgress
                return
            hwnd := RobloxWindows[A_Index]
            Activate(hwnd,200)
            StageOne()
            Sleep 200
        }
        ManaStage := 1
    }

    ; --- Stage 1: after StageOne --------------------------------------------------
    if (ManaStage = 1)
    {
        loop Cycle[2]
        {
            Loop RobloxWindows.Length
            {
                if DetectInProgress
                    return
                hwnd := RobloxWindows[A_Index]
                if !IsWindowAlive(hwnd)
                {
                    RobloxWindows.RemoveAt(A_Index)
                    continue
                }
                Activate(hwnd, 200)
                SendEvent "t"
                Sleep 200
            }
            Sleep 1000 - (400*(RobloxWindows.Length-1))
            Loop RobloxWindows.Length
            {
                if DetectInProgress
                    return
                hwnd := RobloxWindows[A_Index]
                if !IsWindowAlive(hwnd)
                {
                    RobloxWindows.RemoveAt(A_Index)
                    continue
                }
                Activate(hwnd, 200)
                SendEvent "r"
                Sleep 200
            }
            idx++
            if idx > RobloxWindows.Length
                idx := 1
            hwnd := RobloxWindows[idx]
            Activate(hwnd, 200)
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
            if ( A_Index = Cycle[2] )
            {   
                Sleep 200
                break
            }
                
            Sleep 5000
        }
        loop RobloxWindows.Length
        {
            if DetectInProgress
                return
            hwnd := RobloxWindows[A_Index]
            Activate(hwnd, 200)
            StageTwo()
            Sleep 200
        }
        ManaStage := 2
    }

    ; --- Stage 2: after StageTwo --------------------------------------------------
    if (ManaStage = 2)
    {
        loop Cycle[3]
        {
            Loop RobloxWindows.Length
            {
                if DetectInProgress
                    return
                hwnd := RobloxWindows[A_Index]
                if !IsWindowAlive(hwnd)
                {
                    RobloxWindows.RemoveAt(A_Index)
                    continue
                }
                Activate(hwnd, 200)
                SendEvent "r"
                Sleep 200
            }
            idx++
            if idx > RobloxWindows.Length
                idx := 1
            hwnd := RobloxWindows[idx]
            Activate(hwnd, 200)
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
            Sleep 200
        }
        loop RobloxWindows.Length
        {
            if DetectInProgress
                return
            hwnd := RobloxWindows[A_Index]
            Activate(hwnd,200)
            StageThree()
            Sleep 200
        }
        ManaStage := 3
    }

    ; --- Stage 3: after StageThree ------------------------------------------------
    if (ManaStage = 3)
    {
        loop Cycle[4]
        {
            Loop RobloxWindows.Length
            {
                if DetectInProgress
                    return
                hwnd := RobloxWindows[A_Index]
                if !IsWindowAlive(hwnd)
                {
                    RobloxWindows.RemoveAt(A_Index)
                    continue
                }
                Activate(hwnd, 200)
                SendEvent "t"
                Sleep 200
            }
            Sleep 1000 - (400*(RobloxWindows.Length-1))
            Loop RobloxWindows.Length
            {
                if DetectInProgress
                    return
                hwnd := RobloxWindows[A_Index]
                if !IsWindowAlive(hwnd)
                {
                    RobloxWindows.RemoveAt(A_Index)
                    continue
                }
                Activate(hwnd, 200)
                SendEvent "r"
                Sleep 200
            }
            idx++
            if idx > RobloxWindows.Length
                idx := 1
            hwnd := RobloxWindows[idx]
            Activate(hwnd, 200)
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
            Sleep 4000
        }
        ManaStage := 0
    }
}

