**Use case:**

You have built a new vCenter from scratch and would like to move host from an existing vCenter server to this one. As a preparation for this migration you performed following steps

1) Created Network mapping of all VMs in the source vCenter server
2) Exported the Distributed switch configuration from the source vCenter server
3) Imported the Distributed switch configuration to the new vCenter server
4) Added ESXi hosts in the New vCenter server to their respective Datacenter and cluster

However, you are still left with mammoth task of adding the host to Distributed switch and Mapping the VMs to Distributed PortGroups

**This script makes use of Auto assign vmnic to DVS uplink. Due to this there is no way to specify vmnic to uplink mapping. Hence, do not use in an environment where vmnic to uplink mapping is required to be a constant.**

**Do not use the script without testing it in your Test/Dev environment**

**More details at:**

https://vmzoneblog.com/2020/01/08/adding-the-host-to-distributed-switch-and-mapping-the-vms/ 