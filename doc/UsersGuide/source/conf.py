# -*- coding: utf-8 -*-
#
# OpenModelica User's Guide documentation build configuration file, created by
# sphinx-quickstart on Wed Jun  3 06:49:07 2015.
#
# This file is execfile()d with the current directory set to its
# containing dir.
#
# Note that not all possible configuration values are present in this
# autogenerated file.
#
# All configuration values have a default; values that are commented out
# serve to show the default.

import git
import re
import sys
import os
import shlex
import subprocess
from datetime import date

sys.setrecursionlimit(2000)

if not 'OPENMODELICAHOME' in os.environ:
  if os.path.isdir('../../../build_cmake/install'):
    os.environ['OPENMODELICAHOME'] = os.path.realpath('../../../build_cmake/install')
  elif os.path.isdir('../../../install_cmake'):
    os.environ['OPENMODELICAHOME'] = os.path.realpath('../../../install_cmake')
  else:
    os.environ['OPENMODELICAHOME'] = os.path.realpath('../../../build')

os.environ['PATH'] = "%s/bin:%s" % (os.environ['OPENMODELICAHOME'],os.environ['PATH'])

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#sys.path.insert(0, os.path.abspath('.'))

# -- General configuration ------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
needs_sphinx = '1.8'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
sys.path.append(os.path.abspath('.')) # For myext
extensions = [
    'sphinx.ext.intersphinx',
    'sphinx.ext.todo',
    'sphinx.ext.ifconfig',
    'sphinx.ext.imgmath',
    'sphinxcontrib.bibtex',
    'sphinxcontrib.programoutput',
    'sphinxcontribopenmodelica'
]

# As long as we are not generating with the epub tag it is save to use MathJax.
if 'latex' not in tags:
  extensions.append('sphinx.ext.imgmath' if 'nomathjax' in tags else 'sphinx.ext.mathjax')


# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
# source_suffix = ['.rst', '.md']
source_suffix = '.rst'

# The encoding of source files.
#source_encoding = 'utf-8-sig'

# The master toctree document.
master_doc = 'index'

# General information about the project.
project = 'OpenModelica User\'s Guide'
copyright = '''1998-%d Open Source Modelica Consortium <a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="_static/cc-by-80x15.png" /></a> <br> This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>''' % (date.today().year)
author = 'Open Source Modelica Consortium'

today_fmt = '%Y'

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short X.Y version.
if os.path.exists('../../../.git'):
  r = git.repo.Repo('../../../')
  release = r.git.describe(["--tags","--match=v*.*.*"])
  versionx = re.search("^v([0-9]+)[.]([0-9]+)[.]([0-9]+)", release)
  version = versionx.group(0)
  major = int(versionx.group(1))
  minor = int(versionx.group(2))
  patch = int(versionx.group(3))
  thisrelease = (major,minor,patch)
  allversions = [thisrelease]
  for t in r.tags:
    try:
      versionx = re.search("^v([0-9]+)[.]([0-9]+)[.]([0-9]+)$", str(t))
      tagversion = versionx.group(0)
      tagmajor = int(versionx.group(1))
      tagminor = int(versionx.group(2))
      tagpatch = int(versionx.group(3))
      allversions.append((tagmajor, tagminor, tagpatch))
    except:
      pass
  allversions.sort()
  prevrelease = "v%d.%d.%d" % allversions[allversions.index((major,minor,patch))-1]
  if version == release or re.match("^(v[0-9]+)[.]([0-9]+)[.]([0-9]+)-[A-Za-z]+[0-9]*$", release):
    link = "`%s <https://github.com/OpenModelica/OpenModelica/releases/tag/%s>`__ `(diff <https://github.com/OpenModelica/OpenModelica/compare/%s...%s>`__, `doc diff) <https://github.com/OpenModelica/OpenModelica-doc/compare/%s...%s>`__" % (release,release,prevrelease,release,prevrelease,release)
  else:
    thisreleasestr = "v%d.%d.%d" % thisrelease
    docheadcommit = r.commit('HEAD').tree['doc'].hexsha
    thissha = r.commit('HEAD').hexsha
    semver = subprocess.check_output(["sh", "-c", "cd ../../../ && common/semver.sh"]).decode("utf-8").strip()
    link = "`%s <https://github.com/OpenModelica/OpenModelica/commit/%s>`__ (`diff <https://github.com/OpenModelica/OpenModelica/compare/%s...%s>`__, `doc <https://github.com/OpenModelica/OpenModelica-doc/compare/%s...%s>`__)" % (semver,thissha,prevrelease,thissha,prevrelease,docheadcommit)
  releaselink = """.. only :: html or epub

    *Version:* %s""" % link
