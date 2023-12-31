
#Background colour support was added to my version of fmsb as such it doesn't exist on CRAN and must be built from source on the command line:
#git clone https://github.com/BeauJoh/fmsb
#R CMD INSTALL fmsb
library(fmsb)

#x <- reorder_and_subset(featdata.kmeans,size="tiny",kernel="kmeansPoint")
#x <- data.frame(t(colMeans(x)))
#plot_kiviat_with_legend(x,featdata_labels)

get_magnitude_of_number_to_normalise <- function(z){
    i <- 1
    n <- 0
    while(z/i > 10){
        i <- i * 10
        n = n+1
    }
    return(n)
}

plot_kiviat_with_legend <- function(x,labels){
    colnames(x) <- labels
    x_min <- rep(0,length(x))
    x_max <- rep(12,length(x))
    #arbitary scaling of total memory footprint and 90% memory footprint
    n <- get_magnitude_of_number_to_normalise(x[2])
    x[3] <- x[3]/(10**n)
    x[4] <- x[4]/(10**n)

    colnames(x)[3] <- paste("Total Memory Footprint (E+",n,")",sep='')
    colnames(x)[4] <- paste("90% Memory Footprint (E+",n,")",sep='')

    colnames(x)[16] <- "90% Branch Instructions"
    legend_names <- colnames(x)

    colnames(x) <- chartr("123456789", "ABCDEFGHI", seq(1,length(x)))

    x_rad <- rbind(x_min,x_max,x)
    radarchart(x_rad)
    i <- 1
    while (i <= length(x)){
        legend_names[i] <- paste(chartr("123456789", "ABCDEFGHI", i),':',legend_names[i])
        i <- i+1
    }

    legend(1.3,1,legend=legend_names)
}

plot_kiviat_with_numerical_legend <- function(x,labels){
    colnames(x) <- labels
    x_min <- rep(0,length(x))
    x_max <- rep(12,length(x))
    #arbitary scaling of total memory footprint and 90% memory footprint
    n <- get_magnitude_of_number_to_normalise(x$"Total Memory Footprint")
    x$"Workitems" <- x$"Workitems"/(10**n)
    x$"Total Memory Footprint" <- x$"Total Memory Footprint"/(10**n)
    x$"90\\% Memory Footprint" <- x$"90\\% Memory Footprint"/(10**n)

    colnames(x)[2] <- paste("Workitems\n(e",n,")",sep='')
    colnames(x)[3] <- paste("Total Memory Footprint (e",n,")",sep='')
    colnames(x)[4] <- paste("90% Memory Footprint (e",n,")",sep='')

    colnames(x)[16] <- "90% Branch Instructions"
    legend_names <- colnames(x)

    colnames(x) <- seq(1,length(x))

    x_rad <- rbind(x_min,x_max,x)
    radarchart(x_rad)
    i <- 1
    while (i <= length(x)){
        legend_names[i] <- paste(i,':',legend_names[i])
        i <- i+1
    }

    legend(-1,1,legend=legend_names)
}

plot_kiviat_with_labels_old <- function(x,labels,n,m,colour){

    #arbitary scaling of total memory footprint and 90% memory footprint
    #n <- get_magnitude_of_number_to_normalise(x[2])
    x[2] <- x[2]/(10**n)
    x[3] <- x[3]/(10**m)
    x[4] <- x[4]/(10**m)

    colnames(x) <- labels
    colnames(x)[2] <- paste("Workitems\n(E+",n,")",sep='')
    colnames(x)[3] <- paste("Total Memory\nFootprint (E+",m,")",sep='')
    colnames(x)[4] <- paste("90% Memory\nFootprint (E+",m,")",sep='')

    upper_bound <- round(max(x))+1
    x_min <- rep(0,length(x))
    x_max <- rep(upper_bound,length(x))
    ticks <- seq(0,upper_bound,by=upper_bound/4)#4 discrete segments

    x_rad <- rbind(x_max,x_min,x)

    radarchart(x_rad,axistype=1,
               vlcex=0.75, caxislabels=ticks, axislabcol="black",#axis ticks
               pcol=colour)#line colour
               #pfcol=colour,pdensity=30)#blob colour and fill line density
}

