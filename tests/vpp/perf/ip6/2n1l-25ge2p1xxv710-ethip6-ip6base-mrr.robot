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
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | MRR
| ... | NIC_Intel-XXV710 | ETH | IP6FWD | BASE | IP6BASE
| ...
| Suite Setup | Set up 2-node performance topology with DUT's NIC model
| ... | L3 | Intel-XXV710
| Suite Teardown | Tear down 2-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance mrr test
| ...
| Test Template | Local template
| ...
| Documentation | *Raw results IPv6 routing test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-TG 2-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv6 for IPv6 routing.
| ... | *[Cfg] DUT configuration:* DUT1 is configured with IPv6 routing and two
| ... | static IPv6 /64 route entries. DUT1 tested with 2p25GE NIC X710 by
| ... | Intel.
| ... | *[Ver] TG verification:* In MaxReceivedRate test TG sends traffic
| ... | at line rate and reports total received/sent packets over trial period.
| ... | Test packets are generated by TG on links to DUTs. TG traffic profile
| ... | contains two L3 flow-groups (flow-group per direction, 253 flows per
| ... | flow-group) with all packets containing Ethernet header, IPv6 header and
| ... | static payload. MAC addresses are matching MAC addresses of the TG node
| ... | interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# XXV710-DA2 bandwidth limit ~50Gbps/2=25Gbps
| ${s_25G} | ${25000000000}
# XXV710-DA2 Mpps limit 37.5Mpps/2=18.75Mpps
| ${s_18.75Mpps} | ${18750000}
# Traffic profile:
| ${traffic_profile}= | trex-sl-2n-ethip6-ip6src253

*** Keywords ***
| Local template
| | [Documentation]
| | ... | [Cfg] DUT runs IPv6 routing config.\
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Measure MaxReceivedRate for ${framesize} frames using single\
| | ... | trial throughput test.
| | ...
| | ... | *Arguments:*
| | ... | - framesize - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... |   Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| | ...
| | [Arguments] | ${framesize} | ${phy_cores} | ${rxq}=${None}
| | ...
| | Set Test Variable | ${framesize}
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | ${max_rate}= | Calculate pps | ${s_25G} | ${get_framesize}
| | ${max_rate}= | Set Variable If
| | ... | ${max_rate} > ${s_18.75Mpps} | ${s_18.75Mpps} | ${max_rate}
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add PCI devices to all DUTs
| | And Run Keyword If | ${get_framesize} < ${1522}
| | ... | Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize IPv6 forwarding in 2-node circular topology
| | Then Traffic should pass with maximum rate
| | ... | ${max_rate}pps | ${framesize} | ${traffic_profile}

*** Test Cases ***
| tc01-78B-1t1c-ethip6-ip6base-mrr
| | [Tags] | 78B | 1C
| | framesize=${78} | phy_cores=${1}

| tc02-1518B-1t1c-ethip6-ip6base-mrr
| | [Tags] | 1518B | 1C
| | framesize=${1518} | phy_cores=${1}

| tc03-9000B-1t1c-ethip6-ip6base-mrr
| | [Tags] | 9000B | 1C
| | framesize=${9000} | phy_cores=${1}

| tc04-IMIX-1t1c-ethip6-ip6base-mrr
| | [Tags] | IMIX | 1C
| | framesize=IMIX_v4_1 | phy_cores=${1}

| tc05-78B-2t2c-ethip6-ip6base-mrr
| | [Tags] | 78B | 2C
| | framesize=${78} | phy_cores=${2}

| tc06-1518B-2t2c-ethip6-ip6base-mrr
| | [Tags] | 1518B | 2C
| | framesize=${1518} | phy_cores=${2}

| tc07-9000B-2t2c-ethip6-ip6base-mrr
| | [Tags] | 9000B | 2C
| | framesize=${9000} | phy_cores=${2}

| tc08-IMIX-2t2c-ethip6-ip6base-mrr
| | [Tags] | IMIX | 2C
| | framesize=IMIX_v4_1 | phy_cores=${2}

| tc09-78B-4t4c-ethip6-ip6base-mrr
| | [Tags] | 78B | 4C
| | framesize=${78} | phy_cores=${4}

| tc10-1518B-4t4c-ethip6-ip6base-mrr
| | [Tags] | 1518B | 4C
| | framesize=${1518} | phy_cores=${4}

| tc11-9000B-4t4c-ethip6-ip6base-mrr
| | [Tags] | 9000B | 4C
| | framesize=${9000} | phy_cores=${4}

| tc12-IMIX-4t4c-ethip6-ip6base-mrr
| | [Tags] | IMIX | 4C
| | framesize=IMIX_v4_1 | phy_cores=${4}