else:
  version = '1.9.3'
  # The full version, including alpha/beta/rc tags.
  release = '1.9.3-dev'
  releaselink = "*Version:* %s" % release

open("omreleaselink.inc", "w").write(releaselink)


# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = 'en'

# There are two options for replacing |today|: either, you set today to some
# non-false value, then it is used:
#today = ''
# Else, today_fmt is used as the format for a strftime call.
#today_fmt = '%B %d, %Y'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
exclude_patterns = ['omsimulator/*.rst','omsimulator/api/*.rst','api/*.rst','tmp.rst']

# The reST default role (used for this markup: `text`) to use for all
# documents.
#default_role = None

# If true, '()' will be appended to :func: etc. cross-reference text.
#add_function_parentheses = True

# If true, the current module name will be prepended to all description
# unit titles (such as .. function::).
#add_module_names = True

# If true, sectionauthor and moduleauthor directives will be shown in the
# output. They are ignored by default.
#show_authors = False

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# A list of ignored prefixes for module index sorting.
#modindex_common_prefix = []

# If true, keep warnings as "system message" paragraphs in the built documents.
#keep_warnings = False

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = True


# -- Options for HTML output ----------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme = 'alabaster'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
html_theme_options = {
  "logo" : "../_images/logo.svg",
  "logo_name" : "OpenModelica",
  "font_family" : "Arial, Helvetica, sans-serif, 'goudy old style', 'minion pro', 'bell mt', Georgia, 'Hiragino Mincho Pro', serif",
}

# Add any paths that contain custom themes here, relative to this directory.
import alabaster
html_theme_path = [alabaster.get_path()]

# The name for this set of Sphinx documents.  If None, it defaults to
# "<project> v<release> documentation".
#html_title = None

# A shorter title for the navigation bar.  Default is the same as html_title.
#html_short_title = None

# The name of an image file (relative to this directory) to place at the top
# of the sidebar.
#html_logo = None

# The name of an image file (within the static path) to use as favicon of the
# docs.  This file should be a Windows icon file (.ico) being 16x16 or 32x32
# pixels large.
#html_favicon = None

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# Add any extra paths that contain custom files (such as robots.txt or
# .htaccess) here, relative to this directory. These files are copied
# directly to the root of the documentation.
#html_extra_path = []

# If not '', a 'Last updated on:' timestamp is inserted at every page bottom,
# using the given strftime format.
#html_last_updated_fmt = '%b %d, %Y'

# If true, SmartyPants will be used to convert quotes and dashes to
# typographically correct entities.
# html_use_smartypants = False
# This option changed in more recent Sphinx versions (1.6.6)
smartquotes = False

# Custom sidebar templates, maps document names to template names.
html_sidebars = {
    '**': [
        'about.html',
        'searchbox.html',
        'navigation.html',
        'relations.html',
        'donate.html',
    ]
}

# Additional templates that should be rendered to pages, maps page names to
# template names.
#html_additional_pages = {}

# If false, no module index is generated.
#html_domain_indices = True

# If false, no index is generated.
#html_use_index = True

# If true, the index is split into individual pages for each letter.
#html_split_index = False

# If true, links to the reST sources are added to the pages.
#html_show_sourcelink = True

# If true, "Created using Sphinx" is shown in the HTML footer. Default is True.
#html_show_sphinx = True

# If true, "(C) Copyright ..." is shown in the HTML footer. Default is True.
#html_show_copyright = True

# If true, an OpenSearch description file will be output, and all pages will
# contain a <link> tag referring to it.  The value of this option must be the
# base URL from which the finished HTML is served.
#html_use_opensearch = ''

# This is the file name suffix for HTML files (e.g. ".xhtml").
#html_file_suffix = None

# Language to be used for generating the HTML full-text search index.
# Sphinx supports the following languages:
#   'da', 'de', 'en', 'es', 'fi', 'fr', 'hu', 'it', 'ja'
#   'nl', 'no', 'pt', 'ro', 'ru', 'sv', 'tr'
#html_search_language = 'en'

# A dictionary with options for the search language support, empty by default.
# Now only 'ja' uses this config value
#html_search_options = {'type': 'default'}

# The name of a javascript file (relative to the configuration directory) that
# implements a search results scorer. If empty, the default will be used.
#html_search_scorer = 'scorer.js'

