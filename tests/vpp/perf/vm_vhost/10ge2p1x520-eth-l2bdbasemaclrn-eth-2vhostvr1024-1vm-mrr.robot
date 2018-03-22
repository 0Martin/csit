# Copyright (c) 2018 Cisco and/or its affiliates.
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
| Library | resources.libraries.python.QemuUtils
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | MRR
| ... | NIC_Intel-X520-DA2 | ETH | L2BDMACLRN | BASE | VHOST | 1VM | VHOST_1024
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L2 | Intel-X520-DA2
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance mrr test with vhost and VM with dpdk-testpmd
| ... | dut1_node=${dut1} | dut1_vm_refs=${dut1_vm_refs}
| ... | dut2_node=${dut2} | dut2_vm_refs=${dut2_vm_refs}
| ...
| Documentation | *Raw results L2BD test cases with vhost*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 switching of IPv4.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 bridge-
| ... | domain and MAC learning enabled. Qemu Guest is connected to VPP via
| ... | vhost-user interfaces. Guest is running DPDK testpmd interconnecting
| ... | vhost-user interfaces using 5 cores pinned to cpus 5-9 and 2048M
| ... | memory. Testpmd is using socket-mem=1024M (512x2M hugepages), 5 cores
| ... | (1 main core and 4 cores dedicated for io), forwarding mode is set to
| ... | io, rxd/txd=1024, burst=64. Scheduler policy is set to SCHED_RR with
| ... | priority 1 for all Qemu CPUs. DUT1, DUT2 are tested with 2p10GE NIC X520
| ... | Niantic by Intel.
| ... | *[Ver] TG verification:* In MaxReceivedRate test TG sends traffic
| ... | at line rate and reports total received/sent packets over trial period.
| ... | Test packets are generated by TG on links to DUTs. TG traffic profile
| ... | contains two L3 flow-groups (flow-group per direction, 254 flows per
| ... | flow-group) with all packets containing Ethernet header, IPv4 header
| ... | with IP protocol=61 and static payload. MAC addresses are matching MAC
| ... | addresses of the TG node interfaces.

*** Variables ***
| ${perf_qemu_qsz}= | 1024
# Socket names
| ${bd_id1}= | 1
| ${bd_id2}= | 2
| ${sock1}= | /tmp/sock-1-${bd_id1}
| ${sock2}= | /tmp/sock-1-${bd_id2}
# X520-DA2 bandwidth limit
| ${s_limit}= | ${10000000000}
# Traffic profile:
| ${traffic_profile}= | trex-sl-3n-ethip4-ip4src254

*** Keywords ***
| Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with ${wt} thread, ${wt} phy\
| | ... | core, ${rxq} receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for ${framesize} frames using single\
| | ... | trial throughput test.
| | ...
| | [Arguments] | ${framesize} | ${wt} | ${rxq}
| | ...
| | # Test Variables required for test and test teardown
| | Set Test Variable | ${framesize}
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${get_framesize}
| | ${dut1_vm_refs}= | Create Dictionary
| | ${dut2_vm_refs}= | Create Dictionary
| | Set Test Variable | ${dut1_vm_refs}
| | Set Test Variable | ${dut2_vm_refs}
| | ${jumbo_frames}= | Set Variable If | ${get_framesize} < ${1522}
| | ... | ${False} | ${True}
| | ...
| | Given Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Run Keyword If | ${get_framesize} < ${1522}
| | ... | Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize L2 bridge domains with Vhost-User in 3-node circular topology
| | ... | ${bd_id1} | ${bd_id2} | ${sock1} | ${sock2}
| | ${vm1}= | And Configure guest VM with dpdk-testpmd connected via vhost-user
| | ... | ${dut1} | ${sock1} | ${sock2} | DUT1_VM1
| | ... | jumbo_frames=${jumbo_frames}
| | Set To Dictionary | ${dut1_vm_refs} | DUT1_VM1 | ${vm1}
| | ${vm2}= | And Configure guest VM with dpdk-testpmd connected via vhost-user
| | ... | ${dut2} | ${sock1} | ${sock2} | DUT2_VM1
| | ... | jumbo_frames=${jumbo_frames}
| | Set To Dictionary | ${dut2_vm_refs} | DUT2_VM1 | ${vm2}
| | Then Traffic should pass with maximum rate | ${perf_trial_duration}
| | ... | ${max_rate}pps | ${framesize} | ${traffic_profile}

*** Test Cases ***
| tc01-64B-1t1c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 64B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 64B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=${64} | wt=1 | rxq=1

| tc02-1518B-1t1c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 1518B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=${1518} | wt=1 | rxq=1

| tc03-9000B-1t1c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 9000B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=${9000} | wt=1 | rxq=1

| tc04-IMIX-1t1c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single\
| | ... | trial throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=IMIX_v4_1 | wt=1 | rxq=1

| tc05-64B-2t2c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 64B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 64B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=${64} | wt=2 | rxq=1

| tc06-1518B-2t2c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 1518B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=${1518} | wt=2 | rxq=1

| tc07-9000B-2t2c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 9000B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=${9000} | wt=2 | rxq=1

| tc08-IMIX-2t2c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single\
| | ... | trial throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=IMIX_v4_1 | wt=2 | rxq=1

| tc09-64B-4t4c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 64B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 64B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=${64} | wt=4 | rxq=2

| tc10-1518B-4t4c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 1518B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=${1518} | wt=4 | rxq=2

| tc10-9000B-4t4c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single\
| | ... | trial throughput test.
| | ...
| | [Tags] | 9000B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=${9000} | wt=4 | rxq=2

| tc12-IMIX-4t4c-eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single\
| | ... | trial throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for eth-l2bdbasemaclrn-eth-2vhostvr1024-1vm
| | framesize=IMIX_v4_1 | wt=4 | rxq=2
