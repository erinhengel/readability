# Write LaTeX table header.
tableHeader <- function(fh, title, label, col1len, coln, float=FALSE){
  if (float) {
    write("\\begin{table}[H]", file=fh, append=TRUE)
  } else {
    write("\\begin{table}", file=fh, append=TRUE)
  }
  write("\t\\footnotesize\t\n\\centering\t\n\t\\begin{threeparttable}", file=fh, append=TRUE)
  write(paste("\t\t\\caption{", title, "}", sep=""), file=fh, append=TRUE)
  write(paste("\t\t\\label{", label, "}", sep=""), file=fh, append=TRUE)
  write(paste("\t\t\\begin{tabular}{p{", col1len, "}", paste(rep("S@{}", coln), collapse="", sep=""), "}", sep=""), file=fh, append=TRUE)
  write("\t\t\t\\toprule", file=fh, append=TRUE)
  write(paste("\t\t\t", paste(mapply(paste, "&{(", 1:coln, ")}", sep=""), collapse=""), "\\\\"), file=fh, append=TRUE)
  write("\t\t\t\\midrule", file=fh, append=TRUE)
}

# Write table of fixed effects checkmarks to LaTeX file.
tableFixedEffects <- function(fh, ufes, vname, fenames, special_check=NULL, mnum){
  write("\t\t\t\\midrule", file=fh, append=TRUE)
  
  fes_list = list()
  for (f in 1:length(ufes)) { # Loop through fixed effects
    
    fe_label = names(fenames)[match(ufes[f], fenames)] # Fetch fixed effects label.
    
    if (fe_label %in% fes_list) next # Skip if the label has already been done (e.g., because two fixed effects are grouped under one label).
    fes_list$fe_label <- fe_label
    
    fe_text = fe_label
    for (c in 1:mnum) { # Loop through models (or column headers).
      
      fes <- names(get(paste("fit.", vname, ".", c, sep=""))$fe) # Fetch the fixed effects used in a particular model.
      
      # Apply check marks
      if (ufes[f] %in% fes) { # True if fixed effect was used in the particular model.
        scheck <- special_check$check[special_check$label==fe_label&special_check$col==c] # Return fixed effects with special check marks.
        
        if (length(scheck)==0) { # If no special checkmark is specified.
          fe_text = paste(fe_text, "&{\\ding{51}}", sep="") # Apply regular check mark.
        } else { # If a special check mark is specified.
          fe_text = paste(fe_text, "&{", scheck, "}", sep="") # Apply special check mark.
        }
        
      } else {
        fe_text = paste(fe_text, "&", sep="") # Do not apply a check mark b/c fixed effect was not used in the given model.
      }
    }
    write(paste("\t\t\t", fe_text, "\\\\", sep=""), file=fh, append=TRUE) # Append fixed effects line to file.
  }
}

# Write LaTeX table footer.
tableFooter <- function(fh, note, pval=FALSE){
  write("\t\t\t\\bottomrule\n\t\t\\end{tabular}\n\t\t\\begin{tablenotes}\n\t\t\t\\tiny", file=fh, append=TRUE)
  if (pval) {
    note <- paste(note, "***, ** and * statistically significant at 1\\%, 5\\% and 10\\%, respectively.")
  }
  write(paste("\t\t\t\\item \\textit{Notes}.", note), file=fh, append=TRUE)
  write("\t\t\\end{tablenotes}\n\t\\end{threeparttable}\n\\end{table}", file=fh, append=TRUE)
}
