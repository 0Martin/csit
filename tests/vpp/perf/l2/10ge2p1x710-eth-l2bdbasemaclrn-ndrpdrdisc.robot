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
| ... | NIC_Intel-X710 | ETH | L2BDMACLRN | BASE
| ...
| Suite Setup | Set up 3-node performance topology with DUT's NIC model
| ... | L2 | Intel-X710
| Suite Teardown | Tear down 3-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance discovery test | ${min_rate}pps
| ... | ${framesize} | ${traffic_profile}
| ...
| Documentation | *RFC2544: Pkt throughput L2BD test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology\
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 switching of IPv4.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 are configured with L2 bridge-\
| ... | domain and MAC learning enabled. DUT1 and DUT2 tested with 2p10GE NIC
| ... | X710 by Intel.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop\
| ... | Rate) with zero packet loss tolerance or throughput PDR (Partial Drop\
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage\
| ... | of packets transmitted. NDR and PDR are discovered for different\
| ... | Ethernet L2 frame sizes using either binary search or linear search\
| ... | algorithms with configured starting rate and final step that determines\
| ... | throughput measurement resolution. Test packets are generated by TG on\
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups\
| ... | (flow-group per direction, 253 flows per flow-group) with all packets\
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and static\
| ... | payload. MAC addresses are matching MAC addresses of the TG node\
| ... | interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# X710 bandwidth limit
| ${s_limit} | ${10000000000}
# Traffic profile:
| ${traffic_profile} | trex-sl-3n-ethip4-ip4src254

*** Keywords ***
| L2 Bridge Domain NDR Binary Search
| | [Arguments] | ${framesize} | ${min_rate} | ${wt} | ${rxq}
| | Set Test Variable | ${framesize}
| | Set Test Variable | ${min_rate}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | Add PCI devices to all DUTs
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | Run Keyword If | ${get_framesize} < ${1522} | Add no multi seg to all DUTs
| | Apply startup configuration on all VPP DUTs
| | Initialize L2 bridge domain in 3-node circular topology
| | Find NDR using binary search and pps
| | ... | ${framesize} | ${binary_min} | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}

| L2 Bridge Domain PDR Binary Search
| | [Arguments] | ${framesize} | ${min_rate} | ${wt} | ${rxq}
| | Set Test Variable | ${framesize}
| | Set Test Variable | ${min_rate}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | Add PCI devices to all DUTs
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | Run Keyword If | ${get_framesize} < ${1522} | Add no multi seg to all DUTs
| | Apply startup configuration on all VPP DUTs
| | Initialize L2 bridge domain in 3-node circular topology
| | Find PDR using binary search and pps
| | ... | ${framesize} | ${binary_min} | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

*** Test Cases ***
| tc01-64B-1t1c-eth-l2bdbasemaclrn-ndrdisc
| | ... | framesize=${64} | min_rate=${50000} | wt=1 | rxq=1
| | [Tags] | 64B | 1T1C | STHREAD | NDRDISC
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | [Template] | L2 Bridge Domain NDR Binary Search

| tc02-64B-1t1c-eth-l2bdbasemaclrn-pdrdisc
| | ... | framesize=${64} | min_rate=${50000} | wt=1 | rxq=1
| | [Tags] | 64B | 1T1C | STHREAD | PDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | [Template] | L2 Bridge Domain PDR Binary Search

| tc03-1518B-1t1c-eth-l2bdbasemaclrn-ndrdisc
| | ... | framesize=${1518} | min_rate=${50000} | wt=1 | rxq=1
| | [Tags] | 1518B | 1T1C | STHREAD | NDRDISC
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | [Template] | L2 Bridge Domain NDR Binary Search

| tc04-1518B-1t1c-eth-l2bdbasemaclrn-pdrdisc
| | ... | framesize=${1518} | min_rate=${50000} | wt=1 | rxq=1
| | [Tags] | 1518B | 1T1C | STHREAD | PDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | [Template] | L2 Bridge Domain PDR Binary Search

| tc05-9000B-1t1c-eth-l2bdbasemaclrn-ndrdisc
| | ... | framesize=${9000} | min_rate=${10000} | wt=1 | rxq=1
| | [Tags] | 9000B | 1T1C | STHREAD | NDRDISC
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 10kpps.
| | [Template] | L2 Bridge Domain NDR Binary Search

