# Investigating legacy App

The following steps were taken to debug the legacy app:

1) Run app to find which port it is using: 
```bash
netstat -tulpn | grep legacy
```


2) Get a response code from app:
```bash
curl -i -X GET http://127.0.0.1:17873/
```

3) Run a stack trace on app
```bash
strace ./legacy test
```

From the below stacktrace, it seems the app is timing out because a resource isn't available which looks to be site because of the connection time out error:
```bash
clock_gettime(CLOCK_MONOTONIC, {370289, 226050000}) = 0
write(5, "\321\231\1\0\0\1\0\0\0\0\0\0\4test\6hiring\4tray\2io"..., 37) = 37
read(5, 0xc42016e600, 512)              = -1 EAGAIN (Resource temporarily unavailable)
futex(0x800d50, FUTEX_WAIT, 0, NULL)    = 0
epoll_wait(4, {{EPOLLOUT, {u32=148786672, u64=139852873879024}}}, 128, 0) = 1
futex(0x800d50, FUTEX_WAIT, 0, NULL)    = 0
futex(0xc420050b90, FUTEX_WAKE, 1)      = 1
clock_gettime(CLOCK_MONOTONIC, {370290, 173955000}) = 0
futex(0x7fffa0, FUTEX_WAIT, 0, {0, 998975000}) = -1 ETIMEDOUT (Connection timed out)
...
...
...
clock_gettime(CLOCK_MONOTONIC, {370296, 191399000}) = 0
clock_gettime(CLOCK_REALTIME, {1537029114, 326813100}) = 0
clock_gettime(CLOCK_MONOTONIC, {370296, 192066000}) = 0
futex(0xc42002c490, FUTEX_WAKE, 1)      = 1
clock_gettime(CLOCK_REALTIME, timeout
{1537029114, 327787000}) = 0
+++ exited with 1 +++
```

4) Viewing the binary using the less command, this showed that the binary is a GoLang app:
```bash
/home/luka/projects/tray.io/syseng-test/src/github.com/trayio/syseng-test/main.go
```

5) Running tcpdump, I found the app is trying to connect to test.hiring.tray.io
```bash
18:18:32.817235 IP MOD-AWS-X-MGT01.44581 > ip-172-28-248-2.eu-west-1.compute.internal.domain: 31783+ AAAA? test.hiring.tray.io. (37)
18:18:32.817260 IP MOD-AWS-X-MGT01.45313 > ip-172-28-248-2.eu-west-1.compute.internal.domain: 16831+ A? test.hiring.tray.io. (37)
18:18:32.817687 IP MOD-AWS-X-MGT01.48270 > ip-172-28-248-2.eu-west-1.compute.internal.domain: 34668+ AAAA? test.hiring.tray.io.eu-west-1.compute.internal. (64)
18:18:32.817701 IP MOD-AWS-X-MGT01.57351 > ip-172-28-248-2.eu-west-1.compute.internal.domain: 29265+ A? test.hiring.tray.io.eu-west-1.compute.internal. (64)
```

## Investigation Conclusion
It seems the legacy app is timing out trying to connect to the test.hiring.tray.io and test.hiring.tray.io.eu-west-1.compute.internal URLs.
During my investigation, I found that running the app with the below command would result in a 202 response and that it wouldn't timeout.
```bash
./legacy ""
```

# Infrastructure Solution Explained

To host the legacy app, first an AMI was created and 3 files installed:
1) checkLegacyStatus.sh - Stored under /data/legacy/ this script will check HTTP response code of the app, if it isn't equal to 202 then it will start it.
2) legacy - Stored under /data/legacy/ this is the provided app.
3) checkLegacyStatusCron - Stored under /etc/cron.d/ this will execute the checkLegacyStatus.sh script every 10 minutes.

Once the AMI was created (ami-0f0e3bc7c6215ebf8 - can be shared on request), then terraform is used to created the VPC, NetworkACL, Security Groups and EC2 instance.
1) main.tf - Contains the setup.
2) variables.tf - Contains variables used in main.tf.

To make this process, easy to manage a jenkins job can be created to execute the necessary terraform commands:
- jenkinsScript.sh - Contains the terraform commands, the jenkins job can have a simple drop down selection in the build parameters which are create and destroy. 
  - "create" - Command will create VPC, instance etc but also output the URL needed to access the server.
  - "destroy" - Command will automatically remove the VPC etc without needing approval.
  
