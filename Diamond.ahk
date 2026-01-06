#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"

; ================= CONFIG =================
RECONNECT_FILE := "reconnect.txt"  ; MUST match Python
; =========================================
global Code := ""
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
; Reconnect()
; {
;     Critical
;     CoordMode("Mouse", "Screen")  ; Use screen coordinates

;     ; Stop actions during reconnect
;     SetTimer DoActions, 0

;     ; Make sure Roblox exists
;     if !WinExist("Roblox")
;         return

;     WinActivate "Roblox"
;     WinWaitActive "Roblox", , 2
;     Sleep 2000

;     Click 315, 578
;     Sleep 8000
;     Click 1300, 220, 2
;     Sleep 30000

;     SetTimer DoActions, 100
;     CoordMode("Mouse", "Client")  ; Use screen coordinates
;     Click 241, 568   ; any guaranteed in-game area
;     Sleep 200

;     SetTimer DoActions, 100
; }
Reconnect()
{
    Critical
    global Code
    SetTimer DoActions, 0

    if !WinExist("Roblox")
        return

    WinActivate "Roblox"
    WinWaitActive "Roblox", , 2
    Sleep 2000

    ; Click the input box directly
    Click 399, 169, 2
    Sleep 1000

    ; Force focus click (IMPORTANT)
    Click 406, 171, 2
    Sleep 1000

    ; Now type the code
    Send Code
    Sleep 2000
    Send "{Enter}"
    Sleep 1000

    Click 241, 568   ; any guaranteed in-game area
    Sleep 1000 
    Click 200, 550
    Sleep 2000
    Send Code
    Sleep 2000
    Send "{Enter}"
    Sleep 1000
    SetTimer DoActions, 100

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

^p::
{
    CheckReconnectFile()
    global Code
    Send Code
}