| tc06-9000B-1t1c-eth-l2bdbasemaclrn-pdrdisc
| | ... | framesize=${9000} | min_rate=${10000} | wt=1 | rxq=1
| | [Tags] | 9000B | 1T1C | STHREAD | PDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 1 thread, 1 phy core, 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 10kpps, LT=0.5%.
| | [Template] | L2 Bridge Domain PDR Binary Search

| tc07-64B-2t2c-eth-l2bdbasemaclrn-ndrdisc
| | ... | framesize=${64} | min_rate=${50000} | wt=2 | rxq=1
| | [Tags] | 64B | 2T2C | MTHREAD | NDRDISC
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | [Template] | L2 Bridge Domain NDR Binary Search

| tc08-64B-2t2c-eth-l2bdbasemaclrn-pdrdisc
| | ... | framesize=${64} | min_rate=${50000} | wt=2 | rxq=1
| | [Tags] | 64B | 2T2C | MTHREAD | PDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | [Template] | L2 Bridge Domain PDR Binary Search

| tc09-1518B-2t2c-eth-l2bdbasemaclrn-ndrdisc
| | ... | framesize=${1518} | min_rate=${50000} | wt=2 | rxq=1
| | [Tags] | 1518B | 2T2C | MTHREAD | NDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | [Template] | L2 Bridge Domain NDR Binary Search

| tc10-1518B-2t2c-eth-l2bdbasemaclrn-pdrdisc
| | ... | framesize=${1518} | min_rate=${50000} | wt=2 | rxq=1
| | [Tags] | 1518B | 2T2C | MTHREAD | PDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | [Template] | L2 Bridge Domain PDR Binary Search

| tc11-9000B-2t2c-eth-l2bdbasemaclrn-ndrdisc
| | ... | framesize=${9000} | min_rate=${10000} | wt=2 | rxq=1
| | [Tags] | 9000B | 2T2C | MTHREAD | NDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 10kpps.
| | [Template] | L2 Bridge Domain NDR Binary Search

| tc12-9000B-2t2c-eth-l2bdbasemaclrn-pdrdisc
| | ... | framesize=${9000} | min_rate=${10000} | wt=2 | rxq=1
| | [Tags] | 9000B | 2T2C | MTHREAD | PDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 2 threads, 2 phy cores, 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 10kpps, LT=0.5%.
| | [Template] | L2 Bridge Domain PDR Binary Search

| tc13-64B-4t4c-eth-l2bdbasemaclrn-ndrdisc
| | ... | framesize=${64} | min_rate=${50000} | wt=4 | rxq=2
| | [Tags] | 64B | 4T4C | MTHREAD | NDRDISC
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Find NDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | [Template] | L2 Bridge Domain NDR Binary Search

| tc14-64B-4t4c-eth-l2bdbasemaclrn-pdrdisc
| | ... | framesize=${64} | min_rate=${50000} | wt=4 | rxq=2
| | [Tags] | 64B | 4T4C | MTHREAD | PDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Find PDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | [Template] | L2 Bridge Domain PDR Binary Search

| tc15-1518B-4t4c-eth-l2bdbasemaclrn-ndrdisc
| | ... | framesize=${1518} | min_rate=${50000} | wt=4 | rxq=2
| | [Tags] | 1518B | 4T4C | MTHREAD | NDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Find NDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | [Template] | L2 Bridge Domain NDR Binary Search

| tc16-1518B-4t4c-eth-l2bdbasemaclrn-pdrdisc
| | ... | framesize=${1518} | min_rate=${50000} | wt=4 | rxq=2
| | [Tags] | 1518B | 4T4C | MTHREAD | PDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Find PDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | [Template] | L2 Bridge Domain PDR Binary Search

| tc17-9000B-4t4c-eth-l2bdbasemaclrn-ndrdisc
| | ... | framesize=${9000} | min_rate=${10000} | wt=4 | rxq=2
| | [Tags] | 9000B | 4T4C | MTHREAD | NDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Find NDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 10kpps.
| | [Template] | L2 Bridge Domain NDR Binary Search

| tc18-9000B-4t4c-eth-l2bdbasemaclrn-pdrdisc
| | ... | framesize=${9000} | min_rate=${10000} | wt=4 | rxq=2
| | [Tags] | 9000B | 4T4C | MTHREAD | PDRDISC | SKIP_PATCH
| | [Documentation]
| | ... | [Cfg] DUT runs L2BD switching config with with\
| | ... | 4 threads, 4 phy cores, 2 receive queues per NIC port.
| | ... | [Ver] Find PDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 10kpps, LT=0.5%.
| | [Template] | L2 Bridge Domain PDR Binary Search
