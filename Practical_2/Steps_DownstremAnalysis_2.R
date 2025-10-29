# This R script was used and distributed during the ADVANCED DATA ANALYSIS FOR BIOLOGICAL PROCESSES Course
# We hope that it will be useful, but we do not provide ANY WARRANTY,
# not even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

################################################
###           BEFORE TO START                ###
### HAVE A LOOK AT THE FILE AND AT THE DATA  ###
################################################

library("phyloseq")
library(dplyr)
library(tidyr)
library(stringr)
library(microbiome)
library("microbial")
library(vegan)
library(usedist)
library(ggplot2)
library(nortest)
library(car)

#####################################################
### phyloseq object with the microbiome library  ####
#####################################################

otu <- read.table(file = "otu.csv", sep = ",", header = T, row.names = 1, check.names = FALSE)
taxa_present <- row.names(otu)
head(otu)
head(taxa_present)

taxonomy <- read.table(file = "taxonomy.csv", sep = ",", header = T , row.names = 1)
head(taxonomy)

# clean the taxonomy, Greengenes format
tax <- taxonomy %>%
  select(Taxon) %>% 
  separate(Taxon, c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"), "; ")

head(tax)

tax.clean <- data.frame(row.names = row.names(tax),
                        Kingdom = str_replace(tax[,1], "k__",""),
                        Phylum = str_replace(tax[,2], "p__",""),
                        Class = str_replace(tax[,3], "c__",""),
                        Order = str_replace(tax[,4], "o__",""),
                        Family = str_replace(tax[,5], "f__",""),
                        Genus = str_replace(tax[,6], "g__",""),
                        Species = str_replace(tax[,7], "s__",""),
                        stringsAsFactors = FALSE)

tax.clean[is.na(tax.clean)] <- ""
tax.clean[tax.clean=="__"] <- ""
head(tax.clean)

for (i in 1:nrow(tax.clean)){
  if (tax.clean[i,7] != ""){
    tax.clean$Species[i] <- paste(tax.clean$Genus[i], tax.clean$Species[i], sep = " ")
  } else if (tax.clean[i,2] == ""){
    kingdom <- paste("Unclassified", tax.clean[i,1], sep = " ")
    tax.clean[i, 2:7] <- kingdom
  } else if (tax.clean[i,3] == ""){
    phylum <- paste("Unclassified", tax.clean[i,2], sep = " ")
    tax.clean[i, 3:7] <- phylum
  } else if (tax.clean[i,4] == ""){
    class <- paste("Unclassified", tax.clean[i,3], sep = " ")
    tax.clean[i, 4:7] <- class
  } else if (tax.clean[i,5] == ""){
    order <- paste("Unclassified", tax.clean[i,4], sep = " ")
    tax.clean[i, 5:7] <- order
  } else if (tax.clean[i,6] == ""){
    family <- paste("Unclassified", tax.clean[i,5], sep = " ")
    tax.clean[i, 6:7] <- family
  } else if (tax.clean[i,7] == ""){
    tax.clean$Species[i] <- paste("Unclassified ", tax.clean$Genus[i], sep = " ")
  }
}

head(tax)

metadata <- read.table(file = "metadata.csv", sep = ",", header = T, row.names = 1)
head(metadata)

OTU = otu_table(as.matrix(otu), taxa_are_rows = TRUE)
head(OTU)

TAX = tax_table(as.matrix(tax))
head(TAX)

SAMPLE <- sample_data(metadata)
SAMPLE[,]

# merge the data into a Phyloseq Object
ps <- phyloseq(OTU, TAX, SAMPLE)
ps

#######################################
#### plot relative abundance  #########
#######################################
##  library - microbial
##  Selection by metadata
psbar1 <- subset_samples(ps, Status=="HEALTHY" | Status == "BLANK")
metabar1 <- data.frame(sample_data(psbar1))
metabar1
#to find taxa that are "really" present in the considered subsection of samples 
dat = psbar1@otu_table[!apply(psbar1@otu_table, 1, function(x) all(x == 0)), ]
real_taxa <- row.names(dat@.Data)
head(real_taxa)
psbar2_otu <- psbar1@otu_table[c(real_taxa),]
psbar2_taxa <- psbar1@tax_table[c(real_taxa),]
SAMPLE1 <- sample_data(metabar1)
psbar_obj <- phyloseq(psbar2_otu, psbar2_taxa, SAMPLE1)
psbar_obj
##  check for the function "normalize"
##        which method? 
##  method = "relative" argument, calculates relative abundances, which are the proportions of each feature 
##  (like OTUs or ASVs) within a sample. 
##  This method converts raw counts into percentages by dividing each feature's count by the total count 
##  for that sample
phy <- normalize(psbar_obj)
##  plot by samples
plotbar(phy, level="Order", top = 20)
##  plot by taxonomical leyer
plotbar(phy, level="Genus", top = 15, group = "Phylum")

##  try with other taxonomical leyers: Class, Family, etx

#var1 <- plotbar(phy, level="Species", top = 15, group = "Phylum", return = T)
#head(var1)

#####################################################
####    ALPHAs & BETAs with microbiome library  #####
#####################################################

####################
####    ALPHAs  ####
####################

alpha <-microbiome::alpha(ps, index = "all")
head(alpha)

aa <- merge(alpha, metadata, 
            by = 'row.names', all = TRUE) 
head(aa)

# Use relative abundance data
ps1 <- microbiome::transform(ps, "compositional")

# Pick core taxa
ps1 <- core(ps1, detection = 0.001, prevalence = 60/100)

### detection = 0  this sets the minimum abundance threshold.
### 0 means that a taxon is considered “detected” even if it appears at any nonzero abundance.

### prevalence = 60/100  this sets the prevalence threshold, i.e. the minimum fraction of samples in which a taxon must be detected to be considered part of the core.
### 60/100 = 0.6, meaning taxa must appear in at least 60% of the samples.


# Illustrate sample similarities with PCoA (NMDS)
plot_landscape(ps1, "NMDS", "bray", col = "Status")

head(ps@otu_table)
head(ps1@otu_table)

###########
### HEALTHY_HAIR or HEALTHY_CSF and NO_BLANK
##########
xx <- subset(aa, Condition =="NO_BLANK")
head(xx)
tail(xx)

### observed
wilcox.test(xx$observed ~ xx$Status)
boxplot(xx$observed ~ xx$Status)
ggplot(xx, aes(x=Status, y=observed, fill = Status)) + 
  geom_boxplot()+
  geom_dotplot(binaxis='y', stackdir='center')

### diversity_shannon
wilcox.test(xx$diversity_shannon ~ xx$Status)
boxplot(xx$diversity_shannon ~ xx$Status)
ggplot(xx, aes(x=Status, y=diversity_shannon, fill = Status)) + 
  geom_boxplot()+
  geom_dotplot(binaxis='y', stackdir='center')

### diversity_inverse_simpson
wilcox.test(xx$diversity_inverse_simpson ~ xx$Status)
boxplot(xx$diversity_inverse_simpson ~ xx$Status)
ggplot(xx, aes(x=Status, y=diversity_inverse_simpson, fill = Status)) + 
  geom_boxplot()+
  geom_dotplot(binaxis='y', stackdir='center')

##########################
###   question: run the statistics without excluding any sample
###   which is the test?
###   kruskal.test(A ~ B, data = data)
###   pairwise.wilcox.test(data$A, data$B, p.adjust.method = "BH")
##########################

###########
### ALPHA on COMPOSITIONAL DATA
##########
ps_c <- microbiome::transform(ps, "compositional")
alpha_c <-microbiome::alpha(ps_c, index = "all")
head(alpha_c)

aa_c <- merge(alpha_c, metadata, 
              by = 'row.names', all = TRUE) 
head(aa_c)

###########
### HEALTHY_HAIR or HEALTHY_CSF and NO_BLANK
##########
xx_c <- subset(aa_c, Condition =="NO_BLANK")
head(xx_c)
tail(xx_c)

### observed
wilcox.test(xx_c$observed ~ xx_c$Status)
boxplot(xx_c$observed ~ xx_c$Status)
ggplot(xx_c, aes(x=Status, y=observed, fill = Status)) + 
  geom_boxplot()+
  geom_dotplot(binaxis='y', stackdir='center')

### diversity_shannon
wilcox.test(xx_c$diversity_shannon ~ xx_c$Status)
boxplot(xx_c$diversity_shannon ~ xx_c$Status)
ggplot(xx_c, aes(x=Status, y=diversity_shannon, fill = Status)) + 
  geom_boxplot()+
  geom_dotplot(binaxis='y', stackdir='center')

### diversity_inverse_simpson
wilcox.test(xx_c$diversity_inverse_simpson ~ xx_c$Status)
boxplot(xx_c$diversity_inverse_simpson ~ xx_c$Status)
ggplot(xx_c, aes(x=Status, y=diversity_inverse_simpson, fill = Status)) + 
  geom_boxplot()+
  geom_dotplot(binaxis='y', stackdir='center')

### Core microbiota
# Transform to compositional abundances
pseq.rel <- microbiome::transform(ps, "compositional")

# Pick the core (>0.1% relative abundance in >50% of the samples)
pseq.core <- core(pseq.rel, detection = 0.1/100, prevalence = 50/100)
pseq.core

# Core with compositionals:
prevalences <- seq(.05, 1, .05)

detections <- round(10^seq(log10(5e-3), log10(.2), length = 10), 3)

p <- plot_core(pseq.rel, plot.type = "heatmap",
               prevalences = prevalences, detections = detections, min.prevalence = 0.5) +
  xlab("Detection Threshold (Relative Abundance)") +
  theme(axis.text.x = element_text(size = 9))

print(p)

########################
#### Beta Diversity ####
########################

real_samples <- row.names(alpha)

metadata <- metadata[c(real_samples),]
metadata$shannon <- alpha$diversity_shannon
sampledata = sample_data(data.frame(metadata, row.names=sample_names(ps), stringsAsFactors=FALSE))
#sampledata

pseq1 = merge_phyloseq(ps, sampledata)
pseq1

##################
####  BETAs   ####
##################
dist_methods <- unlist(distanceMethodList)
print(dist_methods)

dist = phyloseq::distance(pseq1, method="bray")

ordination = ordinate(pseq1, method="PCoA", distance=dist)
plot_ordination(pseq1, ordination, color="Status", shape = "Condition") + 
  theme(legend.position="right") +
  theme(strip.background = element_blank())

pcoa <- cmdscale(d = dist, k=2, eig = TRUE)
plot(pcoa$points)

pcoa_df <- data.frame(pcoa$points)
colnames(pcoa_df) <- c("PCo1", "PCo2")
#pcoa_df
pcoa_df$condition <- factor(metadata$Status)
pcoa_df$class <- factor(metadata$Condition)
pcoa_df$shannon <- factor(metadata$shannon)


calf <- ggplot(pcoa_df, aes(x = PCo1, y = PCo2)) + 
  geom_point(aes(shape=condition, color=class, size=shannon)) +
  xlab("PCo1") +
  ylab("PCo2") + 
  ggtitle("BrayCurtis") +
  theme(legend.position="right") +
  scale_color_brewer(palette = "Set1") +
  theme_light() +
  guides(size = "none")
calf

####
####  subsets for BETA DIVERSITY evaluation (as for ALPHA)
####

dist1 <- dist_subset(dist, c(metadata$Condition == "NO_BLANK"))
#dist1
ordination = ordinate(pseq1, method="PCoA", distance=dist1)
plot_ordination(pseq1, ordination, color="Status", shape = "Condition") + 
  theme(legend.position="right") +
  theme(strip.background = element_blank())

pcoa1 <- cmdscale(d = dist1, k=2, eig = TRUE)
#pcoa1
#plot(pcoa1$points)

pcoa1_df <- data.frame(pcoa1$points)
colnames(pcoa1_df) <- c("PCo1", "PCo2")
#pcoa1_df

meta <- subset(as.data.frame(metadata), c(metadata$Condition == "NO_BLANK"))
#meta

pcoa1_df$condition <- factor(meta$Status)
pcoa1_df$class <- factor(meta$Condition)
pcoa1_df$shannon <- factor(meta$shannon)
#pcoa1_df

calf <- ggplot(pcoa1_df, aes(x = PCo1, y = PCo2)) + 
  geom_point(aes(color=condition, size=shannon)) +
  xlab("PCo1") +
  ylab("PCo2") + 
  ggtitle("BrayCurtis - Piemontese") +
  theme(legend.position="right") +
  scale_color_brewer(palette = "Set1") +
  theme_light() +
  guides(size = "none")
calf

######################
####  PERMANOVA   ####
######################
psbeta1 <- subset_samples(pseq1, (Condition =='NO_BLANK'))
meta1 <- data.frame(sample_data(psbeta1))
#meta1
ma1 <- psbeta1@otu_table
#ma1
#head(ma)
#mat <- t(ma)
mat1 <- t(ma1)
#mat1

test.adonis1 <- adonis2(mat1 ~ Status, data = meta1, permutation = 999, method = "bray")
test.adonis1

permanova_cohort1 <- vegan::adonis(mat1 ~ Status,
                                   data = meta1,
                                   permutations = 999)
permanova_cohort1$aov.tab
coef <- coef(permanova_cohort1)["Status1",]
##coef
#write.table(coef, file="coefficient.txt", quote=FALSE, sep = "\t")
top.coef <- sort(head(coef[rev(order(abs(coef)))],20))

top_taxa_coeffient_plot <- ggplot(data.frame(x = top.coef,
                                             y = factor(names(top.coef),
                                                        unique(names(top.coef)))),
                                  aes(x = x, y = y)) +
  geom_bar(stat="identity") +
  labs(x="", y="", title="Top Taxa") +
  theme_bw()

top_taxa_coeffient_plot
top.coef
class(top.coef)
top.coef <- as.data.frame(top.coef)
row.names(top.coef)
top.coef$names <- row.names(top.coef)
top.coef
taxa_top <- tax
taxa_top$names <- row.names(taxa_top)
head(taxa_top)
top_translate <- inner_join(top.coef, taxa_top)
class(top_translate)
top_translate


top_taxa_coeffient_plot <- ggplot(data.frame(x = top_translate$top.coef,
                                             y = factor(top_translate$Species)),
                                  aes(x = x, y = y)) +
  geom_bar(stat="identity") +
  labs(x="", y="", title="Top_Taxa") +
  theme_bw()
top_taxa_coeffient_plot

top_taxa_coeffient_plot <- ggplot(data.frame(x = top_translate$top.coef,
                                             y = factor(top_translate$Genus)),
                                  aes(x = x, y = y)) +
  geom_bar(stat="identity") +
  labs(x="", y="", title="Top_Taxa") +
  theme_bw()
top_taxa_coeffient_plot


top_taxa_coeffient_plot <- ggplot(data.frame(x = top_translate$top.coef,
                                             y = factor(top_translate$Family)),
                                  aes(x = x, y = y)) +
  geom_bar(stat="identity") +
  labs(x="", y="", title="Top_Taxa") +
  theme_bw()
top_taxa_coeffient_plot

##########
### EXERCICE: try with another Beta Diversity - e.g. jaccard
##########


###################################
##### DIFFERENTIAL ABUNDANCE  #####
###################################

library(DESeq2)

ps
ps@sam_data
a <- ps@otu_table
b <- ps@sam_data
c <- ps@tax_table
#head(a)
##  to obtain the pseudocounts!!
a[,] <- a[,] + 1
a <- as.data.frame(a)
#head(a)
b <- as.data.frame(b)
b
#head(b)
c <- as.data.frame(c)
c

#ds2 <- DESeqDataSet(a, b)
ds2 <- DESeqDataSetFromMatrix(countData=a, colData=b,
                              design =~ Status)
ds2
ds2$Status
# Does the analysis
dds <- DESeq(ds2)
# Gets the results from the object
res <- results(dds)
res
# Creates a data frame from results
df <- as.data.frame(res)
df$FeatureID <- rownames(df)
rownames(df)

# Get taxonomy as a data.frame
tax <- as.data.frame(tax_table(ps))
tax$FeatureID <- rownames(tax)
head(tax)

# Build two handy annotations:
#    - BestName: the most specific available rank (Species→Genus→Family→…)
#    - Taxon   : the full path "Kingdom; Phylum; Class; …"
rank_order <- c("Kingdom","Phylum","Class","Order","Family","Genus","Species")

# Ensure missing ranks exist so coalesce works cleanly
for (r in rank_order) if (!r %in% names(tax)) tax[[r]] <- NA

tax <- tax %>%
  mutate(
    BestName = coalesce(Species, Genus, Family, Order, Class, Phylum, Kingdom, FeatureID),
    Taxon    = apply(select(., any_of(rank_order)), 1, function(x) paste(na.omit(x), collapse = "; "))
  ) %>%
  select(FeatureID, BestName, Taxon)

#Join annotations onto DESeq2 results
res_annot <- df %>%
  left_join(tax, by = "FeatureID") %>%
  relocate(FeatureID, BestName, Taxon)

head(res_annot)
write.table(res_annot, file="DESeq_Results.txt", quote=FALSE, sep = "\t")
