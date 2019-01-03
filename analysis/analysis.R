# dependencies:
#sudo Rscript -e "install.packages('devtools',repos = 'http://cran.us.r-project.org');"
#sudo Rscript -e "devtools::install_github('stefano-meschiari/latex2exp')"
#sudo Rscript -e "devtools::install_github('tidyverse/ggplot2')"

## with manual data entry
#x = read.csv('~/Documents/2018/thesis/analysis/top500-june2018.csv')
#mean((x$rmax_TFlop_s)/x$power_Kw,na.rm=TRUE)
#y = read.csv('~/Documents/2018/thesis/analysis/top500-june2017.csv')
#mean((y$rmax_TFlop_s)/y$power_Kw)
##TODO: add June 2016
#z = read.csv('~/Documents/2018/thesis/analysis/top500-june2016.csv')
#mean((z$rmax_TFlop_s)/z$power_Kw)

# Load Top500
# by examining the full excel data
csv_files <- c('csv_lists/TOP500_201206.csv',
               'csv_lists/TOP500_201306.csv',
               'csv_lists/TOP500_201406.csv',
               'csv_lists/TOP500_201506.csv',
               'csv_lists/TOP500_201606.csv',
               'csv_lists/TOP500_201706.csv',
               'csv_lists/TOP500_201806.csv')

# find common columns between all datasets
common_cols <- colnames(read.csv(csv_files[1]))
for (i in range(2,length(csv_files))){
    common_cols <- intersect(colnames(read.csv(csv_files[i],stringsAsFactors = FALSE)),common_cols)
}

# load in lists and join by only the shared columns
publication_year <- 2012
top500 <- data.frame(subset(read.csv(csv_files[1],stringsAsFactors=FALSE),select = common_cols),publication.year=publication_year)
for (i in seq(2,length(csv_files))){
    publication_year <- publication_year+1
    top500 <- rbind(top500,data.frame(subset(read.csv(csv_files[i],stringsAsFactors=FALSE),select = common_cols),publication.year=publication_year))
}

# Load Green500
# by examining the full excel data
csv_files <- c('csv_lists/green500_top_201306.csv',
               'csv_lists/green500_top_201406.csv',
               'csv_lists/green500_top_201506.csv',
               'csv_lists/green500_top_201606.csv',
               'csv_lists/green500_top_201706.csv',
               'csv_lists/green500_top_201806.csv')

# find common columns between all datasets
common_cols <- colnames(read.csv(csv_files[1]))
for (i in seq(2,length(csv_files))){
    common_cols <- intersect(colnames(read.csv(csv_files[i])),common_cols)
}

# load in lists and join by only the shared columns
publication_year <- 2013
green500 <- data.frame(subset(read.csv(csv_files[1],stringsAsFactors=FALSE),select = common_cols),publication.year=publication_year)
for (i in seq(2,length(csv_files))){
    publication_year <- publication_year+1
    green500 <- rbind(green500,data.frame(subset(read.csv(csv_files[i]),select = common_cols),publication.year=publication_year))
}

top500 <- within(top500, Accelerator.Co.Processor[Name == 'Sunway TaihuLight'] <- 'SW26010')

# Plot the top 10 -- of the Top500
top10 <- top500[which(top500$Rank < 11),]

library('ggplot2')
library('latex2exp')
library('viridis')

# how many of the top 500 contain accelerators -- broken down to per year?
z = data.frame()
for (y in unique(top500$publication.year)){
    z <- rbind(z,data.frame(year=y,metric="total_accelerators_in_the_top_500",value=nrow(subset(top500,Accelerator.Co.Processor != 'None'& publication.year==y))))
}

p <- ggplot(z,aes(x=year,y=value,colour=metric)) + geom_line() + labs(title="Accelerator use in the Top500",x="publication year",y="number of nodes with accelerators") + expand_limits(y = 0)
pdf("top500_number_of_nodes_with_accelerators.pdf",width=11.7,height=8.3)
print(p)
dev.off()

# TODO: plot top500 cores vs accelerator cores

# The way power is presented changed in the TOP500 in 2017 from Mflops.Watt to Power efficiency
csv_files <- c('csv_lists/TOP500_201206.csv',
               'csv_lists/TOP500_201306.csv',
               'csv_lists/TOP500_201406.csv',
               'csv_lists/TOP500_201506.csv',
               'csv_lists/TOP500_201606.csv')

# find common columns between all datasets
common_cols <- colnames(read.csv(csv_files[1],stringsAsFactors=FALSE))
for (i in seq(1,length(csv_files))){
    common_cols <- intersect(colnames(read.csv(csv_files[i],stringsAsFactors = FALSE)),common_cols)
}

