#Requires AutoHotkey v2.0
#UseHook
SendMode "Input"

RECONNECT_FILE := "reconnect.txt"  ; 
global Code := ""
global Pos := ""
global Coord := [171,226,274,321,373,422,473,523,574,624,624]
global CoordY := 234
global RobloxWindows := []
global idx := 1
global DetectInProgress := false
^t::  ; START
{
    InitRobloxWindows()
    DoActions()
    SetTimer CheckReconnectFile, 1000
}

^b::  ; STOP
{
    SetTimer DoActions, 0
    SetTimer CheckReconnectFile, 0
}

^y::ExitApp

InitRobloxWindows()
{
    global RobloxWindows, idx
    idx := 1
    RobloxWindows := []

    ; Get all Roblox client windows
    for hwnd in WinGetList("ahk_exe RobloxPlayerBeta.exe")
    {   
        RobloxWindows.Push(hwnd)
    }
}
IsWindowAlive(hwnd)
{
    return hwnd && WinExist("ahk_id " . hwnd)
}
; RButton::{
;     InitRobloxWindows()
;     hwnd := RobloxWindows[idx]
;     WinActivate "ahk_id " . hwnd
;     WinWaitActive "ahk_id " . hwnd, , 1
;     Sleep 200
;     Send "t"
;     Sleep 200
;     Send "e"
; }
DoActions()
{
    Critical
    global RobloxWindows, idx, DetectInProgress

    if DetectInProgress
        return
    Count := 0
    Loop RobloxWindows.Length
    {
        Count++
        hwnd := RobloxWindows[idx]
        if !IsWindowAlive(hwnd)
        {
            InitRobloxWindows()
            return
        }
        WinActivate "ahk_id " . hwnd
        WinWaitActive "ahk_id " . hwnd, , 1

        Sleep 200
        Send "2"
        Sleep 300
        ; MouseMove 55, 538
        ; Sleep 100
        Send "e"
        Sleep 1200
        Send "r"
        Sleep 200
     
        if Count = RobloxWindows.Length
            Break
        idx++
        if idx > RobloxWindows.Length
            idx := 1
    }



    detectFile := A_ScriptDir "\detect.txt"
    if FileExist(detectFile)
        FileDelete detectFile
    FileAppend "1", detectFile
    SetTimer DoActions, -2100
}

Reconnect()
{
    Critical
    global Code
    global DetectInProgress
    SetTimer DoActions, 0
    SetTimer CheckReconnectFile, 0
    DetectInProgress := true

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
    global DetectInProgress
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
            Sleep 500
            Click Coord[idx], CoordY+10
            Sleep 500
        }
    }

    SetTimer CheckReconnectFile, 1000
    SetTimer DoActions, 8000
    DetectInProgress := false
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

^l::
{
    detectFile := "detect.txt"


    if FileExist(detectFile)
        FileDelete detectFile

    FileAppend "1", detectFile
}