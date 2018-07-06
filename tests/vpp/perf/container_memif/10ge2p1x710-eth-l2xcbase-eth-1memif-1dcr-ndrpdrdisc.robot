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
| Force Tags | 3_NODE_SINGLE_LINK_TOPO | PERFTEST | HW_ENV | NDRPDRDISC
| ... | NIC_Intel-X710 | ETH | L2XCFWD | BASE | MEMIF | SINGLE_MEMIF | DOCKER
| ...
| Suite Setup | Run Keywords
| ... | Set up 3-node performance topology with DUT's NIC model | L2
| ... | Intel-X710
| ... | AND | Set up performance test suite with MEMIF
| ... | AND | Set up performance topology with containers
| ...
| Suite Teardown | Tear down 3-node performance topology with container
| ...
| Test Setup | Run Keywords
| ... | Set up performance test
| ... | AND | Restart VPP in all 'VNF' containers
| ...
| Test Teardown | Tear down performance discovery test | ${min_rate}pps
| ... | ${framesize} | ${traffic_profile}
| ...
| Test Template | Find NDRPDR for l2xcbase-eth-1memif-1dcr
| ...
| Documentation |  *Raw results L2XC test cases*
| ...
| ... | *[Top] Network Topologies:* TG-DUT1-DUT2-TG 3-node circular topology
| ... | with single links between nodes.
| ... | *[Enc] Packet Encapsulations:* Eth-IPv4 for L2 cross connect.
| ... | *[Cfg] DUT configuration:* DUT1 and DUT2 configured with L2 cross-
| ... | connect. DUT1 and DUT2 tested with 2p10GE NIC X710 by Intel.
| ... | Container is connected to VPP via Memif interface running same VPP
| ... | version as running on DUT. Resources are limited via cgroup to use 5
| ... | cores allocated from pool of isolated CPUs. There are no memory
| ... | contraints. Cross Horizontal topology with packets flowing via DUT (VPP)
| ... | to Container, then via horizontal memif to the next Container, and so on
| ... | until the last Container then to NIC (in last Container). Single
| ... | Container is supported as of now.
| ... | *[Ver] TG verification:* TG finds and reports throughput NDR (Non Drop
| ... | Rate) with zero packet loss tolerance or throughput PDR (Partial Drop
| ... | Rate) with non-zero packet loss tolerance (LT) expressed in percentage
| ... | of packets transmitted. NDR and PDR are discovered for different
| ... | Ethernet L2 frame sizes using either binary search or linear search
| ... | algorithms with configured starting rate and final step that determines
| ... | throughput measurement resolution. Test packets are generated by TG on
| ... | links to DUTs. TG traffic profile contains two L3 flow-groups
| ... | (flow-group per direction, 254 flows per flow-group) with all packets
| ... | containing Ethernet header, IPv4 header with IP protocol=61 and static
| ... | payload. MAC addresses are matching MAC addresses of the TG node
| ... | interfaces.
| ... | *[Ref] Applicable standard specifications:* RFC2544.

*** Variables ***
# X710-DA2 bandwidth limit
| ${s_limit} | ${10000000000}
# Traffic profile
| ${traffic_profile} | trex-sl-3n-ethip4-ip4src254
# Container settings
| ${container_count}= | ${1}
| ${container_engine}= | Docker
| ${container_image}= | ubuntu:xenial-20180412
| ${container_install_dkms}= | ${TRUE}
| ${container_chain_topology}= | cross_horiz
# CPU settings
| ${system_cpus}= | ${1}
| ${vpp_cpus}= | ${5}
| ${container_cpus}= | ${5}

