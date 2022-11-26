EnableExplicit:Global Desk$="ScreenConnectDesktop"; Compiled With PureBasic 6.0.0 LTS x64
Procedure.s ObjectName(h); If Running As "SYSTEM" This program will check to see if it is
  Protected L=260,R$=Space(L):GetUserObjectInformation_(h,$2,@R$,L,@L):ProcedureReturn R$
EndProcedure; running under the "ScreenConnectDesktop" Desktop Session. If it isn't, then
Macro myDesktopName():Trim(ObjectName(GetThreadDesktop_(GetCurrentThreadId_()))):EndMacro
Select UserName(); it assumes it is already running as TrustedInstaller, and it needs to 
  Case "SYSTEM"; change its current desktop to that one, and create a new cmd.exe process
    If myDesktopName() <> Desk$ : Global Station$="WinSta0",lpDesk$=(Station$+"\"+Desk$),
      hDesktop=OpenDesktop_(Desk$,1,0,256),szTitle$="NT SERVICE\TrustedInstall",dwF=$430,
      CommandLine_$="cmd.exe /k taskkill /f /im "+GetFilePart(ProgramFilename())+" >nul",
      startup.STARTUPINFO,p.PROCESS_INFORMATION:ZeroMemory_(@startup,SizeOf(STARTUPINFO))
      startup\cb=SizeOf(STARTUPINFO):startup\lpDesktop=@lpDesk$:startup\lpTitle=@szTitle$
      SetProcessWindowStation_(OpenWindowStation_(Station$,0,$F037F));in that desktop and
      SetThreadDesktop_(hDesktop):SwitchDesktop_(hDesktop); then kill its parent process. 
      CreateProcess_(#Null,@CommandLine_$,#Null,#Null,#False,dwF,#Null,#Null,@startup,@p)
    Else:Goto SelfExec:EndIf; When program is run as a normal elevated user, or directly
    Default; from the ScreenConnectDesktop Environment, Entry Point is Below, where task-
      SelfExec:;scheduler is used in powershell to elevate this program to SYSTEM with NT
      Global hProgram=RunProgram("powershell.exe",; SERVICE\TrustedInstaller  (See Above)
                                 "Register-ScheduledTask -TaskName 'TIBridge' -User 'NT"+
                                 " SERVICE\TrustedInstaller' -Action (New-ScheduledTask"+
                                 "Action -Execute '"+ProgramFilename()+"');$s=New-Objec"+
                                 "t -ComObject 'Schedule.Service';$s.Connect();$u='NT S"+
                                 "ERVICE\TrustedInstaller';$f=$s.GetFolder('\');$t=$f.G"+
                                 "etTask('TIBridge');$t.RunEx($null,0,0,$u);Unregister-"+
                                 "ScheduledTask -TaskName 'TIBridge' -Confirm:$false;;;",
                                 GetCurrentDirectory(),$E); This space intentionally left
    If hProgram:While ProgramRunning(hProgram):Delay(1):Wend:CloseProgram(hProgram):EndIf
EndSelect
