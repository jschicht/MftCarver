#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Extracts raw $MFT records
#AutoIt3Wrapper_Res_Description=Extracts raw $MFT records
#AutoIt3Wrapper_Res_Fileversion=1.0.0.2
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Include <WinAPIEx.au3>
If $cmdline[0] = 0 Then
	$File = FileOpenDialog("Select file",@ScriptDir,"All (*.*)")
	If @error Then Exit
	$MFT_Record_Size = InputBox("Set MFT record size","Record size can be 1024 or 4096",1024)
	If @error then Exit
ElseIf StringInStr($cmdline[1],"PhysicalDrive")=0 And FileExists($cmdline[1]) = 0 Then
	ConsoleWrite("Input file does not exist: " & $cmdline[1] & @CRLF)
	$File = FileOpenDialog("Select file",@ScriptDir,"All (*.*)")
	If @error Then Exit
	$MFT_Record_Size = InputBox("Set MFT record size","Record size can be 1024 or 4096",1024)
	If @error then Exit
Else
	$File = $cmdline[1]
	$MFT_Record_Size = $cmdline[2]
EndIf
If $MFT_Record_Size <> 1024 And $MFT_Record_Size <> 4096 Then
	ConsoleWrite("Error MFT record size must be set correctly" & @CRLF)
	Exit
EndIf
ConsoleWrite("File: " & $File & @CRLF)
If $cmdline[0] = 2 Then
	$OutFile = $cmdline[2]
Else
	$OutFile = $File&".MFT"
EndIf
ConsoleWrite("OutFile: " & $OutFile & @CRLF)
If StringInStr($File,"PhysicalDrive") Then
	$DiskNumber = StringMid($File,14,StringLen($File)-13)
	$DiskInfo = _WinAPI_GetDriveGeometryEx($DiskNumber)
	$FileSize = $DiskInfo[5]
Else
	$FileSize = FileGetSize($File)
EndIf
If $FileSize = 0 Then
	ConsoleWrite("Error retrieving file size" & @CRLF)
	Exit
EndIf
$hFile = _WinAPI_CreateFile("\\.\" & $File,2,2,7)
If $hFile = 0 Then ConsoleWrite("CreateFile: " & _WinAPI_GetLastErrorMessage() & @CRLF)
$rBuffer = DllStructCreate("byte ["&$MFT_Record_Size&"]")
$hFileOut = _WinAPI_CreateFile("\\.\" & $OutFile,3,6,7)
If $hFileOut = 0 Then ConsoleWrite("CreateFile: " & _WinAPI_GetLastErrorMessage() & @CRLF)
$JumpSize = $MFT_Record_Size
$SectorSize = $MFT_Record_Size
$NextOffset = 0
$nBytes = ""
$Timerstart = TimerInit()
Do
	If IsInt(Mod(($NextOffset * $JumpSize),$FileSize)/1000000) Then ConsoleWrite(Round((($NextOffset * $JumpSize)/$FileSize)*100,2) & " %" & @CRLF)
	_WinAPI_SetFilePointerEx($hFile, $NextOffset*$JumpSize, $FILE_BEGIN)
	_WinAPI_ReadFile($hFile, DllStructGetPtr($rBuffer), $SectorSize, $nBytes)
	$DataChunk = DllStructGetData($rBuffer, 1)
	If StringMid($DataChunk,3,8) <> "46494c45" Then
		$NextOffset+=1
		ContinueLoop
	EndIf
	$Written = _WinAPI_WriteFile($hFileOut, DllStructGetPtr($rBuffer), $SectorSize, $nBytes)
	If $Written = 0 Then ConsoleWrite("WriteFile: " & _WinAPI_GetLastErrorMessage() & @CRLF)
	$NextOffset+=1
;Until $NextOffset = ($JumpSize+$FileSize-Mod($FileSize,$JumpSize))/$JumpSize
Until $NextOffset * $JumpSize >= $FileSize
;$timerdiff = TimerDiff($begin)
;$timerdiff = Round(($timerdiff / 1000), 2)
;ConsoleWrite("Job took " & $timerdiff & " seconds" & @CRLF)
ConsoleWrite("Job took " & _WinAPI_StrFromTimeInterval(TimerDiff($Timerstart)))
_WinAPI_CloseHandle($hFile)
_WinAPI_CloseHandle($hFileOut)
Exit

Func _SwapEndian($iHex)
	Return StringMid(Binary(Dec($iHex,2)),3, StringLen($iHex))
EndFunc

Func _HexEncode($bInput)
    Local $tInput = DllStructCreate("byte[" & BinaryLen($bInput) & "]")
    DllStructSetData($tInput, 1, $bInput)
    Local $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", 0, _
            "dword*", 0)

    If @error Or Not $a_iCall[0] Then
        Return SetError(1, 0, "")
    EndIf
    Local $iSize = $a_iCall[5]
    Local $tOut = DllStructCreate("char[" & $iSize & "]")
    $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", DllStructGetPtr($tOut), _
            "dword*", $iSize)
    If @error Or Not $a_iCall[0] Then
        Return SetError(2, 0, "")
    EndIf
    Return SetError(0, 0, DllStructGetData($tOut, 1))
EndFunc  ;==>_HexEncode