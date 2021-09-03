# Kubernetes Host IP (KHIP) trace

Scans Kubernetes hosts for kernel level connections to a given remote host IP, identifying the pod, namespace, and Kubernetes host where the connection originates, as well as IP and PORT information for the origin, gateway, and destination hosts.

Can be used to identify infected hosts when the only available data is the IP address of remote hosts being scanned. 

## Execution

khip_trace.sh must be run with root privileges to allow ssh access to Kubernetes hosts. Execute with IP address of the remote host as only argument.

```
$ sudo ./khip-trace.sh <remote IP>
```

## Sample Output

```
NODE    TYPE    SOURCE IP       PORT    DESTINATION IP  PORT    GATEWAY IP      PORT    NAMESPACE       POD NAME
----    ----    ------------    -----   --------------  -----   ------------    -----   ------------    --------
c04     tcp     10.244.7.235    34592   129.99.99.99    22      129.99.99.1     49009   user1           pod1
c04     tcp     10.244.7.20     45640   129.88.88.88    22      129.88.88.1     51589   user2           pod-test
c05     tcp     10.244.2.232    32786   129.77.77.77    22      129.77.77.1     30337   john            nginx
```
