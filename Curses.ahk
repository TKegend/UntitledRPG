#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"
CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"
; ================= CONFIG =================
RECONNECT_FILE :=  "reconnect.txt"
^t::
{
    SetTimer DoActions, 100
    SetTimer CheckReconnectFile, 1000  ; check every 1 secon
}

^b::
{
    SetTimer DoActions, 0
    SetTimer CheckReconnectFile, 0  ; stop checking reconnect file
}

^p::Reconnect()

DoActions()
{
    Send "2"
    Click "Left"
    Send "e"
    Send "t"
    Send "r"
}


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

    ; ; Leave
    ; Click 1894, 17
    ; Sleep 5000
    ; Click 1894, 17
    ; Sleep 3000

    ; Join
    Click 315, 676
    Sleep 8000
    Click 1300, 220, 2
    Sleep 20000

    SetTimer DoActions, 100
    CoordMode("Mouse", "Client")  ; Use screen coordinates
    Click 400, 400   ; any guaranteed in-game area
    Sleep 200



    Send "{Escape}"
    Sleep 2000
    Send "r"
    Sleep 2000

    Click 306, 360,2
    Sleep 4000
    Click 305, 360,2
    Sleep 5000

    SetTimer DoActions, 100
}
StopMove()
{
    Send "{a up}"
    Send "{d up}"
}

MoveSideways()
{
    global moveLeft, directionSwitches, moveLong

    Send "{a up}"
    Send "{d up}"
    Sleep 1500

    if (directionSwitches >= 4)
    {
        Send "2"
        directionSwitches := 0
    }

    if (moveLong)
    {
        moveLeft := !moveLeft
        moveLong := !moveLong
        directionSwitches++
        Send moveLeft ? "{d down}" : "{a down}"
        nextDelay := 15000
    }
    else
    {
        moveLong := !moveLong
        Send moveLeft ? "{a down}" : "{d down}"
        nextDelay := 500
    }

    SetTimer MoveSideways, nextDelay
}
CheckReconnectFile()
{
    global RECONNECT_FILE

    if FileExist(RECONNECT_FILE)
    {
        FileDelete RECONNECT_FILE

        SetTimer DoActions, 0
        Reconnect()
    }
}

