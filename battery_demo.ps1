# PowerShell .NET WMI battery level demo by ph03n1x.


# Status of the battery:
#
# Other (1)
#     The battery is discharging.
# Unknown (2)
#     The system has access to AC so no battery is being discharged. However, the battery is not necessarily charging.
# Fully Charged (3)
# Low (4)
# Critical (5)
# Charging (6)
# Charging and High (7)
# Charging and Low (8)
# Charging and Critical (9)
# Undefined (10)
# Partially Charged (11)
$battery_status = (Get-WmiObject -Class Win32_Battery).BatteryStatus

# Estimate of the percentage of full charge remaining.
$battery_perc = (Get-WmiObject -Class Win32_Battery).EstimatedChargeRemaining

# Estimate in minutes of the time to battery charge depletion under the present load conditions if the utility power is off,
# or lost and remains off, or a laptop is disconnected from a power source.
$battery_estimated_time = (Get-WmiObject -Class Win32_Battery).EstimatedRunTime

# Design voltage of the battery in millivolts.
#$battery_voltage = (Get-WmiObject -Class Win32_Battery).DesignVoltage

# Watch for changes
for (;;) {
    $new_battery_status = (Get-WmiObject -Class Win32_Battery).BatteryStatus
    $new_battery_perc = (Get-WmiObject -Class Win32_Battery).EstimatedChargeRemaining
    $new_battery_estimated_time = (Get-WmiObject -Class Win32_Battery).EstimatedRunTime
    if (($new_battery_perc -ne $battery_perc) -or ($new_battery_status -ne $battery_status)) {
        $battery_status = $new_battery_status
        $battery_perc = $new_battery_perc
        $battery_estimated_time = $new_battery_estimated_time

        # Create notification
        $form = New-Object System.Windows.Forms.Form
        $form.Height = 0
        $form.Width = 0
        $form.AutoSize = $True
        $form.ShowInTaskbar = $False
        $form.BackColor = [System.Drawing.Color]::Gray
        $form.AllowTransparency = $True
        $form.Opacity = 1
        $form.DesktopLocation = New-Object System.Drawing.Point(0, 0)
        $form.FormBorderStyle = 0
        $label = New-Object System.Windows.Forms.Label
        $label.AutoSize = $True
        $label.Font = New-Object System.Drawing.Font("", 20, [System.Drawing.FontStyle]::Regular)
        $p_text = ""
        if ($battery_status -eq 1) {$p_text = " (" + $battery_estimated_time + "m)"}
        $label.Text = "⚡ " + $battery_perc + "%" + $p_text
        $form.Controls.Add($label)

        # Show notification
        $form.Show()
        $form.TopMost = $True
        
        # Notification display time
        Start-Sleep -Seconds 1

        # Notification fading
        for ($op = .95; $op -gt 0; $op -= .05) {
            $form.Opacity = $op
            Start-Sleep -Milliseconds 50
        }

        # Remove notification
        $form.Close()
        $form.Dispose()
    }

    # Specify time between checks
    Start-Sleep -Seconds 30
}