*** Keywords ***
| Find NDRPDR for l2xcbase-eth-1memif-1dcr
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with ${wt} thread(s), ${wt}\
| | ... | phy core(s), ${rxq} receive queue(s) per NIC port.
| | ... | [Ver] Find ${search_type} for ${framesize} frames using binary search\
| | ... | start at 10GE linerate, step 50kpps.
| | ...
| | [Arguments] | ${framesize} | ${wt} | ${rxq} | ${search_type}
| | ... | ${min_rate}=${50000}
| | Set Test Variable | ${framesize}
| | Set Test Variable | ${min_rate}
| | ${get_framesize}= | Get Frame Size | ${framesize}
| | ${max_rate}= | Calculate pps | ${s_limit} | ${get_framesize}
| | ${binary_min}= | Set Variable | ${min_rate}
| | ${binary_max}= | Set Variable | ${max_rate}
| | ${threshold}= | Set Variable | ${min_rate}
| | Given Add '${wt}' worker threads and '${rxq}' rxqueues in 3-node single-link circular topology
| | And Add single PCI device to all DUTs
| | And Run Keyword If | ${get_framesize} < ${1522}
| | ... | Add no multi seg to all DUTs
| | And Apply startup configuration on all VPP DUTs
| | And Initialize L2 xconnect for single memif in 3-node circular topology
| | ... | ${rxq}
| | Then Run Keyword If | '${search_type}' == 'NDR'
| | ... | Find NDR using binary search and pps
| | ... | ${framesize} | ${binary_min} | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ELSE IF | '${search_type}' == 'PDR'
| | ... | Find PDR using binary search and pps
| | ... | ${framesize} | ${binary_min} | ${binary_max} | ${traffic_profile}
| | ... | ${min_rate} | ${max_rate} | ${threshold}
| | ... | ${perf_pdr_loss_acceptance} | ${perf_pdr_loss_acceptance_type}

*** Test Cases ***
| tc01-64B-1t1c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ...
| | [Tags] | 64B | 1T1C | STHREAD | NDRDISC
| | framesize=${64} | wt=1 | rxq=1 | search_type=NDR

| tc02-64B-1t1c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ...
| | [Tags] | 64B | 1T1C | STHREAD | PDRDISC
| | framesize=${64} | wt=1 | rxq=1 | search_type=PDR

| tc03-1518B-1t1c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ...
| | [Tags] | 1518B | 1T1C | STHREAD | NDRDISC
| | framesize=${1518} | wt=1 | rxq=1 | search_type=NDR

| tc04-1518B-1t1c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ...
| | [Tags] | 1518B | 1T1C | STHREAD | PDRDISC
| | framesize=${1518} | wt=1 | rxq=1 | search_type=PDR

| tc05-9000B-1t1c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ...
| | [Tags] | 9000B | 1T1C | STHREAD | NDRDISC
| | framesize=${9000} | wt=1 | rxq=1 | search_type=NDR

| tc06-9000B-1t1c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ...
| | [Tags] | 9000B | 1T1C | STHREAD | PDRDISC
| | framesize=${9000} | wt=1 | rxq=1 | search_type=PDR

| tc07-IMIX-1t1c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for IMIX_v4_1 frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ... | IMIX_v4_1 = (28x64B;16x570B;4x1518B)
| | ...
| | [Tags] | IMIX | 1T1C | STHREAD | NDRDISC
| | framesize=IMIX_v4_1 | wt=1 | rxq=1 | search_type=NDR

| tc08-IMIX-1t1c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 1 thread, 1 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for IMIX_v4_1 frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ... | IMIX_v4_1 = (28x64B;16x570B;4x1518B)
| | ...
| | [Tags] | IMIX | 1T1C | STHREAD | PDRDISC
| | framesize=IMIX_v4_1 | wt=1 | rxq=1 | search_type=PDR

| tc09-64B-2t2c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 2 thread, 2 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ...
| | [Tags] | 64B | 2T2C | MTHREAD | NDRDISC
| | framesize=${64} | wt=2 | rxq=1 | search_type=NDR

| tc10-64B-2t2c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 2 thread, 2 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ...
| | [Tags] | 64B | 1T1C | MTHREAD | PDRDISC
| | framesize=${64} | wt=2 | rxq=1 | search_type=PDR

| tc11-1518B-2t2c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 2 thread, 2 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ...
| | [Tags] | 1518B | 2T2C | MTHREAD | NDRDISC
| | framesize=${1518} | wt=2 | rxq=1 | search_type=NDR

| tc12-1518B-2t2c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 2 thread, 2 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ...
| | [Tags] | 1518B | 2T2C | MTHREAD | PDRDISC
| | framesize=${1518} | wt=2 | rxq=1 | search_type=PDR

| tc13-9000B-2t2c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 2 thread, 2 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ...
| | [Tags] | 9000B | 2T2C | MTHREAD | NDRDISC
| | framesize=${9000} | wt=2 | rxq=1 | search_type=NDR

