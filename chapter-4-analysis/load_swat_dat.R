
source('../chapter-3-analysis/utils.R')
source('../chapter-3-analysis/stats.R')
source('../chapter-3-analysis/aes.R')
source('../chapter-3-analysis/functions.R')

devices <- c('xeon_es-2697v2','i7-6700k','titanx','gtx1080','gtx1080ti','k20c','k40c','firepro-s9150','tahiti-hd7970','hawaii-r9-295x2','knl')
dev_name<- c('E5-2697','i7-6700K','Titan X','GTX 1080','GTX 1080 Ti',"K20m","K40m",'FirePro S9150','HD 7970','R9 295x2','Xeon Phi 7210')
dev_type<- c('CPU','CPU','Consumer GPU','Consumer GPU','Consumer GPU','HPC GPU','HPC GPU','HPC GPU','Consumer GPU','Consumer GPU','MIC')
sizes <- c('small')
data.swat <- data.frame()
columns <- c('region','repeats_to_two_seconds','id','time','overhead')

index <- 1
for(device in devices){
    for(size in sizes){
        path = paste("./data/",device,"_swat_",size,"_time.0/",sep='')
        print(paste("loading:",path))
        x <- ReadAllFilesInDir.AggregateWithRunIndex(dir.path=path,col=columns)
        x$device <- device
        x$size <- size
        x$dev_name <- dev_name[index]
        x$dev_type <- dev_type[index]
        data.swat <- rbind(data.swat, x)
    }
    index <- index + 1
}

SumPerRunReduction <- function(x){
    z <- data.frame()
    for (y in unique(x$run)){
        m <- x[x$run == y,]
        #averaged by the number of iterations used to fill the 2 second interval
        #print(paste('device = ',unique(x$device),'time (us) = ',sum(m$time)/(max(m$repeats_to_two_seconds)+1)))
        z <- rbind(z,data.frame('time'=sum(m$time)/(max(m$repeats_to_two_seconds)+1),'run'=y))
    }
    return(z)
}

data.procswat <- data.frame()

for(device in devices){
    for(size in sizes){
        x <- data.swat[(data.swat$region=="hTraceBackKernel" | data.swat$region=="hMatchStringKernel_kernel") & data.swat$device == device & data.swat$size == size,]
        y <- x
        x <- SumPerRunReduction(x)
        data.procswat <- rbind(data.procswat,data.frame('application'='sw',
                                                        'device'=unique(y$dev_name),
                                                        'accelerator_type'=unique(y$dev_type),
                                                        'size'=size,
                                                        'time'=x$time,
                                                        'run'=x$run))
    }
}

save(data.procswat,file='./swatdata.all.Rda')