# Output file base name for HTML help builder.
htmlhelp_basename = 'OpenModelicaUsersGuidedoc'

# -- Options for LaTeX output ---------------------------------------------

latex_elements = {
# The paper size ('letterpaper' or 'a4paper').
'papersize': 'a4paper',

# The font size ('10pt', '11pt' or '12pt').
#'pointsize': '10pt',

# Additional stuff for the LaTeX preamble.
'preamble':
"""
\\usepackage{bookmark}
""",
'fontenc': r'\usepackage[LGR,T1]{fontenc}'

# Latex figure (float) alignment
#'figure_align': 'htbp',
}

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
  (master_doc, 'OpenModelicaUsersGuide.tex', 'OpenModelica User\'s Guide', author, 'manual'),
]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
#latex_logo = None

# For "manual" documents, if this is true, then toplevel headings are parts,
# not chapters.
#latex_use_parts = False

# If true, show page references after internal links.
#latex_show_pagerefs = False

# If true, show URL addresses after external links.
#latex_show_urls = False

# Documents to append as an appendix to all manuals.
#latex_appendices = []

# If false, no module index is generated.
#latex_domain_indices = True


# -- Options for manual page output ---------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    (master_doc, 'openmodelicausersguide', 'OpenModelica User\'s Guide Documentation',
     [author], 1)
]

# If true, show URL addresses after external links.
#man_show_urls = False


# -- Options for Texinfo output -------------------------------------------

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author,
#  dir menu entry, description, category)
texinfo_documents = [
  (master_doc, 'OpenModelicaUsersGuide', 'OpenModelica User\'s Guide Documentation',
   author, 'OpenModelicaUsersGuide', 'One line description of project.',
   'Miscellaneous'),
]

# Documents to append as an appendix to all manuals.
#texinfo_appendices = []

# If false, no module index is generated.
#texinfo_domain_indices = True

# How to display URL addresses: 'footnote', 'no', or 'inline'.
#texinfo_show_urls = 'footnote'

# If true, do not generate a @detailmenu in the "Top" node's menu.
#texinfo_no_detailmenu = False


# -- Options for Epub output ----------------------------------------------

# Bibliographic Dublin Core info.
epub_title = project
epub_author = author
epub_publisher = author
epub_copyright = copyright

# The basename for the epub file. It defaults to the project name.
#epub_basename = project

# The HTML theme for the epub output. Since the default themes are not optimized
# for small screen space, using the same theme for HTML and epub output is
# usually not wise. This defaults to 'epub', a theme designed to save visual
# space.
#epub_theme = 'epub'

# The language of the text. It defaults to the language option
# or 'en' if the language is not set.
#epub_language = ''

# The scheme of the identifier. Typical schemes are ISBN or URL.
#epub_scheme = ''

# The unique identifier of the text. This can be a ISBN number
# or the project homepage.
#epub_identifier = ''

# A unique identification for the text.
#epub_uid = ''

# A tuple containing the cover image and cover page html template filenames.
#epub_cover = ()

# A sequence of (type, uri, title) tuples for the guide element of content.opf.
#epub_guide = ()

# HTML files that should be inserted before the pages created by sphinx.
# The format is a list of tuples containing the path and title.
#epub_pre_files = []

# HTML files shat should be inserted after the pages created by sphinx.
# The format is a list of tuples containing the path and title.
#epub_post_files = []

# A list of files that should not be packed into the epub file.
epub_exclude_files = ['search.html']

# The depth of the table of contents in toc.ncx.
#epub_tocdepth = 3

# Allow duplicate toc entries.
#epub_tocdup = True

# Choose between 'default' and 'includehidden'.
#epub_tocscope = 'default'

# Fix unsupported image types using the Pillow.
#epub_fix_images = False

# Scale large images.
#epub_max_image_width = 0

# How to display URL addresses: 'footnote', 'no', or 'inline'.
#epub_show_urls = 'inline'

# If false, no index is generated.
#epub_use_index = True


# Example configuration for intersphinx: refer to the Python standard library.
intersphinx_mapping = {'modelicaspec': ('https://modelica.readthedocs.org/en/latest/', None)}

numfig = True
numfig_format = {'figure': "Figure %s", 'table': "Table %s", 'code-block': "Listing %s"}

highlight_language = 'modelica'
imgmath_image_format = 'svg'

bibtex_bibfiles = ['openmodelica.bib', 'extrarefs.bib']