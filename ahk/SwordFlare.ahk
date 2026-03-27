#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"

global RobloxWindows := []
global Running := false

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
    SetTimer LoopWindows, 100
}

; ========================================
; STOP LOOP (CTRL + B)
; ========================================
^b::
{
    global Running
    Running := false
    SetTimer LoopWindows, 0
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

; ========================================
; MAIN LOOP
; 1 -> 2 -> 3 -> STOP
; then restart from 1
; ========================================
LoopWindows()
{
    global RobloxWindows, Running

    if !Running
        return

    if RobloxWindows.Length = 0
        return

    ; always start from index 1
    Loop RobloxWindows.Length
    {
        if !Running
            return

        hwnd := RobloxWindows[A_Index]

        if !IsWindowAlive(hwnd)
            continue

        WinActivate "ahk_id " hwnd
        WinWaitActive "ahk_id " hwnd,,1

        Sleep 200
        Send "r"
        Sleep 200
    }
    SetTimer DoThis, 200
    Sleep 5000
    SetTimer DoThis, 0
    Sleep 100
}
DoThis()
{
    Click 300 , 300
}