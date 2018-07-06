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
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | MRR
| ... | NIC_Intel-X710 | ETH | IP6FWD | SCALE | FIB_20K
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L3 | Intel-X710
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance mrr test
| ...
| Documentation | *Raw results IPv6 routing test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv6 for IPv6 routing.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with IPv6
| ... | routing and 2x10k static IPv6 /64 route entries. DUT1 and DUT2 tested
| ... | with 2p10GE NIC X710 by Intel.
| ... | *[Ver] TG verification:* In MaxReceivedRate tests TG sends traffic\
| ... | at line rate and reports total received/sent packets over trial period.\
| ... | Test packets are generated by TG on
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups
| ... | (flow-group per direction, 10k flows per flow-group) with all packets
| ... | containing Ethernet header, IPv6 header withq IP and static payload.
| ... | MAC addresses are matching MAC addresses of the TG node interfaces.
| ... | Incrementing of IP.dst (IPv6 destination address) field is applied to
| ... | both streams.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# X710-DA2 bandwidth limit
| ${s_limit}= | ${10000000000}
| ${rts_per_flow}= | ${10000}
# Traffic profile:
| ${traffic_profile}= | trex-sl-3n-ethip6-ip6dst${rts_per_flow}

*** Keywords ***
| Check RR for ip6base-ip6scale
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with ${wt} \
| | ... | thread(s), ${wt} phy core(s), ${rxq} receive queue(s) per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for ${framesize} frames using single\
| | ... | trial throughput test.
| | ...
| | [Arguments] | ${framesize} | ${wt} | ${rxq}
| | ...
| | # Test Variables required for test teardown
| | Set Test Variable | ${framesize}
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${get_framesize}
| | ...
| | Given Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Run Keyword If | ${get_framesize} < ${1522}
| | ... | Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv6 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Traffic should pass with maximum rate | ${perf_trial_duration}
| | ... | ${max_rate}pps | ${framesize} | ${traffic_profile}

*** Test Cases ***
| tc01-78B-1t1c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 78B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 78B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=1 | rxq=1 | framesize=${78}

| tc02-1518B-1t1c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 1518B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=1 | rxq=1 | framesize=${1518}

| tc03-9000B-1t1c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 9000B | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=1 | rxq=1 | framesize=${9000}

| tc04-IMIX-1t1c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single trial\
| | ... | throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX | 1T1C | STHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=1 | rxq=1 | framesize=IMIX_v4_1

| tc05-78B-2t2c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 78B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 78B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=2 | rxq=1 | framesize=${78}

| tc06-1518B-2t2c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 1518B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=2 | rxq=1 | framesize=${1518}

| tc07-9000B-2t2c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 9000B | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=2 | rxq=1 | framesize=${9000}

| tc08-IMIX-2t2c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single trial\
| | ... | throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX | 2T2C | MTHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=2 | rxq=1 | framesize=IMIX_v4_1

| tc09-78B-4t4c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 4 threads, 4 phy cores, 2 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 78B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 78B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=4 | rxq=2 | framesize=${78}

| tc10-1518B-4t4c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 4 threads, 4 phy cores, 2 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 1518B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 1518B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=4 | rxq=2 | framesize=${1518}

| tc11-9000B-4t4c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 4 threads, 4 phy cores, 2 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for 9000B frames using single trial\
| | ... | throughput test.
| | ...
| | [Tags] | 9000B | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=4 | rxq=2 | framesize=${9000}

| tc12-IMIX-4t4c-ethip6-ip6base-ip6scale20k-mrr
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config with \
| | ... | 4 threads, 4 phy cores, 2 receive queue per NIC port.
| | ... | [Ver] Measure MaxReceivedRate for IMIX_v4_1 frames using single trial\
| | ... | throughput test.
| | ... | IMIX_v4_1 = (28x64B; 16x570B; 4x1518B)
| | ...
| | [Tags] | IMIX | 4T4C | MTHREAD
| | ...
| | [Template] | Check RR for ip6base-ip6scale
| | wt=4 | rxq=2 | framesize=IMIX_v4_1
