#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"

; ================= CONFIG =================
RECONNECT_FILE := "reconnect.txt"  ; MUST match Python
; =========================================

^t::  ; START
{
    SetTimer DoActions, 100
    SetTimer CheckReconnectFile, 1000
}

^b::  ; STOP
{
    SetTimer DoActions, 0
    SetTimer CheckReconnectFile, 0
}
^e::Reconnect
^y::ExitApp

; ================= ACTION LOOP =================

DoActions()
{
    Send "2"
    Click "Left"
}

; ================= RECONNECT =================

Reconnect()
{
    Critical
    CoordMode("Mouse", "Screen")  ; Use screen coordinates

    ; Stop actions during reconnect
    SetTimer DoActions, 0

    ; Make sure Roblox exists
    if !WinExist("Roblox")
        return

    WinActivate "Roblox"
    WinWaitActive "Roblox", , 2
    Sleep 2000

    ; Leave
    Click 1894, 17
    Sleep 5000
    Click 1894, 17
    Sleep 3000

    ; Join
    Click 315, 676
    Sleep 8000
    Click 1300, 220, 2
    Click 1300, 220, 2



    ; Resume actions
    SetTimer DoActions, 100
    CoordMode("Mouse", "Client")  ; Use screen coordinates
    Click 400, 400   ; any guaranteed in-game area
    Sleep 200
}

; ================= FILE WATCHER =================

CheckReconnectFile()
{
    global RECONNECT_FILE

    if FileExist(RECONNECT_FILE)
    {
        FileDelete RECONNECT_FILE
        Reconnect()
    }
}