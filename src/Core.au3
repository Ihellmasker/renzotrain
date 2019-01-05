#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <FontConstants.au3>
#include <WindowsConstants.au3>
#include <AutoItConstants.au3>
#include <Include\ImageSearch.au3>
#include <File.au3>
;just For debug _ArrayDisplay
#include <Array.au3>

; 
Global $NoxWindow = 0
Global $consoleLog


Global $completedLoops = 0
Global $maxLoops = 1
Global $stopCommands = False

Global $idCycleStart
Global $idCycleStop

Opt("GUIOnEventMode", 1)

_Main()

Func _Main()
   ; Create a GUI with various controls.
   Local $hGUI = GUICreate("The Renzotrain", 600, 600)

   ; Build Console Log
   $consoleLog = GUICtrlCreateEdit("[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Welcome to the Renzotrain!", 0, 500, 600, 100, $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_READONLY)
   GUICtrlSetFont($consoleLog, 10, $FW_NORMAL, $GUI_FONTNORMAL, "Consolas")
   GUICtrlSetBkColor($consoleLog, $COLOR_WHITE)

   ; Tabs
   GUICtrlCreateTab(0, 0, 600, 500)

   ; Cycle Quest Tab
   GUICtrlCreateTabItem("Cycle Quest")
   $idCycleStart = GUICtrlCreateButton("Start", 20, 30, 120, 25)
   $idCycleStop = GUICtrlCreateButton("Stop", 145, 30, 120, 25)
   GUICtrlSetState($idCycleStop, $GUI_DISABLE)
   GUICtrlCreateTabItem("Settings")

   GUICtrlSetOnEvent($idCycleStart, "BtnCycleStart")
   GUICtrlSetOnEvent($idCycleStop, "BtnCycleStop")

   GUISetOnEvent($GUI_EVENT_CLOSE, "Exit")

   GUISetState() ; display the GUI

   While 1
	  Sleep(1000)
   WEnd
EndFunc   ;==>Example

Func BtnCycleStart()
   GUICtrlSetState($idCycleStart, $GUI_DISABLE)
   $stopCommands = False
   AttachToNox()
   If ValidWindow() Then
	  GUICtrlSetState($idCycleStop, $GUI_ENABLE)
	  GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Starting in 5 seconds", 1)
	  $completedLoops = 0;
	  WinActivate("NoxPlayer1-Android5.1.1")
	  Sleep(5000)
	  StartCycleQuest(0)
   EndIf
EndFunc

Func BtnCycleStop()
   GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Stopping", 1)
   $stopCommands = True
   GUICtrlSetState($idCycleStart, $GUI_ENABLE)
   GUICtrlSetState($idCycleStop, $GUI_DISABLE)
EndFunc

Func MouseTouch($mX, $mY)
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

Func StartCycleQuest($waitCount)
   If $stopCommands Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Cycle\QuestSelect.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  $completedLoops = $completedLoops + 1
	  MouseTouch($iX, $iY)
	  Sleep(1000)
	  StartQuest_Step1(0)
   Else
	  If $waitCount < 60 Then
		 Sleep(1000)
		 StartCycleQuest($waitCount + 1)
	  Else
		 GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found the Quest Button, Quitting", 1)
	  EndIf
   EndIf
EndFunc

Func StartQuest_Step1($waitCount) ; Press Begin
   If $stopCommands Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Cycle\1stBegin.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Starting Quest - Loop " & $completedLoops, 1)
	  MouseTouch($iX, $iY)
	  StartQuest_Step2(0)
   Else
	  If $waitCount < 5 Then
		 Sleep(1000)
		 StartQuest_Step1($waitCount + 1)
	  Else
		 GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found the Begin Button, Quitting", 1)
	  EndIf
   EndIf
EndFunc

