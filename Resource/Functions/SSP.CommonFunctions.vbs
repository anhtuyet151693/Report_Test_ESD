'Global variables
Const VERY_SHORT_TIME = 1
Const SHORT_TIME = 3
Const MEDIUM_TIME = 5
Const LONG_TIME = 10
Const APPLICATION_NAME = "Dev - SmartString Plus"
Const PROCESS_NAME = "SmartStringPlus.exe"
Const ENTER_KEY = "{ENTER}"
Const SHIFT_TAB_KEY = "+{TAB}"
Const PRINT_KEY = "{prtsc}"
Const DOWN_KEY = "{DOWN}"
Const ADOBE_PROCESS_NAME = "AcroRd32.exe"
Const DEFAULT_HEIGHT = 768
Const DEFAULT_WIDTH = 1024
Const DEFAULT_X = 128
Const DEFAULT_Y = 108

'***********************************************************************
'Function Name: Preset_TestSet
'Description: Prepare environment for TestSet
'Parameter: No
'Return value: NO
'***********************************************************************
Function Preset_TestSet
	' Disable Sign Panel of Adobe Reader
	OS_ResetAdobeReader
End Function

'***********************************************************************
'Function Name: Preset_TestCase
'Description: Prepare environment for TC/DE
'Parameter: No
'Return value: always return 1
'CreateDate : 17/06/2013 - TANNM3
'UpdateDate : 18/06/2013 - KHOIDN
	'-change Description 
'***********************************************************************
Function Preset_TestCase
	On Error Resume Next
	Dim winApplication: set winApplication = WpfWindow(APPLICATION_NAME)
	
	' Kill Adobe Reader
	If OS_IsProcessRunning(LOCAL_HOST_NAME, ADOBE_PROCESS_NAME) Then
		OS_KillProcess LOCAL_HOST_NAME, ADOBE_PROCESS_NAME
	End If 
	
	' If SSP is running, click button New file to clear legacy data.
	If OS_IsProcessRunning(LOCAL_HOST_NAME, PROCESS_NAME) Then
		intWidth = winApplication.GetROProperty("width")
		intHeight = winApplication.GetROProperty("height")
		abs_x = winApplication.GetROProperty("abs_x")  
		abs_y = winApplication.GetROProperty("abs_y")
		
		' Check if application window is maximized or minimized
		If (abs_x = 0 and abs_y = 0) or (abs_x = -32000 and abs_y = -32000) Then
			winApplication.Restore
		End If
		' Check resolution of application window
		If intWidth <> DEFAULT_WIDTH and  intHeight <> DEFAULT_HEIGHT then
			winApplication.Resize DEFAULT_WIDTH,DEFAULT_HEIGHT
			winApplication.Move DEFAULT_X, DEFAULT_Y
		End If
		
		
		if winApplication.WpfButton("btn.SSP.New").Exist(MEDIUM_TIME) then
			' Click New file button
			winApplication.WpfButton("btn.SSP.New").Click
			' Check if button cannot click
			If Err.Number <> 0 Then
				LaunchApp
				Err.Clear
				Preset_TestCase = 1
			End If
			' Check Save window exists, if it exists, so click No button to clear data
			If WpfWindow("win.SSP.SaveCurrent").Exist(SHORT_TIME) Then
				PressButtonNewWindow "win.SSP.SaveCurrent", "btn.SSP.SaveCurrent.No"	
				Preset_TestCase = 1
			End If
			Exit Function
		End if			
		
		if TryToNewFile("SHOP") = 1 then 
			Preset_TestCase = 1
			Exit Function
		end if 
		
		' if Print preview is opening
		if TryToNewFile("btn.SSP.PrintPreview.Close") = 1 then 
			Preset_TestCase = 1
			Exit Function
		end if 
		
		' if Export is opening
		if TryToNewFile("btn.SSP.Export.Close") = 1 then 
			Preset_TestCase = 1
			Exit Function
		end if 
		
		LaunchApp
		Preset_TestCase = 1
	Else
	
		LaunchApp
		Preset_TestCase = 1
	End If
	
End Function

'***********************************************************************
'Function Name: TryToNewFile
'Description: Try to New file
'Parameter:
'	- strButtonName: name of button (new file)
'Return value: return 1 if succeed otherwise return -1
'CreateDate : 17/06/2013 - TANNM3	
'***********************************************************************
Function TryToNewFile(strButtonName)
	On Error Resume Next
	if WpfWindow(APPLICATION_NAME).WpfButton(strButtonName).Exist(MEDIUM_TIME) then
		WpfWindow(APPLICATION_NAME).WpfButton(strButtonName).Click
		' Check if button cannot click
		If Err.Number <> 0 Then
			LaunchApp
			Err.Clear
		Else 
			NewFile
		End If
		TryToNewFile = 1
	Else 
		TryToNewFile = -1
	End if
End function

'***********************************************************************
'Function Name: LaunchApp
'Description: Launch SmartStringPlus application
'Parameter: No
'Return value: No
'Note: If the application can start, please check syetem service 
'      Software Place is running or not
'***********************************************************************
Function LaunchApp
	Dim blnStarted
	blnStarted = False
		Do
			Do
				OS_KillProcess LOCAL_HOST_NAME, PROCESS_NAME
				
				Sleep(5)
				
			Loop While OS_IsProcessRunning(LOCAL_HOST_NAME, PROCESS_NAME)
 
			OS_RunApplication(APPLICATION_PATH) 'APPLICATION_PATH declareed in TestDriver
		
			ReportAction 1,"Try to launch SSP application at path " & APPLICATION_PATH, "Passed"
		
			Sleep(5)
		
			If WpfWindow(APPLICATION_NAME).WpfButton("OK").Exist(120) Then
				Sleep(7)
				WpfWindow(APPLICATION_NAME).WpfButton("OK").Click
				blnStarted = True
			Else
				blnStarted = False
			End If
		
		Loop While not blnStarted
End Function

'***********************************************************************
'Function Name: Sleep
'Description: Wrap "Wait" function to use in TestCase file
'Parameter:
'	- intSeconds: seconds that we need to wait
'Return value: No
'***********************************************************************
Function Sleep (intSeconds)
	Wait cint(intSeconds)	
End Function



'***********************************************************************
'Function Name: PressButton
'Description:  Press a button
'Parameter:
' 	- strText: Button name 
'Return value: 1 if success , -1 if Failed
'***********************************************************************
Function PressButton (strButtonName)
	PressButton = PressButtonNewWindow(APPLICATION_NAME,strButtonName)
End Function

'***********************************************************************
'Function Name: PressButtonNewWindow
'Description:  Press a button with specific window
'Parameter:
' 	- strWindowName: Window name 
' 	- strButtonName: Button name 
'Return value: 1 if success , -1 if Failed
'CreateDate : KHOIDN
'UpdateDate : 26/06/2013 - KHOIDN
	'-update rework 
'***********************************************************************

Function PressButtonNewWindow (strWindowName,strButtonName)
	Dim blnResult,objControl
	
	blnResult = True
	
	Set objControl = GetControlNewWindow(strWindowName,"Button",strButtonName)
	
	If objControl.Exist(SHORT_TIME) Then
		
		objControl.Click
		
	Else

		blnResult = False

	End If
	
		Set objControl = Nothing
	
	If blnResult Then
		
		ReportAction 1, StringFormat("Press button '{0}' at window '{1}' successfully",Array(strButtonName,strWindowName)), "Passed"
		PressButtonNewWindow = 1

	Else
		ReportAction -1, StringFormat("Press button '{0}' at window '{1}' fail",Array(strButtonName,strWindowName)), "Failed"
		PressButtonNewWindow = -1
		
	End If
	
End Function
'***********************************************************************
'Function Name: PressButtonNewWindowWithIndex
'Description:  Press a button with specific window
'Parameter:
' 	- strWindowName: Window name 
' 	- strButtonName: Button name 
' 	- strIndex: button index
'Return value: 1 if success , -1 if Failed
'CreateDate : KHOIDN
'UpdateDate : 18/06/2013 - KHOIDN
	'-update ReportAction 
	'-update strControlName to strButtonName
'***********************************************************************

Function PressButtonNewWindowWithIndex (strWindowName,strButtonName,strIndex)
	Dim blnControl,objControl
	
	blnControl = True
	
	Set objControl = GetControlNewWindow(strWindowName,"Button",strButtonName)
	
	If objControl.Exist(SHORT_TIME) Then
		
		objControl.SetTOProperty "Index",strIndex

		objControl.Click
		
	Else
	
		blnControl = False
	
	End If
	
	If blnControl Then
		
		ReportAction 1, "Button '"+strButtonName + "' at '"+strWindowName+"' exists.", "Passed"
		PressButtonNewWindowWithIndex = 1

	Else
		ReportAction -1, "Button '"+strButtonName + "' at '"+strWindowName+"' does not exist.", "Failed"
		PressButtonNewWindowWithIndex = -1
		
	End If
	
End Function
'***********************************************************************
'Function Name: PressObject
'Description:  Press a Object
'Parameter:
' 	- strObjectName: Object name 
'Return value: 1 if press sucess , -1 if not
'***********************************************************************
Function PressObject (strObjectName)
	PressObject = PressObjectNewWindow(APPLICATION_NAME,strObjectName)
End Function

'***********************************************************************
'Function Name: PressObjectNewWindow
'Description:  Press a Object with specific window
'Parameter:
' 	- strWindowName: Window name
' 	- strObjectName: Object name 
'Return value: 1 if press sucess , -1 if not
'CreateDate : KHOIDN
'UpdateDate : 26/06/2013 - KHOIDN
	'-update rework 
'***********************************************************************
Function PressObjectNewWindow (strWindowName,strObjectName)
	Dim blnResult,objControl
	
	blnResult = True
	
	Set objControl = GetControlNewWindow(strWindowName,"Object",strObjectName)
	
	If objControl.Exist(SHORT_TIME) Then
		
		objControl.Click
		
	Else

		blnResult = False

	End If
	
	Set objControl = Nothing
	
	If blnResult Then
		
		ReportAction 1, StringFormat("Press Object '{0}' at window '{1}' successfully",Array(strObjectName,strWindowName)), "Passed"
		PressObjectNewWindow = 1

	Else
		ReportAction -1, StringFormat("Press Object '{0}' at window '{1}' fail",Array(strObjectName,strWindowName)), "Failed"
		PressObjectNewWindow = -1
		
	End If
End Function

'***********************************************************************
'Function Name: SelectCbb
'Description:  Select value of Combo box
'Parameter:
' 	- strName: Combobox name 
' 	- strValue: Value we need to select 
'Return value: No
'***********************************************************************
Function SelectCbb (strName, strValue)
	Dim blnResult,objControl
	blnResult = True
	Set objControl = GetControl("ComboBox",strName)
	If objControl.Exist(VERY_SHORT_TIME) Then
		objControl.Select strValue
		Set objControl = nothing
	Else
		blnResult = False
	End If
	
	If blnResult Then
		ReportAction 1 , StringFormat("Combobox {0} selects {1} successfully",Array(strName,strValue)) , "Passed"
		SelectCbb = 1
	Else
		ReportAction -1 , StringFormat("Combobox {0} selects {1} fail",Array(strName,strValue)) , "Failed"
		SelectCbb = -1	
	End If
End Function

'***********************************************************************
'Function Name: Focused
'Description:  Check control focus
'Parameter:
' 	- strControlType: The control's type we need to check
' 	- strControlName: Control's Name
'Return value: 1: Invoke successfully; -1: Failed to invoke
'***********************************************************************
Function Focused (strControlType,strControlName)
	Dim blnCheck
	
	'Check focus
	Select Case strControlType
	Case "Edit"
		blnCheck = WpfWindow(APPLICATION_NAME).WpfEdit(strControlName).Object.Isfocused
	Case "Button"
		blnCheck = WpfWindow(APPLICATION_NAME).WpfButton(strControlName).Object.Isfocused
	End Select
	
	If Not blnCheck Then
		ReportAction -1, "Focused", "Focused Failed: " & strControlType & ", " & strControlName
		Focused = -1
	End If
	ReportAction 1, "Focused", "Focused Passed: " & strControlType & ", " & strControlName
	Focused = 1
End Function



'***********************************************************************
'Function Name: SendKey
'Description: Sends specific key to actived application.
'Parameter(s):
'	- strKey: Represent a key is being to send.
'Return: 1 if send key successfully
'CreateDate : KHOADLB
'UpdateDate : 18/06/2013 - KHOIDN
	'-update ReportAction 
'***********************************************************************
Function SendKey(strKey)
	Set oShell = CreateObject("WScript.Shell")
	oShell.SendKeys strKey
	Set oShell = nothing
	'report
	ReportAction 1, StringFormat("SendKey : '{0}' successfully .",Array(strKey)), "Passed"
	SendKey = 1
End Function

'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: GetROPropertyNewWindow
'Description:  getROProperty of control in specific window
'Parameter: 
'	- strControlType: type of control (Edit,Button,Object,etc....)
'	- strControlName: name of control
'	- strPropertyName: property name of control need to get value
'Return value: have value if get success , string emty if not
'CreateDate : KHOIDN
'UpdateDate : 18/06/2013 - KHOIDN
	'-update : add write log 
'***********************************************************************
Function GetROPropertyNewWindow(strWindowName,strControlType,strControlName,strPropertyName)
	
	Dim strControlValue,objControl
	'default value of property is string emty
	strControlValue = ""
	
	Set objControl = GetControlNewWindow(strWindowName,strControlType,strControlName)
	'if control not exist => return string emty
	If objControl.Exist(SHORT_TIME) Then
		
		strControlValue = objControl.GetROProperty(strPropertyName)
	Else
		ReportAction -1, "Value is empty", "Failed"
		
	End If
			
	ReportAction 1, StringFormat("WindowName : {0},{1} '{2}' has {3} value : '{4}' ",Array(strWindowName,strControlType,strControlName,strPropertyName,strControlValue)), "Passed"
	
	GetROPropertyNewWindow = strControlValue
	
	Set objControl = Nothing
	
End Function

'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: GetROProperty
'Description:  getROProperty of control in main window
'Parameter: 
' 	- strControlType: type of control (Edit,Button,Object,etc....)
' 	- strControlName: name of control
'	- strPropertyName: property name of control need to get value
'Return value: have value if get success , string emty if not
'***********************************************************************
Function GetROProperty(strControlType,strControlName,strPropertyName)
	
	GetROProperty = GetROPropertyNewWindow(APPLICATION_NAME,strControlType,strControlName,strPropertyName)
	
End Function

'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: IsControlExistNewWindow
'Description:  check control is exist in specific window
'Parameter: 
' 	- strWindowName: name of  window
' 	- strControlType: type of control
'	- strControlName: name of control
'Return value: true if exist , false if not
'CreateDate : KHOIDN
'UpdateDate : 18/06/2013 - KHOIDN
	'-update : add write log 
'***********************************************************************
Function IsControlExistNewWindow(strWindowName,strControlType,strControlName)
	
	Dim blnControl,objControl
	
	Set objControl = GetControlNewWindow(strWindowName,strControlType,strControlName)

	blnControl = objControl.Exist(SHORT_TIME)
	Set objControl = Nothing
	
		If blnControl Then
			ReportAction 1,StringFormat("{0} '{1}' at {2} exists . ",Array(strControlType,strControlName,strWindowName)), "Passed"
		Else
			ReportAction -1,StringFormat("{0} '{1}' at {2} does not exist . ",Array(strControlType,strControlName,strWindowName)), "Failed"
		End If
	
	IsControlExistNewWindow = blnControl
End Function

'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: IsControlExist
'Description:  check control is exist in main window
'Parameter: 
' 	- strControlType: type of control
'	- strControlName: name of control
'Return value: true if exist , false if not
'***********************************************************************
Function IsControlExist(strControlType,strControlName)
	
	IsControlExist = IsControlExistNewWindow(APPLICATION_NAME,strControlType,strControlName)
	
End Function

'***********************************************************************
'Function Name: SaveFile
'Description:  save ssp file to specific path
'Parameter: 
' 	- strDirectoryPath
' 	- strFileName
' 	- strPrefix : belong to version of SSP
'Return value: 1 if save success , -1 if Failed
'CreateDate : KHOIDN
'UpdateDate : 18/06/2013 - KHOIDN
	'-update : Rename strRefix = strPrefix
	'-update : remove hard code of wait and sleep
	'-update : add write log
