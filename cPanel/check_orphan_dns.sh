for user in $(cat /root/suspicious.all); do domain=$(whmapi1 accountsummary user=$user | awk '/domain:/ {print $2}'); assignedip=$(whmapi1 accountsummary user=$user | awk '/ip:/ {print$2}') ; dnsip=$(dig +short $domain); dnsmx=$(dig MX +short $domain @8.8.8.8 | awk '{print $2}' | xargs dig +short); if [[ $dnsip == $assignedip ]]; then echo -n "$user:$domain - A - RESOLVES"; if [[ "$dnsmx" == "$assignedip" ]]; then echo -e " but MX for $user:$domain does point locally"; else echo ""; fi; fi ; done