Func StartQuest_Step2($waitCount) ; Press Begin
   If $stopCommands Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Cycle\LastOnline.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Finding a friend", 1)
	  MouseTouch($iX, $iY)
	  StartQuest_Step3(0)
   Else
	  If $waitCount < 5 Then
		 Sleep(1000)
		 StartQuest_Step2($waitCount + 1)
	  Else
		 GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found a Friend Button, Quitting", 1)
	  EndIf
   EndIf
EndFunc

Func StartQuest_Step3($waitCount) ; Press Begin
   If $stopCommands Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Cycle\2ndBegin.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Starting Quest", 1)
	  MouseTouch($iX, $iY)
	  StartCombat()
   Else
	  If $waitCount < 5 Then
		 Sleep(1000)
		 StartQuest_Step3($waitCount + 1)
	  Else
		 GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found the Begin Button, Quitting", 1)
	  EndIf
   EndIf
EndFunc

Func StartCombat()
   If $stopCommands Then Return
   Combat_Attack(0)
EndFunc

Func Combat_Attack($waitCount)
   If $stopCommands Then Return
   GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Attempting BRV " & $waitCount, 1)
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0

   Local $img = ""
   If NOT Mod($waitCount, 2) Then
	  $img = @ScriptDir & "\Images\Cycle\BrvAttackPhys.png"
   Else
	  $img = @ScriptDir & "\Images\Cycle\BrvAttackMag.png"
   EndIf
   $iResult = _ImageSearchArea($img, 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  If Combat_AttackRenzo(0) Then
		 Combat_Attack(0)
	  Else
		 GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Doing BRV Attack", 1)
		 MouseTouch($iX, $iY)
		 Sleep(1000)
		 Combat_Attack(0)
	  EndIf
   Else
	  If $waitCount < 60 Then
		 If CheckIfCombatEnd() Then
			EndCombat(0)
		 Else
			Sleep(1000)
			Combat_Attack($waitCount + 1)
		 EndIf
	  Else
		 GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Never found an attack after 60 seconds, attempting to leave", 1)
		 EndCombat(0)
	  EndIf
   EndIf
EndFunc

Func Combat_AttackRenzo($waitCount)
   If $stopCommands Then Return
   GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Attempting Renz " & $waitCount, 1)
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Cycle\RenzokukenPlus.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] RRRRRenzooooo", 1)
	  MouseTouch($iX, $iY)
	  Sleep(2000)
	  Return True
   Else
	  If $waitCount < 10 Then
		 Sleep(1000)
		 Local $state = Combat_AttackRenzo($waitCount + 1)
		 If $state Then
			Return True
		 EndIf
	  Else
		 Return False
	  EndIf
   EndIf
EndFunc

Func CheckIfCombatEnd()
   If $stopCommands Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Cycle\Next.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  GUICtrlSetData($consoleLog, @CRLF & "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] Combat over", 1)
	  Return True
   Else
	  Return False
   EndIf
EndFunc

Func EndCombat($waitCount)
   If $stopCommands Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Cycle\Next.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  MouseTouch($iX, $iY)
	  EndCombat(0)
   Else
	  If $waitCount < 60 Then
		 If CheckIfBackToCycleQuestSelect() Then
			StartCycleQuest(0)
		 Else
			Sleep(1000)
			EndCombat($waitCount + 1)
		 EndIf
	  Else
		 EndCombat(0)
	  EndIf
   EndIf
EndFunc

Func CheckIfBackToCycleQuestSelect()
   If $stopCommands Then Return
   Local $iX = 0
   Local $iY = 0
   Local $iResult = 0
   $iResult = _ImageSearchArea(@ScriptDir & "\Images\Cycle\QuestSelect.png", 1, $NoxWindow[0], $NoxWindow[1], $NoxWindow[0] + $NoxWindow[2], $NoxWindow[1] + $NoxWindow[3], $iX, $iY, 50)
   If $iResult Then
	  Return True
   Else
	  Return False
   EndIf
EndFunc