'***********************************************************************
Function SaveFile(strDirectoryPath,strFileName,strPrefix)

	Dim blnResult,strFilePath
	strFilePath = strDirectoryPath+strPrefix+" - "+strFileName
	blnResult = True
	'press button save in app
	blnResult = blnResult and (PressButton("btn.SSP.SaveAs") = 1)
	'press button ok in loss of data warning window
	blnResult = blnResult and (PressButtonNewWindow("Loss of data warning!","OK") = 1)
	
	Sleep(SHORT_TIME)
	'send strFilePath to dialog
	WpfWindow(APPLICATION_NAME).Dialog("Save As").WinEdit("File name:").Click
	strOldFileName = WpfWindow(APPLICATION_NAME).Dialog("Save As").WinEdit("File name:").GetROProperty("text")
	SendKey "{END}"
	For Iterator = 1 To len(strOldFileName) Step 1
		SendKey "{BACKSPACE}"
	Next
	
	WpfWindow(APPLICATION_NAME).Dialog("Save As").WinEdit("File name:").Type strDirectoryPath+strFileName
	Sleep(MEDIUM_TIME)
	
	WpfWindow(APPLICATION_NAME).Dialog("Save As").WinButton("Save").Click
	
	Sleep(SHORT_TIME)
	
	'if file exist => replace it
	If WpfWindow("A file with this name").WpfButton("OK").Exist(SHORT_TIME) Then
		blnResult = blnResult and (PressButtonNewWindow("A file with this name","OK") = 1)
		Wait(LONG_TIME)
	End If

	'Checkpoint 01: check file exist
	if OS_CheckFileExists(strFilePath) then
		ReportAction 1, "Filename " & strFilePath , " exists"
	Else
		ReportAction -1, "Filename " & strFilePath , "does not exist"
		blnResult = False
	End If
	
	'Result 
	If blnResult Then
		ReportAction 1,"Action SaveFile result","Passed"
		SaveFile = 1
	Else
		ReportAction -1,"Action SaveFile result","Failed"
		SaveFile = -1
	End If
	
End Function

'***********************************************************************
'Function Name: OpenFile
'Description: open ssp file from specific path
'Parameter:
' 	- strFilePath: file path
'Return value: 1 if open success , -1 if Failed
'***********************************************************************
Function OpenFile(strFilePath)
	Dim blnResult
	blnResult = True
	
	'Re-open file and check 
	'press 'open' button
	blnResult = blnResult and (PressButton("Open") = 1)
	
	Wait(SHORT_TIME)
	
	'press button ok in loss of data warning window
	If WpfWindow("win.SSP.SaveCurrent").Exist(SHORT_TIME) Then
		blnResult = blnResult and (PressButtonNewWindow("win.SSP.SaveCurrent","btn.SSP.SaveCurrent.No") = 1)
	End If
	
	Wait(SHORT_TIME)
	'focus
	WpfWindow(APPLICATION_NAME).Dialog("dlg.SSP.OpenFile").WinEdit("txt.SSP.OpenFile.FileName").Click
	
	'send strFilePath to dialog
	WpfWindow(APPLICATION_NAME).Dialog("dlg.SSP.OpenFile").WinEdit("txt.SSP.OpenFile.FileName").Type strFilePath
	
	Wait(SHORT_TIME)
	
	WpfWindow(APPLICATION_NAME).Dialog("dlg.SSP.OpenFile").WinObject("obj.SSP.OpenFile.Open").Click
	
	Wait(SHORT_TIME)
	
	'Result 
	If blnResult Then
		ReportAction 1,"Action SaveFile result","Passed"
		OpenFile = 1
	Else
		ReportAction -1,"Action SaveFile result","Failed"
		OpenFile = -1
	End If
	
End Function

'***********************************************************************
'Function Name: TypeValue
'Description:  type value to specific control
'Parameter: 
'	- strControlType: type of control
'	- strControlName: name of control
'	- strValue: typing value
'Return value: 1 if type successfully, otherwise -1
'***********************************************************************
Function TypeValue(strControlType,strControlName,strValue)
	
	TypeValue = TypeNewWindow(APPLICATION_NAME,strControlType,strControlName,strValue)
	
End Function

'***********************************************************************
'Function Name: TypeNewWindow
'Description:  type value to specific control
'Parameter: 
' 	- strWindowName: name of window
' 	- strControlType: type of control
' 	- strControlName: name of control
' 	- strValue: typing value
'Return value: 1 if type successfully, otherwise -1
'CreateDate : KHOIDN
'UpdateDate : 18/06/2013 - KHOIDN
	'-update ReportAction 
'***********************************************************************
Function TypeNewWindow(strWindowName,strControlType,strControlName,strValue)
	
	Dim blnControl,objControl
	
	blnControl = True
	
	Set objControl = GetControlNewWindow(strWindowName,strControlType,strControlName)
	
	If objControl.Exist(VERY_SHORT_TIME) Then
	
		Select Case strControlType
		Case "Edit"
			'clear text
			If trim(objControl.GetROProperty("text")) <> vbNullString Then
				ClearText strControlType,strControlName
			End If
			'type value
			objControl.Type strValue	
			
		Case "ComboBox"
			objControl.Object.Focus
			SendKey strValue
		Case "Calendar"
			objControl.SetDate strValue
		End Select
	Else
		blnControl = False
	End If	
	
	If blnControl Then
		ReportAction 1,StringFormat("{0} '{1}' at {2} typed '{3}' successfully . ",Array(strControlType,strControlName,strWindowName,strValue)), "Passed"
		TypeNewWindow = 1
	Else
		ReportAction -1,StringFormat("{0} '{1}' at {2} typed '{3}' fail . ",Array(strControlType,strControlName,strWindowName,strValue)), "Failed"
		TypeNewWindow = -1
	End If
	
	Set objControl = Nothing
End Function

'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: GetControl
'Description:  get control of main window
'Parameter: 
' 	- strControlType: type of control
' 	- strControlName: name of control
'Return value: control if exsit , otherwise null
'***********************************************************************
Function GetControl(strControlType,strControlName)
	
	Set GetControl = GetControlNewWindow(APPLICATION_NAME,strControlType,strControlName)
	
End Function

'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: GetControlNewWindow
'Description:  get control of specific window
'Parameter: 
' 	- strWindowName: name of window
' 	- strControlType: type of control
' 	- strControlName: name of control
'Return value: control if exsit , otherwise vbNull
'CreateDate : KHOIDN
'UpdateDate : 18/06/2013 - KHOIDN
	'-update ReportAction 
	'-add else case
'***********************************************************************
Function GetControlNewWindow(strWindowName,strControlType,strControlName)
	
	Dim strParams,strFunction
	
	Dim objControl
		
		strParams = BuildFunction(StringFormat("Wpf{0}",Array(strControlType)),strControlName,",")
		
		Select Case strControlType
		
		Case "Window"
			
			strFunction = strParams
		
		Case Else :
		
			strFunction = StringFormat("WpfWindow(strWindowName).{0}",Array(strParams))
	
		End Select
		
		Set objControl = Eval(strFunction)
		
	If  not IsEmpty(objControl) Then
		
		ReportAction 1, StringFormat("Get '{0}' with name '{1}' at window '{2}' successfully ",Array(strControlType,strControlName,strWindowName)), "Passed"
		
	Else
	
		ReportAction -1, StringFormat("Get '{0}' with name '{1}' at window '{2}' fail ",Array(strControlType,strControlName,strWindowName)), "Failed"
		
	End If
	
	Set GetControlNewWindow = objControl
	Set objControl = nothing
End Function
'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: CheckTitle
'Description:  check font size , text of title base on title name => report
'Parameter: 
' 	- strControlName: name of title control
' 	- strExpectedFontSize: expected font size of title
' 	- strExpectedTextValue: expected value of title
'Return value: true if have no different, otherwise false
'***********************************************************************
Function CheckTitle(strControlName,strExpectedFontSize,strExpectedTextValue)
	Dim blnResult
	
	blnResult = True
	'check title
		'check font
		blnResult = blnResult and CheckFont(strControlName,strExpectedFontSize)
		
		'check text
		blnResult = blnResult and CheckText(strControlName,strExpectedTextValue)
	'result	
	CheckTitle = blnResult
End Function

'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: CheckFont
'Description:  check font size of object base on object name => report
'Parameter: 
' 	- strControlName: name of title control
' 	- strExpectedFontSize: expected font size of object
'Return value: true if have no different, otherwise false
'***********************************************************************
Function CheckFont(strControlName,strExpectedFontSize)

	Dim objControl,blnResult,FontSize
	
	blnResult = True
	
	Set objControl = GetControl("Object",strControlName)
	
	If objControl.Exist(VERY_SHORT_TIME) Then
	
		FontSize  = objControl.Object.FontSize 
		
		If FontSize <> CDbl(strExpectedFontSize) Then
			blnResult = False
		End If
	Else

		blnResult = False
	End If
			
	'result
	If blnResult Then
		ReportAction 1, "CheckPoint : CheckFont of '"+strControlName+"' have current fontSize :'"&FontSize&"' with expected fontSize : '"+strExpectedFontSize+"'", "Passed"
	Else
		ReportAction -1, "CheckPoint : CheckFont of '"+strControlName+"' have current fontSize :'"&FontSize&"' with expected fontSize : '"+strExpectedFontSize+"'", "Failed"
	End If
	
	CheckFont = blnResult
	
	Set objControl = Nothing
End Function

'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: CheckText
'Description:  check text value of object base on object name => report
'Parameter: 
' 	- strControlName: name of control
' 	- strExpectedTextValue: expected value of object
'Return value: true if have no different, otherwise false
'***********************************************************************
Function CheckText(strControlName,strExpectedTextValue)
	
	Dim strTextValue,blnResult
	blnResult = True
	strTextValue = ""
	'get text property of strControlName
	strTextValue = GetROProperty("Object",strControlName,"text")
	'compare 2 text
	if strTextValue <> strExpectedTextValue then
	
		blnResult = False
	
	End if
	
	'result
	If blnResult Then
		ReportAction 1, "CheckPoint : CheckText of '"+strControlName+"' have current value :'"+strTextValue+"' with expected value : '"+strExpectedTextValue+"'", "Passed"
	Else
		ReportAction -1, "CheckPoint : CheckText of '"+strControlName+"' have current value :'"+strTextValue+"' with expected value : '"+strExpectedTextValue+"'", "Failed"
	End If
	CheckText = blnResult
End Function

'***********************************************************************
'WARNING : DO NOT USE IN TEST CASE EXCEL FILE
'Function Name: CheckMaxLength
'Description:  check maxlength of value of objects(edit , combobox) base on object name => report
'Parameter: 
' 	- strControlType: type of control(edit,combobox)
' 	- strControlName: name of control
' 	- strExpectedMaxLength: expected maxlength of value of object
'Return value: 1 if pass, otherwise -1
'***********************************************************************
Function CheckMaxLength(strControlType,strControlName,strExpectedMaxLength)
	
	Dim objControl,blnResult,MaxLength
	MaxLength = 0
	blnResult = True
	'Get control need to check max length
	Set objControl = GetControl(strControlType,strControlName)
	
	If objControl.Exist(VERY_SHORT_TIME) Then
	
		Select Case strControlType
			Case "Edit"
				MaxLength  = objControl.Object.MaxLength 
	
			Case "ComboBox"
				'sameple text
				strTypeString = "Halliburton automated test project Halliburton automated test project Halliburton automated test project "
				Wait(5)
				'type text
				objControl.Type strTypeString
				'get length
				MaxLength = Len(objControl.GetVisibleText)
				
		End Select
	
		If MaxLength <> CLng(strExpectedMaxLength) Then
			blnResult = False
		End If
	
	Else	
	
		blnResult = False
		
	End If	
		
	'Result
	If blnResult Then
		ReportAction 1, "CheckPoint : CheckMaxLength of '"+strControlName+"' have current maxlength :'"&MaxLength&"' with expected maxlength : '"+strExpectedMaxLength+"'", "Passed"
		CheckMaxLength = 1
	Else
		ReportAction -1, "CheckPoint : CheckMaxLength of '"+strControlName+"' have current maxlength :'"&MaxLength&"' with expected maxlength : '"+strExpectedMaxLength+"'", "Failed"
		CheckMaxLength = -1
	End If
	
	Set objControl = Nothing
	
End Function

'***********************************************************************
'Function Name: NewFile
'Description:  new ssp file
'Parameter: No
'Return value: 1 if open success , -1 if Failed
'***********************************************************************
Function NewFile
	Dim blnResult
	blnResult = True
	
	blnResult = blnResult and (PressButton("btn.SSP.New")=1)
	
	'press button ok in loss of data warning window
	If WpfWindow("win.SSP.SaveCurrent").Exist(SHORT_TIME) Then
		blnResult = blnResult and (PressButtonNewWindow("win.SSP.SaveCurrent","btn.SSP.SaveCurrent.No") = 1)
	End If
	
	'Result 
	If blnResult Then
		ReportAction 1,"Action NewFile result","Passed"
		NewFile = 1
	Else
		ReportAction -1,"Action NewFile result","Failed"
		NewFile = -1
	End If
	
End Function

'***********************************************************************
'Function Name: SelectRecord
'Description: Choose the record in list
'Parameter:
'	- strRecordName : the style name record which we want to choose
'	- strPosition : the index of record which we want to choose
'Return value: 1 if succeed, otherwise nothing
'***********************************************************************
Function SelectRecord(strRecordName,strIndex)
	WpfWindow(APPLICATION_NAME).WpfObject("devname:="&strRecordName, "Index:=" &cint(strIndex)).Click 10,10
	SelectRecord = 1
End Function

'***********************************************************************
'Function Name: CheckNumberPrecision
'Description: Merge data from RunTally to StandardCompletion
'Parameter: 2
'	- strTextboxName : the position of data which we want to check
'	- intNumberPrecision : the precision of number which we want to check
'Return value: 1: Invoke successfully; -1: Failed to invoke
'***********************************************************************
Function CheckNumberPrecision(strTextboxName,intNumberPrecision)
	Dim intNumber1,intNumber2,intNumber,strLen1,strLen2,strText,blnFlag
	blnFlag = true
	strText = WpfWindow(APPLICATION_NAME).WpfEdit(strTextboxName).GetROProperty("text")
	strLen1 = len(WpfWindow(APPLICATION_NAME).WpfEdit(strTextboxName).GetROProperty("text"))
	strLen2 = InStr(1,strText,".",1)
	intNumber1 = cint(strLen1)
	intNumber2 = cint(strLen2)
	intNumber = intNumber1 - intNumber2
	If cint(intNumber) = cint(intNumberPrecision) Then
		ReportAction 1,"Done","the precision of number is correct."			
	else
		ReportAction -1,"Fail","the precision of number isn`t correct."		
		blnFlag = false
	End If
	
	If blnFlag Then
		CheckNumberPrecision = 1
	else
		CheckNumberPrecision = -1
	End If
	
End Function

'***********************************************************************
'Function Name: CompareTwoNumber
'Description: Merge data from RunTally to StandardCompletion
'Parameter: 2
'	- strTextboxName : the position of textbox which we want to compare
'	- strNumber : the number which we want to use compare
'Return value: 1: Invoke successfully; -1: Failed to invoke
'***********************************************************************
Function CompareTwoNumber(strTextboxName,strNumber)
	Dim strTest,blnFlag
	blnFlag = true
	strTest = WpfWindow(APPLICATION_NAME).WpfEdit(strTextboxName).GetROProperty("text")
	If strTest = strNumber Then
		ReportAction 1,"Done","The value is not consistent after converted."			
	else
		ReportAction -1,"Fail","The value isn`t consistent after converted."	
		blnFlag = false
	End If
	If blnFlag Then
		CompareTwoNumber = 1
	else
		CompareTwoNumber = -1
	End If
End Function

'***********************************************************************
'Function Name: SelectUnitMOrFt
'Description: Choose the Unit M or FT of Number Data
'Parameter: 4
'	- strButtonPosition :position of button change style
'	- strListStylePosition :position of list unit
'	- strStyle :the style unit of data
'	- strButton2Position :the position of button apply the change
'Return value: 1 if succeed, otherwise nothing
'***********************************************************************
Function SelectUnitMOrFt(strButtonPosition,strListStylePosition,strStyle,strButton2Position)
	WpfWindow(APPLICATION_NAME).WpfButton(strButtonPosition).Click
	WpfWindow(APPLICATION_NAME).WpfList(strListStylePosition).Select strStyle
	WpfWindow(APPLICATION_NAME).WpfButton(strButton2Position).Click
	SelectUnitMOrFt = 1
End Function

'***********************************************************************
'Function Name: FillATextBox
'Description: Fill data into a textbox
'Parameter:
'	- strPosition: name of textbox which we want to fill
'	- StrData: data which we want to fill
'Return value: 1: Invoke successfully; -1: Failed to invoke
'***********************************************************************
Function FillATextBox (strPosition,StrData)
	WpfWindow(APPLICATION_NAME).WpfEdit(strPosition).Set StrData
	Dim strTest
	strTest = WpfWindow(APPLICATION_NAME).WpfEdit(strPosition).GetROProperty("text")
	If strTest = null Then
		FillATextBox = -1 
	Else
		FillATextBox = 1 
	End If 
End Function
'***********************************************************************
'Function Name: MoveScrollBarBack
'Description: Move Scroll Bar back to the beginning
'Parameter:
'	- strScrollbarName: number of scrollbar
'Return value: 1 if succeed, otherwise nothing
'***********************************************************************
Function MoveScrollBarBack(strScrollbarName)
	If WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollbarName).Exist Then
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollbarName).ShowContextMenu
		
		Select Case strScrollbarName
			Case "scrollBar.SSP.HorizontalScrollBar":
				WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select "Left Edge"
			Case "scrollBar.SSP.VerticalScrollBar":
				WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select "Top"
		End Select
	End If
	
	MoveScrollBarBack = 1
