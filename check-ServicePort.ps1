## check-servicePort.ps1
## Chris Shearer
## 11.8.2019

## Zero out counters
    $n = 0
    $r = 0

## Enter your service/port variables here
    $service   = "Spooler"
    $ipAddress = "10.20.30.40"
    $TCPport   = "777"
    
## Number of times to check the service
    $check = 3
    
## Enter variables for send-mailmessage here
    $smtpDomain = "example.com"
    $SMTPto     = "me@example.com"
    $SMTPfrom   = $service.replace(' ','') + "@" + $smtpDomain ## Remove spaces and make it the sender of the message
    $SMTPServer = "50.60.70.80"

## This script checks if a TCP port is open on itself. If not, it will restart the associated service 
    do { 
        ## increment the check, and check the port
            $n = $n + 1
            $result = test-netconnection $ipAddress -port $TCPport

        if ($result.tcptestsucceeded -ne $true) 
            {
                ## If the port isn't responding, restart the service and increment the restart counter.
                    get-service $service | Restart-Service
                    $r = $r + 1
            }
    
        ## write the check counter and wait for 10 sec before retrying.
            write-host $n
            start-sleep 10
    }

## Repeat if the counter is 2 or less 
    while ($n -le ($check - 1))

## State how many times we restarted and checked.
    write-host "needed to be restarted $r times"
    write-host "checked port $n times"

## Send a message if there was a restart
    if ($r -ge 1)
        {
            $body = "<br>The service $service has been restarted $r time(s) on $env:computername.<br><br>This happened because port $TCPport was inaccessible on the IP Address $ipAddress during $n tests."
            Send-MailMessage -to $SMTPto -from $SMTPfrom -subject "$service service restart"  -SmtpServer $SMTPServer -body $body -bodyAsHTML
        }
