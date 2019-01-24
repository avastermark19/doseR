## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ------------------------------------------------------------------------

library(mclust)
library(doseR)
library(edgeR)

#MyVignette

xassetCountrySector <- read.table('~/doseR/extdata/format.out.Heliconius.LEG',  sep="\t", header=TRUE, as.is=TRUE)
  GFF <- read.table('~/doseR/extdata/gff_parser.out.Heliconius.LEG',  sep="\t", header=TRUE, as.is=TRUE)
  gene.chr.match <- GFF[match(xassetCountrySector$Gene, GFF$Gene), ]
  counts.head   <- as.matrix(round(xassetCountrySector[3:ncol(xassetCountrySector)] ))
  Groupings <- rep("X", ncol(xassetCountrySector)-2 )
  segLengths <- xassetCountrySector$Len
  cd.head <- new("countDat", data = counts.head, replicates = factor(Groupings), groups = list(Groupings, Groupings), annotation = gene.chr.match  )
  cd.head@rowObservables$seglens = segLengths
  #libsizes(cd.head) <-   getLibsizes(cd.head,   estimationType = "edgeR")
  libsizes(cd.head) <-   unname(getLibsizes2(cd.head,   estimationType = "edgeR"))
OBJ <- cd.head 

#OBJ@replicates<- as.factor(c("F","F", "F", "M", "M", "M","M", "M", "M", "M", "M","M", "F", "F", "F", "F","F", "F", "F", "F", "M","M", "F","F", "F", "F","M", "M", "F", "F", "F","F", "M", "M", "M", "M","M", "M", "M", "M", "F","F", "F", "F", "M", "M","M", "M", "F", "F", "F","F", "F", "F", "M", "M","M", "M"))
OBJ@replicates<- as.factor(c("F","M","M","M","F","F" ))

OBJ@RPKM<- make_RPKM(OBJ)

OBJ@annotation$something <- (gene.chr.match$Chr == "Z")
OBJ@annotation$something[OBJ@annotation$something==TRUE] <- "Z"
OBJ@annotation$something[OBJ@annotation$something==FALSE | is.na(OBJ@annotation$something)] <- "A"

## Factorized anntoation column input:
OBJ@annotation$something <- factor(x = OBJ@annotation$something, levels = c("A", "Z"))

#CYD_AB<- OBJ[,c(39,41,43,45,47,49,51,53,55,57)]
#CYD_HD <- OBJ[,c(40,42,44,46,48,50,52,54,56,58)]
CYD_AB <- OBJ

plotExpr(CYD_AB, col=c("black","red","black","red"), notch=T, outline=FALSE, cex.axis=0.8, mode_mean=FALSE, LOG2=TRUE, clusterby_grouping=FALSE, groupings="something")

# REMOVING 28%
f_CYD_AB <- dafsFilter(CYD_AB)
plotExpr(f_CYD_AB, col=c("black","red","black","red"), notch=T, outline=FALSE, cex.axis=0.8, mode_mean=FALSE, LOG2=TRUE, clusterby_grouping=FALSE, groupings="something")

# REMOVING 56%
f_CYD_AB <- quantFilter(CYD_AB, lo.bound=0.2) 
plotExpr(f_CYD_AB, col=c("black","red","black","red"), notch=T, outline=FALSE, cex.axis=0.8, mode_mean=FALSE, LOG2=TRUE, clusterby_grouping=FALSE, groupings="something")

# REMOVING 71%
f_CYD_AB <- iqrxFilter(CYD_AB, iqr_multi = 1.5)
plotExpr(f_CYD_AB, col=c("black","red","black","red"), notch=T, outline=FALSE, cex.axis=0.8, mode_mean=FALSE, LOG2=TRUE, clusterby_grouping=FALSE, groupings="something")

outlist <- generateStats(f_CYD_AB, groupings="something", mode_mean=TRUE)
outlist$kruskal
outlist$summary

outlist <- test_diffs(f_CYD_AB, groupings="something", mode_mean=TRUE,  treatment1="M", treatment2="F")
outlist$kruskal
outlist$summary

plotRatioBoxes(f_CYD_AB, treatment1="M", treatment2="F", groupings="something", cex.axis=0.8, outline=FALSE)

plotRatioDensity(f_CYD_AB, treatment1="M", treatment2="F", mode_mean=TRUE, LOG2=TRUE, col =c("black","red"), lty = 1, type = "l", groupings="something")


#LEG <- OBJ[,c(2,5,8,11,14,17)]
dm<- cD.DM(CYD_AB)
#glSeq(dm, "-1 + replicate*something") # TOO SLOW TO RUN EVERY TIME..

