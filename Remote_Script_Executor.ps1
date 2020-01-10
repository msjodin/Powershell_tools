$scripts = gci("C:\Directory\ScriptsDirectory")

$count = 1

Foreach($script in $scripts){
    Write-Host "$count - " $script.FullName
    $count++
    }

[int64]$answer = Read-Host -Prompt "Enter the number of the script you would like to run: "

IF(($answer -le $count) -and ($answer -ne 0)){
    $answer--
    $scriptselection = ($scripts | Select-Object -index $answer)}

Write-Host $scriptselection.FullName

$sessions = New-PSSession -ComputerName (Get-Content "C:\Directory\ListOfServers.txt") -Credential domain\username

$servername = $sessions.ComputerName

Invoke-Command -Session $sessions -FilePath $scriptselection.FullName