| tc14-9000B-2t2c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 2 thread, 2 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ...
| | [Tags] | 9000B | 2T2C | MTHREAD | PDRDISC
| | framesize=${9000} | wt=2 | rxq=1 | search_type=PDR

| tc15-IMIX-2t2c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 2 thread, 2 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find NDR for IMIX_v4_1 frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ... | IMIX_v4_1 = (28x64B;16x570B;4x1518B)
| | ...
| | [Tags] | IMIX | 2T2C | MTHREAD | NDRDISC
| | framesize=IMIX_v4_1 | wt=2 | rxq=1 | search_type=NDR

| tc16-IMIX-2t2c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 2 thread, 2 phy core,\
| | ... | 1 receive queue per NIC port.
| | ... | [Ver] Find PDR for IMIX_v4_1 frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ... | IMIX_v4_1 = (28x64B;16x570B;4x1518B)
| | ...
| | [Tags] | IMIX | 2T2C | MTHREAD | PDRDISC
| | framesize=IMIX_v4_1 | wt=2 | rxq=1 | search_type=PDR

| tc17-64B-4t4c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 4 thread, 4 phy core,\
| | ... | 2 receive queue per NIC port.
| | ... | [Ver] Find NDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ...
| | [Tags] | 64B | 4T4C | MTHREAD | NDRDISC
| | framesize=${64} |  wt=4 | rxq=2 | search_type=NDR

| tc18-64B-4t4c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 4 thread, 4 phy core,\
| | ... | 2 receive queue per NIC port.
| | ... | [Ver] Find PDR for 64 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ...
| | [Tags] | 64B | 4T4C | MTHREAD | PDRDISC
| | framesize=${64} |  wt=4 | rxq=2 | search_type=PDR

| tc19-1518B-4t4c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 4 thread, 4 phy core,\
| | ... | 2 receive queue per NIC port.
| | ... | [Ver] Find NDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ...
| | [Tags] | 1518B | 4T4C | MTHREAD | NDRDISC
| | framesize=${1518} |  wt=4 | rxq=2 | search_type=NDR

| tc20-1518B-4t4c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 4 thread, 4 phy core,\
| | ... | 2 receive queue per NIC port.
| | ... | [Ver] Find PDR for 1518 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ...
| | [Tags] | 1518B | 4T4C | MTHREAD | PDRDISC
| | framesize=${1518} |  wt=4 | rxq=2 | search_type=PDR

| tc21-9000B-4t4c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 4 thread, 4 phy core,\
| | ... | 2 receive queue per NIC port.
| | ... | [Ver] Find NDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ...
| | [Tags] | 9000B | 4T4C | MTHREAD | NDRDISC
| | framesize=${9000} |  wt=4 | rxq=2 | search_type=NDR

| tc22-9000B-4t4c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 4 thread, 4 phy core,\
| | ... | 2 receive queue per NIC port.
| | ... | [Ver] Find PDR for 9000 Byte frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ...
| | [Tags] | 9000B | 4T4C | MTHREAD | PDRDISC
| | framesize=${9000} |  wt=4 | rxq=2 | search_type=PDR

| tc23-IMIX-4t4c-eth-l2xcbase-eth-1memif-1dcr-ndrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 4 thread, 4 phy core,\
| | ... | 2 receive queue per NIC port.
| | ... | [Ver] Find NDR for IMIX_v4_1 frames using binary search start at 10GE\
| | ... | linerate, step 50kpps.
| | ... | IMIX_v4_1 = (28x64B;16x570B;4x1518B)
| | ...
| | [Tags] | IMIX | 4T4C | MTHREAD | NDRDISC
| | framesize=IMIX_v4_1 |  wt=4 | rxq=2 | search_type=NDR

| tc24-IMIX-4t4c-eth-l2xcbase-eth-1memif-1dcr-pdrdisc
| | [Documentation]
| | ... | [Cfg] DUT runs L2XC switching config with 4 thread, 4 phy core,\
| | ... | 2 receive queue per NIC port.
| | ... | [Ver] Find PDR for IMIX_v4_1 frames using binary search start at 10GE\
| | ... | linerate, step 50kpps, LT=0.5%.
| | ... | IMIX_v4_1 = (28x64B;16x570B;4x1518B)
| | ...
| | [Tags] | IMIX | 4T4C | MTHREAD | PDRDISC
| | framesize=IMIX_v4_1 | wt=4 | rxq=2 | search_type=PDR
