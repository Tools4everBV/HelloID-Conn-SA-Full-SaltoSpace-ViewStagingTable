#######################################################################
# Template: HelloID SA Powershell data source
# Name: Salto-Staging-View-Grid
# Date: 02-09-2025
#######################################################################

# For basic information about powershell data sources see:
# https://docs.helloid.com/en/service-automation/dynamic-forms/data-sources/powershell-data-sources.html

# Service automation variables:
# https://docs.helloid.com/en/service-automation/service-automation-variables.html

#region init

$VerbosePreference = "SilentlyContinue"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# global variables (Automation --> Variable libary):
# $globalVar = $globalVarName
$connectionString = $sqlSaltoStagingConnectionString
$dbTableStaging = $sqlSaltoStagingTableName
$username = $sqlSaltoStagingOptionalUsername
$password = $sqlSaltoStagingOptionalPassword

# variables configured in form:
$onlyShowErrors = $datasource.onlyShowErrors
$onlyShowNeedProcess = $datasource.onlyShowNeedProcess

#endregion init

#region functions
function Invoke-SQLQuery {
    param(
        [parameter(Mandatory = $true)]
        $ConnectionString,

        [parameter(Mandatory = $false)]
        $Username,

        [parameter(Mandatory = $false)]
        $Password,

        [parameter(Mandatory = $true)]
        $SqlQuery,

        [parameter(Mandatory = $true)]
        [ref]$Data
    )
    try {
        $Data.value = $null

        # Initialize connection and execute query
        if (-not[String]::IsNullOrEmpty($Username) -and -not[String]::IsNullOrEmpty($Password)) {
            # First create the PSCredential object
            $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
            $credential = [System.Management.Automation.PSCredential]::new($Username, $securePassword)

            # Set the password as read only
            $credential.Password.MakeReadOnly()

            # Create the SqlCredential object
            $sqlCredential = [System.Data.SqlClient.SqlCredential]::new($credential.username, $credential.password)
        }

        # Connect to the SQL server
        $SqlConnection = [System.Data.SqlClient.SqlConnection]::new()
        $SqlConnection.ConnectionString = $ConnectionString
        if (-not[String]::IsNullOrEmpty($sqlCredential)) {
            $SqlConnection.Credential = $sqlCredential
        }
        $SqlConnection.Open()
        Write-Information "Successfully connected to SQL database"

        # Set the query
        $SqlCmd = [System.Data.SqlClient.SqlCommand]::new()
        $SqlCmd.Connection = $SqlConnection
        $SqlCmd.CommandText = $SqlQuery

        # Set the data adapter
        $SqlAdapter = [System.Data.SqlClient.SqlDataAdapter]::new()
        $SqlAdapter.SelectCommand = $SqlCmd

        # Set the output with returned data
        $DataSet = [System.Data.DataSet]::new()
        $null = $SqlAdapter.Fill($DataSet)

        # Set the output with returned data
        $Data.value = $DataSet.Tables[0] | Select-Object -Property * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors
    }
    catch {
        $Data.Value = $null
        Write-Error $_
    }
    finally {
        if ($SqlConnection.State -eq "Open") {
            $SqlConnection.close()
        }
        Write-Information "Successfully disconnected from SQL database"
    }
}

#endregion functions

#region lookup
try {
    $actionMessage = "querying records from Salto Staging DB"

    $conditions = @()
    if ($onlyShowErrors -eq 'true') {
        $conditions += "ErrorCode != '0'"
    }
    if ($onlyShowNeedProcess -eq 'true') {
        $conditions += "ToBeProcessedBySalto = 1"
    }
    if ($conditions.Count -gt 0) {
        $optionalWhere = "WHERE " + ($conditions -join " AND ")
    }
    else {
        $optionalWhere = ""
    }

    $getSaltoStagingAccountSplatParams = @{
        ConnectionString = $connectionString
        Username         = $username
        Password         = $password
        SqlQuery         = "
        SELECT
            ToBeProcessedBySalto,
            ProcessedDateTime,
            ErrorCode,
            ErrorMessage,
            Action,
            ExtID,
            dtActivation,
            dtExpiration,
            FirstName,
            LastName,
            Dummy1,
            Dummy2,
            Dummy3,
            Dummy4,
            Dummy5,
            Title,
            ExtAccessLevelIDList
        FROM
            [dbo].[$($dbTableStaging)]
        $optionalWhere
        ORDER BY
            ProcessedDateTime DESC
        "
        Verbose          = $false
        ErrorAction      = "Stop"
    }

    Write-Information "SQL Query: $($getSaltoStagingAccountSplatParams.SqlQuery | Out-String)"

    $getSaltoStagingAccountResponse = [System.Collections.ArrayList]::new()
    Invoke-SQLQuery @getSaltoStagingAccountSplatParams -Data ([ref]$getSaltoStagingAccountResponse)
    Write-Information "Successfully queried data. Result count: $(($getSaltoStagingAccountResponse | Measure-Object).Count)"

    $actionMessage = "returning records to HelloID"
    if (($getSaltoStagingAccountResponse | Measure-Object).Count -gt 0) {   
        foreach ($account in $getSaltoStagingAccountResponse) {
            $result = @{}
            foreach ($property in $account.PSObject.Properties) {
                if ($null -eq $property.Value -or $property.Value -is [System.DBNull]) {
                    $result[$property.Name] = $null
                }
                else {
                    $result[$property.Name] = [string]$property.Value
                }
            }

            $returnObject = @{
                ToBeProcessedBySalto = $result.ToBeProcessedBySalto
                ProcessedDateTime    = $result.ProcessedDateTime
                ErrorCode            = $result.ErrorCode
                ErrorMessage         = $result.ErrorMessage
                Action               = $result.Action
                ExtID                = $result.ExtID
                dtActivation         = $result.dtActivation
                dtExpiration         = $result.dtExpiration
                FirstName            = $result.FirstName
                LastName             = $result.LastName
                Dummy1               = $result.Dummy1
                Dummy2               = $result.Dummy2
                Dummy3               = $result.Dummy3
                Dummy4               = $result.Dummy4
                Dummy5               = $result.Dummy5
                Title                = $result.Title
                ExtAccessLevelIDList = $result.ExtAccessLevelIDList
            }
            Write-Output $returnObject
        }
    }
}
catch {
    $ex = $PSItem
    $auditMessage = "Error $($actionMessage). Error: $($ex.Exception.Message)"
    $warningMessage = "Error at Line [$($ex.InvocationInfo.ScriptLineNumber)]: $($ex.InvocationInfo.Line). Error: $($ex.Exception.Message)"
    Write-Warning $warningMessage
    Write-Error $auditMessage
}
#endregion lookup
