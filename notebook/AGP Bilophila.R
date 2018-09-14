library("RODBC")
library(dplyr)
.libPaths(c(.libPaths(), '/opt/cloudera/impalaodbc/lib/64'))
conn <- odbcConnect("Sample Cloudera Impala DSN 64")

sqlTables(conn)

## Preparation data
meta <- sqlQuery(conn,"select * from  fr5_rst_dtm.r_str_sub_sam where fat<>'not provided' and fat <>'Unknown' and fat<>'Unspecified' and fat<>'no_data' ", dec=".")
dim(meta)
summary(meta$fat)
meta <- meta[!(is.na(meta$fat)),]
dim(meta)
summary(meta$fat)
# 3278  551

metaFat <- meta[,which(colnames(meta) %in% c("seq_id", "fat", "col_dat"))]

# tab <- sqlQuery(conn,"select * from  fr5_rst_dtm.f_str_txn where run_id='2017-04' and cat_val='notrim'", dec=".")
tab100nt <- sqlQuery(conn,"select * from  fr5_rst_dtm.f_str_txn where run_id='2017-04' and cat_val='100nt'", dec=".")
# dim(tab)
dim(tab100nt)
# 16264  2170

sampOrigin <- sqlQuery(conn,"select sub_id, seq_id from  fr5_rst_dwh.r_str_seq where spe_val='Stool'", dec=".")

dim(sampOrigin)
# 15623     2

tab100ntStool<-merge(tab100nt, sampOrigin, by="seq_id", all=F)
dim(tab100ntStool)
# 12547  2171

metaFatStool <- merge(tab100ntStool, metaFat, by="seq_id", all=F)
dim(metaFatStool)
# 2166 2172
metaFatStool <- metaFatStool[,c(1,2171,2172,2173, 2:2170)]

metaFatStoolfilt <- metaFatStool[,10:length(metaFatStool)]
metaFatStoolfilt <- metaFatStoolfilt[,-which(colSums(metaFatStoolfilt)==0)]
dim(metaFatStoolfilt)
# 2166 1261

metaFatStoolfilt <- cbind(metaFatStool[,1:8], metaFatStoolfilt)
dim(metaFatStoolfilt)

# Gather levels fat

# test <- sqlQuery(conn,"select * from  fr5_rst_dtm.f_str_txn", dec=".")
# test2 <- sqlQuery(conn,"select * from  fr5_rst_dwh.r_str_seq", dec=".")
# dim(test)
# dim(test2)

# Keep one subject with first date of completion
metaFatStoolfilt$col_dat <- as.Date(metaFatStoolfilt$col_dat, format = "%Y-%m-%d")
metaFatStoolfilt <- metaFatStoolfilt %>% group_by(sub_id) %>% slice(which.min(col_dat)) 
metaFatStoolfilt <- as.data.frame(metaFatStoolfilt)
dim(metaFatStoolfilt)
#1119 1269
pdf("/home/NEAD/moreaurm/HistFat.pdf")
hist(metaFatStoolfilt$fat)

dev.off()

QuartFat <- within(metaFatStoolfilt, quartile <- as.integer(cut(fat, quantile(fat, probs=0:4/4), include.lowest=TRUE)))
dim(QuartFat)
QuartFat <- QuartFat[,c(1:3,1270,4:1269)]
names(QuartFat)[names(QuartFat) == 'quartile'] <- 'Fat_level'
QuartFat[10:1270][is.na(QuartFat[10:1270])] <- 0

bilophila <- which(grepl( "bilophila" , names(QuartFat)))
boxplot(QuartFat[,bilophila] ~ QuartFat$Fat_level, outline=FALSE)
pdf("/home/NEAD/moreaurm/histBilophila.pdf")
hist(QuartFat[,bilophila])

pdf("/home/NEAD/moreaurm/LinearPlot.pdf")
plot(QuartFat$fat, QuartFat[,bilophila], cex=0.5, pch=20)
plot(QuartFat$fat, QuartFat[,bilophila], ylim=c(0,0.02), cex=0.5, pch=20)
plot(QuartFat$fat, QuartFat[,bilophila], xlim=c(0,200), ylim=c(0,0.02), cex=0.5, pch=20)
hist(QuartFat[,bilophila], breaks=1000, xlim=c(0,0.01))
cor(QuartFat$fat, QuartFat[,bilophila])

QuartFat1 <- QuartFat[which(QuartFat$Fat_level == "1"),]
summary(QuartFat1[,bilophila])
pdf("/home/NEAD/moreaurm/HistFat1.pdf")
hist(QuartFat1[,bilophila], xlim=c(0,0.01), breaks=1000)
hist(QuartFat1[,bilophila])
dev.off()

QuartFat2 <- QuartFat[which(QuartFat$Fat_level == "2"),]
summary(QuartFat2[,bilophila])
pdf("/home/NEAD/moreaurm/HistFat2.pdf")
hist(QuartFat2[,bilophila], xlim=c(0,0.01), breaks=1000)
hist(QuartFat2[,bilophila])
dev.off()

QuartFat3 <- QuartFat[which(QuartFat$Fat_level == "3"),]
summary(QuartFat3[,bilophila])
pdf("/home/NEAD/moreaurm/HistFat3.pdf")
hist(QuartFat3[,bilophila], xlim=c(0,0.01), breaks=1000)
hist(QuartFat3[,bilophila])
dev.off()

QuartFat4 <- QuartFat[which(QuartFat$Fat_level == "4"),]
summary(QuartFat4[,bilophila])
pdf("/home/NEAD/moreaurm/HistFat4.pdf")
hist(QuartFat4[,bilophila], xlim=c(0,0.01), breaks=1000)
hist(QuartFat4[,bilophila])
dev.off()


## Replace 0 value by minimum / 10
# Test <- QuartFat
# QuartFat[,bilophila][QuartFat[,bilophila]==0] <- min(QuartFat[,bilophila][QuartFat[,bilophila]!=0])/10
LogQuartfat <- QuartFat
LogQuartfat[,10:length(LogQuartfat)][LogQuartfat[,10:length(LogQuartfat)]==0] <- min(LogQuartfat[,10:length(LogQuartfat)][LogQuartfat[,10:length(LogQuartfat)]!=0])/10

# Normalization CLR
LogQuartfat[,10:length(LogQuartfat)] <- log(LogQuartfat[,10:length(LogQuartfat)])
boxplot(LogQuartfat[,bilophila] ~ LogQuartfat$Fat_level, outline=FALSE)
plot(LogQuartfat$fat, LogQuartfat[,bilophila], cex=0.5, pch=20)
hist(LogQuartfat[,bilophila])
cor(LogQuartfat$fat, LogQuartfat[,bilophila])
