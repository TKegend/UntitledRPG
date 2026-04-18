#Requires AutoHotkey v2.0
#UseHook
SendMode "Event"

global RobloxWindows := []

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
            ToolTip "Already added. Total: " RobloxWindows.Length
            SetTimer () => ToolTip(), -1000
            return
        }
    }

    RobloxWindows.Push(hwnd)
    ToolTip "Added window. Total: " RobloxWindows.Length
    SetTimer () => ToolTip(), -1000
}

; ========================================
; CLEAR WINDOW LIST (CTRL + SHIFT + P)
; ========================================
^+p::
{
    global RobloxWindows
    RobloxWindows := []
    ToolTip "Window list cleared."
    SetTimer () => ToolTip(), -1000
}

; ========================================
; BROADCAST — spawn one AHK process per window so they all
; activate + send in parallel (no sequential loop stall)
; ========================================
BroadcastKey(key)
{
    global RobloxWindows

    slaveScript := A_ScriptDir "\SendKeyToWindow.ahk"
    sent := 0

    for hwnd in RobloxWindows
    {
        if !WinExist("ahk_id " hwnd)
            continue
        Run 'AutoHotkey.exe "' slaveScript '" ' hwnd ' "' key '"', , "Hide"
        sent++
    }

    ToolTip "Broadcast sent to " sent " window(s)"
    SetTimer () => ToolTip(), -1000
}

; ========================================
; TEST BROADCAST (CTRL + T) — edit key as needed
; ========================================
^t::
{
    BroadcastKey("r")
}

^y::ExitApp

