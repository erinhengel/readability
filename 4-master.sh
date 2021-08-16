#!/bin/bash
# This script generates all figures and tables in Hengel (2021).

# Create Textatistic readability scores.
python 1-update-textatistic.py

# Create Readability readability scores.
Rscript 2-update-readability.R

# Generate all other analyses, figures and graphs in Stata.
stata-mp -q -b 3-master.do

# Create Figure 3 and Figure G.2 in Mathematica.
# Requires that the WolframScript is installed: https://www.wolfram.com/wolframscript/
wolframscript -code "UsingFrontEnd[NotebookEvaluate[\"$(pwd)/0-code/output/\"<>#<>\".nb\"]]&/@{\"Figure-3\", \"Figure-G.2\"};Quit[]"