# load in lists and join by only the shared columns
publication_year <- 2012
emeasure <- data.frame(subset(read.csv(csv_files[1],stringsAsFactors = FALSE),select = common_cols),publication.year=publication_year)
for (i in seq(2,length(csv_files))){
    publication_year <- publication_year+1
    emeasure <- rbind(emeasure,data.frame(subset(read.csv(csv_files[i],stringsAsFactors = FALSE),select = common_cols),publication.year=publication_year))
}

emeasure$Gflops.Watt <-  emeasure$Mflops.Watt/1000

tmp <- read.csv('csv_lists/TOP500_201706.csv',stringsAsFactors = FALSE)
tmp$Gflops.Watt <- tmp$Power.Effeciency..GFlops.Watts.
tmp$publication.year <- 2017
new_common_cols <- intersect(colnames(tmp),colnames(emeasure))
emeasure <- subset(emeasure, select = colnames(emeasure) %in% new_common_cols)
tmp <- subset(tmp, select = colnames(tmp) %in% new_common_cols)
emeasure <- rbind(emeasure,tmp)

tmp <- read.csv('csv_lists/TOP500_201806.csv',stringsAsFactors = FALSE)
tmp$Gflops.Watt <- tmp$Power.Effeciency..GFlops.Watts.
tmp$publication.year <- 2018
new_common_cols <- intersect(colnames(tmp),colnames(emeasure))
tmp <- subset(tmp, select = colnames(tmp) %in% new_common_cols)
emeasure <- rbind(emeasure,tmp)

z = data.frame()
for (y in unique(emeasure$publication.year)){
    q <- subset(emeasure,Accelerator.Co.Processor != 'None' & Accelerator.Co.Processor.Cores != 0 & publication.year==y)
    q$Gflops.Watt[q$Gflops.Watt==0.0] <- NA
    z <- rbind(z,data.frame(year=y,metric="mean_GFlops_per_Watt_of_accelerators_in_the_top_500",value=mean(na.exclude(q$Gflops.Watt))))
    q <- subset(emeasure,(Accelerator.Co.Processor == 'None' | Accelerator.Co.Processor.Cores == 0) & publication.year==y)
    q$Gflops.Watt[q$Gflops.Watt==0.0] <- NA
    z <- rbind(z,data.frame(year=y,metric="mean_GFlops_per_Watt_without_accelerators_in_the_top_500",value=mean(na.exclude(q$Gflops.Watt))))
}

energy_df <- z

p <- ggplot(energy_df,aes(x=year,y=value,colour=metric)) + geom_line() + expand_limits(y = 0) + labs(x="Publication Year (TOP500 June issue)",y=TeX("Power Efficiency $\\left[$mean$\\left(\\frac{$GFlops$}{$Watt$}\\right)\\right]$"),colour="Metric") + scale_color_viridis(discrete=TRUE,labels=c("supercomputers with accelerators",'supercomputers without accelerators')) #scale_colour_manual(labels=c("Machines using Accelerators in the TOP500",TeX("mean($\\frac{Accelerator Cores}{Total Cores}$)")),values=c("blue","red"))#title="Accelerator use in the Top500",
pdf("top500_GFlops_per_Watt_of_supercomputers_with_and_without_accelerators.pdf",width=11.7,height=8.3)
print(p)
dev.off()



#emeasure <- data.frame(read.csv('./csv_lists/TOP500_201306.csv'),publication.year=2013)
#emeasure <- rbind(emeasure,data.frame(read.csv('./csv_lists/TOP500_201406.csv'),publication.year=2014))
#emeasure <- rbind(emeasure,data.frame(read.csv('./csv_lists/TOP500_201506.csv'),publication.year=2015))
#emeasure <- rbind(emeasure,data.frame(read.csv('./csv_lists/TOP500_201606.csv'),publication.year=2016))

# TODO: top10 Rpeak [TFlop/s] / Power (kW) -- Power efficiency GFlops/Watts
# TODO: top10 sorted by accelerator type Rpeak [TFlop/s] / Power (kW) -- Power efficiency GFlops/Watt

# TODO: Conventional core MFLOPs/accelerator MFLOPS

# TODO: accelerator core count vs conventional core count
# TODO: accelerator core count over time

top500_accelerated <- subset(top500,Accelerator.Co.Processor != 'None')
top500_accelerated$ratio <- (top500_accelerated$Accelerator.Co.Processor.Cores/top500_accelerated$Total.Cores)
top500_accelerated$ratio[!is.finite(top500_accelerated$ratio)] <- 0
#remove outliers in the data
#which.max(top500_accelerated$ratio)
top500_accelerated = top500_accelerated[-c(283),]

p <- ggplot(top500_accelerated,aes(x=publication.year,y=ratio,group=publication.year)) + geom_boxplot() + expand_limits(y = 0) + 
    labs(x="publication year",y="Proportion of (Accelerator Cores / Total Cores) to examine supercomputer reliance on accelerators")#title="Accelerator use in the Top500",

