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
csv_files <- c('csv_lists/TOP500_201306.csv',
               'csv_lists/TOP500_201406.csv',
               'csv_lists/TOP500_201506.csv',
               'csv_lists/TOP500_201606.csv',
               'csv_lists/TOP500_201706.csv',
               'csv_lists/TOP500_201806.csv')

# find common columns between all datasets
common_cols <- colnames(read.csv(csv_files[1]))
for (i in range(2,length(csv_files))){
    common_cols <- intersect(colnames(read.csv(csv_files[i])),common_cols)
}

# load in lists and join by only the shared columns
publication_year <- 2013
top500 <- data.frame(subset(read.csv(csv_files[1]),select = common_cols),publication.year=publication_year)
for (i in seq(2,length(csv_files))){
    publication_year <- publication_year+1
    top500 <- rbind(top500,data.frame(subset(read.csv(csv_files[i]),select = common_cols),publication.year=publication_year))
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
green500 <- data.frame(subset(read.csv(csv_files[1]),select = common_cols),publication.year=publication_year)
for (i in seq(2,length(csv_files))){
    publication_year <- publication_year+1
    green500 <- rbind(green500,data.frame(subset(read.csv(csv_files[i]),select = common_cols),publication.year=publication_year))
}

# Plot the top 10 -- of the Top500
top10 <- top500[which(top500$Rank < 11),]

library('ggplot2')
library('latex2exp')

# how many of the top 500 contain accelerators -- broken down to per year?
z = data.frame()
for (y in unique(top500$publication.year)){
    z <- rbind(z,data.frame(year=y,metric="total_accelerators_in_the_top_500",value=nrow(subset(top500,Accelerator.Co.Processor != 'None'& publication.year==y))))
}

p <- ggplot(z,aes(x=year,y=value)) + geom_line() + labs(title="Accelerator use in the Top500",x="publication year",y="number of nodes with accelerators") + expand_limits(y = 0)
pdf("top500_number_of_nodes_with_accelerators.pdf",width=11.7,height=8.3)
print(p)
dev.off()

# TODO: plot top500 cores vs accelerator cores

# The way power is presented changed in the TOP500 in 2017 from Mflops.Watt to Power efficiency
csv_files <- c('csv_lists/TOP500_201306.csv',
               'csv_lists/TOP500_201406.csv',
               'csv_lists/TOP500_201506.csv',
               'csv_lists/TOP500_201606.csv')

# find common columns between all datasets
common_cols <- colnames(read.csv(csv_files[1]))
for (i in seq(2,length(csv_files))){
    common_cols <- intersect(colnames(read.csv(csv_files[i])),common_cols)
}

# load in lists and join by only the shared columns
publication_year <- 2013
emeasure <- data.frame(subset(read.csv(csv_files[1]),select = common_cols),publication.year=publication_year)
for (i in seq(2,length(csv_files))){
    publication_year <- publication_year+1
    emeasure <- rbind(emeasure,data.frame(subset(read.csv(csv_files[i]),select = common_cols),publication.year=publication_year))
}
#emeasure <- data.frame(read.csv('./csv_lists/TOP500_201306.csv'),publication.year=2013)
#emeasure <- rbind(emeasure,data.frame(read.csv('./csv_lists/TOP500_201406.csv'),publication.year=2014))
#emeasure <- rbind(emeasure,data.frame(read.csv('./csv_lists/TOP500_201506.csv'),publication.year=2015))
#emeasure <- rbind(emeasure,data.frame(read.csv('./csv_lists/TOP500_201606.csv'),publication.year=2016))

# TODO: top10 Rpeak [TFlop/s] / Power (kW) -- Power efficiency GFlops/Watts
# TODO: top10 sorted by accelerator type Rpeak [TFlop/s] / Power (kW) -- Power efficiency GFlops/Watts
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
    q <- subset(top500,Accelerator.Co.Processor != 'None'& publication.year==y)
    z <- rbind(z,data.frame(year=y,metric="total_accelerators_in_the_top_500",value=nrow(q)))
}
top500_accelerator_use <- z
p <- ggplot(top500_accelerator_use,aes(x=year,y=value)) + geom_line() + expand_limits(y = 0) + labs(x="publication year",y="# of supercomputers using accelerators")#title="Accelerator use in the Top500",
pdf("top500_number_of_supercomputers_with_accelerators.pdf",width=11.7,height=8.3)
print(p)
dev.off()

# NOTE: % of supercomputers with accelerators
p <- ggplot(top500_accelerator_use,aes(x=year,y=(value/500)*100)) + geom_line() + expand_limits(y = 0) + labs(x="publication year",y="(%) of supercomputers using accelerators")#title="Accelerator use in the Top500",
pdf("top500_percentage_of_supercomputers_with_accelerators.pdf",width=11.7,height=8.3)
print(p)
dev.off()

z = data.frame()
for (y in unique(top500$publication.year)){
    q <- subset(top500,Accelerator.Co.Processor != 'None'& publication.year==y & Rank < 11)
    z <- rbind(z,data.frame(year=y,metric="total_accelerators_in_the_top_10",value=nrow(q)))
}
top10_accelerator_use <- z

p <- ggplot(top10_accelerator_use,aes(x=year,y=(value/10)*100)) + geom_line() + expand_limits(y = 0) + labs(x="publication year",y="(%) of supercomputers in the using accelerators")#title="Accelerator use in the Top10 of the Top500",
pdf("top10_percentage_of_supercomputers_with_accelerators.pdf",width=11.7,height=8.3)
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



