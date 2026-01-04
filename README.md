# Active Directory HTML Dashboard

## Overview

This project is a PowerShell driven Active Directory dashboard that automatically collects data from domain controllers and renders it into a clean, interactive HTML report. The goal of the project was to create a centralized, readable view of Active Directory health and structure without manually maintaining static documentation or spreadsheets.

The script gathers live information from the environment and converts it into HTML using a PowerShell module, allowing the dashboard to be opened in any browser with no additional dependencies.

## Features

* Forest level information
* Domain level details
* Domain controller inventory
* User and computer summaries per domain
* Interactive tables with sorting and searching
* Fully generated HTML with no manual markup

## How It Works

The script queries Active Directory using native PowerShell cmdlets, structures the data into objects, and passes those objects into an HTML generation module. The module handles layout, styling, and interactive elements automatically.

No raw HTML or CSS is manually written. All visual output is generated directly from PowerShell.

## Technologies Used

* PowerShell
* ActiveDirectory PowerShell module
* PSWriteHTML

PSWriteHTML is responsible for converting PowerShell objects into structured HTML sections, panels, and tables, including built in JavaScript and CSS for interactivity.

## Requirements

* Windows PowerShell 5.1 or PowerShell 7+
* RSAT Active Directory tools
* PSWriteHTML module

## Installation

```powershell
Install-Module PSWriteHTML -Scope CurrentUser
```

Ensure the ActiveDirectory module is available on the system running the script.

## Usage

1. Run the script on a system joined to the domain
2. Allow the script to query domain controllers and Active Directory objects
3. Open the generated HTML file in a web browser

The output is a standalone HTML file that can be shared internally or archived for documentation purposes.

## Use Cases

* Active Directory documentation
* Environment visibility for audits or reviews
* Change tracking over time
* Lab or learning environments

## Notes

This script is read only and does not modify any Active Directory objects. It is intended for reporting and visibility only.

## License

This project is provided as is for educational and administrative use.
