# Connection string
$filecontent = "Server= t - eun-demo1-sql.database.windows.net; Database = t-eun-demo1-db;uid=demo001; Password= gJv^qY0QkH>U+9Wpn8LQqzR32;Trusted_Connection=False;Connection Timeout=2000;TrustServerCertificate=True;"

# Remove newline characters, spaces, and carriage return characters
$filecontent = $filecontent -replace "`n","" -replace " ","" -replace "`r",""

Here's a breakdown of the operations being performed:

1. -replace "n","": This removes newline characters (n`).
2. -replace " ","": This removes spaces.
3. -replace "r","": This removes carriage return characters (r`).

# Display the modified connection string
Write-Host "Modified Connection String:"
Write-Host $filecontent

# Now you can use $filecontent in your script for database connection or other purposes
# For example, connecting to the database using the modified connection string
# YourDatabaseConnectionFunction -ConnectionString $filecontent

# Remove spaces after semicolons and equal signs
$filecontent = $filecontent -replace "`n|(?<=[;=])\s+|`r",""

# Remove spaces before and after semicolons and equal signs
$filecontent = $filecontent -replace "`n|\s*([-;=])\s*|`r", '$1'


** Let's break down the regular expression used in the -replace operator:

- `n : Removes newline characters.
- \s*([-;=])\s* : Captures any combination of whitespace (including none) around certain characters (-, ;, or =). The captured character is used to preserve these specific separators.
- `r : Removes carriage return characters.
