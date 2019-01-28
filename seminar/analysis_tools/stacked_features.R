
#load('../data/intermediate/full_dat.Rda')
load('../analysis_tools/newfeat.Rdf')

source('../analysis_tools/restructure_aiwc_data.R')
featdata.all <- drop_metrics_for_simple_kiviat(featdata.all)
#rename 2 kernels
featdata.all$kernel[featdata.all$kernel=='kernel1'] <- 'bfs_kernel1'
featdata.all$kernel[featdata.all$kernel=='kernel2'] <- 'bfs_kernel2'
full_dat <- reorder_features(featdata.all)

library(cowplot)
library(ggplot2)
library(viridis)

#min-max normalization
normalize <- function(x) {
    return ((x - min(x)) / (max(x) - min(x)))
}

#full_dat$granularity <- normalize(full_dat$granularity)

#full_dat$opcode <- normalize(full_dat$opcode)
#full_dat$barriers_per_instruction <- normalize(full_dat$barriers_per_instruction)
#full_dat$global_memory_address_entropy <- normalize(full_dat$global_memory_address_entropy)
##full_dat$branch_entropy_yokota <- normalize(full_dat$branch_entropy_yokota)
#full_dat$branch_entropy_average_linear <- normalize(full_dat$branch_entropy_average_linear)

#group.colours <- c(rgb(100, 149, 237, 127, maxColorValue=255),#compute category (cornflowerblue)
#                   rgb(173, 255,  47, 127, maxColorValue=255),#parallelism (greenyellow)
#                   rgb(255, 228, 196, 255, maxColorValue=255),#memory (bisque)
#                   rgb(191,  62, 255, 127, maxColorValue=255))#branch (darkorchid1)

y <- data.frame()

for(j in unique(full_dat$kernel)){
    for(i in unique(full_dat$size)){
        x <- subset(full_dat, kernel == j & size == i)
        if(nrow(x) == 0){
            next
        }

        y <- rbind(y,
                   data.frame('kernel'=j,
                              'size'=i,
#                              'metric'='Branch Entropy (Yokota)',
#                              'value'=unique(x$branch_entropy_yokota)))
                              'metric'='Branch Entropy (Linear Average)',
                              'value'=median(x$branch_entropy_average_linear)),
                   data.frame('kernel'=j,
                              'size'=i,
                              'metric'='Opcode',
                              'value'=median(x$opcode)),
                   data.frame('kernel'=j,
                              'size'=i,
                              'metric'='Barriers Per Instruction',
                              'value'=median(x$barriers_per_instruction)),
                   data.frame('kernel'=j,
                              'size'=i,
                              'metric'='Global Memory Address Entropy',
                              'value'=median(x$global_memory_address_entropy)))

#        y <- rbind(y, 
#                   data.frame('kernel'=j,
#                              'size'=i,
#                              'opcode'=unique(x$opcode),
#                              'barriers_per_instruction'=unique(x$barriers_per_instruction),
#                              'global_memory_address_entropy'=unique(x$global_memory_address_entropy),
#                              'branch_entropy_yokota'=unique(x$branch_entropy_yokota)))
    }
}

for(s in c('tiny','small','medium','large')){
    z <- subset(y,size==s)

    pdf(paste('../figures/stacked_',s,'.pdf',sep=''))
    p <- ggplot(z, aes(x = kernel, y = value, fill=metric)) +
        geom_histogram(stat = 'identity', binwidth = 1) +
        facet_grid(metric ~ ., margins = FALSE, scales="free") +
        scale_fill_viridis(discrete=TRUE) +
        labs(x="Kernel",y="Count",fill="Metric") +
        #theme_minimal() +
        annotate("segment", x=-Inf, xend=Inf, y=0, yend=0)+
        coord_cartesian() +
        theme(strip.placement='outside',
              strip.background=element_blank(),
              strip.text.y=element_blank(),
              axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
              axis.text.y = element_text(size = 8),
              axis.title.x = element_text(size=10),
              axis.title.y = element_text(size=10),
              legend.position = "none")

    if(s == 'tiny')
        p <- p + scale_x_discrete(position = 'top') + theme(axis.text.x = element_text(angle = 45, hjust = 0, vjust=0, size = 6))
    if(s == 'small')
        p <- p + scale_y_continuous(position = 'right') + scale_x_discrete(position = 'top') + theme(axis.text.x = element_text(angle = 45, hjust = 0, vjust=0, size = 6))
    if(s == 'medium')
        p <- p + scale_y_continuous(position = 'left') + scale_x_discrete(position = 'bottom')
    if(s == 'large')
        p <- p + scale_y_continuous(position = 'right') + scale_x_discrete(position = 'bottom')

    print(p)
    dev.off()
    #and save p for safe keeping -- maybe for some later cowplot
    assign(paste('stacked_',s,sep=''),p)

}

##This has been moved to the grinding paper
#legend_generic <- get_legend(stacked_tiny + theme(legend.title=element_text(face="bold",size=10),
#                                                  legend.text=element_text(size=10),
#                                                  legend.position="bottom",
#                                                  legend.justification="right",
#                                                  legend.direction="horizontal"))
#plots <- align_plots(stacked_tiny  ,
#                     stacked_small ,
#                     stacked_medium,
#                     stacked_large)
#                     #align="hv",axis="tblr")
#
#xoff <- .22 # relative x position of label, within one plot
#yoff <- .98 # relative y position of label, within one plot
#
#x <- plot_grid(plot_grid(plots[[1]],plots[[2]],ncol=2,align="h")+draw_plot_label(label=c("Tiny",  "Small"),
#                                                                                 x=(xoff+0:1)/2,
#                                                                                 y=rep(1-(1-yoff),2),
#                                                                                 hjust=.5, vjust=.5,
#                                                                                 size=15),
#               plot_grid(plots[[3]],plots[[4]],ncol=2,align="h")+draw_plot_label(label=c("       Medium",  "Large"),
#                                                                                 x=(xoff+0:1)/2,
#                                                                                 y=rep(1-(1-yoff),2),
#                                                                                 hjust=.5, vjust=.5,
#                                                                                 size=15),
#               legend_generic,
#               rel_heights=c(1,1,.05),
#               nrow=3)