plot_kiviat_with_labels_normalize <- function(x,labels,nv,colour,colour_spokes,all_sizes){
    #x[1] <- x[1]/o
    #x[2] <- x[2]/n
    #x[3] <- x[3]/m
    #x[4] <- x[4]/m
    #for (i in seq(5,19)){
    #    x[i] <- x[i]/o
    #}
    if(all_sizes){
        normalize <- function(x) {
            if(max(x) - min(x) == 0){
                return(rep(1,length(x)))
            }
            return ((x - min(x)) / (max(x) - min(x)))
        }
        normalize <- function(x,nv) {
            if(max(nv) - min(nv) == 0){
                return(rep(1,length(nv)))
            }
            return ((x - min(nv)) / (max(nv) - min(nv)))
        }
        
        for (i in seq(1,ncol(x))){
            x[,i] <- normalize(x[,i],nv[,i])
        }

    }else{
        x <- x/nv
    }
    colnames(x) <- labels
    #colnames(x)[2] <- "Workitems"
    #colnames(x)[3] <- "Total Memory\nFootprint"
    #colnames(x)[4] <- "90% Memory\nFootprint"

    x_min <- rep(0.0,ncol(x))
    x_max <- rep(1.0,ncol(x))
    ticks <- seq(0,1,by=0.25)#4 discrete segments

    x_rad <- rbind(x_max,x_min,x)

    if(colour_spokes){
        #generate colour grouping
        background_colours <- c(rep(rgb(100, 149, 237, 127, maxColorValue=255), 1),#compute category (cornflowerblue)
                                rep(rgb(173, 255,  47, 127, maxColorValue=255), 4),#parallelism (greenyellow)
                                rep(rgb(255, 228, 196, 127, maxColorValue=255),13),#memory (bisque)
                                rep(rgb(191,  62, 255, 127, maxColorValue=255), 4))#branch (darkorchid1)
        background_density <- rep(45,26)

    }
    else{
        background_colours <- NULL
        background_density <- NULL
    }

    if(all_sizes){
        colour_border=c(rgb(0.2,0.5,0.5,0.9), rgb(0.8,0.2,0.5,0.9) , rgb(0.7,0.5,0.1,0.9),rgb(0.0,0.0,0.0,0.9))

        #remove margins and plot
        par(mar=c(0,0,0,0),mai=c(0,10,0,10),plt=c(0.0,1.0,0.0,1.0))
        radarchart(x_rad,axistype=1,
                   vlcex=.9, caxislabels=ticks, axislabcol="black",#axis ticks
                   pcol=colour_border,#line colour
                   cgfcol=background_colours, cgdensity=background_density)

        legend(x=0.97, y=1.3, legend = c('tiny','small','medium','large'), bty = "n", pch=20, col=colour_border, cex=1.1, pt.cex=1.5)

    }else{
    radarchart(x_rad,axistype=1,
               vlcex=0.60, caxislabels=ticks, axislabcol="black",#axis ticks
               pcol=colour,#line colour
               cgfcol=background_colours, cgdensity=background_density)
               #pfcol=colour,pdensity=30)#blob colour and fill line density
    }
}

plot_kiviat <- function(x,nv,colour_spokes=FALSE,colour="black",all_sizes=FALSE){
    labels <- c("Opcode\n",
                "Granularity",
                "Barriers Per Instruction",
                "Instructions Per Operand",
                "Load Imbalance",
                #"Workitems",
                #"Total Barriers Hit",
                #"Min ITB",
                #"Max ITB",
                #"Median ITB",
                #"Max\nSIMD Width",
                #"Mean\nSIMD Width",
                #"SD\nSIMD Width",
                "Total\nMemory\nFootprint",
                "90%\nMemory\nFootprint",
                "Global Memory\nAddress Entropy",
                "LMAE -- \nSkipped 1 LSBs",
                "LMAE -- \nSkipped\n2 LSBs",
                "LMAE -- \nSkipped 3 LSBs",
                "LMAE -- \nSkipped 4 LSBs",
                "LMAE -- \nSkipped 5\n LSBs",
                "LMAE -- \nSkipped 6\n LSBs",
                "LMAE -- \nSkipped 7 LSBs",
                "LMAE -- \nSkipped 8 LSBs",
                "LMAE -- \nSkipped 9\nLSBs",
                "LMAE -- \nSkipped\n10 LSBs",
                "Total Unique\nBranch\nInstructions",
                "90% Branch\nInstructions",
                "Branch Entropy\n(Yokota)",
                "Branch Entropy\n(Average Linear)")
    if (missing(nv)){
        n<-get_magnitude_of_number_to_normalise(x[2])
        m<-get_magnitude_of_number_to_normalise(x[3])
        plot_kiviat_with_labels_old(x,labels,n,m,colour)
    } else{
        plot_kiviat_with_labels_normalize(x,labels,nv,colour,colour_spokes,all_sizes)
    }
}

getMaxForNormalisation <- function(x){
    i_max <- c()
    for (i in unique(x$metric)){
        i_max <- c(i_max,max(subset(x,metric == i)$count,na.rm=TRUE))
    }
    return(i_max)
}

