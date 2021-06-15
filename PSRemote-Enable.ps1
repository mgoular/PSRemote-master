# Enable Remoting by going on to the remote machine 
# and entering
#
#   Enable-PSRemoting -Force
#
#  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-5.1
#

Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value '146.1.1.1' 


# Connect to remote machine...

$so = New-PsSessionOption –SkipCACheck -SkipCNCheck

Get-Help New-PSSessionOption -ShowWindow  # ShowWindow create a help popup window.

# Get and store credentials to connec to remote sessions...
$cred = Get-Credential

<#  
            Copying a large file over PSRemoting...
#>

# ED Wilson, the Scripting Guy...
# https://blogs.technet.microsoft.com/heyscriptingguy/2013/12/11/use-powershell-to-create-remote-session/
$rs1 = New-PSSession -ComputerName '146.1.1.1' -SessionOption $so -Credential $cred -UseSSL 

# $ls = New-PSSession -ComputerName Prev-SQL2016
Copy-Item C:\Users\username\Downloads\some.exe -Destination "C:\" -ToSession $rs1


# Other uses of PSRemoting...

Enter-PSSession -ComputerName '146.1.1.1'  -Credential $cred -UseSSL -SessionOption $so

<#
     Invoking commands on remote computers...
#>

#  Define an array of strings with the computer names (or IP addresses)...
$computers = @('146.1.1.1','146.1.1.2')


# Run a script block against the list of computers...
Invoke-Command -ComputerName $computers -SessionOption $so -ScriptBlock { Get-Process -Name wininit } -Credential $cred  -UseSSL 

<#
   Define and run a script block variable on the list of computers...
    
#>

$psscript = { 
IF ((Get-Service -Name 'MSSQLSERVER').Status -ne 'Running') 
  { 
  'SQL Server is not running.  Starting SQL Server service.'
  Start-Service -Name 'MSSQLSERVER' -Verbose
  }
  ELSE
  {
  'SQL Server Service is already running.'
  }
}

&$psscript  #  Executes the script block

Invoke-Command -ComputerName $computers -SessionOption $so -ScriptBlock $psscript -Credential $cred -UseSSL 

Invoke-Command -ComputerName $computers -SessionOption $so -ScriptBlock { Stop-Service -Name 'MSSQLSERVER' -Verbose } -Credential $cred -UseSSL 

Get-PSSession