End Function
'***********************************************************************
'TO DO :rework
'Function Name: IsExistImage
'Description: check image is exist or not
'Parameter: 
'-intDefaultHeight : height before insert image
'-strTypeName_CheckControl : type of control use to check height
'-strName_CheckControl : name of control use to check height
'Return value: True if have image , false if not
'***********************************************************************

Function IsExistImage(intDefaultHeight,strTypeName_CheckControl,strName_CheckControl)
	
	Dim intCurrentHeight
	
	WpfWindow(APPLICATION_NAME).Activate

	intCurrentHeight = GetROProperty(strTypeName_CheckControl,strName_CheckControl,"y")
	
	If(intCurrentHeight <> intDefaultHeight) Then
		IsExistImage = True
	Else 
		IsExistImage = False
	End If
	
End Function

'***********************************************************************
'TO DO :redundant
'Function Name: CheckTextBoxMaxLength
'Description: Check valid maximum length of a textbox
' -strTextboxName: Name of textbox control
' -intMaxLength: maximum length want to check
'Return value: 1 if check successfully, -1 if check fail
'***********************************************************************
Function CheckTextBoxMaxLength(strTextboxName,intMaxLength)
	If Len(WpfWindow(APPLICATION_NAME).WpfEdit(strTextboxName).GetVisibleText) > CInt(intMaxLength) Then
		ReportAction -1,"Check max length fail",strTextboxName & " should have maximum " & intMaxLength &" characters"
		CheckTextBoxMaxLength = -1
	Else
		ReportAction 1, "Check max length success",strTextboxName & " have valid max length"
		CheckTextBoxMaxLength = 1
	End If
End Function

'***********************************************************************
'Function Name: CheckValidDepthMD
'Description: Check valid value of DepthMD from 0 to 50000
' -strTextboxName: Name of textbox control
'Return value: 1 if check successfully, -1 if check fail
'***********************************************************************
Function CheckValidDepthMD(strTextboxName)
	Dim intDepthMD
	intDepthMD = CDbl(WpfWindow(APPLICATION_NAME).WpfEdit(strTextboxName).GetVisibleText)
	If intDepthMD > 50000 or intDepthMD < 0 Then
		If WpfWindow(APPLICATION_NAME).WpfObject("obj.Application.UnitToolTip").Exist Then
			ReportAction 1,"Check flag successfully","It displays an error flag message if the DepthMD value is not valid"
			CheckValidDepthMD = 1
		Else
			ReportAction -1, "Check flag fail","It should be flagged if the DepthMD value is not valid"
			CheckValidDepthMD = -1
		End If
	Else
		ReportAction 1,"Data is valid","DepthMD value is in valid range"
		CheckValidDepthMD = 1
	End If
End Function

'***********************************************************************
'Function Name: CheckSelectedComboboxItem
'Description: Check if Combobox label is match with selection
' -strComboboxName: Name of combobox control
' -strSelectName: expected select name
'Return value: 1 if check successfully, -1 if check fail
'***********************************************************************
Function CheckSelectedComboboxItem(strComboboxName, strSelectName)
	If WpfWindow(APPLICATION_NAME).WpfComboBox(strComboboxName).GetROProperty("text") = strSelectName Then
		ReportAction 1,"Check selected success","Selected combobox is matched"
		CheckSelectedComboboxItem = 1
	Else
		ReportAction -1,"Check selected fail","Selected combobox should be " & strSelectName
		CheckSelectedComboboxItem = -1
	End If
End Function

'***********************************************************************
'Function Name: CheckSelectedCBBItem
'Description: Check if Combobox label is match with selection
'	- strControl: Name of combobox control
'	- strLayer: expected value
'Return value: 1 if check successfully, -1 if check fail
'***********************************************************************
Function CheckSelectedCBBItem(strControl, strLayer)
	If WpfWindow(APPLICATION_NAME).WpfComboBox(strControl).GetROProperty("text") = strLayer Then
		ReportAction 1,"Check selected Drawing Layer success","Selected Drawing Layer combobox is match"
		CheckSelectedCBBItem = 1
	Else
		ReportAction -1,"Check selected Drawing Layer fail","Selected Drawing Layer combobox should be " & strLayer
		CheckSelectedCBBItem = -1
	End If
End Function

'***********************************************************************
'Function Name: GetGridTotalItems
'Description: get total of items in a grid
' -strGridDevNameItem: devname of grid item, so we can get item through item index 
'Return value: number of item
'UpdateDate : 18/06/2013 - KHOIDN
	'-update strGridDevName to strGridDevNameItem
'***********************************************************************
Function GetGridTotalItems(strGridDevNameItem)
	Dim intNumber
	intNumber=0		 
	While WpfWindow(APPLICATION_NAME).WpfObject("devname:="&strGridDevNameItem, "index:="&intNumber).Exist(SHORT_TIME)
	     intNumber = intNumber + 1
	Wend	
	' return the number of items
	if intNumber <> 0 then
		ReportAction 1,"Get grid total items successfully","Total grid items is "&intNumber
		GetGridTotalItems = intNumber
	else
		ReportAction -1,"Get grid total items fail","Can't get total grid items"
		GetGridTotalItems=-1
	end if
	
End Function

'***********************************************************************
'Function Name: FillDescriptionWithLines
'Description: Fill test data into rich textbox with lines
' -strRichTextBoxName: Name of textbox control
' -strText: text to input
' -intLines: number of lines
'Return value: 1
'***********************************************************************
Function FillDescriptionWithLines(strRichTextBoxName,strText,intLines)
	For i = 1 To intLines
		WpfWindow(APPLICATION_NAME).WpfEdit(strRichTextBoxName).Type strText
		WpfWindow(APPLICATION_NAME).WpfEdit(strRichTextBoxName).Type micReturn
	Next
	ReportAction 1,"Fill Description successfully","Description rich textbox is filled with "&intLines &" lines"
	FillDescriptionWithLines = 1
End Function

'***********************************************************************
'Function Name: CheckRichTextVisibleLines
'Description: Check displayed line of Rich textbox control 
' - strRichTextBoxName: name of Rich textbox control
' -intLineNumber: number of lines
' -strScrollBarName: scrollbar name
'Return value: 1 if check successfully, -1 if check fail
'***********************************************************************
Function CheckRichTextVisibleLines(strRichTextBoxName,intLineNumber,strScrollBarName) 
	oldPosition=WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Value 
	For i = 1 To intLineNumber Step 1
		WpfWindow(APPLICATION_NAME).WpfEdit(strRichTextBoxName).Type micUp 
	Next
	
	newPosition=WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Value
	If oldPosition<>newPosition Then
		ReportAction 1,"Check displayed line successfully","Display "& intLineNumber &" lines on RichTextBox" 
		CheckRichTextVisibleLines = 1
	Else
		ReportAction -1,"Check displayed line fail",strRichTextBoxName&" must display "& intLineNumber &" lines on RichTextBox"
		CheckRichTextVisibleLines = -1
	End If
End Function

'***********************************************************************
'Function Name: CheckNameOfSectionMatchTitle
'Description: Verify the name of sections match Business Entities Spreadsheet
'Parameter: 1
'	- strTitleName: Name of title
'Return value: 1: check successfully; -1: Check fail
'***********************************************************************
Function CheckNameOfSectionMatchTitle(strTitleName)
	If WpfWindow(APPLICATION_NAME).WpfObject("obj.Shop.SAMS.Title").GetROProperty("text") = strTitleName Then
		ReportAction 1, "The name of section match Biz", "The name of section matched with "&strTitleName
		CheckNameOfSectionMatchTitle = 1
	Else
		ReportAction -1, "The name of section does't match Biz", "The name of section must be "&strTitleName
		CheckNameOfSectionMatchTitle = -1
	End If
End Function

Function CheckPrecisionForControl(strControlType, strControlName, strExpectedResult)
	Dim strText, strCurrentPrecision
	Select Case strControlType
		Case "Object":
			strText = WpfWindow(APPLICATION_NAME).WpfObject(strControlName).GetROProperty ("text")
		Case "Edit":
		Case else:
			ReportAction -1, "CheckPrecisionForControl result", "Function doesn't support "&strControlType&" control"
			CheckPrecisionForControl = -1
	End Select
	strCurrentPrecision = Split(strText,".")(1)
	if CStr(len(strCurrentPrecision)) = strExpectedResult then 
		ReportAction 1, "CheckPrecisionForControl" ,"Precision of " & strControlName& "is "&strExpectedResult
		CheckPrecisionForControl = 1
	Else
		ReportAction -1, "CheckPrecisionForControl" ,"Precision of " & strControlName& "is "&len(strCurrentPrecision)
		CheckPrecisionForControl = -1
	End if
End Function

'***********************************************************************
'Function Name: ChangeControlIndex
'Description: Change TO index property
'Parameter:
' 	- strControlType: Type of control (WpfButton, WpfEdit, WpfObject, ...)
' 	- strControlName: Name of control
' 	- intIndexOfItem: Index of item
'Return value: 1 if successfully, otherwise -1
'Createdate : NAMDH7
'UpdateDate : 19/06/2013 - KHOIDN
	'-rework function
'***********************************************************************
Function ChangeControlIndex (strControlType, strControlName, intIndexOfItem)
	Dim objControl,blnResult
	
	blnResult = True
	Set objControl = GetControl(strControlType,strControlName)

	If objControl.Exist(VERY_SHORT_TIME) Then
	
		objControl.SetTOProperty "Index",intIndexOfItem
		
	Else
		blnResult = False
	End If
	
	'result
	If blnResult Then
	
		ReportAction 1, strControlName & "  exists", "Passed"
		ChangeControlIndex = 1
	
	Else	
	
		ReportAction -1, strControlName & " does not exist", "Failed"
		ChangeControlIndex = -1
		
	End If
	
	Set objControl = Nothing
End Function

'***********************************************************************
'Function Name: IsFocused
'Description: Check whether a control is focus or not
'Parameter:
'	- strControlType: Type of control (Button, Edit, ...)
' 	- strControlName: Name of control
'Return value: 1 if focused, -1 if unfocus
'Change log
'	- 24-Jun-2013	|	KhoaTA2	| Insert command if control's type is "Calendar"
'***********************************************************************
Function IsFocused (strControlType, strControlName)
	Dim strCalendarType
	strCalendarType = "Calendar"
	Dim blnResult
	blnResult = true
	
	If strControlType <> strCalendarType Then
		'If control's type is not "Calendar"
		Dim blnFocusedValue ,objControl
	
		blnFocusedValue = False
		
		Set objControl = GetControl(strControlType, strControlName)
		
		If objControl.Exist(VERY_SHORT_TIME) Then
			
			blnFocusedValue = objControl.Object.Isfocused
			
		Else
			blnResult = False
		End If
		
		'result
		
		If blnResult Then
		
			If blnFocusedValue Then
				
				ReportAction 1, StringFormat("Check focused successfully,{0} {1} is focused",Array(strControlType,strControlName)),"Passed"
				IsFocused = 1
			Else
			
				ReportAction -1, StringFormat("Check focused successfully,{0} {1} is not focused",Array(strControlType,strControlName)),"Failed"
				IsFocused = -1
			End If
			
		Else	
			ReportAction -1, StringFormat("Check focused fail"),"Failed"
			IsFocused = -1
		End If
		
		Set objControl = Nothing	
	Else
		'If control's type is "Calendar"
		SendKey " "
		SendKey "{RIGHT}"
		SendKey "{ENTER}"
		
		blnResult = CheckDatePickerSet(strControlName)
		If blnResult > 0 Then
			ReportAction 1, StringFormat("Check focused successfully,{0} {1} is focused",Array(strControlType,strControlName)),"Passed"
			IsFocused = 1
			Exit Function
		Else
			ReportAction -1, StringFormat("Check focused successfully,{0} {1} is not focused",Array(strControlType,strControlName)),"Failed"
			IsFocused = -1
			Exit Function
		End If
	End If
	
End Function

'***********************************************************************
'Function Name: IsEnabled
'Description: Check whether a control is enabled or not
'Parameter:
'	- strControlType: Type of control (Button, Edit, ...)
' 	- strControlName: Name of control
'Return value: 1 if enabled, -1 if disable
'***********************************************************************
Function IsEnabled (strControlType, strControlName)
	Dim blnEnabledValue ,objControl
	
	blnEnabledValue = False
	Set objControl = GetControl(strControlType, strControlName)
	
	If objControl.Exist(VERY_SHORT_TIME) Then
	
		blnEnabledValue = objControl.GetROProperty("Enabled")
		
		If blnEnabledValue Then
			ReportAction 1, "Check " & strControlName & " is enabled", "Passed"
			IsEnabled = 1
		Else
			ReportAction -1, "Check " & strControlName & " is enabled", "Failed"
			IsEnabled = -1
		End If
	Else
		ReportAction -1, strControlName & " does not exist", "Failed"
		IsEnabled = -1
	End If
	
	Set objControl = Nothing
End Function

'***********************************************************************
'Function Name: Export_IncludeItem
'Description: Include an item to export
'Parameter:
'	- strItemName: Name of the item
'Return value: 1 if Include successfully, -1 if failed to include
'***********************************************************************
Function Export_IncludeItem (strItemName)
	If WpfWindow(APPLICATION_NAME).WpfButton("classname:=System.Windows.Controls.Primitives.ToggleButton","devname:=" & strItemName,"Index:=0").Exist(1) Then
		WpfWindow(APPLICATION_NAME).WpfButton("classname:=System.Windows.Controls.Primitives.ToggleButton","devname:=" & strItemName,"Index:=0").Click
		ReportAction 1, "Include item " & strItemName, "Passed"
		Export_IncludeItem = 1
	Else
		ReportAction 1, "Include item " & strItemName, "Failed"
		Export_IncludeItem = -1
	End If
End Function

'***********************************************************************
'Function Name: Export_SetPageSize
'Description: Set page size for special item
'Parameter:
'	- intItemIndex: Index of the item
' 	- strPageSize: Type of page size to set
'Return value: 1 if Set successfully, -1 if failed to set
'***********************************************************************
Function Export_SetPageSize (intItemIndex, strPageSize)
	If WpfWindow(APPLICATION_NAME).WpfComboBox("classname:=System.Windows.Controls.ComboBox", "Index:=" & intItemIndex).Exist(SHORT_TIME) Then
		WpfWindow(APPLICATION_NAME).WpfComboBox("classname:=System.Windows.Controls.ComboBox", "Index:=" & intItemIndex).Select strPageSize
		ReportAction 1, "Set page size for item at " & intItemIndex, "Passed"
		Export_SetPageSize = 1
	Else
		ReportAction -1, "Set page size for item at " & intItemIndex, "Failed"
		Export_SetPageSize = -1
	End If
End Function

'***********************************************************************
'Function Name: Export_ExpandChildItem
'Description: Expand items in Export
'Parameter:
'	- strItemName: Name of parent item to expand
'Return value: 1 if expand successfully, -1 if failed to expand
'***********************************************************************
 Function Export_ExpandChildItem (strItemName)
 	If WpfWindow(APPLICATION_NAME).WpfButton("classname:=System.Windows.Controls.Primitives.ToggleButton","text:=" & strItemName,"Index:=0").Exist(SHORT_TIME) Then
		WpfWindow(APPLICATION_NAME).WpfButton("classname:=System.Windows.Controls.Primitives.ToggleButton","text:=" & strItemName,"Index:=0").Set "On"
		ReportAction 1, "Expand item " & strItemName, "Passed"
		Export_ExpandChildItem = 1
	Else
		ReportAction -1, "Expand item " & strItemName, "Failed"
		Export_ExpandChildItem = -1
	End If
 End Function
 
'***********************************************************************
'Function Name: Export_Export
'Description: Export all items to pdf
'Parameter:
'	- strPath: File path to save
'Return value: 1 if export successfully, -1 if failed to export
'***********************************************************************
Function Export_Export (strPath)
	If OS_CheckFileExists(strPath) Then
		OS_DeleteFile(strPath)
	End If
	
	If WpfWindow(APPLICATION_NAME).WpfButton("devname:=Export").Exist(SHORT_TIME) Then
		WpfWindow(APPLICATION_NAME).WpfButton("devname:=Export").Click
		
		WpfWindow(APPLICATION_NAME).Dialog("Save As").WinEdit("File name:").Type strPath
		WpfWindow(APPLICATION_NAME).Dialog("Save As").WinButton("Save").Click
		ReportAction 1, "Export to " & strPath, "Passed"
		Export_Export = 1
	Else
		ReportAction -1, "Export to " & strPath, "Failed"
		Export_Export = -1
	End If
End Function

'***********************************************************************
'Function Name: SelectDateTimePicker
'Description: Select a date in date time picker
'Parameter:
' 	- strControlName: Name of the DateTimePicker
' 	- strDate: Date to select
'Return value: 1 if successful, -1 if failed
'***********************************************************************
Function SelectDateTimePicker (strControlName, strDate)
	If WpfWindow(APPLICATION_NAME).WpfCalendar(strControlName).Exist(SHORT_TIME) Then
		WpfWindow(APPLICATION_NAME).WpfCalendar(strControlName).SetDate strDate
		ReportAction 1, "Select DateTimePicker " & strControlName, "Passed"
		SelectDateTimePicker = 1
	Else
		ReportAction -1, "Select DateTimePicker " & strControlName, "Failed"
		SelectDateTimePicker = -1
	End If
