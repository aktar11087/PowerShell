Add-Type -AssemblyName System.Windows.Forms

$position = [System.Windows.Forms.Cursor]::Position
$moveDirection = 1
$moveAmount = 10

while ($true) {
    $position.X += $moveDirection * $moveAmount
    [System.Windows.Forms.Cursor]::Position = $position
    $moveDirection *= -1
    Start-Sleep -Seconds 10
}
