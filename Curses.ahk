#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"
CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"

moveLeft := true
moveLong := true
directionSwitches := 0
RECONNECT_FILE :=  "reconnect.txt"
^t::
{
    global moveLeft, directionSwitches, moveLong
    moveLeft := true 
    moveLong := true
    directionSwitches := 0
    KeyWait "Ctrl"
    SetTimer DoActions, 100
    SetTimer CheckReconnectFile, 1000  ; check every 1 secon
    MoveSideways()
}

^b::
{
    KeyWait "Ctrl"
    SetTimer DoActions, 0
    SetTimer MoveSideways, 0
    SetTimer CheckReconnectFile, 0  ; stop checking reconnect file
    StopMove()
}

^p::Reconnect()

DoActions()
{
    Click "Left"
    Send "e"
    Send "t"
    Send "r"
}


Reconnect()
{
    Critical
    SetTimer DoActions, 0

    ; Make sure Roblox Game Client exists
    if !WinExist("Roblox")
        return

    ; Activate Roblox window for consistency
    WinActivate "Roblox"
    WinWaitActive "Roblox", , 2
    Sleep 2000

    ; Leave
    Click 310, 386, 2
    Sleep 5000
    Click 310, 386, 2
    Sleep 2000

    ; Server
    Click 224, 345, 2
    Sleep 5000
    Click 224, 345, 2
    Sleep 8000

    ; Join
    Click 184, 433, 2
    Sleep 5000
    Click 184, 433, 2
    Sleep 20000


    Send "{Escape}"
    Sleep 2000
    Send "r"
    Sleep 2000

    Click 306, 360,2
    Sleep 4000
    Click 305, 360,2
    Sleep 5000

    Send "2"
    global moveLeft, directionSwitches
    moveLeft := true
    directionSwitches := 0
    SetTimer DoActions, 100
    MoveSideways()
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

        ; Stop movement/actions before reconnect
        SetTimer DoActions, 0
        SetTimer MoveSideways, 0
        StopMove()
        Reconnect()
    }
}

