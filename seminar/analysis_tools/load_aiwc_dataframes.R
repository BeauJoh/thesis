
#to be run from the paper level of the project "finding-hidden-dwarfs-in-kernels/paper"
## @knitr load_data

sizes <- c('tiny','small','medium','large')

if (!exists("featdata.csr")){
    featdata.csr <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/csr_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "csr"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.csr <- rbind(featdata.csr,x)
            #print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.fft")){
    featdata.fft <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/fft_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "fft"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.fft <- rbind(featdata.fft,x)
            #print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.gem")){
    featdata.gem <- data.frame()
    #app crashes at medium and large
    sizes <- c("tiny","small")
    for(size in sizes){
        path <- paste("../data/feat_data/gem_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "gem"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.gem <- rbind(featdata.gem,x)
            #print(paste("loaded file:",file))
        }
    }
    sizes <- c('tiny','small','medium','large')
}

if (!exists("featdata.kmeans")){
    featdata.kmeans <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/kmeans_",size,"/",sep='')
        files <- list.files(path)
        files <- files[grep('*.csv',files)]
        for (file in files){
            file_path <- paste(path,file,sep='')
            kernel_name <- gsub('aiwc_(.*)_(.*).csv','\\1',file)
            invocation_count <-  gsub('aiwc_(.*)_(.*).csv','\\2',file)
            x <- read.csv(file_path)
            x$application <- "kmeans"
            x$kernel <- kernel_name
            x$invocation <- invocation_count
            x$size <- size
            featdata.kmeans <- rbind(featdata.kmeans,x)
            #print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.lud")){
    featdata.lud <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/lud_",size,"/",sep='')
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
            #print(paste("loaded file:",file))
        }
    }
}

if (!exists("featdata.dwt")){
    featdata.dwt <- data.frame()
    for(size in sizes){
        path <- paste("../data/feat_data/dwt_",size,"/",sep='')
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
            featdata.dwt <- rbind(featdata.dwt,x)
            #print(paste("loaded file:",file))
        }
    }
}

#still to load -- alas they currently crash for small collections

#srad
#crc

if (!exists("featdata.all")){
    featdata.all <- rbind(featdata.kmeans,featdata.lud)
    featdata.all <- rbind(featdata.all,featdata.csr)
    featdata.all <- rbind(featdata.all,featdata.fft)
    featdata.all <- rbind(featdata.all,featdata.gem)
    featdata.all <- rbind(featdata.all,featdata.dwt)
}

