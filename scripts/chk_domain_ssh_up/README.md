# Check a list of domains or IPs to determine if they're available via ssh


## How to:
Replace DOM_FILE variable in script to list of domains or IPs to verify and run!

Difference between scripts:

- chk_domain_ssh_up_SSH.sh uses SSH > Only returns if ssh server can be accessed
- chk_domain_ssh_up.sh uses netcat > Will return if ssh is running but inaccesible

The script will create 2 files:
1. good_doms_$DATE - Domains or IPs reachable by SSH
2. bad_doms_$DATE - Domains or IPs not reachable by SSH
