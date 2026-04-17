# HelloID-Conn-SA-Full-SaltoSpace-ViewStagingTable
## Description
This HelloID Service Automation Delegated Form provides a Salto report containing the staging database. The following options are available:
 1. Overview of all columns and rows in the staging database of Salto.
 2. Option to only show rows that contain an error (`Error Code` is not `0`).
 3. Option to only show rows that need to be processed by Salto (`To Be Processed By Salto` is `1`).
 4. No actions are available; this report only queries the current state of the Salto staging database.
 5. This report can be used in combination with the [HelloID-Conn-Prov-Target-SaltoSpace](https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-SaltoSpace) repository.

## Versioning
| Version | Description     | Date       |
| ------- | --------------- | ---------- |
| 1.0.0   | Initial release | 2025/09/23 |

## Table of Contents
- [HelloID-Conn-SA-Full-SaltoSpace-ViewStagingTable](#helloid-conn-sa-full-saltospace-viewstagingtable)
  - [Description](#description)
  - [Versioning](#versioning)
  - [Table of Contents](#table-of-contents)
  - [All-in-one PowerShell setup script](#all-in-one-powershell-setup-script)
    - [Getting started](#getting-started)
    - [Post-setup configuration](#post-setup-configuration)
  - [Manual resources](#manual-resources)
    - [Powershell data source 'Salto-Staging-View-Grid'](#powershell-data-source-salto-staging-view-grid)
  - [Getting help](#getting-help)
  - [HelloID Docs](#helloid-docs)


## All-in-one PowerShell setup script
The PowerShell script "createform.ps1" contains a PowerShell script that uses the HelloID API to create the Form, including user-defined variables, tasks, and data sources.

_Please note that this script assumes none of the required resources exist within HelloID. The script does not contain versioning or source control_

### Getting started
Please follow the documentation steps on [HelloID Docs](https://docs.helloid.com/hc/en-us/articles/360017556559-Service-automation-GitHub-resources) in order to set up and run the All-in-one PowerShell Script in your own environment.
 
### Post-setup configuration
After the all-in-one PowerShell script has run and created all the required resources, the following items need to be configured according to your environment:
 1. Update the following [user defined variables](https://docs.helloid.com/hc/en-us/articles/360014169933-How-to-Create-and-Manage-User-Defined-Variables)

| Variable name                   | Description                                                                                                                                                                                 | Mandatory |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| sqlSaltoStagingConnectionString | The connection string used to connect to the Salto Staging SQL database.                                                                                                                    | Yes       |
| sqlSaltoStagingTableName        | The name of the Salto staging table.                                                                                                                                                        | Yes       |
| sqlSaltoStagingOptionalUsername | Optional: The username of the SQL user to use in the connection string. Note: Not compatible with `Trusted_Connection=True` in the connection string as it requires Windows Authentication. | No        |
| sqlSaltoStagingOptionalPassword | Optional: The password of the SQL user to use in the connection string. Note: Not compatible with `Trusted_Connection=True` in the connection string as it requires Windows Authentication. | No        |

## Manual resources
This Delegated Form uses the following resources in order to run

### Powershell data source 'Salto-Staging-View-Grid'
This Powershell data source runs an SQL select query on the Salto staging database.

## HelloID Docs
The official HelloID documentation can be found at: https://docs.helloid.com/
