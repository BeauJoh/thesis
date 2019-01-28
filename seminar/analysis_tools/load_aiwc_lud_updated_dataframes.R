
#to be run from the paper level of the project "finding-hidden-dwarfs-in-kernels/paper"
## @knitr load_data

sizes <- c('tiny','small','medium')#,'large')

if (!exists("featdata.lud")){
    featdata.lud <- data.frame()
    for(size in sizes){
        path <- paste("../data/lud_with_load_imbalance/lud_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "lud"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.lud <- rbind(featdata.lud,x)
            print(paste("loaded file:",file))
        }
    }
}

#large is reconstituted
#Note: due to camera-ready submission deadlines the LUD large data for the kiviat data need to be rerun -- however this is the largest applications and requires the many iterations and days to complete.
#As such, the last full results from ../feat_data/lud_large were used and supplemented with the "min instructions executed by a work-item", "max instructions executed by a work-item" and "median instructions executed by a work-item" which don't change for this application in any of the 3 kernels between invocation / iteration.

#starting with diagonal kernels
ludlarge <- data.frame()

y <- read.csv('../data/lud_with_load_imbalance/lud_large/aiwc_lud_diagonal_0.csv')
y <- subset(y, metric=="min instructions executed by a work-item"|metric=="max instructions executed by a work-item"|metric=="median instructions executed by a work-item")

path <- paste("../data/feat_data/lud_large/",sep='')
files <- list.files(path)
files <- files[grep('*.csv',files)]
for (file in files){
    file_path <- paste(path,file,sep='')
    kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
    if (kernel_name != "lud_diagonal") next
    invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
    x <- read.csv(file_path)
    x <- rbind(x,y)
    x$application <- "lud"
    x$kernel <- kernel_name
    x$invocation <- invocation_count
    x$size <- 'large'
    ludlarge <- rbind(ludlarge,x)
    print(paste("loaded file:",file))
}

featdata.lud <- rbind(featdata.lud,ludlarge)

# then the perimeter kernels
ludlarge <- data.frame()

y <- read.csv('../data/lud_with_load_imbalance/lud_large/aiwc_lud_perimeter_0.csv')
y <- subset(y, metric=="min instructions executed by a work-item"|metric=="max instructions executed by a work-item"|metric=="median instructions executed by a work-item")

path <- paste("../data/feat_data/lud_large/",sep='')
files <- list.files(path)
files <- files[grep('*.csv',files)]
for (file in files){
    file_path <- paste(path,file,sep='')
    kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
    if (kernel_name != "lud_perimeter") next
    invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
    x <- read.csv(file_path)
    x <- rbind(x,y)
    x$application <- "lud"
    x$kernel <- kernel_name
    x$invocation <- invocation_count
    x$size <- 'large'
    ludlarge <- rbind(ludlarge,x)
    print(paste("loaded file:",file))
}

featdata.lud <- rbind(featdata.lud,ludlarge)

# finally the internal kernels
ludlarge <- data.frame()

y <- read.csv('../data/lud_with_load_imbalance/lud_large/aiwc_lud_internal_0.csv')
y <- subset(y, metric=="min instructions executed by a work-item"|metric=="max instructions executed by a work-item"|metric=="median instructions executed by a work-item")

path <- paste("../data/feat_data/lud_large/",sep='')
files <- list.files(path)
files <- files[grep('*.csv',files)]
for (file in files){
    file_path <- paste(path,file,sep='')
    kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
    if (kernel_name != "lud_internal") next
    invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
    x <- read.csv(file_path)
    x <- rbind(x,y)
    x$application <- "lud"
    x$kernel <- kernel_name
    x$invocation <- invocation_count
    x$size <- 'large'
    ludlarge <- rbind(ludlarge,x)
    print(paste("loaded file:",file))
}

featdata.lud <- rbind(featdata.lud,ludlarge)
