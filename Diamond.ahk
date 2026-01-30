#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"

RECONNECT_FILE := "reconnect.txt"  ; 
global Code := ""
global Pos := ""
global Coord := [171,226,274,321,373,422,473,523,574,624]
global CoordY := 234

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

^y::ExitApp

DoActions()
{
    Send "r"
    Send "e"
    ; Send "2"
    ; Click "Left"
}

Reconnect()
{
    Critical
    global Code
    SetTimer DoActions, 0
    SetTimer CheckReconnectFile, 0

    if !WinExist("Roblox")
        return

    WinActivate "Roblox"
    WinWaitActive "Roblox", , 2
    Sleep 2000

    ; Click the input box directly
    MouseMove 363, 142
    Sleep 1000

    Click 383, 143
    Sleep 1000
    SetTimer CheckReconnectFile2, 1000

}
Reconnect2()
{
    Critical
    global Code
    global Pos
    global Coord
    global CoordY
    SetTimer CheckReconnectFile2, 0

    digitToIndex := Map()

    Position := StrSplit(Pos)
    for i, d in Position
    {
        digitToIndex[d] := i
    }

    Codes := StrSplit(Code)

    for c in Codes
    {
        idx := digitToIndex[c]

        if idx
        {
            MouseMove Coord[idx], CoordY
            Sleep 200
            Click Coord[idx], CoordY+10
            Sleep 200
        }
    }

    SetTimer CheckReconnectFile, 1000
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
CheckReconnectFile2()
{
    global RECONNECT_FILE

    if FileExist(RECONNECT_FILE)
    {
        global Pos
        Pos := Trim(FileRead(RECONNECT_FILE))
        FileDelete RECONNECT_FILE
        Reconnect2()
    }
}

^p::
{
    CheckReconnectFile()
    global Code
    Send Code
}

^z::{
    digits := "0987643215"
    a := StrSplit(digits)

    MsgBox a[1]  ; 0
    MsgBox a[2]  ; 9
    MsgBox a[10] ; 5
}