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

; ================= ACTION LOOP =================

DoActions()
{
    Send "2"
    Send "e"
    Send "r"
    Click "Left"
}

; ================= RECONNECT =================

Reconnect()
{
    Critical

    ; Stop actions during reconnect
    SetTimer DoActions, 0

    ; Make sure Roblox exists
    if !WinExist("Roblox")
        return

    WinActivate "Roblox"
    WinWaitActive "Roblox", , 2
    Sleep 2000

    ; Leave
    Click 310, 386, 2
    Sleep 5000
    Click 310, 386, 2
    Sleep 3000

    ; Server
    Click 155, 416, 2
    Sleep 5000
    Click 155, 416, 2
    Sleep 8000

    ; Join
    Click 184, 433, 2
    Sleep 8000
    Click 184, 433, 2
    Sleep 2000


    ; Resume actions
    SetTimer DoActions, 100
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