End Function
'***********************************************************************
'Function Name: SelectItemNewWindow
'Description: select item in specific window
'Parameter:
'	- strWindowName: window name
'	- strDevName: dev name of record
' 	- strIndex: index of record
' 	- strX: x position
' 	- strY: y position
'Return value: 1 if selected sucessfull, otherwise -1
'***********************************************************************
Function SelectItemNewWindow(strWindowName,strDevName,strIndex,strX,strY)
	Dim blnResult
	blnResult = True
	
	If not WpfWindow(strWindowName).WpfObject("devname:="&strDevName, "Index:=" &cint(strIndex)).Exist(SHORT_TIME) Then
		
		blnResult = false
	Else

		WpfWindow(strWindowName).WpfObject("devname:="&strDevName, "Index:=" &cint(strIndex)).Click cint(strX),cint(strY)
	
	End If
		
	'result
	If blnResult Then
		ReportAction 1, "Action : SelectItemNewWindow ", "Passed"
		SelectItemNewWindow = 1
	Else
		ReportAction -1, "Action : SelectItemNewWindow ", "Failed"
		SelectItemNewWindow = -1
	End If	
	
End Function
'***********************************************************************
'Function Name: SelectItem
'Description:  select item in main window
'Parameter:
'	- strDevName: dev name of record
' 	- strIndex: index of record
' 	- strX: x position
' 	- strY: y position
'Return value: 1 if selected sucessfull, otherwise -1
'***********************************************************************
Function SelectItem(strDevName,strIndex,strX,strY)
	
	SelectItem = SelectItemNewWindow(APPLICATION_NAME,strDevName,strIndex,strX,strY)
	
End Function

'***********************************************************************
'Function Name: CheckControlExistNewWindow
'Description:  check control is exist or not
'Parameter:
'	- strWindowName: window name
' 	- strControlType: control type
' 	- strControlName: control name
'Return value: 1 if enabled, -1 if disable
'***********************************************************************
Function CheckControlExistNewWindow(strWindowName,strControlType,strControlName)
	Dim blnResult
	
	blnResult =True
	
	blnResult = IsControlExistNewWindow(strWindowName,strControlType,strControlName)
	
	'result
	If blnResult Then
		ReportAction 1, "Action : CheckControlExistNewWindow ", "Passed"
		CheckControlExistNewWindow = 1
	Else
		ReportAction -1, "Action : CheckControlExistNewWindow ", "Failed"
		CheckControlExistNewWindow = -1
	End If	
	
End Function
'***********************************************************************
'Function Name: CheckControlExist
'Description:  check control is exist or not
'Parameter:
' 	- strControlType: control type
' 	- strControlName: control name
'Return value: 1 if enabled, -1 if disable
'***********************************************************************
Function CheckControlExist(strControlType,strControlName)
	
	CheckControlExist = CheckControlExistNewWindow(APPLICATION_NAME,strControlType,strControlName)
	
End Function
'***********************************************************************
'Function Name: CheckPropertyValueNewWindow
'Description:  compare value of selected value with expected value
'Parameter:
'	- strWindowName: window name
' 	- strControlType: control type
'	- strPropertyName: property name
' 	- strControlName: control name
' 	- strExpectedValue: expected value
'Return value: 1 if enabled, -1 if disable
'***********************************************************************
Function CheckPropertyValueNewWindow(strWindowName,strControlType,strPropertyName,strControlName,strExpectedValue)
	Dim blnResult,strValue
	blnResult = True
	strValue = ""
	
	If not IsControlExistNewWindow(strWindowName,strControlType,strControlName) Then
		
		blnResult = false
	Else
		strValue = GetROPropertyNewWindow(strWindowName,strControlType,strControlName,strPropertyName)
		
		If strValue<>strExpectedValue Then
			
			blnResult = false
			
		End If	
	End If
	
	'result
	If blnResult Then
		ReportAction 1, "Action : CheckPropertyValueNewWindow ", "Passed"
		CheckPropertyValueNewWindow = 1
	Else
		ReportAction -1, "Action : CheckPropertyValueNewWindow ", "Failed"
		CheckPropertyValueNewWindow = -1
	End If	
End Function
'***********************************************************************
'Function Name: CheckPropertyValue
'Description:  compare value of selected value with expected value
'Parameter:
' 	- strControlType: control type
'	- strPropertyName: property name
' 	- strControlName: control name
' 	- strExpectedValue: expected value
'Return value: 1 if enabled, -1 if disable
'***********************************************************************
Function CheckPropertyValue(strControlType,strPropertyName,strControlName,strExpectedValue)
	
	CheckPropertyValue = CheckPropertyValueNewWindow(APPLICATION_NAME,strControlType,strPropertyName,strControlName,strExpectedValue)
	
End Function
'***********************************************************************
'Function Name: MoveScrollbar
'Description:  move selected scrollbar to specific position
'Parameter:
' 	- strName: name of control
'	- strPosition: position which scroll bar move to
'Return value: 1 if success, otherwise -1
'UpdateDate : 18/06/2013 - KHOIDN
	'-update Parameter 
'***********************************************************************
Function MoveScrollbar(strName,strPosition)
	Dim blnResult
	blnResult = True
	
	If WpfWindow(APPLICATION_NAME).WpfScrollBar(strName).Exist Then
		
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strName).Set CDbl(strPosition)
	Else
		blnResult = False
	End If
	
	'result
	If blnResult Then
		ReportAction 1, "Action : MoveScrollbar ", "Passed"
		MoveScrollbar = 1
	Else
		ReportAction -1, "Action : MoveScrollbar ", "Failed"
		MoveScrollbar = -1
	End If
End Function
'***********************************************************************
'Function Name: SelectListItem
'Description: select item in selected list Item
'Parameter:
' 	- strControlName: control name
'	- strItemName: item name
'Return value: 1 if success, otherwise -1
'***********************************************************************
Function SelectListItem(strControlName,strItemName)

	SelectListItem = SelectListItemNewWindow(APPLICATION_NAME,strControlName,strItemName)
	
End Function
'***********************************************************************
'Function Name: SelectListItemNewWindow
'Description: select item in selected list Item in specific window
'Parameter:
' 	- strWindowName: name of window
' 	- strControlName: control name
'	- strItemName: item name
'Return value: 1 if success, otherwise -1
'***********************************************************************
Function SelectListItemNewWindow(strWindowName,strControlName,strItemName)
	Dim blnResult
	blnResult = True
	
	If WpfWindow(strWindowName).WpfList(strControlName).Exist(SHORT_TIME) Then
		
		WpfWindow(strWindowName).WpfList(strControlName).Select strItemName
	Else
		blnResult = False
	End If
	
	'result
	If blnResult Then
		ReportAction 1, "Action : SelectListItem in {0} ", "Passed"
		SelectListItemNewWindow = 1
	Else
		ReportAction -1, "Action : SelectListItem in {0} ", "Failed"
		SelectListItemNewWindow = -1
	End If	
End Function
'***********************************************************************
'Function Name: Merge_ChooseFile
'Description: merge exsit data with selected file by file path
'Parameter:
' 	- strFilePath: file Path
'Return value: 1 if success, otherwise -1
'***********************************************************************
Function Merge_ChooseFile(strFilePath)
	Dim blnResult
	blnResult = True
	
	Wait(SHORT_TIME)
	'focus
	WpfWindow(APPLICATION_NAME).Dialog("dlg.SSP.OpenFile").WinEdit("txt.SSP.OpenFile.FileName").Click
	
	'send strFilePath to dialog
	WpfWindow(APPLICATION_NAME).Dialog("dlg.SSP.OpenFile").WinEdit("txt.SSP.OpenFile.FileName").Type strFilePath
	
	Wait(SHORT_TIME)
	
	WpfWindow(APPLICATION_NAME).Dialog("dlg.SSP.OpenFile").WinObject("obj.SSP.OpenFile.Open").Click
	
	Wait(SHORT_TIME)
		
	'result
	If blnResult Then
		ReportAction 1, "Action : Merge_ChooseFile ", "Passed"
		Merge_ChooseFile = 1
	Else
		ReportAction -1, "Action : Merge_ChooseFile ", "Failed"
		Merge_ChooseFile = -1
	End If		
End Function
'***********************************************************************
'Function Name: Merge_ExpandChildItem
'Description:expand child item base on devName(default = "HeaderSite") and index
'Parameter:
' 	- strWindowName: window which contain this control
' 	- strDevName: dev name of control (default = "HeaderSite")
' 	- strName: name of item
' 	- strIndex: index of control (begin with 1 , 0 is parent button)
'Return value: 1 if success, otherwise -1
'***********************************************************************
Function Merge_ExpandChildItem(strWindowName,strDevName,strName,strIndex)
	Dim blnResult,objControl
	blnResult = True
	Set objControl = GetControlNewWindow(strWindowName,"Button",StringFormat("devname:={0},Index:={1},text:={2}",Array(strDevName,cint(strIndex),strName)))
	'check control is exist
	If objControl.Exist(SHORT_TIME) Then
		blnChecked = objControl.Object.IsChecked
		If not blnChecked Then
			objControl.Click
		End If
	Else
		blnResult = False
	End If
	
	'result
	If blnResult Then
		ReportAction 1, "Action : Merge_ExpandChildItem ", "Passed"
		Merge_ExpandChildItem = 1
	Else
		ReportAction -1, "Action : Merge_ExpandChildItem ", "Failed"
		Merge_ExpandChildItem = -1
	End If	
	Set objControl = nothing
End Function
'***********************************************************************
'Function Name: Merge_ExpandAllChildItem
'Description:expand ALL child item 
'Parameter:
' 	- strWindowName: window which contain this control
' 	- strDevName: dev name of control (default = "HeaderSite")
'Return value: 1 if have item to expand,  -1 have no item to expand
'UpdateDate : 18/06/2013 - KHOIDN
	'-update Function name 
'***********************************************************************
Function Merge_ExpandAllChildItem(strWindowName,strDevName)
	Dim blnResult,intBeginItemIndex
	blnResult = False
	intBeginItemIndex = 1
	
	While WpfWindow(strWindowName).WpfButton("devname:="&strDevName, "Index:=" &cint(intBeginItemIndex)).Exist(SHORT_TIME)
					
		blnChecked = WpfWindow(strWindowName).WpfButton("devname:="&strDevName, "Index:=" &cint(intBeginItemIndex)).Object.IsChecked
		
		If not blnChecked Then
			WpfWindow(strWindowName).WpfButton("devname:="&strDevName, "Index:=" &cint(intBeginItemIndex)).Click
		End If
		
		intBeginItemIndex = intBeginItemIndex + 1
		
		'it have at least 1 item to expand
		If not blnResult Then
			
			blnResult = True
			
		End If
	Wend
	
	'result
	If blnResult Then
		ReportAction 1, "Action : Merge_ExpandAllChildItem ", "Passed"
		Merge_ExpandAllChildItem = 1
	Else
		ReportAction -1, "Action : Merge_ExpandAllChildItem ", "Failed"
		Merge_ExpandAllChildItem = -1
	End If		
End Function
'***********************************************************************
'Function Name: Merge_IncludeItem
'Description:include specific item
'Parameter:
' 	- strWindowName: window which contain this control
' 	- strControlName: name of control(include item)
' 	- strName: text name in item
' 	- strIndex: if have more than item with the same name , change the index(default = 1)
'Return value: 1 if have item to expand,  -1 have no item to expand
'***********************************************************************
Function Merge_IncludeItem(strWindowName,strControlName,strName,strIndex)
	Dim blnResult,intBeginItemIndex,strDevNamePath,intIndex
	blnResult = True
	
	strDevNamePath = strName&"{0,1000}"
	
	If strIndex = "" Then
		intIndex = 0
	Else
		intIndex = cint(strIndex)
	End If
	
	If WpfWindow(strWindowName).WpfButton(strControlName).Exist(SHORT_TIME) Then
		
		WpfWindow(strWindowName).WpfButton(strControlName).SetTOProperty "devnamepath",strDevNamePath
		WpfWindow(strWindowName).WpfButton(strControlName).SetTOProperty "Index",intIndex
		WpfWindow(strWindowName).WpfButton(strControlName).Click
	Else

		blnResult = False
	End If
	
	'result
	If blnResult Then
		ReportAction 1, "Action : Merge_IncludeItem ", "Passed"
		Merge_IncludeItem = 1
	Else
		ReportAction -1, "Action : Merge_IncludeItem ", "Failed"
		Merge_IncludeItem = -1
	End If	
End Function
'***********************************************************************
'Function Name: RunCheckPointNewWindow
'Description:run check point
'Parameter:
' 	- strWindowName: window which contain this control
' 	- strControlType: type of control
' 	- strControlName: name of control
' 	- strCheckPointName: name of checkpoint
'Return value: 1 if checkPoint successfully,  otherwise -1
'UpdateDate : 18/06/2013 - KHOIDN
	'-remove unuse code
	'-add condition check objControl is vbNull or not
'***********************************************************************
Function RunCheckPointNewWindow(strWindowName,strControlType,strControlName,strCheckPointName)
	Dim lbnResult,objControl
	blnResult = True
	
	Select Case strControlType
	'if is file content
	Case "FileContent"
		
		blnResult = FileContent(strControlName).Check (CheckPoint(strCheckPointName))

	Case Else
	
	'if they are wpf control
		Set objControl = GetControlNewWindow(strWindowName,strControlType,strControlName)
			if 	objControl.Exist(VERY_SHORT_TIME) Then
				blnResult = objControl.Check (CheckPoint(strCheckPointName))
			Else
				blnResult = False
			End If
	
	End Select
	
	'result
	If blnResult Then
		ReportAction 1,StringFormat("CheckPoint : {0} with Control : {1} ",Array(strCheckPointName,strControlName)), "Passed"
		RunCheckPointNewWindow = 1
	Else
		ReportAction -1,StringFormat("CheckPoint : {0} with Control : {1} ",Array(strCheckPointName,strControlName)), "Failed"
		RunCheckPointNewWindow = -1
	End If
	
	Set objControl = nothing	
	
End Function
'***********************************************************************
'Function Name: RunCheckPoint
'Description:run check point
'Parameter:
' 	- strControlType: type of control
' 	- strControlName: name of control
' 	- strCheckPointName: name of checkpoint
'Return value: 1 if checkPoint successfully,  otherwise -1
'***********************************************************************
Function RunCheckPoint(strControlType,strControlName,strCheckPointName)
	
	RunCheckPoint = RunCheckPointNewWindow(APPLICATION_NAME,strControlType,strControlName,strCheckPointName)
	
End Function

'***********************************************************************
'Function Name: StringFormat
'Description:format string
'Parameter:
' 	- strFormatString: window which contain this control
' 	- Arguments: params
'Return value: string after format
'CreateDate : KHOIDN
'UpdateDate : 18/06/2013 - KHOIDN
	'-update description 
'***********************************************************************
Function StringFormat(strFormatString, Arguments())
    Dim Value, CurArgNum

	StringFormat = strFormatString
	
    CurArgNum = 0
    For Each Value In Arguments
        StringFormat = Replace(StringFormat, "{" & CurArgNum & "}", Value)
        CurArgNum = CurArgNum + 1
    Next
   
End Function

'***********************************************************************
'Function Name: MoveScrollBarEnd
'Description:  move selected scrollbar to maximum position
'Parameter:
' 	- strScrollbarName: control type
'Return value: 1 if success, otherwise -1
'***********************************************************************
Function MoveScrollBarEnd(strScrollbarName)
	WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollbarName).ShowContextMenu
	
	Select Case strScrollbarName
		Case "scrollBar.SSP.HorizontalScrollBar":
			WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select "Right Edge"
		Case "scrollBar.SSP.VerticalScrollBar":
			WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select "Bottom"
	End Select
	
	MoveScrollBarEnd = 1
End Function
'***********************************************************************
'Function Name: PrintPreview_ExportPDF
'Description:  export pdf file in print preview , override if exist
'Parameter:
' 	- strFilePath: file path
'Return value: 1 if success, otherwise -1
'***********************************************************************
Function PrintPreview_ExportPDF(strFilePath)
	Dim blnResult
	blnResult = True
	
	Wait(SHORT_TIME)
	If OS_CheckFileExists(strPath) Then
		OS_DeleteFile(strPath)
	End If
	
	Wait(SHORT_TIME)
	
	WpfWindow("Dev - SmartString Plus").Dialog("Save As").WinEdit("File name:").Click
	WpfWindow("Dev - SmartString Plus").Dialog("Save As").WinEdit("File name:").Type strFilePath
	
	Wait(SHORT_TIME)
	WpfWindow("Dev - SmartString Plus").Dialog("Save As").WinButton("Save").Click
	'SendKey strFilePath
	Wait(SHORT_TIME)	
	
	If Dialog("dl.SSP.ExportPDF.ConfirmSaveAs").Exist(MEDIUM_TIME) Then
		Dialog("dl.SSP.ExportPDF.ConfirmSaveAs").WinButton("btn.SSP.ExportPDF.ConfirmSaveAs").Click
	End If
	
	Wait(SHORT_TIME)
		
	'result
	If blnResult Then
		ReportAction 1, "Action : PrintPreview_ExportPDF ", "Passed"
		PrintPreview_ExportPDF = 1
	Else
		ReportAction -1, "Action : PrintPreview_ExportPDF ", "Failed"
		PrintPreview_ExportPDF = -1
	End If		
	
