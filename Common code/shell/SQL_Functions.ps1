function Invoke-Script ($DbServerName,$MyaDbName,$script,$logFile)
{
    Write-Verbose "Running Script : $script"
    Invoke-Sqlcmd -Server $DbServerName -Database $MyaDbName -InputFile $script -AbortOnError -querytimeout 0 -Verbose 4>> $logFile
}
function Invoke-Query ($DbServerName,$MyaDbName,$query,$logFile)
{
    Write-Verbose "Running Query : $query"
    Invoke-Sqlcmd -Server $DbServerName -Database $MyaDbName -Query $query -AbortOnError -querytimeout 0 -Verbose 4>> $logFile
}

function Invoke-ScriptFolder ($DbServerName,$MyaDbName,$localScriptRoot,$logFile)
{
    $scripts = Get-ChildItem -Recurse $localScriptRoot | Where-Object {$_.Extension -eq ".sql"} | Select-Object -ExpandProperty FullName

    #Clean core database
    try {
        foreach ($s in $scripts)
        {
            Invoke-Script $DbServerName $MyaDbName $s $logfile
        }
    }
    catch {
        Write-Warning "error when running sql $s"
        throw $error
    }
}