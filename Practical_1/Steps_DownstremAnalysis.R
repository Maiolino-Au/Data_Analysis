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
plotbar(phy, level="Genus", top = 20)
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