End Function

'***********************************************************************
'Function Name: SelectItemInGroupListEditor
'Description:  Select an item in Group list editor
'Parameter: 
' 	- intIndexOfItem: Index of the item
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-24 | NAMDH7
'***********************************************************************
Function SelectItemInGroupListEditor(intIndexOfItem)
	
	ChangeControlIndex "Object", "obj.SSP.GroupListEditorItem", intIndexOfItem
	If CheckControlExist("Object", "obj.SSP.GroupListEditorItem")= -1 Then
		ReportAction -1,"Action SelectItemInGroupListEditor result", StringFormat("Item with index {0} does not exist",Array(intIndexOfItem))
		SelectItemInGroupListEditor = -1
		Exit Function
	End if
	
	' Choose object
	MoveScrollBarBack("scrollBar.SSP.HorizontalScrollBar")
	
	If Not (RunCheckPoint("Object", "obj.SSP.GroupListEditorItem", "cp.Bitmap.SSP.SelectedGroupListEditorItem")=1) Then
		If PressObjectByCoordinate("obj.SSP.GroupListEditorItem", "5", "10")=1 Then
			ReportAction 1,"Action SelectItemInGroupListEditor result","Select successfully"
			SelectItemInGroupListEditor = 1
		Else
			ReportAction -1,"Action SelectItemInGroupListEditor result","Can not select the item" & intIndexOfItem
			SelectItemInGroupListEditor = 1
		End If
	Else
		ReportAction 1,"Action SelectItemInGroupListEditor result","Item is selected"
		SelectItemInGroupListEditor = 1
	End If
End Function

'***********************************************************************
'Function Name: DeleteItemInGroupListEditor
'Description:  Delete an item in Group list editor
'Parameter: 
'	- intIndexOfItem: Index of the item
'Return value: 1 if succeed, -1 if not
'History:
'	- 2013-06-18 | KHOIDN update ReportAction
'	- 2013-06-24 | NAMDH7 split select item to SelectItemInGroupListEditor function
'***********************************************************************
Function DeleteItemInGroupListEditor(intIndexOfItem)
	Dim blnResult,intdelayTimeInSecond
	blnResult = True
	blnResult = blnResult and (SelectItemInGroupListEditor(intIndexOfItem)=1)
	
	Sleep(VERY_SHORT_TIME)
	' Click delete button
	blnResult = blnResult and (PressButton("btn.SSP.DeleteItem")=1)
	Sleep(VERY_SHORT_TIME)
	
	blnResult = blnResult and (PressButtonNewWindow("win.SSP.DeleteItem","btn.SSP.DeleteItem.Ok")=1)
	
	'Result 
	If blnResult Then
		ReportAction 1,"Action DeleteItemInGroupListEditor result","Delete successfully "
		DeleteItemInGroupListEditor = 1
	Else
		ReportAction -1,"Action DeleteItemInGroupListEditor result","Can not delete the item " & intIndexOfItem
		DeleteItemInGroupListEditor = -1
	End If
End function

'***********************************************************************
'Function Name: ClickUndoButton
'Description:  Click undo button
'Parameter: 
' 	- intTimes: times you want to click
'Return value: 1 if succeed, -1 if not
'UpdateDate : 18/06/2013 - KHOIDN
	'-update function name 
'***********************************************************************
Function ClickUndoButton(intTimes)
	For Iterator = 1 To intTimes Step 1
		WpfWindow(APPLICATION_NAME).WpfButton("btn.SSP.Undo").Click
	Next
	
	ReportAction 1, "Button 'btn.SSP.Undo' at '" + APPLICATION_NAME+ "' exists", "Passed"
	ClickUndoButton = 1
End Function

'***********************************************************************
'Function Name: ClickRedoButton
'Description:  Click Redo button
'Parameter: 
' 	- intTimes: times you want to click
'Return value: 1 if succeed, -1 if not
'UpdateDate : 18/06/2013 - KHOIDN
	'-update function name 
'***********************************************************************
Function ClickRedoButton(intTimes)
	For Iterator = 1 To intTimes Step 1
		WpfWindow(APPLICATION_NAME).WpfButton("btn.SSP.Redo").Click
	Next
	
	ReportAction 1, "Button 'btn.SSP.Redo' at '" + APPLICATION_NAME+ "' exists", "Passed"
	ClickRedoButton = 1
End Function

'***********************************************************************
'Function Name: CheckObjectLabelByDevPath
'Description:  check the text of textbox of record after we moved the record     		 
'Parameter: 3
'strStyleName : name style of record
'strRecordIndex : the index of record which we want to check the text of textbox
'strExpectedData : expected data
'Return value: 1: Invoke successfully; -1: Failed to invoke
'UpdateDate : 18/06/2013 - KHOIDN
	'-update strIndex to strRecordIndex 
	'-update parameter strData
'***********************************************************************
Function CheckObjectLabelByDevPath(strStyleName,strRecordIndex,strExpectedData)
	Dim strTest,bnFlag
	bnFlag= true
	strTest = WpfWindow(APPLICATION_NAME).WpfObject("devnamepath:="&strStyleName,"index:="&cint(strRecordIndex)).GetROProperty("text")
	If strTest = strExpectedData Then		
		ReportAction 1,"CheckLabelObject","Pass"			
	else
		ReportAction -1,"CheckLabelObject","Failed"
		bnFlag= False
	End If
	If bnFlag= False Then
		CheckObjectLabelByDevPath = -1
	else
		CheckObjectLabelByDevPath = 1
	End If
End Function

'***********************************************************************
'Function Name: RunPDFBitmapCheckpoint
'Description: Check bitmap on PDF file use Adobe Reader
'Parameter:
' 	- strNameOfCheckPoint: Name of the bitmap checkpoint
'Return value: 1 if match checkpoint, -1 if failed
'***********************************************************************
Function RunPDFBitmapCheckpoint (strNameOfCheckPoint)
	If Window("win.AdobeReader").Exist(60) Then
		
		SendKey "^{l}"

		Window("win.AdobeReader").WinObject("obj.AVTableContainerView").WaitProperty "visible",true,MEDIUM_TIME
		
		If Window("win.AdobeReader").WinObject("obj.AVPageView").Check(CheckPoint(strNameOfCheckPoint)) Then
			ReportAction 1, "Check bitmap " & strNameOfCheckPoint, "Passed"
			RunPDFBitmapCheckpoint= 1
		Else
			ReportAction -1, "Check bitmap " & strNameOfCheckPoint, "Failed"
			RunPDFBitmapCheckpoint= -1
		End If
	Else
		ReportAction -1, "Adobe Reader not exist", "Failed"
		RunPDFBitmapCheckpoint= -1
	End If
End Function

'***********************************************************************
'Function Name: PressObjectByCoordinate
'Description:  Press a Object with specific window and specific x , y Coordinate 
'Parameter:
' 	- strObjectName: Object name 
' 	- strX: x Coordinate
' 	- strY: y Coordinate
'Return value: true if sucess, Failed if not
'***********************************************************************
Function PressObjectByCoordinate (strObjectName,strX,strY)
	PressObjectByCoordinate = PressObjectNewWindowByCoordinate(APPLICATION_NAME,strObjectName,strX,strY)
End Function

'***********************************************************************
'Function Name: PressObjectNewWindowByCoordinate
'Description:  Press a Object with specific window and specific x , y Coordinate 
'Parameter:
' 	- strWindowName: Window name
' 	- strObjectName: Object name 
' 	- strX: x Coordinate
' 	- strY: y Coordinate
'Return value: 1 if successfully , otherwise -1
'UpdateDate : 18/06/2013 - KHOIDN
	'-update Parameter ,  Description
'***********************************************************************
Function PressObjectNewWindowByCoordinate (strWindowName,strObjectName,strX,strY)
	Dim blnControl
	
	blnControl = False
	blnControl = WpfWindow(strWindowName).WpfObject(strObjectName).Exist(SHORT_TIME)
	
	If blnControl Then
		
		WpfWindow(strWindowName).WpfObject(strObjectName).Click cint(strX),cint(strY)
		ReportAction 1, "Object '"+strObjectName + "' at '"+strWindowName+"' exists.", "Passed"
		PressObjectNewWindowByCoordinate = 1
	Else
		ReportAction -1, "Object '"+strObjectName + "' at '"+strWindowName+"' doesnt exist.", "Failed"
		PressObjectNewWindowByCoordinate = -1

	End If

End Function

'***********************************************************************
'Function Name: CheckVisibleTextContains
'Description: Check whether visible text property contains a string or not
'Parameter:
'	- strControlType: Type of control (Button, Edit, ...)
' 	- strControlName: Name of control
' 	- strExpectedText: Expected text
'Return value: 1 if enabled, -1 if disable
'***********************************************************************
Function CheckVisibleTextContains (strControlType, strControlName, strExpectedText)
	Dim strValue
	
	If IsControlExist(strControlType, strControlName) Then
		Select Case strControlType
		Case "Edit"
			strValue = WpfWindow(APPLICATION_NAME).WpfEdit(strControlName).GetVisibleText
		Case "Button"
			strValue = WpfWindow(APPLICATION_NAME).WpfButton(strControlName).GetVisibleText
		Case "Object"
			strValue = WpfWindow(APPLICATION_NAME).WpfObject(strControlName).GetVisibleText
		Case "ComboBox"
			strValue = WpfWindow(APPLICATION_NAME).WpfComboBox(strControlName).GetVisibleText
		Case "Calendar"
			strValue = WpfWindow(APPLICATION_NAME).WpfCalendar(strControlName).GetVisibleText
		Case "List"
			strValue = WpfWindow(APPLICATION_NAME).WpfList(strControlName).GetContent
		End Select
		
		If InStr(1, strValue, strExpectedText, 1) > 0 Then
			ReportAction 1, "Check " & strControlName & " contain " & strExpectedText, "Passed"
			CheckVisibleTextContains = 1
		Else
			ReportAction -1, "Check " & strControlName & " contain " & strExpectedText, "Failed"
			CheckVisibleTextContains = -1
		End If
	Else
		ReportAction -1, strControlName & " does not exist", "Failed"
		CheckVisibleTextContains = -1
	End If
End Function

'***********************************************************************
'Function Name: Merge_IsChildItemExist
'Description:check child item base on devName(default = "HeaderSite") and index is exist or not
'Parameter:
' 	- strWindowName: window which contain this control
' 	- strControlName: control name (default = "HeaderSite")
' 	- strName: header name 
' 	- strIndex: index of control (begin with 1 , 0 is parent button)
'Return value: 1 if success, otherwise -1
'CreateDate : 17/06/2013 - KHOIDN
'UpdateDate : 17/06/2013 - KHOIDN
'***********************************************************************
Function Merge_IsChildItemExist(strWindowName,strControlName,strName,strIndex)
	Dim blnResult,intBeginItemIndex,strDevNamePath,intIndex
	blnResult = True
	
	strDevNamePath = strName&"{0,1000}"
	
	If strIndex = "" Then
		intIndex = 0
	Else
		intIndex = cint(strIndex)
	End If
	
	If WpfWindow(strWindowName).WpfButton(strControlName).Exist(2) Then
		
		WpfWindow(strWindowName).WpfButton(strControlName).SetTOProperty "devnamepath",strDevNamePath
		WpfWindow(strWindowName).WpfButton(strControlName).SetTOProperty "Index",intIndex
		
		If not WpfWindow(strWindowName).WpfButton(strControlName).Exist(2) Then
			
			blnResult = False
			
		End If
		
	Else

		blnResult = False
	End If
	
	'result
	If blnResult Then
		ReportAction 1, StringFormat("CheckPoint : control name : '{0}' , index : {1} at window : '{2}' exist ",Array(strName,strIndex,strWindowName)), "Passed"
		Merge_IsChildItemExist = 1
	Else
		ReportAction -1, StringFormat("CheckPoint : control name : '{0}' , index : {1} at window : '{2}' does not exist ",Array(strName,strIndex,strWindowName)), "Failed"
		Merge_IsChildItemExist = -1
	End If	
End Function

'***********************************************************************
'Function Name: MoveHorizontalScrollBar
'Description: Move horizontal scrollbar to special location
'Parameter:
'	- strScrollBarName: Name of horizontal scrollbar
'	- intLocation: location to move horizontal scrollbar to
'Return value: 1 if move successfully, -1 if failed to move
'CreateDate : 19/06/2013 - NamDH7
'***********************************************************************
Function MoveHorizontalScrollBar(strScrollBarName, intLocation)
	Dim intScrollBarLocation
	intScrollBarLocation = 20
	If WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Exist(VERY_SHORT_TIME) Then
		'Move 25 real pixels
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).ShowContextMenu
		WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select "Top"
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Drag intScrollBarLocation, 5
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Drop intScrollBarLocation + 25, 5
		
		'Calculate 25 real pixels equivalent how many scrollbar value
		floatMoved = WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Value
		floatNewLocation = intLocation * 25 / floatMoved + intScrollBarLocation
		
		'Move to new location base on calculated value
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).ShowContextMenu
		WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select "Top"
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Drag intScrollBarLocation, 5
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Drop floatNewLocation, 5
		
		ReportAction 1, "Move " & strScrollBarName, "Passed"
		MoveHorizontalScrollBar = 1
	Else
		ReportAction -1, "Move " & strScrollBarName, "Failed"
		MoveHorizontalScrollBar = -1
	End If
End Function

'***********************************************************************
'Function Name: MoveVerticalScrollBar
'Description: Move vertical scrollbar to special location
'Parameter:
'	- strScrollBarName: Name of vertical scrollbar
'	- intLocation: location to move vertical scrollbar to
'Return value: 1 if move successfully, -1 if failed to move
'CreateDate : 19/06/2013 - NamDH7
'***********************************************************************
Function MoveVerticalScrollBar(strScrollBarName, intLocation)
	Dim intScrollBarLocation 
	intScrollBarLocation = 20
	
	If WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Exist(VERY_SHORT_TIME) Then
		'Move 25 real pixels
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).ShowContextMenu
		WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select "Top"
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Drag 5, intScrollBarLocation
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Drop 5, intScrollBarLocation + 25
		
		'Calculate 25 real pixels equivalent how many scrollbar value
		floatMoved = WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Value
		floatNewLocation = intLocation * 25 / floatMoved + intScrollBarLocation
		
		'Move to new location base on calculated value
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).ShowContextMenu
		WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select "Top"
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Drag 5, intScrollBarLocation
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Drop 5, floatNewLocation
		
		ReportAction 1, "Move " & strScrollBarName, "Passed"
		MoveVerticalScrollBar = 1
	Else
		ReportAction -1, "Move " & strScrollBarName, "Failed"
		MoveVerticalScrollBar = -1
	End If
End Function
Function MoveVerticalScrollBar3(strScrollBarName, intLocation)

	If WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Exist(VERY_SHORT_TIME) Then
		'length of scrollbar (by pixel)
		viewportSize = WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Object.ViewportSize
		'Length of scrollbar by range
		intMaxSrollBarValue = WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Maximum
		'unit pixel/range
		dbUnit = viewportSize / intMaxSrollBarValue
		'length of thumbSize by range
		thumbSize = (viewportSize/(intMaxSrollBarValue+viewportSize))*intMaxSrollBarValue
		
		dbNewLocationByPixel = ((thumbSize / sqr(2)) + intLocation) * dbUnit
		
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Click 5,dbNewLocationByPixel,micRightBtn
		WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select "Scroll Here"
		
		ReportAction 1, "Move " & strScrollBarName, "Passed"
		MoveVerticalScrollBar3 = 1
	Else
		ReportAction -1, "Move " & strScrollBarName, "Failed"
		MoveVerticalScrollBar3 = -1
	End If
End Function
'***********************************************************************
'Function Name: GetDataFromServices 
'Description: Get data from services
'Parameter: No
'Return value: No
'***********************************************************************
Function GetDataFromServices()
	' Waiting time to get data from services
	intWaitingTime = 8
	PressButton "btn.SSP.GetData"
	Wait intWaitingTime
	ReportAction 1, "GetDataFromServices", "Succeed"
