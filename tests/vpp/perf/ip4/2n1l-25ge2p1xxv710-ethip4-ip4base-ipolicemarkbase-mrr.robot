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
| Library | resources.libraries.python.Policer
| ...
| Force Tags | 2_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | MRR
| ... | NIC_Intel-XXV710 | IP4FWD | FEATURE | POLICE_MARK
| ...
| Suite Setup | Set up 2-node performance topology with DUT's NIC model
| ... | L3 | Intel-XXV710
| Suite Teardown | Tear down 2-node performance topology
| ...
| Test Setup | Set up performance test
| ...
| Test Teardown | Tear down performance mrr test
| ...
| Test Template | Local Template
| ...
| Documentation | *Raw results IPv4 policer test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-TG 2-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for IPv4 routing.
| ... | *[Cfg] DUT configuration:* DUT1 is configured with IPv4 routing and
| ... | two IPv4 ARP entries and policer with 2R3C color-aware configuration.
| ... | Policer is applied on links TG - DUT1. DUT1 is tested with 2p25GE
| ... | NIC XXV710 by Intel.
| ... | *[Ver] TG verification:* In MaxReceivedRate tests TG sends traffic\
| ... | at line rate and reports total received/sent packets over trial period.\
| ... | Test packets are generated by TG on links to DUT1. TG traffic profile
| ... | contains two L3 flow-groups (flow-group per direction, 253 flows per
| ... | flow-group) with all packets containing Ethernet header, IPv6 header
| ... | and generated payload. MAC addresses are matching MAC addresses
| ... | of the TG node interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544, RFC2698.

*** Variables ***
# XXV710-DA2 bandwidth limit ~49Gbps/2=24.5Gbps
| ${s_24.5G} | ${24500000000}
# XXV710-DA2 Mpps limit 37.5Mpps/2=18.75Mpps
| ${s_18.75Mpps} | ${18750000}
| ${cir}= | ${100}
| ${eir}= | ${150}
# Traffic profile:
| ${traffic_profile}= | trex-sl-2n-ethip4-ip4src253

*** Keywords ***
| Local Template
| | ...
| | [Documentation]
| | ... | [Cfg] DUT runs IPv4 routing config.
| | ... | Each DUT uses ${phy_cores} physical core(s) for worker threads.
| | ... | [Ver] Measure MaxReceivedRate for ${framesize}B frames using single\
| | ... | trial throughput test.
| | ...
| | ... | *Arguments:*
| | ... | - framesize - Framesize in Bytes in integer or string (IMIX_v4_1).
| | ... | Type: integer, string
| | ... | - phy_cores - Number of physical cores. Type: integer
| | ... | - rxq - Number of RX queues, default value: ${None}. Type: integer
| | ...
| | [Arguments] | ${framesize} | ${phy_cores} | ${rxq}=${None}
| | ...
| | Set Test Variable | ${cb} | ${framesize}
| | Set Test Variable | ${eb} | ${framesize}
| | ...
| | Given Add worker threads and rxqueues to all DUTs | ${phy_cores} | ${rxq}
| | And Add PCI devices to all DUTs
| | ${max_rate} | ${jumbo} = | Get Max Rate And Jumbo And Handle Multi Seg
| | ... | ${s_24.5G} | ${framesize} | pps_limit=${s_18.75Mpps}
| | And Apply startup configuration on all VPP DUTs
| | When Initialize IPv4 forwarding in circular topology
| | And Initialize IPv4 policer 2r3c-'ca' in circular topology
| | Then Traffic should pass with maximum rate
| | ... | ${max_rate}pps | ${framesize} | ${traffic_profile}

*** Test Cases ***
| tc01-64B-1c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | 64B | 1C
| | framesize=${64} | phy_cores=${1}

| tc02-64B-2c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | 64B | 2C
| | framesize=${64} | phy_cores=${2}

| tc03-64B-4c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | 64B | 4C
| | framesize=${64} | phy_cores=${4}

| tc04-1518B-1c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | 1518B | 1C
| | framesize=${1518} | phy_cores=${1}

| tc05-1518B-2c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | 1518B | 2C
| | framesize=${1518} | phy_cores=${2}

| tc06-1518B-4c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | 1518B | 4C
| | framesize=${1518} | phy_cores=${4}

| tc07-9000B-1c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | 9000B | 1C
| | framesize=${9000} | phy_cores=${1}

| tc08-9000B-2c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | 9000B | 2C
| | framesize=${9000} | phy_cores=${2}

| tc09-9000B-4c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | 9000B | 4C
| | framesize=${9000} | phy_cores=${4}

| tc10-IMIX-1c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | IMIX | 1C
| | framesize=IMIX_v4_1 | phy_cores=${1}

| tc11-IMIX-2c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | IMIX | 2C
| | framesize=IMIX_v4_1 | phy_cores=${2}

| tc12-IMIX-4c-ethip4-ip4base-ipolicemarkbase-mrr
| | [Tags] | IMIX | 4C
| | framesize=IMIX_v4_1 | phy_cores=${4}
