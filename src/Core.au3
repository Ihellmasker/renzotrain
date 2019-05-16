#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <FontConstants.au3>
#include <WindowsConstants.au3>
#include <AutoItConstants.au3>
#include <ColorConstants.au3>

#include <GDIPlus.au3>
#Include <Misc.au3>
#include <Include\ImageSearch.au3>
#include <File.au3>
;just For debug _ArrayDisplay
#include <Array.au3>

Global $NoxWindow = 0
Global $hGUI
Global $consoleLog
Global $btnCycleStart
Global $btnCycleStop

Global $completedLoops = 0
Global $maxLoops = 1

Global $sqImg, $sqGraphic

Global $interrupt = False

Opt("GUIOnEventMode", 1)

; Create a GUI with various controls.
$hGUI = GUICreate("The Renzotrain", 650, 600)

; Build Console Log
$consoleLog = GUICtrlCreateEdit("[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Welcome to the Renzotrain!", 0, 500, 650, 100, $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_READONLY)
GUICtrlSetFont($consoleLog, 10, $FW_NORMAL, $GUI_FONTNORMAL, "Consolas")
GUICtrlSetBkColor($consoleLog, $COLOR_WHITE)

_GDIPlus_StartUp()
$sqImg = _GDIPlus_ImageLoadFromFile(@ScriptDir & "\Images\DFFOO_Squall.png")
$sqGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
WM_PAINT()
GUIRegisterMsg($WM_PAINT, "WM_PAINT")

; Tabs
GUICtrlCreateTab(0, 0, 450, 500)

; Cycle Quest Tab
GUICtrlCreateTabItem("Auto Quest")

$btnCycleStart = GUICtrlCreateButton("Start", 10, 30, 120, 40)
GUICtrlSetFont($btnCycleStart, 10)
GUICtrlSetOnEvent($btnCycleStart, "BtnCycleStart")

$btnCycleStop = GUICtrlCreateButton("Stop", 135, 30, 120, 40)
GUICtrlSetFont($btnCycleStop, 10)
GUICtrlSetState($btnCycleStop, $GUI_DISABLE)
GUICtrlSetOnEvent($btnCycleStop, "BtnCycleStop")



; Settings Tab
GUICtrlCreateTabItem("Settings")

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")

GUISetState() ; display the GUI

GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND")

While 1
   Sleep(10)
WEnd

_GDIPlus_GraphicsDispose($sqGraphic)
_GDIPlus_ImageDispose($sqImg)
_GDIPlus_ShutDown()

Func _Exit()
   Exit
EndFunc

Func WM_PAINT()
   _WinAPI_RedrawWindow($hGUI, "", "", BitOR($RDW_INVALIDATE, $RDW_UPDATENOW, $RDW_FRAME));
   _GDIPlus_GraphicsDrawImageRect($sqGraphic, $sqImg, 448, 25, 319, 476)
   Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_PAINT

Func _WM_COMMAND($hWnd, $Msg, $wParam, $lParam)
   ; The Func 2 button was pressed so set the flag
   If BitAND($wParam, 0x0000FFFF) =  $btnCycleStop Then $interrupt = true
   Return $GUI_RUNDEFMSG
EndFunc   ;==>_WM_COMMAND

Func _Interrupt_Sleep($iDelay)
   Local $iBegin = TimerInit()
   Do
      Sleep(10)
      If $interrupt Then
         Return True
      EndIf
   Until TimerDiff($iBegin) > $iDelay
   Return False
EndFunc   ;==>_Interrupt_Sleep

Func _Mouse_Touch($mX, $mY)
   MouseMove($mX, $mY)
   MouseDown($MOUSE_CLICK_PRIMARY)
   Sleep(100)
   MouseUp($MOUSE_CLICK_PRIMARY)
EndFunc

Func AttachToNox()
   $NoxWindow = WinGetPos("NoxPlayer1-Android5.1.1")
   If @error Then Exit
   If ValidWindow() Then
      GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Attached to Nox", 1)
   Else
	   GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Failed to attach to Nox. Is it minimised?", 1)
   EndIf
EndFunc

Func ValidWindow()
   If IsArray($NoxWindow) Then
	  Return True
   ElseIf $NoxWindow[0] = -32000 Then
	  Return False
   Else
	  Return False
   EndIf
EndFunc



Func BtnCycleStart()
   GUICtrlSetState($btnCycleStart, $GUI_DISABLE)
   $interrupt = False
   AttachToNox()
   If ValidWindow() Then
      BeginCycleQuest()
   EndIf
EndFunc

Func BtnCycleStop()
   GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Stopping", 1)
   $interrupt = True
   GUICtrlSetState($btnCycleStart, $GUI_ENABLE)
   GUICtrlSetState($btnCycleStop, $GUI_DISABLE)
EndFunc



Func BeginCycleQuest()
   GUICtrlSetState($btnCycleStop, $GUI_ENABLE)
   GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Starting in 3 seconds", 1)
   $completedLoops = 0;
   WinActivate("NoxPlayer1-Android5.1.1")
   If Not _Interrupt_Sleep(3000) Then
      FindCycleQuest(0)
   EndIf