End function
'***********************************************************************
'Function Name: ComparePropertyOfSameControls
'Description:
'Parameter:
' 	- strControlType: type of name
' 	- strControlName: control of name
' 	- strPropertyName: property name
' 	- strFirstControlIndex: index of first control 
' 	- strSecondControlIndex: index of second control 
' 	- blnExpectedResult: True if Same,False if difference
'Return value: 1 if success, otherwise -1
'CreateDate : 21/06/2013 - KHOIDN
'UpdateDate : 21/06/2013 - KHOIDN
'***********************************************************************
Function ComparePropertyOfSameControls(strControlType,strControlName,strPropertyName,strFirstControlIndex,strSecondControlIndex,blnExpectedResult)
	Dim blnResult,strFirstControlValue,strSecondControlValue,objControl
	blnResult = True
	Set objControl = GetControl(strControlType,strControlName)
	
	If not IsEmpty(objControl) Then
	
		objControl.SetTOProperty "Index",strFirstControlIndex
		
		If not IsEmpty(objControl) Then
		
			strFirstControlValue = objControl.GetROProperty(strPropertyName)
			
			objControl.SetTOProperty "Index",strSecondControlIndex
			
			If not IsEmpty(objControl) Then
			
				strSecondControlValue = objControl.GetROProperty(strPropertyName)
				
				If not ((strFirstControlValue=strSecondControlValue) = CBool(blnExpectedResult)) Then
					
					blnResult = False
					
				End If
			Else
			
				blnResult = False
			
			End If
		Else
		
			blnResult = False
		
		End If

	Else

		blnResult = False

	End If
	
	
	'result
	If blnResult Then
		ReportAction 1, StringFormat("CheckPoint : {0} {1} Index {2} : '{3}' ,Index {4} : '{5}' .",Array(strControlType,strControlName,strFirstControlIndex,strFirstControlValue,strSecondControlIndex,strSecondControlValue)), "Passed"
		ComparePropertyOfSameControls = 1
	Else
		ReportAction -1, StringFormat("CheckPoint : {0} {1} Index {2} : '{3}' ,Index {4} : '{5}' .",Array(strControlType,strControlName,strFirstControlIndex,strFirstControlValue,strSecondControlIndex,strSecondControlValue)), "Failed"
		ComparePropertyOfSameControls = -1
	End If	
End Function

'***********************************************************************
'Function Name: AddItemWithDataForMeasurementDetails
'Description: Add new item for Measurement Details and fill all data to it
'Parameter: 
' 	- strIndex: index value
' 	- strDescription: description value
' 	- strMeasurementType: measurement type value
' 	- strActual: actual value
' 	- strComments: comments value
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-24 | NAMDH7
'***********************************************************************
Function AddItemWithDataForMeasurementDetails(strIndex, strDescription, strMeasurementType, strActual, strComments)
	Dim blnActionResult : blnActionResult = True
	
	blnActionResult = blnActionResult and (PressButton("btn.Shop.SAMS_AdditionalMeasurements.AddItem")=1)
	Sleep VERY_SHORT_TIME
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_Additional Measurements.Index",strIndex)=1)
	Sleep VERY_SHORT_TIME
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_Additional Measurements.Description",strDescription)=1)
	Sleep VERY_SHORT_TIME
	SelectCbb "cbb.Shop.SAMS_AM.MeasurementType",strMeasurementType
	Sleep VERY_SHORT_TIME
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_AM.ActualInput", strActual)=1)
	Sleep VERY_SHORT_TIME
	WpfWindow("Dev - SmartString Plus").WpfButton("btn.Shop.SAMS_AM_MeasurementDetails.Comments").Set "On"
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_AdditionalMeasurements_MeasurementsDetails.Comment",strComments)=1)
	WpfWindow("Dev - SmartString Plus").WpfButton("btn.Shop.SAMS_AM_MeasurementDetails.Comments").Set "Off"
	
	If blnActionResult Then
		ReportAction 1, "AddItemWithDataForMeasurementDetails", "Passed"
		AddItemWithDataForMeasurementDetails = 1
	Else
		ReportAction -1, "AddItemWithDataForMeasurementDetails", "Failed"
		AddItemWithDataForMeasurementDetails = -1
	End If
End Function

'***********************************************************************
'Function Name: CheckDataOfMeasurementDetailsItem
'Description: Check data of Measurement Details item
'Parameter: 
' 	- strIndex: index value
' 	- strDescription: description value
' 	- strMeasurementType: measurement type value
' 	- strActual: actual value
' 	- strComments: comments value
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-24 | NAMDH7
'***********************************************************************
Function CheckDataOfMeasurementDetailsItem(strIndex, strDescription, strMeasurementType, strActual, strComments)
	Dim blnActionResult : blnActionResult = True
	
	SelectItemInGroupListEditor 0
	If strIndex <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_Additional Measurements.Index",strIndex)=1)
	End If
	If strDescription <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_Additional Measurements.Description",strDescription)=1)
	End If
	If strMeasurementType <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("ComboBox","text","cbb.Shop.SAMS_AM.MeasurementType",strMeasurementType)=1)
	End If
	If strActual <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_AM.ActualInput",strActual)=1)
	End If
	If strComments <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Button","text","btn.Shop.SAMS_AM_MeasurementDetails.Comments",strComments)=1)
	End If
	
	If blnActionResult Then
		ReportAction 1, "CheckDataOfMeasurementDetailsItem", "Passed"
		CheckDataOfMeasurementDetailsItem = 1
	Else
		ReportAction -1, "CheckDataOfMeasurementDetailsItem", "Failed"
		CheckDataOfMeasurementDetailsItem = -1
	End If
End Function

'***********************************************************************
'Function Name: AddItemWithDataForMeasuringDevices
'Description: Add new item for Measurement Devices and fill all data to it
'Parameter:
' 	- strDescription: description value
' 	- strSerial: serial value
' 	- strCalibrationDate: calibration date value
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-24 | NAMDH7
'***********************************************************************
Function AddItemWithDataForMeasuringDevices(strDescription, strSerial, strCalibrationDate)
	Dim blnActionResult : blnActionResult = True
	
	blnActionResult = blnActionResult and (PressButton("btn.Shop.SAMS_AdditionalMeasurements.AddItem")=1)
	Sleep 1
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_AdditionalMeasurements_MeasuringDevices.Description",strDescription)=1)
	Sleep 1
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_AdditionalMeasurements_MeasuringDevices.Serial",strSerial)=1)
	Sleep 1
	blnActionResult = blnActionResult and (TypeValue("Calendar","cld.Shop.SAMS_AdditionalMeasurements_MeasuringDevices.CalibrationDate", strCalibrationDate)=1)
	
	If blnActionResult Then
		ReportAction 1, "AddItemWithDataForMeasuringDevices", "Passed"
		AddItemWithDataForMeasuringDevices = 1
	Else
		ReportAction -1, "AddItemWithDataForMeasuringDevices", "Failed"
		AddItemWithDataForMeasuringDevices = -1
	End If
End Function

'***********************************************************************
'Function Name: CheckDataOfMeasuringDevicesItem
'Description: Check data of Measurement Devices item
'Parameter:
' 	- strDescription: description value
' 	- strSerial: serial value
' 	- strCalibrationDate: calibration date value
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-24 | NAMDH7
'***********************************************************************
Function CheckDataOfMeasuringDevicesItem(strDescription, strSerial, strCalibrationDate)
	Dim blnActionResult : blnActionResult = True
	
	SelectItemInGroupListEditor 0
	If strDescription <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_AdditionalMeasurements_MeasuringDevices.Description",strDescription)=1)
	End If
	If strSerial <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_AdditionalMeasurements_MeasuringDevices.Serial",strSerial)=1)
	End If
	If strCalibrationDate <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Calendar","date","cld.Shop.SAMS_AdditionalMeasurements_MeasuringDevices.CalibrationDate",strCalibrationDate)=1)
	End If
	
	If blnActionResult Then
		ReportAction 1, "CheckDataOfMeasuringDevicesItem", "Passed"
		CheckDataOfMeasuringDevicesItem = 1
	Else
		ReportAction -1, "CheckDataOfMeasuringDevicesItem", "Failed"
		CheckDataOfMeasuringDevicesItem = -1
	End If
End Function

'***********************************************************************
'Function Name: AddItemWithDataForTubulars
'Description: Add new item for Tubulars and fill all data to it
'Parameter:
' 	- strIndex: index value
' 	- strDescription: description value
' 	- strTable: table value
' 	- strSize: size value
' 	- strWeight: weight value
' 	- strGrade: grade value
' 	- strThread: thread value
' 	- strPipeId: pipe id value
' 	- strDrift: drift value
' 	- strOD: OD value
' 	- strConnectionId: connection id value
' 	- strLength: length value
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-24 | NAMDH7
'***********************************************************************
Function AddItemWithDataForTubulars(strIndex, strDescription, strTable, strSize, strWeight, strGrade, strThread, strPipeId, strDrift, strOD, strConnectionId, strLength)
	Dim blnActionResult : blnActionResult = True
	
	blnActionResult = blnActionResult and (PressButton("btn.Shop.SAMS_Tubulars.AddItem")=1)
	blnActionResult = blnActionResult and (PressButtonNewWindow("win.Shop.SAMS_Tubulars.ChooseFeatures","btn.Shop.SAMS_Tubulars.ChooseFeatures.Create") =1)
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_Tubulars.Index",strIndex)=1)
	
	WpfWindow(APPLICATION_NAME).WpfButton("btn.Shop.SAMS_Tubulars.Description").Set "On"
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_Tubulars.Description",strDescription)=1)
	WpfWindow(APPLICATION_NAME).WpfButton("btn.Shop.SAMS_Tubulars.Description").Set "Off"
	
	SelectCbb "cbb.Shop.SAMS_Tubulars.Table",strTable
	SelectCbb "cbb.Shop.SAMS_Tubulars.Size",strSize
	SelectCbb "cbb.Shop.SAMS_Tubulars.Weight",strWeight
	SelectCbb "cbb.Shop.SAMS_Tubulars.Grade",strGrade
	SelectCbb "cbb.Shop.SAMS_Tubulars.Thread",strThread
	
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_Tubulars.PipeId",strPipeId)=1)
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_Tubulars.Drift",strDrift)=1)
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_Tubulars.OD",strOD)=1)
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_Tubulars.ConnectionId",strConnectionId)=1)
	blnActionResult = blnActionResult and (TypeValue("Edit","txt.Shop.SAMS_Tubulars.Length",strLength)=1)
	
	If blnActionResult Then
		ReportAction 1, "AddItemWithDataForTubulars", "Passed"
		AddItemWithDataForTubulars = 1
	Else
		ReportAction -1, "AddItemWithDataForTubulars", "Failed"
		AddItemWithDataForTubulars = -1
	End If
End Function

'***********************************************************************
'Function Name: CheckDataOfTubularsItem
'Description: Check data of Tubulars item
'Parameter:
' 	- strIndex: index value
' 	- strDescription: description value
' 	- strTable: table value
' 	- strSize: size value
' 	- strWeight: weight value
' 	- strGrade: grade value
' 	- strThread: thread value
' 	- strPipeId: pipe id value
' 	- strDrift: drift value
' 	- strOD: OD value
' 	- strConnectionId: connection id value
' 	- strLength: length value
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-24 | NAMDH7
'***********************************************************************
Function CheckDataOfTubularsItem(strIndex, strDescription, strTable, strSize, strWeight, strGrade, strThread, strPipeId, strDrift, strOD, strConnectionId, strLength)
	Dim blnActionResult : blnActionResult = True
	
	SelectItemInGroupListEditor 0
	If strIndex <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_Tubulars.Index",strIndex)=1)
	End If
	If strDescription <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Button","text","btn.Shop.SAMS_Tubulars.Description",strDescription)=1)
	End If
	If strTable <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("ComboBox","text","cbb.Shop.SAMS_Tubulars.Table",strTable)=1)
	End If
	If strSize <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("ComboBox","text","cbb.Shop.SAMS_Tubulars.Size",strSize)=1)
	End If
	If strWeight <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("ComboBox","text","cbb.Shop.SAMS_Tubulars.Weight",strWeight)=1)
	End If
	If strGrade <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("ComboBox","text","cbb.Shop.SAMS_Tubulars.Grade",strGrade)=1)
	End If
	If strThread <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("ComboBox","text","cbb.Shop.SAMS_Tubulars.Thread",strThread)=1)
	End If
	If strPipeId <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_Tubulars.PipeId",strPipeId)=1)
	End If
	If strDrift <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_Tubulars.Drift",strDrift)=1)
	End If
	If strOD <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_Tubulars.OD",strOD)=1)
	End If
	If strConnectionId <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_Tubulars.ConnectionId",strConnectionId)=1)
	End If
	If strLength <> "" Then
		blnActionResult = blnActionResult and (CheckPropertyValue("Edit","text","txt.Shop.SAMS_Tubulars.Length",strLength)=1)
	End If
	
	If blnActionResult Then
		ReportAction 1, "CheckDataOfTubularsItem", "Passed"
		CheckDataOfTubularsItem = 1
	Else
		ReportAction -1, "CheckDataOfTubularsItem", "Failed"
		CheckDataOfTubularsItem = -1
	End If
End Function

'***********************************************************************
'Function Name: ClearText
'Description: Clear text of control
'Parameter:
' 	- strControlType: type of control
' 	- strControlName: name of control
'Return value: 1 if successfully, -1 if failed
'History:
'	- Create 2013-06-24 | NAMDH7
'	- Update 2013-06-26 | KHOIDN
'	- Update 2013-07-01 | NAMDH7
'***********************************************************************
Function ClearText(strControlType,strControlName)
	
	Set objControl = GetControl(strControlType,strControlName)	
	If objControl.Exist(VERY_SHORT_TIME) Then
		objControl.Object.Focus
		strOldFileName = objControl.GetROProperty("text")
		SendKey "{END}"
		For Iterator = 1 To len(strOldFileName) Step 1
			SendKey "{BACKSPACE}"
		Next
		
		ReportAction 1,"Clear text of " & strControlName, "Passed"
		ClearText = 1
	Else
		ReportAction -1,"Clear text of " & strControlName, "Failed"
		ClearText = -1
	End If
	
End Function
'***********************************************************************
'Function Name: MultiExecute
'Description: execute selected function with specific times
'Parameter:
' 	- strFunctionName: selected function name
' 	- strExecuteTime: times(5 times , 10times ,..)
' 	- strParams: params of selected function must like a string (example : with 3 params =>strParams is : "example1|example2|1")
'Return value: 1 if successfully, -1 if failed
'History:
'	-Create : 2013-06-25 | KHOIDN
'***********************************************************************
Function MultiExecute(strFunctionName,strExecuteTime,strParams)
	Dim iResult,strAction
	
	iResult = True

	' Build Function 	
	strAction = BuildFunction(strFunctionName,strParams,"|")
	'execute
	For ip = 1 To CInt(strExecuteTime)	
	iResult = iResult and (Not IsEmpty(Eval(strAction))) 
	Next
	
	If iResult Then
		MultiExecute = 1
	Else
	
		MultiExecute = -1
	End If
End Function
'***********************************************************************
'Function Name: BuildFunction
'Description: build fuction name and parameters
'Parameter:
' 	- strFunctionName: selected function name
' 	- strParams: params of selected function must like a string (example : with 3 params =>strParams is : "example1,example2,1")
'Return value: string function
'History:
'	-Create : 2013-06-25 | KHOIDN
'***********************************************************************
Function BuildFunction(strFunctionName,strParams,strPrefix)
	Dim arr,arrLength,strAction
	
	strFunctionName = Trim(strFunctionName)
	arr =Split(strParams,strPrefix)

	arrLength = 0
 
	 For ItemIndex = 0 To UBound(arr)
	 If Not(arr(ItemIndex)) = Empty Then
	 
	 	arr(ItemIndex) = Trim(arr(ItemIndex))
	 	
	    arrLength = arrLength + 1
	 End If
	 Next
	
	' Build Function 	
	strAction = strFunctionName & "("					
	If arrLength = 0 Then
		strAction = strAction & ")"
	Else
		strParam = ConvertParam(arr(0))
		strAction = strAction & """" & strParam & """"
		
		For index = 1 To arrLength-1
			strParam = ConvertParam(arr(index))
			strAction = strAction & ", " & """" & strParam & """"
		Next
		strAction = strAction & ")"	
	End If	
	
	BuildFunction = strAction
End Function
'*******************************************SPRINT 4************************************************************
'***********************************************************************
'Function Name: ClickRadioButton
'Description: click selected radio button
'Parameter:
' 	- strRadioButtonName: radio button name

'Return value: 1 if click successfully,otherwise -1
'History:
'	-Create : 2013-06-27 | KHOIDN
'***********************************************************************
Function ClickRadioButton(strRadioButtonName)
	Dim strDefaultX,strDefaultY
	strDefaultX = "5"
	strDefaultY = "5"
	ClickRadioButton = ClickRadioButtonNewWindow(APPLICATION_NAME,strRadioButtonName,strDefaultX,strDefaultY)
	
End Function
'***********************************************************************
'Function Name: ClickRadioButtonNewWindow
'Description: click selected radio button in specific window with Coordinate
'Parameter:
' 	- strWindowName: window name
' 	- strRadioButtonName: radio button name
' 	- strX: string X Coordinate
' 	- strY: string Y Coordinate
'Return value: 1 if click successfully,otherwise -1
'History:
'	-Create : 2013-06-27 | KHOIDN
'***********************************************************************
Function ClickRadioButtonNewWindow(strWindowName,strRadioButtonName,strX,strY)
	Dim blnResult,objControl
	
	blnResult = True
	Set objControl = GetControlNewWindow(strWindowName,"Object",strRadioButtonName)
	
	If objControl.Exist(VERY_SHORT_TIME) Then
		
		objControl.Click strX,strY
		
	Else

		blnResult = False

	End If
	
	Set objControl = Nothing
	
	If blnResult Then
		
		ReportAction 1,StringFormat("Click radio button '{0}' at window {1} allocate :X '{2}' ,Y '{3}' ",Array(strRadioButtonName,strWindowName,strX,strY)), "Passed"
		ClickRadioButtonNewWindow = 1
	Else
		
		ReportAction -1,StringFormat("Click radio button '{0}' at window {1} allocate :X '{2}' ,Y '{3}' ",Array(strRadioButtonName,strWindowName,strX,strY)), "Failed"
		ClickRadioButtonNewWindow = -1
	End If
	
