# Copyright (c) 2017 Cisco and/or its affiliates.
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
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | PDRCHK
| ... | NIC_Intel-X520-DA2 | DOT1Q | L2BDMACLRN | BASE | VHOST | VM | VHOST_1024
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L2 | Intel-X520-DA2
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| Test Teardown | Tear down performance pdrchk test with vhost and VM with dpdk-testpmd
| ... | ${rate}pps | ${framesize} | ${traffic_profile}
| ... | dut1_node=${dut1} | dut1_vm_refs=${dut1_vm_refs}
| ... | dut2_node=${dut2} | dut2_vm_refs=${dut2_vm_refs}
| ...
| Documentation | *RFC2544: Packet throughput L2BD test cases with vhost*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 switching of IPv4. 802.1q
| ... | tagging is applied on link between DUT1 and DUT2.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 bridge-
| ... | domain and MAC learning enabled. Qemu Guest is connected to VPP via
| ... | vhost-user interfaces. Guest is running DPDK testpmd interconnecting
| ... | vhost-user interfaces using 5 cores pinned to cpus 5-9 and 2048M
| ... | memory. Testpmd is using socket-mem=1024M (512x2M hugepages), 5 cores
| ... | (1 main core and 4 cores dedicated for io), forwarding mode is set to
| ... | io, rxd/txd=256, burst=64. DUT1, DUT2 are tested with 2p10GE NIC X520
| ... | Niantic by Intel.
| ... | *[Ver] TG verification:* TG verifies throughput PDR (Partial Drop
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage
| ... | of packets transmitted. Ref-PDR value is periodically updated acording to
| ... | formula: ref-PDR = 0.9x PDR, where PDR is found in RFC2544 long
| ... | performance tests for the same DUT configuration. Test packets are
| ... | generated by TG on links to DUTs. TG traffic profile contains two L3
| ... | flow-groups (flow-group per direction, 253 flows per flow-group) with
| ... | all packets containing Ethernet header, IPv4 header with IP protocol=61
| ... | and static payload. MAC addresses are matching MAC addresses of the
| ... | TG node interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
| ${perf_qemu_qsz}= | 1024
| ${subid}= | 10
| ${tag_rewrite}= | pop-1
# Socket names
| ${bd_id1}= | 1
| ${bd_id2}= | 2
| ${sock1}= | /tmp/sock-1-${bd_id1}
| ${sock2}= | /tmp/sock-1-${bd_id2}
# Traffic profile:
| ${traffic_profile}= | trex-sl-3n-ethip4-ip4src254

*** Keywords ***
| Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with ${wt} thread, ${wt} phy\
| | ... | core, ${rxq} receive queue per NIC port.
| | ... | [Ver] Verify ref-PDR for ${framesize} Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Arguments] | ${framesize} | ${rate} | ${wt} | ${rxq}
| | ...
| | # Test Variables required for test and test teardown
| | Set Test Variable | ${framesize}
| | Set Test Variable | ${rate}
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | ${dut1_vm_refs}= | Create Dictionary
| | ${dut2_vm_refs}= | Create Dictionary
| | Set Test Variable | ${dut1_vm_refs}
| | Set Test Variable | ${dut2_vm_refs}
| | ...
| | Given Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to DUTs in 3-node single link topology
| | And Run Keyword If | ${get_framesize} < ${1522}
| | ... | Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize L2 bridge domains with Vhost-User and VLAN in a 3-node circular topology
| | ... | ${bd_id1} | ${bd_id2} | ${sock1} | ${sock2} | ${subid}
| | ... | ${tag_rewrite}
| | ${vm1}= | And Configure guest VM with dpdk-testpmd connected via vhost-user
| | ... | ${dut1} | ${sock1} | ${sock2} | DUT1_VM1
| | Set To Dictionary | ${dut1_vm_refs} | DUT1_VM1 | ${vm1}
| | ${vm2}= | And Configure guest VM with dpdk-testpmd connected via vhost-user
| | ... | ${dut2} | ${sock1} | ${sock2} | DUT2_VM1
| | Set To Dictionary | ${dut2_vm_refs} | DUT2_VM1 | ${vm2}
| | Then Traffic should pass with partial loss | ${perf_trial_duration}
| | ... | ${rate} | ${framesize} | ${traffic_profile}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

*** Test Cases ***
| tc01-64B-1t1c-dot1q-l2bdbasemaclrn-eth-2vhostvr1024-1vm-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-PDR for 64 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 64B | 1T1C | STHREAD
| | ...
| | [Template] | Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | framesize=${64} | rate=1.2mpps | wt=1 | rxq=1

| tc02-1518B-1t1c-dot1q-l2bdbasemaclrn-eth-2vhostvr1024-1vm-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-PDR for 1518 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 1518B | 1T1C | STHREAD
| | ...
| | [Template] | Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | framesize=${1518} | rate=350000pps | wt=1 | rxq=1

| tc03-IMIX-1t1c-dot1q-l2bdbasemaclrn-eth-2vhostvr1024-1vm-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 1 thread, 1 phy\
| | ... | core, 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-PDR for 64 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | IMIX | 1T1C | STHREAD
| | ...
| | [Template] | Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | framesize=IMIX_v4_1 | rate=0.9mpps | wt=1 | rxq=1

| tc04-64B-2t2c-dot1q-l2bdbasemaclrn-eth-2vhostvr1024-1vm-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-PDR for 64 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 64B | 2T2C | MTHREAD
| | ...
| | [Template] | Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | framesize=${64} | rate=2.2mpps | wt=2 | rxq=1

| tc05-1518B-2t2c-dot1q-l2bdbasemaclrn-eth-2vhostvr1024-1vm-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-PDR for 1518 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 1518B | 2T2C | MTHREAD
| | ...
| | [Template] | Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | framesize=${1518} | rate=0.6mpps | wt=2 | rxq=1

| tc06-IMIX-2t2c-dot1q-l2bdbasemaclrn-eth-2vhostvr1024-1vm-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 2 threads, 2 phy\
| | ... | cores, 1 receive queue per NIC port.
| | ... | [Ver] Verify ref-PDR for 64 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | IMIX | 2T2C | MTHREAD
| | ...
| | [Template] | Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | framesize=IMIX_v4_1 | rate=1.5pps | wt=2 | rxq=1

| tc07-64B-4t4c-dot1q-l2bdbasemaclrn-eth-2vhostvr1024-1vm-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Verify ref-PDR for 64 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 64B | 4T4C | MTHREAD
| | ...
| | [Template] | Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | framesize=${64} | rate=3.4mpps | wt=4 | rxq=2

| tc08-1518B-4t4c-dot1q-l2bdbasemaclrn-eth-2vhostvr1024-1vm-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Verify ref-PDR for 1518 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | 1518B | 4T4C | MTHREAD
| | ...
| | [Template] | Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | framesize=${1518} | rate=0.7mpps | wt=4 | rxq=2

| tc09-IMIX-4t4c-dot1q-l2bdbasemaclrn-eth-2vhostvr1024-1vm-pdrchk
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with 4 threads, 4 phy\
| | ... | cores, 2 receive queues per NIC port.
| | ... | [Ver] Verify ref-PDR for 64 Byte frames using single trial\
| | ... | throughput test at 2x ${rate}.
| | ...
| | [Tags] | IMIX | 4T4C | MTHREAD
| | ...
| | [Template] | Check PDR for L2 bridge domain with vhost and VM with dpdk-testpmd
| | framesize=IMIX_v4_1 | rate=2.2mpps | wt=4 | rxq=2