EndFunc



Func FindCycleQuest($timeout)
   If $interrupt Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Searching for the Quest Button", 1)
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Quests\Cycle.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
      $completedLoops = $completedLoops + 1
      _Mouse_Touch($iX, $iY)
      If Not _Interrupt_Sleep(1000) Then
         StartQuest_Step1(0)
      EndIf
   Else
      If $timeout < 60 Then
         If Not _Interrupt_Sleep(1000) Then
            FindCycleQuest($timeout + 1)
         EndIf
      Else
         GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found the Quest Button, Quitting", 1)
      EndIf
   EndIf
EndFunc



Func StartQuest_Step1($timeout) ; Press Begin
   If $interrupt Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\GameUI\1stBegin.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
      GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Finding a friend", 1)
      _Mouse_Touch($iX, $iY)
      StartQuest_Step2(0)
   Else
      If $timeout < 5 Then
         If Not _Interrupt_Sleep(1000) Then
            StartQuest_Step1($timeout + 1)
         EndIf
      Else
         GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found the Begin Button, Quitting", 1)
      EndIf
   EndIf
EndFunc

Func StartQuest_Step2($timeout) ; Press Select a Friend
   If $interrupt Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\GameUI\LastOnline.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
      _Mouse_Touch($iX, $iY)
      StartQuest_Step3(0)
   Else
      If $timeout < 5 Then
         If Not _Interrupt_Sleep(1000) Then
            StartQuest_Step2($timeout + 1)
         EndIf
      Else
         GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found a Friend :(, Quitting", 1)
      EndIf
   EndIf
EndFunc

Func StartQuest_Step3($timeout) ; Press Begin again
   If $interrupt Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\GameUI\2ndBegin.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
      GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Starting Quest - Loop " & $completedLoops, 1)
      _Mouse_Touch($iX, $iY)
      StartCombat()
   Else
      If $timeout < 5 Then
         If Not _Interrupt_Sleep(1000) Then
            StartQuest_Step3($timeout + 1)
         EndIf
      Else
         GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found the Begin Button, Quitting", 1)
      EndIf
   EndIf
EndFunc



Func StartCombat()
   If $interrupt Then Return
   If Not _Interrupt_Sleep(3000) Then
      Combat_Attack(0)
   EndIf
EndFunc

Func Combat_Attack($timeout)
   If $interrupt Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   Local $img = ""
   If Mod($timeout, 3) = 0 Then
	   $img = @ScriptDir & "\Images\Combat\BRVAttackMag.png"
   ElseIf Mod($timeout, 3) = 1 Then
	   $img = @ScriptDir & "\Images\Combat\BRVAttackPhy.png"
   Else
	   $img = @ScriptDir & "\Images\Combat\BRVAttackRan.png"
   EndIf
   $iResult = _ImageSearchArea($img, 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
      If Combat_AttackRenzo(0) Then
         Combat_Attack(0)
      Else
         GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Doing BRV Attack", 1)
         _Mouse_Touch($iX, $iY)
         If Not _Interrupt_Sleep(3000) Then
            Combat_Attack(0)
         EndIf
      EndIf
   Else
      If $timeout < 120 Then
         If CheckIfCombatEnd() Then
            EndCombat(0)
         Else
            If Not _Interrupt_Sleep(500) Then
               Combat_Attack($timeout + 1)
            EndIf
         EndIf
      Else
         GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found an attack after 60 seconds, attempting to leave", 1)
         EndCombat(0)
      EndIf
   EndIf
EndFunc

Func Combat_AttackRenzo($timeout)
   If $interrupt Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Combat\RenzokukenPlus.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
      GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] RRRRRenzooooo", 1)
      _Mouse_Touch($iX, $iY)
      If Not _Interrupt_Sleep(300) Then
         Return True
      EndIf
   Else
      If $timeout < 6 Then
         If Not _Interrupt_Sleep(500) Then
            Local $state = Combat_AttackRenzo($timeout + 1)
            If $state Then
               Return True
            EndIf
         EndIf
      Else
         Return False
      EndIf
   EndIf
EndFunc

Func CheckIfCombatEnd()
   If $interrupt Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\GameUI\Next.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Combat over", 1)
	  Return True
   Else
	  Return False
   EndIf
EndFunc

Func EndCombat($timeout)
   If $interrupt Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\GameUI\Next.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  _Mouse_Touch($iX, $iY)
	  EndCombat(0)
   Else
      $iResult = _ImageSearchArea(@ScriptDir & "\Images\GameUI\Cross.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
      If $iResult Then
         _Mouse_Touch($iX, $iY)
         EndCombat(0)
      Else
         If $timeout < 60 Then
            If CheckIfBackToCycleQuestSelect() Then
               FindCycleQuest(0)
            Else
               If Not _Interrupt_Sleep(1000) Then
                  EndCombat($timeout + 1)
               EndIf
            EndIf
         Else
            EndCombat(0)
         EndIf
      EndIf
   EndIf
EndFunc

Func CheckIfBackToCycleQuestSelect()
   If $interrupt Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Quests\Cycle.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  Return True
   Else
	  Return False
   EndIf
EndFunc