End Function
'***********************************************************************
'Function Name: ClickRadioButtonWithCoordinate
'Description: click selected radio button with Coordinate
'Parameter:
' 	- strRadioButtonName: radio button name
' 	- strX: string X Coordinate
' 	- strY: string Y Coordinate
'Return value: 1 if click successfully,otherwise -1
'History:
'	-Create : 2013-06-27 | KHOIDN
'***********************************************************************
Function ClickRadioButtonWithCoordinate(strRadioButtonName,strX,strY)
	
	ClickRadioButtonWithCoordinate = ClickRadioButtonNewWindow(APPLICATION_NAME,strRadioButtonName,strX,strY)
	
End Function
'***********************************************************************
'Function Name: CoreClickAction
'Description: execute click multi buttons,objects in multi windows
'Parameter:
' 	- strWorkFlow: work flow example(MainWindow::Button-Add;WindowAdd::Object-SandControl|Button-Create;Window::Button-C|Object-D)
'	-parameterDescription :
'	at 'MainWindow' we will execute action in Button Add
'	at 'WindowAdd' we will execute action in Object SandControl then execute action in Button Create
'	at 'Window' we will execute action in Button C then execute action in Object D
'**********************Example**********************

''test add shop sams standard item
'work1 = "Dev - SmartString Plus::Button-btn.Shop.SAMS_AM.AddItem;"
'work2 = "win.Shop.SAMS.AddItem::Button-btn.Shop.SAMS_AddItemWin.Create;"
'work3 = "win.Shop.SAMS.ChooseItem::Object-obj.Shop.SAMS.ChooseItem.StandardCompletion|Button-btn.Shop.SAMS.ChooseItem.Create"
'CoreClickAction work1&work2&work3

''test add tubular items
'work1 = "Dev - SmartString Plus::Button-btn.Shop.SAMS_Tubulars.AddItem;"
'work2 = "win.Shop.SAMS_Tubulars.ChooseFeatures::Button-btn.Shop.SAMS_Tubulars.ChooseFeatures.Create"
'CoreClickAction work1&work2

''test add component
'work1 = "Dev - SmartString Plus::Button-btn.Shop.SAMS_Components_ComDetails.AddItem;"
'work2 = "win.Shop.SAMS_Components_ComponentsDetails.ChooseFeatures::Button-btn.Shop.SAMS_Components_ComponentsDetails.ChooseFeatures.Create;"
'work3 = "win.Shop.SAMS_Components_ComponentsDetails.AddItem::Object-obj.Shop.SAMS_Components_ComponentsDetails.AddItem.SubassemblyItem|Button-btn.Shop.SAMS_Components_ComponentsDetails.AddItem.Create"
'CoreClickAction work1&work2&work3
'**********************Example**********************

'Return value: 1 if run successfully,otherwise -1
'History:
'	-Create : 2013-06-27 | KHOIDN
'***********************************************************************
Function CoreClickAction(strWorkFlow)
	Dim blnResult , arrWorkFlow
	
	blnResult = True
	arrWorkFlow = Split(strWorkFlow,";")
	
	'for each child workflow sperate by ";"
	For Each strChildWorkFlow In arrWorkFlow
		
		'trim
		strChildWorkFlow = Trim(strChildWorkFlow)
		
  		If not strChildWorkFlow="" Then
	   		'sperate windowName and array Controls
	  		arrChildWorkFlow = Split(strChildWorkFlow,"::")
	  		'get window name
			strWindowName = Trim(arrChildWorkFlow(0))
			'get string controls
			strActionFlow = Trim(arrChildWorkFlow(1))
			'get array controls
			arrActionFlow = Split(strActionFlow,"|")
			'foreach control
			For Each strAction In arrActionFlow
				
				'trim
				strAction = Trim(strAction)
				
				arrAction = Split(strAction,"-")
				'get control type
				strControlType =  Trim(arrAction(0))
				'get control name
				strControlName =  Trim(arrAction(1))
				
				'execute action
				
				Select Case strControlType
				
				Case "Button"
					blnResult = blnResult and (PressButtonNewWindow(strWindowName,strControlName) = 1)
				Case "Object"
					blnResult = blnResult and (PressObjectNewWindow(strWindowName,strControlName) = 1)
				Case Else :
					'do nothing
				End Select
				
			Next 
			
  		End If
	
	Next
	
	If blnResult Then
		
		ReportAction 1,"AddPopUpItem","Passed"
		AddPopUpItem = 1
	Else

		ReportAction 1,"AddPopUpItem","Failed"
		AddPopUpItem = -1
	End If
	
End Function	
'***********************************************************************
'Function Name: AddOnePopUpItem
'Description: create item in 1 popup window
'Parameter:
' 	- strAddButtonName: name of button add in main window
' 	- strWindowName: popup window name
' 	- strCreateButtonName: create button name
'Return value: 1 if click successfully,otherwise -1
'History:
'	-Create : 2013-06-26 | KHOIDN
'***********************************************************************
Function AddOnePopUpItem(strAddButtonName,strWindowName,strCreateButtonName)
	Dim blnResult
	blnResult = True
	
	'press button add
	blnResult = blnResult and (PressButton(strAddButtonName)=1)
	'press button create
	blnResult = blnResult and (PressButtonNewWindow(strWindowName,strCreateButtonName) = 1)
	
	If blnResult Then
		
		ReportAction 1,"AddOnePopUpItem successfully","Passed"
		AddOnePopUpItem = 1
	Else
		ReportAction -1,"AddOnePopUpItem successfully","Failed"
		AddOnePopUpItem = -1

	End If
End Function		
'***********************************************************************
'Function Name: AddOnePopUpItemWithItemType
'Description: create item in 1 popup window with selected Item
'Parameter:
' 	- strAddButtonName: name of button add in main window
' 	- strWindowName: popup window name
' 	- strItemType: name of item type
' 	- strCreateButtonName: create button name
'Return value: 1 if click successfully,otherwise -1
'History:
'	-Create : 2013-06-26 | KHOIDN
'***********************************************************************
Function AddOnePopUpItemWithItemType(strAddButtonName,strWindowName,strItemType,strCreateButtonName)
	Dim blnResult
	blnResult = True
	
	'press button add
	blnResult = blnResult and (PressButton(strAddButtonName)=1)
	'select item
	blnResult = blnResult and (PressObjectNewWindow(strWindowName,strItemType) = 1)
	'press button create
	blnResult = blnResult and (PressButtonNewWindow(strWindowName,strCreateButtonName) = 1)
	
	If blnResult Then
		
		ReportAction 1,"AddOnePopUpItemWithItemType successfully","Passed"
		AddOnePopUpItemWithItemType = 1
	Else
		ReportAction -1,"AddOnePopUpItemWithItemType fail","Failed"
		AddOnePopUpItemWithItemType = -1

	End If
End Function
'***********************************************************************
'Function Name: AddTwoPopUpItem
'Description: create item in 2 popup window
'Parameter:
' 	- strAddButtonName: name of button add in main window
' 	- strFirstWindowName: popup window name 1
' 	- strFirstCreateButtonName: create button name 1
' 	- strTwoWindowName: popup window name 2
' 	- strItemType: name of item type
' 	- strTwoCreateButtonName: create button name 2
'Return value: 1 if click successfully,otherwise -1
'History:
'	-Create : 2013-06-26 | KHOIDN
'***********************************************************************
	Function AddTwoPopUpItem(strAddButtonName,strFirstWindowName,strFirstCreateButtonName,strTwoWindowName,strItemType,strTwoCreateButtonName)
	Dim blnResult
	blnResult = True
	
	'press button add
	blnResult = blnResult and (PressButton(strAddButtonName)=1)
	'press button create
	blnResult = blnResult and (PressButtonNewWindow(strFirstWindowName,strFirstCreateButtonName) = 1)
	'select item
	blnResult = blnResult and (PressObjectNewWindow(strTwoWindowName,strItemType) = 1)
	'press button create
	blnResult = blnResult and (PressButtonNewWindow(strTwoWindowName,strTwoCreateButtonName) = 1)
	If blnResult Then
		
		ReportAction 1,"AddTwoPopUpItem successfully","Passed"
		AddTwoPopUpItem = 1
	Else
		ReportAction -1,"AddTwoPopUpItem successfully","Failed"
		AddTwoPopUpItem = -1

	End If
End Function
'*******************************************
'Function Name: CheckContentInComboBox
'Owner: KhoaTA2
'Description: Check if content of all items in combox box is the same with expected string
'Parameter:
'	- strComboBoxName: 		Name of combo box
' 	- strExpectedContent:	Expected content with expected order of all items in combo box, seperated by ','
'Return value: 
' 	- 1: if content of all items in combo box has no difference with expected string
' 	- Otherwise return -1
'Change log:
'	- 26-Jun-2013	|	KhoaTA2	| Create new
'***********************************************************************
Function CheckContentInComboBox(strComboBoxName, strExpectedContent)
	Dim strActualContent
	Dim arrayActualValues, arrayExpectedValue
	
	' Click combo box
	WpfWindow(APPLICATION_NAME).WpfComboBox(strComboBoxName).Click
	
	
	'Get string contains all items' values of combo box
	strActualContent = WpfWindow(APPLICATION_NAME).WpfComboBox(strComboBoxName).GetContent
	arrayActualValues = Split(strActualContent, cstr(Chr(10)))
	arrayExpectedValue = Split(strExpectedContent, ",")
	

	'If number of actual items is different with expected items, retun -1
	If Ubound(arrayActualValues) <> Ubound(arrayExpectedValue) Then
		ReportAction -1, "CheckContentInComboBox", "Items in combo box is not as expected list"
		CheckContentInComboBox = -1
		Exit function
	End If
	
	'Compare each item in actual array with each item in expected array
	For i = 0 To Ubound(arrayExpectedValue)
		If arrayActualValues(i) <> arrayExpectedValue(i) Then
			ReportAction -1, "CheckContentInComboBox", "Items in combo box is not as expected list"
			CheckContentInComboBox = -1
			Exit function
		End If
	Next
	
	'All items in combo box is the same with expected
	ReportAction 1, "CheckContentInComboBox", "Items in combo box is the same with expected list"
	CheckContentInComboBox = 1
End Function

'***********************************************************************
'Function Name: SetFocus
'Owner: KhoaTA2
'Description: Set focus on an object
'Parameter:
'	- strControlStyle: Style of control (Ex: Edit, Button)
' 	- strControlName: Control's name
'Return value: 
' 	- 1: if succeed
' 	- Otherwise return -1
'Change log:
'	- 26-Jun-2013	|	KhoaTA2	| Create new
'***********************************************************************
Function SetFocus(strControlStyle, strControlName)
	Select Case strControlStyle
		Case "Edit"
			WpfWindow(APPLICATION_NAME).WpfEdit(strControlName).Object.Focus
		Case "Button"
			WpfWindow(APPLICATION_NAME).WpfButton(strControlName).Object.Focus
	End select
	
	ReportAction 1, "Set focus on " & strControlName, "Passed"
	SetFocus = 1
End Function

'***********************************************************************
'Function Name: CheckDatePickerSetNewWindow
'Owner: KhoaTA2
'Description: Check if user had chosen a date in Date picker
'Parameter:
'	- strWindowName: Window name
'	- strControlName: Control's name
'Return value: 
' 	- 1: if property's value is a date string
' 	- Otherwise return -1
'Change log:
'	- 26-Jun-2013	|	KhoaTA2	| Create new
'***********************************************************************
Function CheckDatePickerSetNewWindow(strWindowName,strControlName)
	Dim blnResult,strValue, strPropertyName, strControlType
	blnResult = True
	strValue = ""
	strPropertyName = "Text"
	strControlType = "Calendar"
	
	If not IsControlExistNewWindow(strWindowName,strControlType,strControlName) Then
		blnResult = false
	Else
		strValue = GetROPropertyNewWindow(strWindowName,strControlType,strControlName,strPropertyName)
		
		If strValue = "Select A Date" Then
			blnResult = false			
		End If
		
	End If
	
	'result
	If blnResult Then
		ReportAction 1, "Action : CheckDateChosenNewWindow ", "Passed"
		CheckDatePickerSetNewWindow = 1
	Else
		ReportAction -1, "Action : CheckDateChosenNewWindow ", "Failed"
		CheckDatePickerSetNewWindow = -1
	End If	
End Function

'***********************************************************************
'Function Name: CheckDatePickerSet
'Owner: KhoaTA2
'Description: Check if user had chosen a date in Date picker
'Parameter:
'	- strControlName: Control's name
'Return value: 
' 	- 1: if property's value is a date string
' 	- Otherwise return -1
'Change log:
'	- 26-Jun-2013	|	KhoaTA2	| Create new
'***********************************************************************
Function CheckDatePickerSet(strControlName)
	CheckDatePickerSet = CheckDatePickerSetNewWindow(APPLICATION_NAME,strControlName)	
End Function

'***********************************************************************
'Function Name: MultiExecuteMultiFunction
'Description: execute multi function with specific times
'Parameter:
' 	- strFunctions: multi functions with params(example : Function1::params1,param2,param3;Function2::params4,param5,param6)
' 	- strExecuteTime: times(5 times , 10times ,..)
'Return value: 1 if successfully, -1 if failed
'example
'work1 = "PressButton::btn.Shop.SAMS_AM.AddItem;"
'work2 = "PressButtonNewWindow::win.Shop.SAMS.AddItem,btn.Shop.SAMS_AddItemWin.Create;"
'work3 = "PressObjectNewWindow::win.Shop.SAMS.ChooseItem,obj.Shop.SAMS.ChooseItem.StandardCompletion;"
'work4 = "PressButtonNewWindow::win.Shop.SAMS.ChooseItem,btn.Shop.SAMS.ChooseItem.Create;"
'MultiExecuteMultiFunction work1&work2&work3&work4,5
'History:
'	-Create : 2013-06-25 | KHOIDN
'***********************************************************************
Function MultiExecuteMultiFunction(strFunctions,strExecuteTime)
	Dim iResult,arrFunctions
	
	iResult = True
	arrFunctions = Split(strFunctions,";")
	For ip = 1 To CInt(strExecuteTime)
	
		'for each child function sperate by ";"
		For Each strFunction In arrFunctions

			If not strFunction="" Then
				strChildFunction = Split(strFunction,"::")
				'get function name
				strFunctionName = strChildFunction(0)
				'get str params
				strParams = strChildFunction(1)
				
				iResult = iResult and (MultiExecute(strFunctionName,"1",strParams) = 1)
			End If
			
		Next
	
	Next

	If iResult Then
		MultiExecuteMultiFunction = 1
	Else
		MultiExecuteMultiFunction = -1
	End If
End Function
'*******************************************************
'Function Name: AddMultipleItems
'Description: Add the items into the list
'Parameter: 
'	- intNumber : the number of item want to add
'Owner: Thinh
'Return value: 1: Invoke successfully; -1: Failed to invoke
'***********************************************************************
Function AddMultipleItems(intNumber)
	'Add intNumber Items to list of strPosition1
	If WpfWindow(APPLICATION_NAME).WpfButton("btn.Shop.SAMS_AM.AddItem").Exist(1) Then
		For i = 1 To CInt(intNumber) Step 1
		WpfWindow(APPLICATION_NAME).WpfButton("btn.Shop.SAMS_AM.AddItem").Click	
		Next
		ReportAction 1, "AddMultipleItems","items are added"
		AddMultipleItems = 1		
	Else
		ReportAction -1, "AddMultipleItems","items are not added"
		AddMultipleItems = -1
	End If			
End Function	
	
'***********************************************************************
'Function Name: PrintScreen
'Description: Press Print Screen on clipboard
'Parameter: 
'	- intNumber : the number of item want to add
'Owner: Thinh
'Return value: N/A
'***********************************************************************
Function PrintScreen
	'capture image
	Set WshWord = CreateObject("Word.Basic")
	WshWord.SendKeys "{prtsc}"
	
	' Release WshShell object
	Set WshWord = Nothing
	
	OS_KillProcess LOCAL_HOST_NAME,"WINWORD.EXE"
End Function

'***********************************************************************
'Function Name: CheckNumberOfItemInGrid
'Description: Check the number of 
'Parameter: 1
'	- intNumberExpect :the expexcted number of item
'Owner: Thinh
'Return value: 1: Invoke successfully; -1: Failed to invoke
'***********************************************************************
Function CheckNumberOfItemInGrid(intNumberExpect)
	Dim intCount1
	intCount1 = CountRecordInGrid()
	'Checkpoint 2 : check the number of records after Duplicate Button
	If intCount1 = cint(intNumberExpect) Then
		ReportAction 1,"CheckNumberOfItemInGrid","Pass"
		CheckNumberOfItemInGrid = 1
	Else
		ReportAction -1,"CheckNumberOfItemInGrid","Fail"
		CheckNumberOfItemInGrid = -1	
	End If
