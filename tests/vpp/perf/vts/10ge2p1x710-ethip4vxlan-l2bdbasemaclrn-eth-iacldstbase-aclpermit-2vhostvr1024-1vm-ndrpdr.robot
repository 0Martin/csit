# Copyright (c) 2019 Cisco and/or its affiliates.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

*** Settings ***
| Resource | resources/libraries/robot/performance/performance_setup.robot
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDR
| ... | NIC_Intel-X710 | L2BDMACLRN | ENCAP | VXLAN | L2OVRLAY | IP4UNRLAY
| ... | VHOST | VM | VHOST_1024 | VTS | ACL_PERMIT
| ...
| Suite Setup | Run Keywords
| ... | Set up 3-node performance topology with DUT's NIC model
| ... | L3 | ${nic_name}
| ... | AND | Set up performance test suite with ACL
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance test with vhost and VM with dpdk-testpmd and ACL
| ... | dut1_node=${dut1} | dut1_vm_refs=${dut1_vm_refs}
| ...
| Test Template | Local Template
| ...
| Documentation | *RFC2544: Packet throughput L2BD test cases with VXLANoIPv4
| ... | and vhost*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 switching of IPv4.
| ... | Eth-IPv4-VXLAN-Eth-IPv4 is applied on link between DUT1 and DUT2.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 bridge-
| ... | domain and MAC learning enabled. Qemu Guest is connected to VPP via
| ... | vhost-user interfaces. Guest is running DPDK testpmd interconnecting
| ... | vhost-user interfaces using 5 cores pinned to cpus 5-9 and 2048M
| ... | memory. Testpmd is using socket-mem=1024M (512x2M hugepages), 5 cores
| ... | (1 main core and 4 cores dedicated for io), forwarding mode is set to
| ... | io, rxd/txd=256, burst=64. DUT1, DUT2 are tested with ${nic_name}.\
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop\
| ... | Rate) with zero packet loss tolerance and throughput PDR (Partial Drop\
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage\
| ... | of packets transmitted. NDR and PDR are discovered for different\
| ... | Ethernet L2 frame sizes using MLRsearch library.\
| ... | Test packets are generated by TG on
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups
| ... | (flow-group per direction, 253 flows per flow-group) with all packets
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and static
| ... | payload. MAC addresses are matching MAC addresses of the TG node
| ... | interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544, RFC7348.

*** Variables ***
| ${nic_name}= | Intel-X710
| ${overhead}= | ${50}
# Socket names
| ${dut1_bd_id1}= | 1
| ${dut1_bd_id2}= | 2
| ${dut2_bd_id1}= | 1
| ${sock1}= | /var/run/vpp/sock-1-${dut1_bd_id1}
| ${sock2}= | /var/run/vpp/sock-1-${dut1_bd_id2}
# Traffic profile:
| ${traffic_profile}= | trex-sl-ethip4-vxlansrc253
| ${acl_type}= | permit
# Defaults for teardown:
| ${dut1}= | ${None}
| ${dut1_vm_refs}= | ${None}

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config.
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Measure NDR and PDR values using MLRsearch algorithm.\
| | ...
| | ... | *Arguments:*
| | ... | - frame_size - L2 Frame Size [B]. Type: integer
| | ... | - phy_cores - Number of worker threads to be used. Type: integer
| | ... | - rxq - Number of Rx queues to be used. Type: integer
| | ... | - acl_type - FIXME.
| | ...
| | [Arguments] | ${frame_size} | ${phy_cores} | ${rxq}=${None}
| | ...
| | Set Test Variable | \${frame_size}
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | Add PCI devices to all DUTs
| | Set Max Rate And Jumbo And Handle Multi Seg
| | And Apply startup configuration on all VPP DUTs
| | &{vxlan1} = | Create Dictionary | vni=24 | vtep=172.17.0.2
| | &{vxlan2} = | Create Dictionary | vni=24 | vtep=172.27.0.2
| | @{dut1_vxlans} = | Create List | ${vxlan1}
| | @{dut2_vxlans} = | Create List | ${vxlan2}
| | Set interfaces in path up
| | Configure vhost interfaces for L2BD forwarding | ${dut1}
| | ... | ${sock1} | ${sock2}
| | When Init L2 bridge domains with single DUT with Vhost-User and VXLANoIPv4 in 3-node circular topology
| | ... | 172.16.0.1 | 16 | 172.26.0.1 | 16 | 172.16.0.2 | 172.26.0.2
| | ... | ${dut1_vxlans} | ${dut2_vxlans} | 172.17.0.0 | 16 | 172.27.0.0 | 16
| | @{permit_list} = | Create List | 10.0.0.1/32 | 10.0.0.2/32
| | Run Keyword If | '${acl_type}' != '${EMPTY}'
| | ... | Configure ACLs on a single interface | ${dut1} | ${dut1_if2} | input
| | ... | ${acl_type} | @{permit_list}
| | ${nf_cpus}= | Get Affinity NF | ${nodes} | ${dut1} | nf_chains=${1}
| | | ... | nf_nodes=${1} | nf_chain=${1} | nf_node=${1}
| | | ... | vs_dtc=${cpu_count_int} | nf_dtc=${cpu_count_int}
| | ${vm1} = | And Configure guest VM with dpdk-testpmd connected via vhost-user
| | ... | DUT1 | ${sock1} | ${sock2} | ${TEST NAME}DUT1_VM1 | ${nf_cpus}
| | ... | jumbo=${jumbo} | perf_qemu_qsz=${1024} | use_tuned_cfs=${False}
| | Set Test Variable | &{dut1_vm_refs} | ${TEST NAME}DUT1_VM1=${vm1}
| | Then Find NDR and PDR intervals using optimized search

*** Test Cases ***
| tc01-114B-1c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 114B | 1C
| | frame_size=${114} | phy_cores=${1}

| tc02-114B-2c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 114B | 2C
| | frame_size=${114} | phy_cores=${2}

| tc03-114B-4c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 114B | 4C
| | frame_size=${114} | phy_cores=${4}

| tc04-1518B-1c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 1518B | 1C
| | frame_size=${1518} | phy_cores=${1}

| tc05-1518B-2c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 1518B | 2C
| | frame_size=${1518} | phy_cores=${2}

| tc06-1518B-4c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 1518B | 4C
| | frame_size=${1518} | phy_cores=${4}

| tc07-9000B-1c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 9000B | 1C
| | frame_size=${9000} | phy_cores=${1}

| tc08-9000B-2c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 9000B | 2C
| | frame_size=${9000} | phy_cores=${2}

| tc09-9000B-4c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | 9000B | 4C
| | frame_size=${9000} | phy_cores=${4}

| tc10-IMIX-1c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | IMIX | 1C
| | frame_size=IMIX_v4_1 | phy_cores=${1}

| tc11-IMIX-2c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | IMIX | 2C
| | frame_size=IMIX_v4_1 | phy_cores=${2}

| tc12-IMIX-4c-ethip4vxlan-l2bdbasemaclrn-eth-iacldstbase-aclpermit-2vhostvr1024-1vm-ndrpdr
| | [Tags] | IMIX | 4C
| | frame_size=IMIX_v4_1 | phy_cores=${4}
