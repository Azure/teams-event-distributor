# Script to load the URL into all Azure Storage accounts deployed as part of the Teams load-balancing solution

# Install Azure PowerShell
# https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-5.5.0
# This is the only Az module required for this script (you don't have to install all Az modules)
Install-Module AzTable
# Login to Azure with a browser sign-in token
Connect-AzAccount

# Set to the subscription ID in which the solution got deployed in
Set-AzContext -Subscription "xxxx-xxxx-xxxx-xxxx"

# url-list.txt needs to contain the list of backend URLs, one per line
$urls = Get-Content sample-url-list.txt

Write-Host "Fount $($urls.Count) URLs to import"

$resourceGroup = "teamsdistributor" # <-- Change me!

$tableName = "Urls" # does not need to be changed unless it was changed in the ARM template
$partitionKey = "event1" # does not need to be changed

# Get all storage accounts in the resource group
$storageAccounts = Get-AzStorageAccount -ResourceGroupName $resourceGroup

foreach ($storageAccount in $storageAccounts) {
    Write-Host "Importing data into storage account $($storageAccount.StorageAccountName)"
    $ctx = $storageAccount.Context

    $cloudTable = (Get-AzStorageTable –Name $tableName –Context $ctx).CloudTable

    # First, delete all current entries in the table
    $currentRows = Get-AzTableRow -Table $cloudTable 
    Write-Host "Deleting $($currentRows.Count) old rows from the table"
    $currentRows | Remove-AzTableRow -Table $cloudTable 

    $i = 0
    foreach ($url in $urls) {
        Add-AzTableRow `
            -Table $cloudTable `
            -PartitionKey $partitionKey `
            -RowKey ($i) `
            -Property @{"url" = "$url" } `
            -UpdateExisting

        $i++
    }
}