End Function

'***********************************************************************
'Function Name: CountRecordInGrid
'Description: Count the records in list
'Parameter: No
'Owner: Thinh
'Return value: The number of record
'***********************************************************************
Function CountRecordInGrid()
	Dim intNumber
	intNumber=0		 
	While WpfWindow(APPLICATION_NAME).WpfObject("classname:=Halliburton.Pfg.Presentation.Common.GroupListEditorItem", "index:="&intNumber).Exist(2)
	     intNumber = intNumber + 1
	Wend	
	' return the number of items
	CountRecordInGrid = intNumber
End Function


'***********************************************************************
'Function Name: ChooseMultiItemByShift
'Description: choose multiple  record continously
'Parameter: 2
'	- iStart: the position of start object is choosen
'	- iEnd: the position of end object is choosen
'strDevNameRecord : dev name of record
'Return value: 1: Invoke successfully; -1: Failed to invoke
'***********************************************************************
Function ChooseMultiItemByShift(iStart,iEnd)
	Dim blnStatus, tabKey, shiftTab
    ' Declare an object to send key
	Dim iFirst
	Dim iLast
	iFirst = cInt(iStart) - 1 
	iLast = cInt(iEnd) - 1
	WpfWindow(APPLICATION_NAME).WpfObject("classname:=Halliburton.Pfg.Presentation.Common.GroupListEditorItem", "index:=" & iFirst).Click 10,10
	Wpfwindow(APPLICATION_NAME).Type micShiftDwn
	WpfWindow(APPLICATION_NAME).WpfObject("classname:=Halliburton.Pfg.Presentation.Common.GroupListEditorItem", "index:=" & iLast).Click 10,10
	Wpfwindow(APPLICATION_NAME).Type micShiftUp
	ChooseMultiItemByShift = 1
End Function

'***********************************************************************
'Function Name: HoldCtrl
'Description: 
'Parameter: No
'Owner: Thinh
'Return value: 1: Invoke successfully; -1: Failed to invoke
'***********************************************************************
Function HoldCtrl
	Wpfwindow(APPLICATION_NAME).Type micCtrlDwn
	HoldCtrl = 1
End Function

'***********************************************************************
'Function Name: unHoldCtrl
'Description:  
'Parameter: No
'Owner: Thinh
'Return value: 1: Invoke successfully; -1: Failed to invoke
'***********************************************************************
Function UnHoldCtrl
	Wpfwindow(APPLICATION_NAME).Type micCtrlUp
	unHoldCtrl = 1
End Function
'***********************************************************************
'Function Name: SelectTypeForGridItems
'Description: select item type for grid items
'Parameter:
'	- strDevName: dev name of item
'	- strControlIndexName: name of control index need to be set
'	- strControlTypeName: name of type control need to be set
'	- strKeyPairValue: index - value (example : 1 - abc ; 2 - def )
'Return value: 
' 	- 1: if select successfully
' 	- Otherwise return -1
'Change log:
'	- 27-Jun-2013	|	KHOIDN	| Create new
'***********************************************************************
Function SelectTypeForGridItems(strDevName,strControlIndexName,strControlTypeName,strKeyPairValue)
	Dim strX,strY,arrKeyPairValue,blnResult
	strX = "10"
	strY = "10"
	blnResult = True
	arrKeyPairValue = Split(strKeyPairValue,";")
	
	For each childKeyPairValue In arrKeyPairValue
		
		If not childKeyPairValue = "" Then
			
			arrChildKeyPairValue = Split(childKeyPairValue,"-")
		
			strIndex = Trim(arrChildKeyPairValue(0))
			
			strValue = Trim(arrChildKeyPairValue(1))
			
			blnResult = blnResult and (SelectItem(strDevName,strIndex,strX,strY) = 1)
			'type index value
			blnResult = blnResult and (TypeValue("Edit",strControlIndexName,strIndex) = 1)
			
			'select combobox
			Set objCbbControl = GetControl("ComboBox",strControlTypeName)
			
			If objCbbControl.Exist(VERY_SHORT_TIME) Then
					
					objCbbControl.Select strValue
					
				Else
					blnResult = False
			End If
			
			Set objCbbControl = Nothing
		End If
			
	Next
	
	If blnResult Then
		
		ReportAction 1 , "SelectItemTypeForGridItems" , "Passed"
		SelectItemTypeForGridItems = 1
	Else
	
		ReportAction -1 , "SelectItemTypeForGridItems" , "Failed"
		SelectItemTypeForGridItems = -1		
	
	End If
	
End Function
'***********************************************************************
'Function Name: CheckControlExistWithExpectedValue
'Description:  check control is exist or not with expected value
'Parameter:
' 	- strControlType: control type
' 	- strControlName: control name
' 	- strExpectedValue: expected value : true or false
'Return value: 1 if enabled, -1 if disable
'***********************************************************************
Function CheckControlExistWithExpectedValue(strControlType,strControlName,strExpectedValue)
	Dim blnResult,blnExpectedValue,objControl
	blnResult = True
	blnExpectedValue = CBool(strExpectedValue)
	
	Set objControl = GetControl(strControlType,strControlName)
	
	blnResult = (objControl.Exist(SHORT_TIME) = blnExpectedValue)
	
	Set objControl = Nothing
	
	If blnExpectedValue Then
		
		If blnResult Then
			
			ReportAction 1 , StringFormat("{0} {1} exist ",Array(strControlType,strControlName)) , "Passed"
			CheckControlExistWithExpectedValue = 1
		Else
		
			ReportAction -1 , StringFormat("{0} {1} does not exist ",Array(strControlType,strControlName)) , "Failed"
			CheckControlExistWithExpectedValue = -1
		
		End If
	
	Else
	
		If blnResult Then
			
			ReportAction 1 , StringFormat("{0} {1} does not exist ",Array(strControlType,strControlName)) , "Passed"
			CheckControlExistWithExpectedValue = 1
		Else
		
			ReportAction -1 , StringFormat("{0} {1} exist ",Array(strControlType,strControlName)) , "Failed"
			CheckControlExistWithExpectedValue = -1
		
		End If

	End If
	
End Function
'***********************************************************************
'Function Name: SelectUnit
'Description: Choose the Unit of the list
'Parameter: 2
'	- strButtonUnit :button unit
'	- strSelectedData :data want to be selected
'Return value: 1 if succeed, otherwise -1
'***********************************************************************
Function SelectUnit(strButtonUnit,strSelectedData)
	Dim blnResult 
	blnResult = True
	
	blnResult = blnResult and (PressButton(strButtonUnit) = 1)
	
	WpfWindow(APPLICATION_NAME).WpfList("lst.SSP.UnitItem").Select strSelectedData
	
	blnResult = blnResult and (PressButton("btn.SSP.ApplyUnit") = 1)
	
	If blnResult Then
		
		ReportAction 1 , StringFormat("SelectUnit {0} successfully",Array(strSelectedData)) , "Passed"
		SelectUnit = 1
	Else
		ReportAction -1 ,StringFormat("SelectUnit {0} fail",Array(strSelectedData)) , "Failed"
		SelectUnit = -1		
		
	End If
End Function
'*******************************************SPRINT 4************************************************************

'***********************************************************************
'Function Name: SetCheckBoxValue
'Description: Set value for checkbox control
'Parameter:
' 	- strCheckBoxName: name of checkbox
' 	- blnValue: value to set
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-28 | NAMDH7
'***********************************************************************
Function SetCheckBoxValue(strCheckBoxName, blnValue)
	If WpfWindow("Dev - SmartString Plus").WpfCheckBox(strCheckBoxName).Exist(VERY_SHORT_TIME) Then
		If blnValue Then
			WpfWindow("Dev - SmartString Plus").WpfCheckBox(strCheckBoxName).Set "On"
		Else
			WpfWindow("Dev - SmartString Plus").WpfCheckBox(strCheckBoxName).Set "Off"
		End If
		
		ReportAction 1, "Set value for checkbox " & strCheckBoxName, "Passed"
		SetCheckBoxValue = 1
	Else
		ReportAction -1, "Set value for checkbox " & strCheckBoxName, "Failed"
		SetCheckBoxValue = -1
	End If
End Function

'*******************************************
'Function Name: CheckContentInList
'Owner: ThinhHD1
'Description: Check if content of all items in list is the same with expected string
'Parameter:
' 	- strExpectedContent:	Expected content with expected order of all items in combo box, seperated by ','
'Return value: 
' 	- 1: if content of all items in combo box has no difference with expected string
' 	- Otherwise return -1
'Change log:
'	- 28-Jun-2013	|	ThinhHD1	| Create new
'***********************************************************************
Function CheckContentInList(strExpectedContent)
Dim strActualContent
	Dim arrayActualValues, arrayExpectedValue		
	
	Wait 1
	WpfWindow(APPLICATION_NAME).WpfList("lst.SSP.UnitItem").Click
	'Get string contains all items' values of combo box
	strActualContent = WpfWindow(APPLICATION_NAME).WpfList("lst.SSP.UnitItem").GetContent
	arrayActualValues = Split(strActualContent, cstr(Chr(10)))
	arrayExpectedValue = Split(strExpectedContent, ",")

	'If number of actual items is different with expected items, retun -1
	If Ubound(arrayActualValues) <> Ubound(arrayExpectedValue) Then
		ReportAction -1, "CheckContentInList", "Items in combo box is not as expected list"
		CheckContentInList = -1
		Exit function
	End If
	
	'Compare each item in actual array with each item in expected array
	For i = 0 To Ubound(arrayExpectedValue)
		If arrayActualValues(i) <> arrayExpectedValue(i) Then
			ReportAction -1, "CheckContentInList", "Items in combo box is not as expected list"
			CheckContentInList = -1
			Exit function
		End If
	Next
	PressButton("btn.SSP.CancelUnit") 
	'All items in combo box is the same with expected
	ReportAction 1, "CheckContentInList", "Items in combo box is the same with expected list"
	CheckContentInList = 1
End Function

Function KillAdobe
	' Kill Adobe Reader
	If OS_IsProcessRunning(LOCAL_HOST_NAME, ADOBE_PROCESS_NAME) Then
		OS_KillProcess LOCAL_HOST_NAME, ADOBE_PROCESS_NAME
	End If
	
	KillAdobe = 1
End Function
'	- 2013-06-28 | NAMDH7
'***********************************************************************
Function CheckDrawingGenerator(intImageIndex, strGraphicType)
	If WpfWindow(APPLICATION_NAME).WpfImage("classname:=System.Windows.Controls.Image","Index:=" & intImageIndex).Exist(VERY_SHORT_TIME) Then
		If WpfWindow(APPLICATION_NAME).WpfImage("classname:=System.Windows.Controls.Image","Index:=" & intImageIndex).Check(CheckPoint("cp.Bitmap." & strGraphicType)) Then
			ReportAction 1, "CheckDrawingGenerator of image index " & intImageIndex, "Passed"
			CheckDrawingGenerator = 1
		Else
			ReportAction -1, "CheckDrawingGenerator of image index " & intImageIndex, "Failed"
			CheckDrawingGenerator = -1
		End If
	Else
		ReportAction -1, "CheckDrawingGenerator of image index " & intImageIndex, "Failed"
		CheckDrawingGenerator = -1
	End If
End Function

'***********************************************************************
'Function Name: ToggleIndex
'Description: Toggle on/off index of one item
'Parameter:
' 	- intIndexNumber: number of item index
' 	- blnValue: value to set (on/off)
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-28 | NAMDH7
'***********************************************************************
Function ToggleIndex(intIndexNumber, strValue)
	If WpfWindow("Dev - SmartString Plus").WpfCheckBox("classname:=System.Windows.Controls.CheckBox","devname:=" & intIndexNumber,"Index:=0").Exist(EVERY_SHORT_TIME) Then
		WpfWindow("Dev - SmartString Plus").WpfCheckBox("classname:=System.Windows.Controls.CheckBox","devname:=" & intIndexNumber,"Index:=0").Set strValue
		
		ReportAction 1, "ToggleIndex number " & intIndexNumber, "Passed"
		ToggleIndex = 1
	Else
		ReportAction -1, "ToggleIndex number " & intIndexNumber, "Failed"
		ToggleIndex = -1
	End If
End Function
'***********************************************************************
'Function Name: CheckDrawingGenerator
'Description: Check drawing image at index is match with expected type
'Parameter:
' 	- intImageIndex: index of image
' 	- strGraphicType: type of graphic
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-28 | NAMDH7
'***********************************************************************
Function CheckDrawingGenerator(intImageIndex, strGraphicType)
	If WpfWindow(APPLICATION_NAME).WpfImage("classname:=System.Windows.Controls.Image","Index:=" & intImageIndex).Exist(VERY_SHORT_TIME) Then
		If WpfWindow(APPLICATION_NAME).WpfImage("classname:=System.Windows.Controls.Image","Index:=" & intImageIndex).Check(CheckPoint("cp.Bitmap." & strGraphicType)) Then
			ReportAction 1, "CheckDrawingGenerator of image index " & intImageIndex, "Passed"
			CheckDrawingGenerator = 1
		Else
			ReportAction -1, "CheckDrawingGenerator of image index " & intImageIndex, "Failed"
			CheckDrawingGenerator = -1
		End If
	Else
		ReportAction -1, "CheckDrawingGenerator of image index " & intImageIndex, "Failed"
		CheckDrawingGenerator = -1
	End If
End Function

'***********************************************************************
'Function Name: ToggleIndex
'Description: Toggle on/off index of one item
'Parameter:
' 	- intIndexNumber: number of item index
' 	- blnValue: value to set (on/off)
'Return value: 1 if successfully, -1 if failed
'History:
'	- 2013-06-28 | NAMDH7
'***********************************************************************
Function ToggleIndex(intIndexNumber, strValue)
	If WpfWindow("Dev - SmartString Plus").WpfCheckBox("classname:=System.Windows.Controls.CheckBox","devname:=" & intIndexNumber,"Index:=0").Exist(EVERY_SHORT_TIME) Then
		WpfWindow("Dev - SmartString Plus").WpfCheckBox("classname:=System.Windows.Controls.CheckBox","devname:=" & intIndexNumber,"Index:=0").Set strValue
		
		ReportAction 1, "ToggleIndex number " & intIndexNumber, "Passed"
		ToggleIndex = 1
	Else
		ReportAction -1, "ToggleIndex number " & intIndexNumber, "Failed"
		ToggleIndex = -1
	End If
End Function

'***********************************************************************
'Function Name: MouseWheel
'Description: Scroll a mouse wheel
'Parameter:
'	- intScroll: number of time to scroll
'	- blnForward: False to scroll down and True to scroll up
'Return value: 1 if success, -1 if failed
'History:
'	- 2013-06-31 | NAMDH7
'***********************************************************************
Function MouseWheel(intScroll, blnForward)
	Extern.Declare micVoid, "mouse_event", "user32", "", micLong, micLong, micLong, micLong, micLong
	Const MOUSEEVENTF_WHEEL = &H800
	Const WHEEL_DELTA = 120

	If blnForward Then
		For i=1 To intScroll
			 'Forward away from user
			Extern.mouse_event MOUSEEVENTF_WHEEL, 0, 0, WHEEL_DELTA,0
		Next
	Else
		For i=1 To intScroll
			'Towards user
			Extern.mouse_event MOUSEEVENTF_WHEEL, 0, 0, -1*WHEEL_DELTA, 0
		Next
	End If
End Function

'***********************************************************************
'Function Name: RightClickOnScrollBar
'Description: Scroll a mouse wheel
'Parameter:
'	- strScrollBarName: name of scrollbar
'	- intLocationX: X location
'	- intLocationY: Y location
'	- strOption: option to choose in the context menu
'Return value: 1 if success, -1 if failed
'History:
'	- 2013-06-31 | NAMDH7
'***********************************************************************
Function RightClickOnScrollBar(strScrollBarName, intLocationX, intLocationY, strOption)
	If WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Exist(VERY_SHORT_TIME) Then
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Click intLocationX,intLocationY,micRightBtn
		WpfWindow(APPLICATION_NAME).WpfMenu("WpfMenu.ContextMenu").Select strOption
		
		ReportAction 1, "Right click on scrollbar " & strScrollBarName, "Passed"
		RightClickOnScrollBar = 1
	Else
		ReportAction -1, "Right click on scrollbar " & strScrollBarName, "Failed"
		RightClickOnScrollBar = -1
	End If
End Function

'***********************************************************************
'Function Name: PressScrollBar
'Description: Press on the scrollbar
'Parameter:
'	- strScrollBarName: name of the scrollbar
'Return value: 1 if success, -1 if failed
'History:
'	- 2013-06-31 | NAMDH7
'***********************************************************************
Function PressScrollBar(strScrollBarName)
	If WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Exist(VERY_SHORT_TIME) Then
		WpfWindow(APPLICATION_NAME).WpfScrollBar(strScrollBarName).Click
		
		ReportAction 1, "PressScrollBar " & strScrollBarName, "Passed"
		strScrollBarName = 1
	Else
		ReportAction -1, "PressScrollBar " & strScrollBarName, "Failed"
		strScrollBarName = -1
	End If
End Function
