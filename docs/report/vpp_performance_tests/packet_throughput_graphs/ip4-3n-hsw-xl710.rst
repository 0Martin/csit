
.. raw:: latex

    \clearpage

.. raw:: html

    <script type="text/javascript">

        function getDocHeight(doc) {
            doc = doc || document;
            var body = doc.body, html = doc.documentElement;
            var height = Math.max( body.scrollHeight, body.offsetHeight,
                html.clientHeight, html.scrollHeight, html.offsetHeight );
            return height;
        }

        function setIframeHeight(id) {
            var ifrm = document.getElementById(id);
            var doc = ifrm.contentDocument? ifrm.contentDocument:
                ifrm.contentWindow.document;
            ifrm.style.visibility = 'hidden';
            ifrm.style.height = "10px"; // reset to minimal height ...
            // IE opt. for bing/msn needs a bit added or scrollbar appears
            ifrm.style.height = getDocHeight( doc ) + 4 + "px";
            ifrm.style.visibility = 'visible';
        }

    </script>

..
    ## 3n-hsw-xl710
    ### 64b-?t?c-ip4routing-base-scale-dpdk
    10ge2p1xl710-dot1q-ip4base-ndrpdr
    10ge2p1xl710-ethip4-ip4base-ndrpdr
    10ge2p1xl710-ethip4-ip4scale2m-ndrpdr

    Tests.Vpp.Perf.Ip4.40Ge2P1Xl710-Dot1Q-Ip4Base-Ndrpdr.64B-1t1c-dot1q-ip4base-ndrpdr
    Tests.Vpp.Perf.Ip4.40Ge2P1Xl710-Ethip4-Ip4Base-Ndrpdr.64B-1t1c-ethip4-ip4base-ndrpdr
    Tests.Vpp.Perf.Ip4.40Ge2P1Xl710-Ethip4-Ip4Scale2M-Ndrpdr.64B-1t1c-ethip4-ip4scale2m-ndrpdr

3n-hsw-xl710
~~~~~~~~~~~~

64b-1t1c-ip4routing-base-scale-dpdk
-----------------------------------

.. raw:: html

    <center>
    <iframe id="01" onload="setIframeHeight(this.id)" width="700" frameborder="0" scrolling="no" src="../../_static/vpp/3n-hsw-xl710-64b-1t1c-ip4routing-base-scale-dpdk-ndr.html"></iframe>
    <p><br></p>
    </center>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 0cm 5cm 0cm, width=0.70\textwidth]{3n-hsw-xl710-64b-1t1c-ip4routing-base-scale-dpdk-ndr}
            \label{fig:3n-hsw-xl710-64b-1t1c-ip4routing-base-scale-dpdk-ndr}
    \end{figure}

.. raw:: latex

    \clearpage

.. raw:: html

    <center>
    <iframe id="02" onload="setIframeHeight(this.id)" width="700" frameborder="0" scrolling="no" src="../../_static/vpp/3n-hsw-xl710-64b-1t1c-ip4routing-base-scale-dpdk-pdr.html"></iframe>
    <p><br></p>
    </center>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 0cm 5cm 0cm, width=0.70\textwidth]{3n-hsw-xl710-64b-1t1c-ip4routing-base-scale-dpdk-pdr}
            \label{fig:3n-hsw-xl710-64b-1t1c-ip4routing-base-scale-dpdk-pdr}
    \end{figure}