pdf("top500_ratio_of_cpu_vs_accelerator_cores.pdf",width=11.7,height=8.3)
print(p)
dev.off()

# NOTE: # of supercomputers with accelerators
z = data.frame()
for (y in unique(top500$publication.year)){
    q <- subset(top500,Accelerator.Co.Processor != 'None' & Accelerator.Co.Processor.Cores != 0 & publication.year==y)
    z <- rbind(z,data.frame(year=y,metric="total_accelerators_in_the_top_500",value=nrow(q)/500))
    x <- (sum(na.exclude(q$Accelerator.Co.Processor.Cores))/sum(na.exclude(q$Total.Cores)))
    x[x==0.0] <- NA
    z <- rbind(z,data.frame(year=y,metric="mean_fraction_of_cores_belonging_to_accelerators_in_the_top_500",value=mean(na.exclude(x))))
}

top500_accelerator_use <- subset(z, metric == "total_accelerators_in_the_top_500")
p <- ggplot(top500_accelerator_use,aes(x=year,y=value)) + geom_line() + expand_limits(y = 0) + labs(x="publication year",y="# of supercomputers using accelerators")#title="Accelerator use in the Top500",
pdf("top500_number_of_supercomputers_with_accelerators.pdf",width=11.7,height=8.3)
print(p)
dev.off()

nz = data.frame()
for (y in unique(top500$publication.year)){
    q <- subset(top500,Accelerator.Co.Processor != 'None'& publication.year==y & Rank < 11)
    nz <- rbind(nz,data.frame(year=y,metric="total_accelerators_in_the_top_10",value=nrow(q)))
}
top10_accelerator_use <- nz

p <- ggplot(top10_accelerator_use,aes(x=year,y=(value/10)*100)) + geom_line() + expand_limits(y = 0) + labs(x="publication year",y="(%) of supercomputers in the using accelerators")#title="Accelerator use in the Top10 of the Top500",
pdf("top10_percentage_of_supercomputers_with_accelerators.pdf",width=11.7,height=8.3)
print(p)
dev.off()

# NOTE: % of supercomputers with accelerators
top500_accelerator_use <- z
p <- ggplot(z,aes(x=year,y=value*100,colour=metric)) + geom_line() + expand_limits(y = 0) + labs(x="Publication Year (TOP500 June issue)",y="Percentage of system (%)",colour="Metric") + scale_color_discrete(labels=c("using accelerators in the TOP500",lapply(sprintf('dedicated to accelerator $\\left(\\frac{\\sum$Accelerator Cores$}{\\sum$Total Cores$}\\right)$'), TeX)))  #scale_colour_manual(labels=c("Machines using Accelerators in the TOP500",TeX("mean($\\frac{Accelerator Cores}{Total Cores}$)")),values=c("blue","red"))#title="Accelerator use in the Top500",
pdf("top500_percentage_of_supercomputers_with_accelerators.pdf",width=11.7,height=8.3)
print(p)
dev.off()

#new superfigure adds the line from the top10 accelerator use into the top500 accelerator use plot -- and replaces that plot
top10_accelerator_use$value <- top10_accelerator_use$value/10
z <- rbind(top500_accelerator_use,top10_accelerator_use)
top500_accelerator_use <- z
p <- ggplot(z,aes(x=year,y=value*100,colour=metric)) + geom_line() + expand_limits(y = 0) + labs(x="Publication Year (TOP500 June issue)",y="Percentage of system (%)",colour="Metric") + scale_color_viridis(discrete=TRUE,labels=c("using accelerators in the TOP500",lapply(sprintf('dedicated to accelerator $\\left(\\frac{\\sum$Accelerator Cores$}{\\sum$Total Cores$}\\right)$'), TeX),"using accelerators in the top 10 of the TOP500"))  #scale_colour_manual(labels=c("Machines using Accelerators in the TOP500",TeX("mean($\\frac{Accelerator Cores}{Total Cores}$)")),values=c("blue","red"))#title="Accelerator use in the Top500",
pdf("top500_percentage_of_supercomputers_with_accelerators.pdf",width=11.7,height=8.3)
print(p)
dev.off()

## how many of the green 500 contain accelerators -- broken down to per year?
#z = data.frame()
#for (y in unique(green500$publication.year)){
#    z <- rbind(z,data.frame(year=y,metric="total_accelerators_in_the_green_500",value=nrow(subset(green500,Accelerator.Co.Processor != 'None'& publication.year==y))))
#}
#
#p <- ggplot(z,aes(x=year,y=value)) + geom_line() + labs(title="Accelerator use in the Green500",x="publication year",y="number of nodes with accelerators")
#pdf("green500_number_of_nodes_with_accelerators.pdf",width=11.7,height=8.3)
#print(p)
#dev.off()



