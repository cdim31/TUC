# Lab Report: Creating a simple Firewall.

**Authors:**  
Michalis Lamprakis - 2020030077  
Christos Dimas     - 2021030183

This `README.md` serves as a lab report for the 6th exercise, explaining the code implementation of a simple blocking mechanism (a firewall).

---

### Implementation

We created the function `configure()` which configures IPv4, IPv6 and resolves a domain into IPv4, IPv6 and 
adds them as a new rule to `iptables`/`ip6tables` in the INPUT chain.
The INPUT chain in tables is used specifically to manage incoming 
network traffic that is destined for user's local system.

`dig` command is used to match ip addresses. Then adds REJECT rules to block those IPs.

Load/Save is used to load/save from/to `rulesV4`, `rulesV6` using
`iptables-restore`, `ip6tables-restore` / `iptables-save`, `ip6tables-save`.

Finally, we reset the firewall using `-F` to clear all rules in the INPUT chain and setting default policy `ACCEPT` (allow all traffic).  

---
### Question. After configuring the firewall rules, test your script by visiting your favorite websites without any other adblocking mechanism (e.g., adblock browser extensions). Can you see ads? Do they load? Some ads persist, why?


We could still see ads although some were blocked, but some were still visible. This is due to the short list of domain names in config.text (professional ad-blockers use about 50k hostnames).
Also ads can be embedded directly within the webpage itself or loaded dynamically and a Firewall based on domain blocking cannot address embedded or dynamically loaded ads. Last,
pop-ups, redirections, and notification-based ads are often initiated via JavaScript or other scripting mechanisms in the browser. These aren't connected with hostnames or IP addresses, so firewall rules are ineffective against them.

---
