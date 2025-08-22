library(tidyverse)
asvtab = read.csv('data/active_seqtab_nochim.csv', row.names = 1)
dim(asvtab)
head(colnames(asvtab))
seqs = rownames(asvtab)
rownames(asvtab) = NULL

# Remove negative controls

fixtab = asvtab[,!grepl('neg', colnames(asvtab))]
dim(fixtab)

# Deal with suffixes

suf = colnames(fixtab)[endsWith(colnames(fixtab),'A') | 
                           endsWith(colnames(fixtab), 'B')]
suf
suf_fixed = sub('A', '', suf)
suf_fixed = sub('B', '', suf_fixed)

suf_fixed
names(suf) = suf_fixed
rpts = suf[suf_fixed %in% colnames(fixtab)]
rpts

rpts_col = cbind(fixtab[,rpts], fixtab[,names(rpts)])
head(rpts_col)

sum_df = rep(NA,nrow(fixtab))
for (samp in names(rpts)){
    df = cbind(fixtab[,samp], fixtab[,rpts[samp]])
    samp_col = rowSums(df)
    sum_df = cbind(sum_df, samp_col)
}
head(sum_df)
sum_df = data.frame(sum_df[,-1])
colnames(sum_df) = names(rpts)
head(sum_df)

fixtab[,colnames(sum_df)] = sum_df
fixtab = fixtab[,!colnames(fixtab) %in% rpts]
suf
rpts
single = suf[!suf %in% rpts]
single
single_fixed = names(single)
names(single_fixed) = single
single_fixed

colnames(fixtab)[colnames(fixtab) %in% single] = single_fixed[colnames(fixtab)[colnames(fixtab) %in% single]]

head(asvtab[,'IMG176A'])
head(fixtab[,'IMG176'])

dim(fixtab)
rownames(fixtab) = seqs
write.csv(fixtab, file = 'cleaned/seqtab_cleaned.csv')
