# -*- coding: utf-8 -*-
#
# CSIT report documentation build configuration file
#
# This file is execfile()d with the current directory set to its
# containing dir.
#
# Note that not all possible configuration values are present in this
# autogenerated file.
#
# All configuration values have a default; values that are commented out
# serve to show the default.

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.


import os
import sys

sys.path.insert(0, os.path.abspath('.'))

# -- General configuration ------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
#
# needs_sphinx = '1.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = ['sphinxcontrib.programoutput',
              'sphinx.ext.ifconfig']

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix(es) of source file names.
# You can specify multiple suffix as a list of string:
#
source_suffix = ['.rst', '.md']

# The master toctree document.
master_doc = 'index'

# General information about the project.
project = u'FD.io CSIT-1810.49'
copyright = u'2018, FD.io'
author = u'FD.io CSIT'

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short X.Y version.
# version = u''
# The full version, including alpha/beta/rc tags.
# release = u''

rst_epilog = """
.. |release-1| replace:: {prev_release}
.. |srelease| replace:: {srelease}
.. |csit-release| replace:: CSIT-{csitrelease}
.. |csit-release-1| replace:: CSIT-{csit_prev_release}
.. |vpp-release| replace:: VPP-{vpprelease} release
.. |vpp-release-1| replace:: VPP-{vpp_prev_release} release
.. |dpdk-release| replace:: DPDK {dpdkrelease}
.. |trex-release| replace:: TRex {trex_version}
.. |virl-image-ubuntu| replace:: {csit_ubuntu_ver}
.. |virl-image-centos| replace:: {csit_centos_ver}

.. _pdf version of this report: https://docs.fd.io/csit/{release}/report/_static/archive/csit_{release}.{report_week}.pdf
.. _tag documentation rst file: https://git.fd.io/csit/tree/docs/tag_documentation.rst?h={release}
.. _TRex intallation: https://git.fd.io/csit/tree/resources/tools/trex/trex_installer.sh?h={release}
.. _TRex driver: https://git.fd.io/csit/tree/resources/tools/trex/trex_stateless_profile.py?h={release}
.. _VIRL topologies directory: https://git.fd.io/csit/tree/resources/tools/virl/topologies/?h={release}
.. _VIRL ubuntu images lists: https://git.fd.io/csit/tree/resources/tools/disk-image-builder/ubuntu/lists/?h={release}
.. _VIRL centos images lists: https://git.fd.io/csit/tree/resources/tools/disk-image-builder/centos/lists/?h={release}
.. _VIRL nested: https://git.fd.io/csit/tree/resources/tools/disk-image-builder/nested/?h={release}
.. _CSIT Honeycomb Functional Tests Documentation: https://docs.fd.io/csit/{release}/doc/tests.vpp.func.honeycomb.html
.. _CSIT Honeycomb Performance Tests Documentation: https://docs.fd.io/csit/{release}/doc/tests.vpp.perf.honeycomb.html
.. _CSIT DPDK Performance Tests Documentation: https://docs.fd.io/csit/{release}/doc/tests.dpdk.perf.html
.. _CSIT VPP Functional Tests Documentation: https://docs.fd.io/csit/{release}/doc/tests.vpp.func.html
.. _CSIT VPP Performance Tests Documentation: https://docs.fd.io/csit/{release}/doc/tests.vpp.perf.html
.. _CSIT NSH_SFC Functional Tests Documentation: https://docs.fd.io/csit/{release}/doc/tests.nsh_sfc.func.html
.. _CSIT DMM Functional Tests Documentation: https://docs.fd.io/csit/{release}/doc/tests.dmm.func.html
.. _CSIT VPP Device Tests Documentation: https://docs.fd.io/csit/{release}/doc/tests.vpp.device.html
.. _VPP test framework documentation: https://docs.fd.io/vpp/{vpprelease}/vpp_make_test/html/
.. _FD.io test executor dpdk performance job 3n-hsw: https://jenkins.fd.io/view/csit/job/csit-dpdk-perf-verify-{srelease}-3n-hsw
.. _FD.io test executor dpdk performance job 3n-skx: https://jenkins.fd.io/view/csit/job/csit-dpdk-perf-verify-{srelease}-3n-skx
.. _FD.io test executor dpdk performance job 2n-skx: https://jenkins.fd.io/view/csit/job/csit-dpdk-perf-verify-{srelease}-2n-skx
.. _FD.io test executor vpp performance job 3n-hsw: https://jenkins.fd.io/view/csit/job/csit-vpp-perf-verify-1807-3n-hsw
.. _FD.io test executor vpp performance job 3n-skx: https://jenkins.fd.io/view/csit/job/csit-vpp-perf-verify-1807-3n-skx
.. _FD.io test executor vpp performance job 2n-skx: https://jenkins.fd.io/view/csit/job/csit-vpp-perf-verify-1807-2n-skx
.. _FD.io test executor ligato performance jobs: https://jenkins.fd.io/job/csit-ligato-perf-{srelease}-all
.. _FD.io test executor vpp functional jobs using Ubuntu: https://jenkins.fd.io/view/csit/job/csit-vpp-functional-{srelease}-ubuntu1604-virl
.. _FD.io test executor vpp functional jobs using CentOs: https://jenkins.fd.io/view/csit/job/csit-vpp-functional-{srelease}-centos7-virl
.. _FD.io test executor vpp device jobs using Ubuntu: https://jenkins.fd.io/view/csit/job/csit-vpp-device-{srelease}-ubuntu1804-1n-skx
.. _FD.io test executor Honeycomb functional jobs: https://jenkins.fd.io/view/csit/job/hc2vpp-csit-integration-{srelease}-ubuntu1604
.. _FD.io test executor NSH_SFC functional jobs: https://jenkins.fd.io/view/csit/job/csit-nsh_sfc-verify-func-{srelease}-ubuntu1604-virl
.. _FD.io test executor DMM functional jobs: https://jenkins.fd.io/view/csit/job/csit-dmm-functional-{srelease}-ubuntu1604-virl
.. _FD.io VPP compile job: https://jenkins.fd.io/view/vpp/job/vpp-merge-{srelease}-ubuntu1604/
.. _FD.io DPDK compile job: https://jenkins.fd.io/view/deb-dpdk/job/deb_dpdk-merge-{sdpdkrelease}-ubuntu1604/
.. _CSIT Testbed Setup: https://git.fd.io/csit/tree/resources/tools/testbed-setup/README.md?h={release}
.. _K8s configuration files: https://github.com/FDio/csit/tree/{release}/resources/templates/kubernetes
""".format(release='rls1810',
           report_week='49',
           prev_release='rls1807',
           srelease='1810',
           csitrelease='1810',
           csit_prev_release='1807',
           vpprelease='18.10',
           vpp_prev_release='18.07',
           dpdkrelease='18.08',
           sdpdkrelease='1808',
           trex_version='v2.35',
           csit_ubuntu_ver='csit-ubuntu-16.04.1_2018-03-07_2.1',
           csit_centos_ver='csit-centos-7.4-1711_2018-03-20_1.9')

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = 'en'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This patterns also effect to html_static_path and html_extra_path
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = False

