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
| ...
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDRDISC
| ... | NIC_Intel-X520-DA2 | ETH | IP4FWD | SCALE | FIB_20K
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L3 | Intel-X520-DA2
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance discovery test | ${min_rate}pps
| ... | ${framesize} | ${traffic_profile}
| ...
| Documentation | *RFC2544: Pkt throughput IPv4 routing test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for IPv4 routing.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with IPv4
| ... | routing and 2x10k static IPv4 /32 route entries. DUT1 and DUT2 tested
| ... | with 2p10GE NIC X520 Niantic by Intel.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop
| ... | Rate) with zero packet loss tolerance or throughput PDR (Partial Drop
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage
| ... | of packets transmitted. NDR and PDR are discovered for different
| ... | Ethernet L2 frame sizes using either binary search or linear search
| ... | algorithms with configured starting rate and final step that determines
| ... | throughput measurement resolution. Test packets are generated by TG on
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups
| ... | (flow-group per direction, 10k flows per flow-group) with all packets
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and
| ... | static payload. MAC addresses are matching MAC addresses of the TG
| ... | node interfaces. Incrementing of IP.dst (IPv4 destination address) field
| ... | is applied to both streams.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# X520-DA2 bandwidth limit
| ${s_limit} | ${10000000000}
| ${rts_per_flow}= | ${10000}
# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip4-ip4dst${rts_per_flow}

*** Test Cases ***
| tc01-64B-1t1c-ethip4-ip4scale20k-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 64 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps.
| | [Tags] | 64B | 1T1C | STHREAD | NDRDISC
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc02-64B-1t1c-ethip4-ip4scale20k-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Find PDR for 64 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps, LT=0.5%.
| | [Tags] | 64B | 1T1C | STHREAD | PDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

| tc03-1518B-1t1c-ethip4-ip4scale20k-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 1518 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps.
| | [Tags] | 1518B | 1T1C | STHREAD | NDRDISC
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc04-1518B-1t1c-ethip4-ip4scale20k-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Find PDR for 1518 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps, LT=0.5%.
| | [Tags] | 1518B | 1T1C | STHREAD | PDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

| tc05-9000B-1t1c-ethip4-ip4scale20k-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 9000 Byte frames
| | ... | using binary search start at 10GE linerate, step 10kpps.
| | [Tags] | 9000B | 1T1C | STHREAD | NDRDISC
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc06-9000B-1t1c-ethip4-ip4scale20k-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 1 thread, 1 phy core, \
| | ... | 1 receive queue per NIC port. [Ver] Find PDR for 9000 Byte frames
| | ... | using binary search start at 10GE linerate, step 10kpps, LT=0.5%.
| | [Tags] | 9000B | 1T1C | STHREAD | PDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '1' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

| tc07-64B-2t2c-ethip4-ip4scale20k-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 64 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps.
| | [Tags] | 64B | 2T2C | MTHREAD | NDRDISC
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc08-64B-2t2c-ethip4-ip4scale20k-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Find PDR for 64 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps, LT=0.5%.
| | [Tags] | 64B | 2T2C | MTHREAD | PDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

| tc09-1518B-2t2c-ethip4-ip4scale20k-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 1518 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps.
| | [Tags] | 1518B | 2T2C | MTHREAD | NDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc10-1518B-2t2c-ethip4-ip4scale20k-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Find PDR for 1518 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps, LT=0.5%.
| | [Tags] | 1518B | 2T2C | MTHREAD | PDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

| tc11-9000B-2t2c-ethip4-ip4scale20k-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Find NDR for 9000 Byte frames
| | ... | using binary search start at 10GE linerate, step 10kpps.
| | [Tags] | 9000B | 2T2C | MTHREAD | NDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc12-9000B-2t2c-ethip4-ip4scale20k-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 2 threads, 2 phy cores, \
| | ... | 1 receive queue per NIC port. [Ver] Find PDR for 9000 Byte frames
| | ... | using binary search start at 10GE linerate, step 10kpps, LT=0.5%.
| | [Tags] | 9000B | 2T2C | MTHREAD | PDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '2' worker threads and '1' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

| tc13-64B-4t4c-ethip4-ip4scale20k-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Find NDR for 64 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps.
| | [Tags] | 64B | 4T4C | MTHREAD | NDRDISC
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc14-64B-4t4c-ethip4-ip4scale20k-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Find PDR for 64 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps, LT=0.5%.
| | [Tags] | 64B | 4T4C | MTHREAD | PDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${64}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

| tc15-1518B-4t4c-ethip4-ip4scale20k-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Find NDR for 1518 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps.
| | [Tags] | 1518B | 4T4C | MTHREAD | NDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc16-1518B-4t4c-ethip4-ip4scale20k-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Find PDR for 1518 Byte frames
| | ... | using binary search start at 10GE linerate, step 50kpps, LT=0.5%.
| | [Tags] | 1518B | 4T4C | MTHREAD | PDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${1518}
| | ${min_rate}= | Set Variable | ${50000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

| tc17-9000B-4t4c-ethip4-ip4scale20k-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Find NDR for 9000 Byte frames
| | ... | using binary search start at 10GE linerate, step 10kpps.
| | [Tags] | 9000B | 4T4C | MTHREAD | NDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find NDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| tc18-9000B-4t4c-ethip4-ip4scale20k-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config with 4 threads, 4 phy cores, \
| | ... | 2 receive queues per NIC port. [Ver] Find PDR for 9000 Byte frames
| | ... | using binary search start at 10GE linerate, step 10kpps, LT=0.5%.
| | [Tags] | 9000B | 4T4C | MTHREAD | PDRDISC | SKIP_PATCH
| | ${framesize}= | Set Variable | ${9000}
| | ${min_rate}= | Set Variable | ${10000}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '4' worker threads and '2' rxqueues in 3-node single-link circular topology
| | And Add PCI devices to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv4 forwarding with scaling in 3-node circular topology
| | ... | ${rts_per_flow}
| | Then Find PDR using binary search and pps | ${framesize} | ${binary_min}
| | ... | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}
