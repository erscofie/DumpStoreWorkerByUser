# Procdump must exist in C:\temp\Procdump folder. If not, change path in script or move procdump that location.
# Usage: .\DumpStoreWorkerByUser.ps1 user01
#
###########

param(
[parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[string]$user
)


# Load module and run StoreQuery against specified mailbox:
. "$env:ExchangeInstallPath\scripts\ManagedStoreDiagnosticFunctions.ps1"

$mdb = (Get-Mailbox $user).Database
$guid = (Get-Mailbox $user).ExchangeGuid
Get-StoreQuery -Database $mdb -query "SELECT * from ThreadDiagnosticInfo where MailboxGuid = '$guid'" | Export-Clixml "C:\temp\Procdump\$user.xml"

# Get PID of DB store worker process
$workerId = (Get-MailboxDatabase $mdb -status).WorkerProcessId

Write-Host "Store worker process ID for $mdb is $workerId"

#Trigger Procdump of store worker
& "c:\temp\procdump\.\procdump.exe" -mp -s 60 -n 3 $workerId c:\temp\procdump

Write-Host -ForegroundColor Gray  "$user.xml and dump files have been saved to c:\temp\procdump"
Write-Host -ForegroundColor Yellow "All work is done."
