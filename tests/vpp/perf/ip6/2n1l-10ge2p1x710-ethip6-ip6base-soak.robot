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
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | SOAK
| ... | NIC_Intel-X710 | ETH | IP6FWD | BASE | IP6BASE
| ...
| Suite Setup | Set up 2-node performance topology with DUT's NIC model
| ... | L3 | Intel-X710
| Suite Teardown | Tear down 2-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance mrr test
| ...
| Test Template | Local Template
| ...
| Documentation | *Raw results IPv6 routing test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-TG 2-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv6 for IPv6 routing.
| ... | *[Cfg] DUT configuration:* DUT1 is configured with IPv6 routing and two
| ... | static IPv6 /64 route entries. DUT1 tested with 2p10GE NIC X710 by
| ... | Intel.
| ... | *[Ver] TG verification:* Perform PLRsearch to find critical load.

*** Variables ***
# X710-DA2 bandwidth limit
| ${s_limit}= | ${10000000000}
# Traffic profile:
| ${traffic_profile}= | trex-sl-2n-ethip6-ip6src253

*** Keywords ***
| Local Template
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config.\
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Perform PLRsearch to find critical load.
| | ...
| | ... | *Arguments:*
| | ... | - framesize - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... |   Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| | ...
| | [Arguments] | ${framesize} | ${phy_cores} | ${rxq}=${None}
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add PCI devices to all DUTs
| | ${max_rate} | ${jumbo} = | Get Max Rate And Jumbo And Handle Multi Seg
| | ... | ${s_limit} | ${framesize}
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding in 2-node circular topology
| | Then Find critical load using PLRsearch
| | ... | ${framesize} | ${traffic_profile} | ${10000} | ${max_rate}

*** Test Cases ***
| tc01-78B-1c-ethip6-ip6base-soak
| | [Tags] | 78B | 1C
| | framesize=${78} | phy_cores=${1}
