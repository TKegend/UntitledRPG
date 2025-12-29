#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"

moveTimes := [3000, 6700, 3020, 6500] ; up, right, down, left (ms)
pauseTime := 3000
isPause := false
moveIndex := 0

; ---------- HOTKEYS ----------
^t::StartMacro()
^b::StopMacro()

; ---------- START ----------
StartMacro()
{
    global moveIndex, isPause
    moveIndex := 0
    isPause := false

    SetTimer DoActions, 100
    MovementController()
}

; ---------- STOP ----------
StopMacro()
{
    SetTimer DoActions, 0
    SetTimer MovementController, 0
    Send "{w up}{a up}{s up}{d up}"
}

; ---------- MAIN ACTIONS ----------
DoActions()
{
    Click "Left"
    SetTimer () => Send("e"), -30
    SetTimer () => Send("t"), -60
}

; ---------- MOVEMENT ----------
MovementController()
{
    global moveIndex, isPause, moveTimes, pauseTime

    ; always release movement keys
    Send "{w up}{a up}{s up}{d up}"

    if !isPause {
        ; movement just ended → DO pause actions ONCE
        PauseActions()

        isPause := true
        moveIndex := Mod(moveIndex + 1, 4)
        SetTimer MovementController, pauseTime
    } else {
        ; pause finished → start movement
        StartMove(moveIndex)
        isPause := false
        SetTimer MovementController, moveTimes[moveIndex + 1]
    }
}

; ---------- MOVEMENT HELPER ----------
StartMove(index)
{
    if (index = 0)
        Send "{w down}"
    else if (index = 1)
        Send "{d down}"
    else if (index = 2)
        Send "{s down}"
    else
        Send "{a down}"
}

; ---------- PAUSE ACTIONS ----------
PauseActions()
{
    keys := ["a", "w", "d", "s"]

    for key in keys {
        Send "{" key "}"
        Sleep 40
        Click "Left"
        Sleep 40
    }
}
