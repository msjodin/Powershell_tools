$subscriptionId = "Insert Sub Id Here"
$storageAccountRG = "Insert Resource Group Name Here"
$storageAccountName = "Insert Storage Account Name Here"
$storageContainerName = "Insert Container Name Here"
$storageAccountKey = "Insert Storage Account Key For Dest SA Here"

# Establishing Directories to use

$RawDir = "\\Server-FQDN\PathOfDir\"
$dir = gci $RawDir

#Files to store errors and successes
$good = "C:\OutputFolder\SuccessfulTransfers.txt"
$bad = "C:\OutputFolder\ProblemOutput.txt"
$progress = "C:\OutputFolder\Progress.txt" 

# Select right Azure Subscription
Select-AzSubscription -SubscriptionId $SubscriptionId

# Set AzStorageContext to access SA
$destinationContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

Out-file -InputObject "Step 1: Storage creds authenticated" -FilePath $progress -Append

foreach($file in $dir)
    {
    $Ifile = $RawDir + $file
    $erroractionpreference = 'Stop'
    Try
    {Set-AzStorageBlobContent -File $Ifile -Context $destinationContext -Container backups -Force
    Out-File -InputObject "$file" -FilePath $GoodResult -Append}
    Catch
        {Out-File -InputObject "$file" -FilePath  $BadResult -Append}
    Finally
        {$erroractionpreference = 'Continue'}
    }

Out-file -InputObject "Step 2: Backups Transferred" -FilePath $progress -Append

#Send an email with the contents of the transfers
$GoodResult = gc $good
$BadResult = gc $bad

$SourceEmail = "SourceEmail@domain.com"
$DestEmail = "YourEmail@domain.com"
$BccEmail = "BccEmail@domain.com"
$SmtpServer = "SendingServerFQDN"

Send-MailMessage -BodyAsHtml -From $SourceEmail -To $DestEmail -Bcc $BccEmail -Subject "Backups Offloaded" -Body "Hello, <br><br> Generated from server_fqdn concerning task: Offload Backups <br><br> Successful Backups: $GoodResult <br> Failed Backups: $BadResult <br> Thanks" -SmtpServer $SmtpServer

Out-file -InputObject "Step 3: Email Sent" -FilePath $progress -Append

#Remove all contents of the log files
#foreach($file in $GoodResult){Remove-Item $RawDir$file -Force -Verbose}

Out-File -InputObject "" -FilePath $good -Force
Out-File -InputObject "" -FilePath $bad -Force

Out-file -InputObject "Step 4: Text Files wiped" -FilePath $progress -Force

Out-File -InputObject "" -FilePath $progress -Force