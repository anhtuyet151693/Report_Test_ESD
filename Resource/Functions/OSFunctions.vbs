'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Script name: OSFunctions.vbs
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Option Explicit

Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8
Const ALL_USER_DESKTOP_PATH = "C:\Users\All Users\Desktop\"
Const EXCEL_PROCESS_NAME = "EXCEL.EXE"

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_RunApplication
'
' Description: Run applicaiton
'              
' Parameter:   
'	- strAppPath : Application path
'
' History: 
'	- 2011-12-22 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_RunApplication(strAppPath)
	SystemUtil.Run strAppPath
End Function

Public Function  OS_CloseApplication(byval sApplicationExe)
	Dim strComputer
	Dim objWMIService
	Dim colProcesses
	Dim objProcess
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

	Set colProcesses = objWMIService.ExecQuery ("Select * from Win32_Process Where Name = '" & sApplicationExe & "'")
	For Each objProcess in colProcesses
	objProcess.Terminate()
	Next
	Set objWMIService = Nothing
	Set colProcesses=Nothing
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: KillProcess
'
' Description: Kill a running process in Windows
'              
' Parameter:  
'	- strServerName 
'	- strProcessName : Process name
'
' History: 
'	- 2011-11-24 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_KillProcess(strServerName, strProcessName)
	Dim oWshShell
	Set oWshShell = CreateObject("Wscript.Shell")
	oWshShell.Run "taskkill /S \\" & strServerName & " /IM " & strProcessName & " /F /T", 2, True
	Set oWshShell = Nothing
End Function



'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_KillBrowsers
'
' Description: Close all IE & Firefox Browsers 
'              
' Parameter: No
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_KillBrowsers()
	strSQL = "Select * From Win32_Process Where Name = 'iexplore.exe' OR Name = 'firefox.exe'"
 
Set oWMIService = GetObject("winmgmts:\\.\root\cimv2")
Set ProcColl = oWMIService.ExecQuery(strSQL)
 
For Each oElem in ProcColl
    oElem.Terminate
Next
 
Set oWMIService = Nothing
wait(5)
End Function



'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: IsProcessRunning
'
' Description: Check if a process is running in Windows
'              
' Parameter:  
'	- strServerName
'	- strProcessName : Process name
'
' History: 
'	- 2013-05-23 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_IsProcessRunning(strComputer,strProcessName)
	Dim objWMIService, strWMIQuery
	strWMIQuery = "Select * from Win32_Process where name like '" & strProcessName & "'"
	Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
			
	If objWMIService.ExecQuery(strWMIQuery).Count > 0 Then
		OS_IsProcessRunning = True
	Else
		OS_IsProcessRunning = False
	End If
	Set objWMIService = Nothing 
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_CheckFolderExists
'
' Description: Check Folder Exists
'              
' Parameter:   
'	- strFolderPath : Folder Path
'
' Return value: 1: if folder exists; 0: if folder does not exist
'
' History: 
'	- 2011-11-24 | Initial Revision
'	- 2012-01-17 | Change return value
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CheckFolderExists(strFolderPath)
	Dim FSO, str
	Set FSO = CreateObject("Scripting.FileSystemObject")	
	If FSO.FolderExists(strFolderPath) Then
		OS_CheckFolderExists = 1
	Else
		OS_CheckFolderExists = 0
	End If  
	Set FSO = Nothing
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_CheckFileExists
'
' Description: Check File Exists
'              
' Parameter:   
'	- strFilePath : File Path
'
' Return value: True if folder exists; False if folde does not exist
'
' History: 
'	- 2011-11-26 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CheckFileExists(strFilePath)
	Dim FSO, str
	Set FSO = CreateObject("Scripting.FileSystemObject")	
	If FSO.FileExists(strFilePath) Then
		OS_CheckFileExists = True
	Else
		OS_CheckFileExists = False
	End If  
	Set FSO = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: CreateAFolder