# -- Options for HTML output ----------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
#
html_theme_options = {
    'canonical_url': '',
    'analytics_id': '',
    'logo_only': False,
    'display_version': True,
    'prev_next_buttons_location': 'bottom',
    'style_external_links': False,
    # Toc options
    'collapse_navigation': True,
    'sticky_navigation': True,
    'navigation_depth': 3,
    'includehidden': True,
    'titles_only': False
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_theme_path = ['env/lib/python2.7/site-packages/sphinx_rtd_theme']

# html_static_path = ['_build/_static']
html_static_path = ['_tmp/src/_static']

html_context = {
    'css_files': [
        '_static/theme_overrides.css',  # overrides for wide tables in RTD theme
        ],
    }

# If false, no module index is generated.
html_domain_indices = True

# If false, no index is generated.
html_use_index = True

# If true, the index is split into individual pages for each letter.
html_split_index = False

# -- Options for LaTeX output ---------------------------------------------

latex_engine = 'pdflatex'

latex_elements = {
     # The paper size ('letterpaper' or 'a4paper').
     #
     'papersize': 'a4paper',

     # The font size ('10pt', '11pt' or '12pt').
     #
     #'pointsize': '10pt',

     # Additional stuff for the LaTeX preamble.
     #
     'preamble': r'''
         \usepackage{pdfpages}
         \usepackage{svg}
         \usepackage{charter}
         \usepackage[defaultsans]{lato}
         \usepackage{inconsolata}
         \usepackage{csvsimple}
         \usepackage{longtable}
         \usepackage{booktabs}
     ''',

     # Latex figure (float) alignment
     #
     'figure_align': 'H',

     # Latex font setup
     #
     'fontpkg': r'''
         \renewcommand{\familydefault}{\sfdefault}
     ''',

     # Latex other setup
     #
     'extraclassoptions': 'openany',
     'sphinxsetup': r'''
         TitleColor={RGB}{225,38,40},
         InnerLinkColor={RGB}{62,62,63},
         OuterLinkColor={RGB}{225,38,40},
         shadowsep=0pt,
         shadowsize=0pt,
         shadowrule=0pt
     '''
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
    (master_doc, 'csit.tex', u'CSIT REPORT',
     u'', 'manual'),
]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
#
# latex_logo = 'fdio.pdf'

# For "manual" documents, if this is true, then toplevel headings are parts,
# not chapters.
#
# latex_use_parts = True

# If true, show page references after internal links.
#
latex_show_pagerefs = True

# If true, show URL addresses after external links.
#
latex_show_urls = 'footnote'

# Documents to append as an appendix to all manuals.
#
# latex_appendices = []

# It false, will not define \strong, \code, 	itleref, \crossref ... but only
# \sphinxstrong, ..., \sphinxtitleref, ... To help avoid clash with user added
# packages.
#
# latex_keep_old_macro_names = True

# If false, no module index is generated.
#
# latex_domain_indices = True