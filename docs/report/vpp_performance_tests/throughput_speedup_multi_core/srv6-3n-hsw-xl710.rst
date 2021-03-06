
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
    ### 78b-srv6-ip6routing-base-dpdk
    10ge2p1xl710-ethip6ip6-ip6base-srv6enc1sid-ndrpdr
    10ge2p1xl710-ethip6srhip6-ip6base-srv6enc2sids-ndrpdr
    10ge2p1xl710-ethip6srhip6-ip6base-srv6enc2sids-nodecaps-ndrpdr
    10ge2p1xl710-ethip6srhip6-ip6base-srv6proxy-dyn-ndrpdr
    10ge2p1xl710-ethip6srhip6-ip6base-srv6proxy-masq-ndrpdr
    10ge2p1xl710-ethip6srhip6-ip6base-srv6proxy-stat-ndrpdr

3n-hsw-xl710
~~~~~~~~~~~~

78b-srv6-ip6routing-base-dpdk
-----------------------------

.. raw:: html

    <center>
    <iframe id="01" onload="setIframeHeight(this.id)" width="700" frameborder="0" scrolling="no" src="../../_static/vpp/3n-hsw-xl710-78b-srv6-ip6routing-base-dpdk-ndr-tsa.html"></iframe>
    <p><br></p>
    </center>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 0cm 5cm 0cm, width=0.70\textwidth]{3n-hsw-xl710-78b-srv6-ip6routing-base-dpdk-ndr-tsa}
            \label{fig:3n-hsw-xl710-78b-srv6-ip6routing-base-dpdk-ndr-tsa}
    \end{figure}

.. raw:: latex

    \clearpage

.. raw:: html

    <center>
    <iframe id="02" onload="setIframeHeight(this.id)" width="700" frameborder="0" scrolling="no" src="../../_static/vpp/3n-hsw-xl710-78b-srv6-ip6routing-base-dpdk-pdr-tsa.html"></iframe>
    <p><br></p>
    </center>

.. raw:: latex

    \begin{figure}[H]
        \centering
            \graphicspath{{../_build/_static/vpp/}}
            \includegraphics[clip, trim=0cm 0cm 5cm 0cm, width=0.70\textwidth]{3n-hsw-xl710-78b-srv6-ip6routing-base-dpdk-pdr-tsa}
            \label{fig:3n-hsw-xl710-78b-srv6-ip6routing-base-dpdk-pdr-tsa}
    \end{figure}