'
' Description: Create A Folder
'              
' Parameter:   
'	- strFolderPath : Folder Path
'
' Return value: 
'
' History: 
'	- 2011-11-24 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CreateAFolder(strFolderPath)
	Dim FSO, str
	Set FSO = CreateObject("Scripting.FileSystemObject")	
	If OS_CheckFolderExists(strFolderPath) = 0 Then
		FSO.CreateFolder(strFolderPath)	
	End If  
	Set FSO = Nothing
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_CreateFolderByPath
'
' Description: Create Folder and Subfolders by path
'              
' Parameter:   
'	- strFolderPath : Folder Path
'
' Return value: 
'
' History: 
'	- 2012-02-16 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CreateFolderByPath(strFolderPath)
	Dim arr, i, strPath	
	arr = Split(strFolderPath, "\")
	strPath = arr(0) 
	For i = 1 To Ubound(arr)
		strPath = strPath & "\" & arr(i)
		OS_CreateAFolder strPath 
	Next
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: GenerateRandomData
'
' Description: Generate a Random Data
'              
' Parameter:   
'
' Return value: A radom number 
'	
' History: 
'	- 2011-12-14 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GenerateRandomData()
	Dim val
	Randomize
	val = Minute(Now) & Second(Now) 
	Wait 1
	val = val & Second(Now)
	val = Int(val * rnd)
	OS_GenerateRandomData = val
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GenerateRandomNumber
'
' Description: Generate a Random Data
'              
' Parameter:   
'	- lowerbound
'	- upperbound
'
' Return value: A radom number 
'	
' History: 
'	- 2012-03-20 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GenerateRandomNumber(lowerbound, upperbound)
	Randomize
	OS_GenerateRandomNumber = Int((upperbound - lowerbound + 1) * Rnd + lowerbound)	
End Function



'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_CountFiles
'
' Description: Count Files in a Folder
'              
' Parameter:   
'	- strFolderPath : Folder Path
' History: 
'	- 2012-03-20 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CountFiles(strFolderPath)
	Dim oFS, oFolder
	Set oFS = CreateObject("Scripting.FileSystemObject")     	
	If oFS.FolderExists(strFolderPath) Then
		Set oFolder = oFS.GetFolder(strFolderPath)
		OS_CountFiles = oFolder.Files.Count
		Set oFolder = Nothing
		Exit Function
	End If
	OS_CountFiles = -1
	Set oFS = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_CountFolderAndFile
'
' Description: Count Subfolders and Files in a Folder
'              
' Parameter:   
'	- strFolderPath : Folder Path
'
' History: 
'	- 2012-03-20 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CountFolderAndFile(strFolderPath)
	Dim oFS, oFolder
	Set oFS = CreateObject("Scripting.FileSystemObject")     	
	If oFS.FolderExists(strFolderPath) Then
		Set oFolder = oFS.GetFolder(strFolderPath)
		OS_CountFolderAndFile = oFolder.Files.Count + oFolder.SubFolders.Count
		Set oFolder = Nothing
		Exit Function
	End If
	OS_CountFolderAndFile = -1
	Set oFS = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GetDesktopPath
'
' Description: Get Desktop Path
'              
' Parameter:   
'	
' Return value: Desktop folder path
'
' History: 
'	- 2012-03-20 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GetDesktopPath()
	Dim WSHShell
	Set WSHShell = CreateObject("WScript.Shell")
	GetDesktopPath = WSHShell.SpecialFolders("Desktop")
	Set WSHShell = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_Check64BitSystem
'
' Description: Check 64 bit OS system
'              
' Parameter:   
'	
' Return value: 
'	- True : System is 64bit
'	- Flase: System is 32bit
'
' History: 
'	- 2011-12-28 | Initial Revision
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_Check64BitSystem()
	If instr(Environment("ProductDir"),"(x86)") Then
		OS_Check64BitSystem = True
	Else
		OS_Check64BitSystem = False
	End If
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_DeleteFile
'
' Description: Delete a file
'              
' Parameter:   
'	- strFilePath: File path
'
' Return value: 1: if file is deleted; Others: if file is not deleted
'
' History: 
'	- 2011-12-28 | Initial Revision
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_DeleteFile(strFilePath)
	Dim FSO, str
	Set FSO = CreateObject("Scripting.FileSystemObject")	
	If FSO.FileExists(strFilePath) Then
		FSO.DeleteFile(strFilePath)
	End If
	If FSO.FileExists(strFilePath) Then
		OS_DeleteFile = 1
	Else
		OS_DeleteFile = 0
	End If
	Set FSO = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_DeleteFolder
'
' Description: Delete a folder
'              
' Parameter:   
'	- strFolderPath: Folder path
'
' Return value: 1: if file is deleted; 0: if file is not deleted
'
' History: 
'	- 2012-01-17 | Initial Revision
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_DeleteFolder(strFolderPath)
	Dim FSO 
	Set FSO = CreateObject("Scripting.FileSystemObject")	
	If FSO.FolderExists(strFolderPath) Then
		FSO.DeleteFolder strFolderPath,True		
	End If
	If FSO.FolderExists(strFolderPath) Then
		OS_DeleteFolder = 0
	Else
		OS_DeleteFolder = 1
	End If
	Set FSO = Nothing
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_CheckFolderPathExist
'
' Description: Check Folders exist from left to right of the path
'              
' Parameter:   
'	- strFolderPath: Folder path
'
' History: 
'	- 2011-12-28 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CheckFolderPathExist(strFolderPath)
	Dim arr, i, j, strPath, rc
	arr = Split(strFolderPath, "\")
	For i = 2 To Ubound(arr)	
		For j = 0 To i-1
			If j <> 0 Then
				strPath = strPath & "\"
			End If
			strPath = strPath & CStr(arr(j))
		Next
		rc = OS_CheckFolderExists(strPath & "\" & arr(i))
		If rc <> 1 Then
			print "Folder not exist: " & strPath & "\" & arr(i)
			OS_CheckFolderPathExist = -1
			Exit Function
		End If
		strPath = ""
	Next
	OS_CheckFolderPathExist = 1
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_ShareFolder
'
' Description: Share a folder
'              
' Parameter:   
'	- strShareName: Share Name
'	- strFolderPath: Folder path
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_ShareFolder(strShareName, strFolderPath)
	Dim strCommand
	'Check and Create If Folder not exist
	If OS_CheckFolderExists(strFolderPath) = 0 Then
		OS_CreateAFolder(strFolderPath)
	End If
	'Share folder
	strCommand = "Net Share " & strShareName & "=" & strFolderPath & " /GRANT:Everyone,FULL"
	OS_RunDosCommand(strCommand)
	'Check if folder is shared
	If OS_CheckFolderExists("\\" & LOCAL_HOST_NAME & "\" & strShareName) = 0 Then
		OS_ShareFolder = -1
	Else
		OS_ShareFolder = 1
	End If
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_RunDosCommand
'
' Description: Run a DOS command
'              
' Parameter:   
'	- strCommand: Dos command 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_RunDosCommand(strCommand)
	Dim oWshShell
	Set oWshShell = CreateObject("Wscript.Shell")	
	oWshShell.Run "cmd /C """ &  strCommand & """", 0
	Set oWshShell = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_Verify_ArrayCheckboxes_Value
'
' Description: Verify value of an array of check boxes
'              
' Parameter:   
'	- arrCheckboxes: Array of check box objects
'	- strExpectedValue: "ON": Checked; "OFF": Unchecked
'
' Return value: 1: Correct; Others: Incorrect
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_Verify_ArrayCheckboxes_Value(arrCheckboxes, strExpectedValue)
	Dim i
	For i = 0 To Ubound(arrCheckboxes)
		If arrCheckboxes(i).CheckProperty("checked", strExpectedValue) = False Then
			ReportAction -1, "OS_Verify_ArrayCheckboxes_Value", "Value of the check box " & arrCheckboxes(i) & " should be " & strExpectedValue
			OS_Verify_ArrayCheckboxes_Value = -1
			Exit Function
		End If			
	Next	
	ReportAction 1, "OS_Verify_ArrayCheckboxes_Value", "Value of all check boxes are correct"
	OS_Verify_ArrayCheckboxes_Value = 1	
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_StartService
'
' Description: Start a window service
'              
' Parameter:   
'	- strServiceName: Service Name
'
' Return value: 1: Correct; Others: Incorrect
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_StartService(strServiceName)
	Dim rc
	Dim objShell, blnStatus 
	
	Set objShell= CreateObject("Shell.Application")
	blnStatus = objShell.IsServiceRunning(strServiceName)

	If blnStatus = True Then
		OS_StartService = 0
		Exit Function
	End If

	rc = objShell.ServiceStart(strServiceName, False)
	If rc = False Then
		OS_StartService = -1
	Else
	   OS_StartService = 1
	End If
   
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_StopService
'
' Description: Stop a window service
'              
' Parameter:   
'	- strServiceName: Service Name
'
' Return value: 1: Correct; Others: Incorrect
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_StopService(strServiceName)
	Dim rc
	Dim objShell, blnStatus 

	Set objShell= CreateObject("Shell.Application")
	blnStatus = objShell.IsServiceRunning(strServiceName)

	If blnStatus = False Then
		OS_StopService = 0
		Exit Function
	End If

	rc = objShell.ServiceStop(strServiceName, False)
	If rc = False Then
		OS_StopService = -1	
	Else
		OS_StopService = 1
	End If

End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GetServiceStatus
'
' Description: Get status of a window service
'              
' Parameter:   
'	- strServiceName: Service Name
'
' Return value: 1: Correct; Others: Incorrect
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GetServiceStatus(strServerName, strServiceName)
	Dim strTempFile
	strTempFile = "C:\WINDOWS\ServiceState.txt"
	OS_RunDosCommand("SC \\" & strServerName & " QUERY " & strServiceName & " > " & strTempFile) 
	Dim oFS, oFile
	Set oFS = CreateObject("Scripting.FileSystemObject")
	Set oFile = oFS.OpenTextFile(strTempFile, 1)
	Dim strLine
	While oFile.AtEndOfStream <> True
		strLine = oFile.ReadLine()
		If InStr(1, strLine, "STATE") > 0 Then
			arr = Split(strLine," ")
			OS_GetServiceStatus = arr(Ubound(arr)-1)
			Exit Function
		End If
	Wend
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_SearchTextInAFile
'
' Description: Search Text In A Text File
'              
' Parameter:   
'	- strFilePath : File Path
'	- strTextToSearch : Text to Search
'
' Return value: 1: Text found; -1: File not exists; -2: Text not found
'
' History: 
'	- 2012-02-03 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_SearchTextInAFile(strFilePath, strTextToSearch)
	Dim FSO, oFile
	Set FSO = CreateObject("Scripting.FileSystemObject")	
	If Not FSO.FileExists(strFilePath) Then
		ReportAction -1, "OS_SearchTextInAFile", "File '" & strFilePath & "' does not exist"
		OS_SearchTextInAFile = -1		
	End If
	Set oFile = FSO.OpenTextFile(strFilePath, 1)
	While oFile.AtEndOfStream <> True
		strLine = oFile.ReadLine()
		If InStr(strLine, strTextToSearch) > 0 Then
			ReportAction 1, "OS_SearchTextInAFile", "Text '" & strTextToSearch & "' found in file '" & strFilePath & "'"
			OS_SearchTextInAFile = 1     
			oFile.Close
			Set FSO = Nothing
			Exit Function
		End If
	Wend	
	ReportAction -2, "OS_SearchTextInAFile", "Text '" & strTextToSearch & "' not found in file '" & strFilePath & "'"
	OS_SearchTextInAFile = -2
	oFile.Close
	Set FSO = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_ReplaceTextInAFile
'
' Description: Replace Text in A Text File 
'              
' Parameter:   
'	- strFilePath : File Path
'	- strTextToSearch : Text to Search
'	- strTextToReplace: Text to Replace
'
' Return value: 1: Replace successfully; -1: File not exists
'
' History: 
'	- 2012-02-03 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_ReplaceTextInAFile(strFilePath, strTextToSearch, strTextToReplace)
	Dim FSO, oFile, strOldText, strNewText
	Set FSO = CreateObject("Scripting.FileSystemObject")	
	If Not FSO.FileExists(strFilePath) Then
		ReportAction -1, "OS_ReplaceTextInAFile", "File '" & strFilePath & "' does not exist"
		OS_ReplaceTextInAFile = -1		
	End If
	Set oFile = FSO.OpenTextFile(strFilePath, 1)
	strOldText = oFile.ReadAll
	oFile.Close
	strNewText = Replace(strOldText, strTextToSearch, strTextToReplace)
	Set oFile = FSO.OpenTextFile(strFilePath, 2)
	oFile.WriteLine strNewText
	oFile.Close    	
	Set FSO = Nothing
	ReportAction 1, "OS_ReplaceTextInAFile", "Replace text successfully"
	OS_ReplaceTextInAFile = 1
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_CopyFile
'
' Description: Copy a File to a Folder
'              
' Parameter:   
'	- strSourceFile : Source File Path
'	- strDestination: Destination Folder
'
' Return value: 1: Copy successfully; -1: File not exists
'
' History: 
'	- 2012-02-03 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CopyFile(strSourceFile, strDestination)
	Dim FSO, oFile, strOldText, strNewText
	Set FSO = CreateObject("Scripting.FileSystemObject")	
	If Not FSO.FileExists(strSourceFile) Then
		ReportAction -1, "OS_CopyFile", "File '" & strSourceFile & "' does not exist"
		OS_CopyFile = -1		
	End If
	If Right(strDestination, 1) <> "\" Then
		strDestination = strDestination & "\" 
	End If
	FSO.CopyFile strSourceFile, strDestination, True
	Set FSO = Nothing
	ReportAction 1, "OS_CopyFile", "Copy file '" & strSourceFile & "'" & " to '" & strDestination & "' successfully"
	OS_CopyFile = 1
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GetClipboardText
'
' Description: Get text in windows clipboard
'              
' Parameter:   
'
' Return value: Text in windows clipboard
'
' History: 
'	- 2012-02-07 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GetClipboardText()
	Set Clip = CreateObject("Mercury.Clipboard")
	OS_GetClipboardText = Clip.GetText()
	Set Clip = Nothing
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GetClipboardText
'
' Description: Get text in windows clipboard
'              
' Parameter:   
'
' Return value: Text in windows clipboard
'
' History: 
'	- 2012-02-07 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CheckClipboardText(strTextToCheck)
	If strTextToCheck <> OS_GetClipboardText() Then
		OS_CheckClipboardText = -1
	Else
		OS_CheckClipboardText = 1
	End If
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_RunRegistryFile
'
' Description: Run Registry File
'              
' Parameter:   
'
' Return value: 
'
' History: 
'	- 2012-02-23 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_RunRegistryFile(strRegistryFileName)
   Dim objShell
   Set objShell = CreateObject("Wscript.Shell")
   objShell.Run "Regedit.exe /s " & REGISTRY_FOLDER & strRegistryFileName 	
   Set objShell = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_CompareTextFiles
'
' Description: 
'              
' Parameter:   
'	- strFilePath1: 
'	- strFilePath2: 
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CompareTextFiles(strFilePath1, strFilePath2)
	Dim fso, f1, f2, text1, text2, rc
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set f1 = fso.OpenTextFile(strFilePath1, ForReading)
	Set f2 = fso.OpenTextFile(strFilePath2, ForReading)
	text1 = f1.ReadAll
	text2 = f2.ReadAll
	rc = StrComp(text1, text2, 1)
	If rc <> 0 Then
		OS_CompareTextFiles = -1
	Else
		OS_CompareTextFiles = 1
	End If
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_ReadRegistryKey
'
' Description: 
'              
' Parameter:   
'	- strKeyPath: 
'	
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_ReadRegistryKey(strKeyPath)	
	Set objRegistry = CreateObject("Wscript.Shell")	
	OS_ReadRegistryKey = objRegistry.RegRead(strKeyPath)
	Set objRegistry = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GetMyDocumentFolderPath
'
' Description: 
'              
' Parameter:   
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GetMyDocumentFolderPath()
	Dim strKeyPath
	strKeyPath = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Personal"
	OS_GetMyDocumentFolderPath = OS_ReadRegistryKey(strKeyPath) 	
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_CreateTextFile
'
' Description: 
'              
' Parameter:  
'	- strFilePath:
'	- strFileContent
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_CreateTextFile(strFilePath, strFileContent)
	Dim fso, f
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set f = fso.CreateTextFile(strFilePath, True)
	f.WriteLine strFileContent
	f.Close
	Set f = Nothing
	Set fso = Nothing
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GetUninstallString
'
' Description: 
'              
' Parameter:  
'	- sDisplayName:
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GetUninstallString(sDisplayName)
	OS_GetUninstallString = OS_GetRegistryStringByKeySearch (sDisplayName, "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "DisplayName", "UninstallString", 32)
	If OS_GetUninstallString = "" and OS_Check64BitSystem = True Then
       OS_GetUninstallString = OS_GetRegistryStringByKeySearch (sDisplayName, "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "DisplayName", "UninstallString", 64)
	End If
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_Check64BitSystem
'
' Description: 
'              
' Parameter:  
'	- sDisplayName:
'
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_Check64BitSystem()
	If instr(Environment("ProductDir"),"(x86)") Then
		OS_Check64BitSystem = True
	Else
		OS_Check64BitSystem = False
	End If
End Function


'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GetRegistryStringByKeySearch
'
' Description: 
'              
' Parameter:  
'	- sSearchString
'	- sKeyPath
'	- sSearchKeyName 
'	- sOutKeyName
'	- iArchitecture
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GetRegistryStringByKeySearch(sSearchString, sKeyPath, sSearchKeyName, sOutKeyName, iArchitecture) 
   Dim strComputer, oCtx, oLocator
	Dim oServices, oStdRegProv, oInparams
	Dim oOutparams, oOutparams2, sUninstallDisplayName
	Dim aSubKeys, sSubkey
   
	Set oCtx = CreateObject("WbemScripting.SWbemNamedValueSet")
   oCtx.Add "__ProviderArchitecture", iArchitecture
   oCtx.Add "__RequiredArchitecture", True
   Set oLocator = CreateObject("Wbemscripting.SWbemLocator")
   Set oServices = oLocator.ConnectServer("","root\default","","",,,,oCtx)
   Set oStdRegProv = oServices.Get("StdRegProv") 
	
   oStdRegProv.EnumKey &h80000002, sKeyPath, aSubKeys

   On Error Resume Next
	For Each sSubkey In aSubKeys
		Set oInparams = oStdRegProv.Methods_("GetStringValue").Inparameters
		oInparams.Hdefkey = "&h80000002"
		oInparams.Ssubkeyname = sKeyPath & "\" & sSubkey
		oInparams.Svaluename = sSearchKeyName
		
		Set oOutparams = oStdRegProv.ExecMethod_("GetStringValue", oInparams,,oCtx)
		sUninstallDisplayName = oOutparams.SValue
		
		If sUninstallDisplayName = sSearchString Then	
			oInparams.Svaluename = sOutKeyName
			Set oOutparams2 = oStdRegProv.ExecMethod_("GetStringValue", oInparams,,oCtx)
			OS_GetRegistryStringByKeySearch = oOutparams2.SValue			
			Exit For
		End If
	 Next
    On Error GoTo 0

	Set oCtx = nothing
	Set oLocator = nothing
	Set oServices = nothing
	Set oStdRegProv = nothing
	Set oInparams = nothing
	Set oOutparams = nothing
	Set oOutparams2 = nothing

End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_ScreenPopup
'
' Description: 
'              
' Parameter:  
'	- strMessage
'	- iTimeout
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_ScreenPopup(strMessage, iTimeout)	
	Dim WshShell
	Set WshShell = CreateObject("WScript.Shell")
	WshShell.Popup strMessage, iTimeout, "Info"
	Set WshShell = Nothing	
End Function



'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GenerateRandomNumberOutOfList
'
' Description: 
'              
' Parameter:  
'	- iLowNumber
'	- iUpNumber
'	- arrExclude
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GenerateRandomNumberOutOfList(iLowNumber, iUpNumber, arrExclude)
	Dim num, iflag, i

	Do		
		num = OS_GenerateRandomNumber(iLowNumber, iUpNumber)			
		If IsArray(arrExclude) Then               
			iflag = 0
			For i = 0 To Ubound(arrExclude)
				If num = CInt(arrExclude(i)) Then
					iflag = 1
					Exit For
				End If
			Next			
		End If
	Loop Until iflag = 0
	OS_GenerateRandomNumberOutOfList = num
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
' Function Name: OS_GetRegistryKeyList
'
' Description: 
'              
' Parameter:  
'	- strRoot
'	- strKeyPath
'
' Return value: 
'
' History: 
'	- 2012-01-13 | Initial Revision
'
'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Function OS_GetRegistryKeyList(strRoot, strKeyPath)
	Dim str, oReg, objShell, strComputer, arrSubkeys
	strComputer = "." 
	Select Case strRoot
		Case "HKCU"
			str = &H80000001 	
		Case "HKLM"
			str = &H80000002 	
	End Select

	On Error Resume next 
	Set objShell = CreateObject("WScript.Shell") 
	Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv") 	
	oReg.EnumKey str, strKeyPath, arrSubkeys
	OS_GetRegistryKeyList = arrSubkeys 	
	Set oReg = Nothing
	Set objShell = Nothing
	On Error Goto 0
End Function

'***********************************************************************
'Function Name: ResetAdobeReader
'Description: Reset Adobe Reader
'Parameter: No
'Return value: N/A
'***********************************************************************
Function OS_ResetAdobeReader
	'Disable Sign Pane
	Set objShell = CreateObject("WScript.Shell")
	objShell.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Adobe\Acrobat Reader\10.0\FeatureLockDown\cServices\bEnableSignPane", 0, "REG_DWORD"
	Set objShell = Nothing
End Function

'=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Sub LoadKeyword(fSpec)
    filePath = "C:\QTPF\Resource\Functions\"+fSpec+".txt"
    LoadFunctionLibrary(filePath)
End Sub 
