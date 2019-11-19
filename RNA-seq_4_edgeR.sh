##R in windows version

library(edgeR)
exprSet<- read.table(file = "gene_count_matrix.txt", sep = "\t", header = TRUE, row.names = 1, stringsAsFactors = FALSE)
exprSet <- exprSet[,1:6]
head(exprSet)
group_list <- factor(c(rep("DR",3),rep("CK",3)), levels = c("CK", "DR"))
head(group_list)
exprSet <- exprSet[rowSums(cpm(exprSet) > 1) >= 2,]
exprSet <- DGEList(counts = exprSet, group = group_list)
exprSet <- calcNormFactors(exprSet)
exprSet <- estimateCommonDisp(exprSet)
exprSet <- estimateTagwiseDisp(exprSet)
et <- exactTest(exprSet)
tTag <- topTags(et, n=nrow(exprSet))
topTags(et, n=nrow(exprSet))[1:10,]
diff_gene_edgeR <- subset(tTag$table)
write.csv(diff_gene_edgeR,file = "DR_vF_CK_edgeR.csv")

