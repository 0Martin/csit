Release Notes
=============

Changes in |csit-release|
-------------------------

#. VPP PERFORMANCE TESTS

   - CSIT test environment is now versioned, with ver. 1 associated
     with CSIT rls1908 git branch as of 2019-08-21, and ver. 2
     associated with CSIT rls2001 and master git branches as of
     2020-03-27.

   - To identify performance changes due to VPP code changes from
     v20.01.0 to v20.05.0, both have been tested in CSIT environment
     ver. 2 and compared against each other. All substantial
     progressions has been marked up with RCA analysis. See
     :ref:`vpp_compare_current_vs_previous_release` and
     :ref:`vpp_known_issues`.

#. TEST FRAMEWORK

   - **CSIT PAPI support**: Due to issues with PAPI performance, VAT is
     still used in CSIT for all VPP scale tests. See known issues below.

   - **General Code Housekeeping**: Ongoing RF keywords optimizations,
     removal of redundant RF keywords and aligning of suite/test
     setup/teardowns.

#. PRESENTATION AND ANALYTICS LAYER

   - **Graphs layout improvements**: Improved performance graphs layout
     for better readibility and maintenance: test grouping, axis
     labels, descriptions, other informative decoration.

.. raw:: latex

    \clearpage

.. _vpp_known_issues:

Known Issues
------------

List of known issues in |csit-release| for VPP performance tests:

+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| #  | JiraID                                  | Issue Description                                                                                         |
+====+=========================================+===========================================================================================================+
| 1  | `CSIT-570                               | Sporadic (1 in 200) NDR discovery test failures on x520. DPDK reporting rx-errors, indicating L1 issue.   |
|    | <https://jira.fd.io/browse/CSIT-570>`_  | Suspected issue with HW combination of X710-X520 in LF testbeds. Not observed outside of LF testbeds.     |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 2  | `VPP-662                                | 9000B packets not supported by NICs VIC1227 and VIC1387.                                                  |
|    | <https://jira.fd.io/browse/VPP-662>`_   |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 3  | `CSIT-1498                              | Memif tests are sporadically failing on initialization of memif connection.                               |
|    | <https://jira.fd.io/browse/CSIT-1498>`_ |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 4  | `VPP-1677                               | 9000B ip4 nat44: VPP crash + coredump.                                                                    |
|    | <https://jira.fd.io/browse/VPP-1677>`_  | VPP crashes very often in case that NAT44 is configured and it has to process IP4 jumbo frames (9000B).   |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 5  | `CSIT-1591                              | All CSIT scale tests can not use PAPI due to much slower performance compared to VAT/CLI (it takes much   |
|    | <https://jira.fd.io/browse/CSIT-1499>`_ | longer to program VPP). This needs to be addressed on the PAPI side.                                      |
|    +-----------------------------------------+                                                                                                           |
|    | `VPP-1763                               |                                                                                                           |
|    | <https://jira.fd.io/browse/VPP-1763>`_  |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 6  | `VPP-1675                               | IPv4 IPSEC 9000B packet tests are failing as no packet is forwarded.                                      |
|    | <https://jira.fd.io/browse/VPP-1675>`_  | Reason: chained buffers are not supported.                                                                |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 7  | `CSIT-1593                              | IPv4 AVF 9000B packet tests are failing on 3n-skx while passing on 2n-skx.                                |
|    | <https://jira.fd.io/browse/CSIT-1593>`_ |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 8  | `CSIT-1675                              | Intel Xeon 2n-skx, 3n-skx and 2n-clx testbeds behaviour and performance became inconsistent following     |
|    | <https://jira.fd.io/browse/CSIT-1675>`_ | the upgrade to the latest Ubuntu 18.04 LTS kernel version (4.15.0-72-generic) and associated microcode    |
|    |                                         | packages (skx ucode 0x2000064, clx ucode 0x500002c). VPP as well as DPDK L3fwd tests are affected.        |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 9  | `CSIT-1679                              | All 2n-clx VPP ip4 tests with xxv710 and avf driver are failing.                                          |
|    | <https://jira.fd.io/browse/CSIT-1679>`_ |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 10 | `CSIT-1680                              | Some 2n-clx cx556a rdma tests are failing.                                                                |
|    | <https://jira.fd.io/browse/CSIT-1680>`_ |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 11 | `CSIT-1699                              | Root Cause Analysis for CSIT-2001. Investigate high stdev of tests with VPP inside VM.                    |
|    | <https://jira.fd.io/browse/CSIT-1699>`_ |                                                                                                           |
|    +-----------------------------------------+                                                                                                           |
|    | `CSIT-1704                              |                                                                                                           |
|    | <https://jira.fd.io/browse/CSIT-1704>`_ |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 12 | `CSIT-1699                              | Root Cause Analysis for CSIT-2001. Identify cause of dot1q-l2xcbase progression.                          |
|    | <https://jira.fd.io/browse/CSIT-1699>`_ |                                                                                                           |
|    +-----------------------------------------+                                                                                                           |
|    | `CSIT-1705                              |                                                                                                           |
|    | <https://jira.fd.io/browse/CSIT-1705>`_ |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 13 | `CSIT-1699                              | Root Cause Analysis for CSIT-2001. Identify cause of avf-ip4scale regression.                             |
|    | <https://jira.fd.io/browse/CSIT-1699>`_ |                                                                                                           |
|    +-----------------------------------------+                                                                                                           |
|    | `CSIT-1706                              |                                                                                                           |
|    | <https://jira.fd.io/browse/CSIT-1706>`_ |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 14 | `CSIT-1699                              | Root Cause Analysis for CSIT-2001. Identify cause of progression in vhost-user tests with testpmd in VM.  |
|    | <https://jira.fd.io/browse/CSIT-1699>`_ |                                                                                                           |
|    +-----------------------------------------+                                                                                                           |
|    | `CSIT-1707                              |                                                                                                           |
|    | <https://jira.fd.io/browse/CSIT-1707>`_ |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
| 15 | `CSIT-1699                              | Root Cause Analysis for CSIT-2001. Identify cause for avf-ip4base regression.                             |
|    | <https://jira.fd.io/browse/CSIT-1699>`_ |                                                                                                           |
|    +-----------------------------------------+                                                                                                           |
|    | `CSIT-1708                              |                                                                                                           |
|    | <https://jira.fd.io/browse/CSIT-1708>`_ |                                                                                                           |
+----+-----------------------------------------+-----------------------------------------------------------------------------------------------------------+
