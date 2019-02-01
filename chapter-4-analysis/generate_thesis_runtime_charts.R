"%!in%" <- Negate("%in%")
library(ggplot2)
library(cowplot)
library(plyr)
library(viridis)

#source("load_data.R")
load('../chapter-3-analysis/rundata.all.Rda')
rundata.all <- subset(rundata.all,select=-c(kernel_time,kernel))
data.all <- rundata.all
load('./swatdata.all.Rda')
names(data.procswat)[names(data.procswat) == 'time'] <- 'total_time'
data.procswat <- subset(data.procswat,select=-c(accelerator_type))
data.all <- rbind(data.all,data.procswat)

#rename devices
data.all$device <- revalue(data.all$device,
                           c("xeon_es-2697v2"="E5-2697",
                             "i7-6700k"="i7-6700K",
                             "i5-3350"="i5-3550",
                             "titanx"="Titan X",
                             "gtx1080"="GTX 1080",
                             "gtx1080ti"="GTX 1080 Ti",
                             "k20c"="K20m",
                             "k40c"="K40m",
                             "knl"="Xeon Phi 7210",
                             "fiji-furyx"="R9 Fury X",
                             "hawaii-r9-290x"="R9 290X",
                             "hawaii-r9-295x2"="R9 295x2",
                             "polaris-rx480"="RX 480",
                             "tahiti-hd7970"="HD 7970",
                             "firepro-s9150"="FirePro S9150"
                             ))
#reorder devices
data.all$device <- factor(data.all$device,levels=levels(data.all$device)[c(1,2,12,3,4,5,6,7,15,14,10,11,9,13,8)])

#attach accelerator type
device_index <- c("i7-6700K",
                  "E5-2697",
                  "i5-3550",
                  "Titan X",
                  "GTX 1080",
                  "GTX 1080 Ti",
                  "K20m",
                  "K40m",
                  "HD 7970",
                  "R9 290X",
                  "R9 295x2",
                  "FirePro S9150",
                  "R9 Fury X",
                  "RX 480",
                  "Xeon Phi 7210")
accelerator_type <- c("CPU",#"i7-6700K" #"Desktop CPU"
                      "CPU",#"E5-2697"   #"Server CPU"
                      "CPU",#"i5-3550"  #"Desktop CPU"
                      "Consumer GPU",#"Titan X"
                      "Consumer GPU",#"GTX 1080"
                      "Consumer GPU",#"GTX 1080 Ti"
                      "HPC GPU",#"K20m"
                      "HPC GPU",#"K40m"
                      "Consumer GPU",#"HD 7970"
                      "Consumer GPU",#"R9 290X"
                      "Consumer GPU",#"R9 295x2"
                      "HPC GPU",#"FirePro S9150"
                      "Consumer GPU",#"R9 Fury X"
                      "Consumer GPU",#"RX 480"
                      "MIC")#"Xeon Phi 7210"
data.all$accelerator_type <- accelerator_type[match(data.all$device,device_index)]
data.all$accelerator_type <- factor(data.all$accelerator_type,
                                    levels=c("CPU","Consumer GPU","HPC GPU","MIC"))

drop_phi = FALSE
#generates boxplots of relative execution times
print("generating boxplots...")
applications <- c("nw",
                  "sw",
                  "gem",
                  "kmeans",
                  "hmm")

sizes <- c('small')

#generate a plot for each application with all 4 sizes
i <- 0
indexs <- c('(a)','(b)','(c)','(d)','(e)')
for(a in applications){
    print(paste("saving ",a,"...",sep=''))
    for(s in sizes){
        i <- i + 1
        pdf(paste('./single-plots/',a,"_",s,'.pdf',sep=''))
        x <- data.all[data.all$application == a & data.all$size == s,]

        #drop phi except for listed applications
        if(drop_phi & a %!in% c("crc")){
            x <- subset(x,device != "Xeon Phi 7210")
        }

        p <- ggplot(x, aes(x=factor(device), y=total_time*0.001,colour=accelerator_type)) +
            geom_boxplot(outlier.alpha = 0.1,varwidth=TRUE)+
            labs(colour="accelerator type",y='time (ms)',x='')+
            scale_y_continuous(limit = c(0, max(x$total_time*0.001)*1.05)) +
            scale_color_viridis(discrete=TRUE,end=1) + theme_bw() + 
            theme(axis.text.x = element_text(size=10, angle = 45, hjust = 1),
                  title = element_text(size=10, face="bold"),
                  plot.margin = unit(c(0,0,0,0), "cm"))
        if (a == 'sw'){ a <- "swat"}
        p <- p + ggtitle(paste(indexs[i],a))
        print(p)
        dev.off()

        assign(paste("plot.",a,".",s,sep=""),p)
    }
}

plots <- align_plots(plot.nw.small +theme(legend.position = "none"),
                     plot.swat.small +theme(legend.position = "none"),
                     plot.gem.small +theme(legend.position = "none"),
                     plot.kmeans.small +theme(legend.position = "none"),
                     plot.hmm.small +theme(legend.position = "none"),
                     align='v',axis='l')

smallr    <- plot_grid(plots[[1]], plots[[2]],
                       plots[[3]], plots[[4]],
                       plots[[5]],
                       ncol=2,nrow=3,
                       #labels=c("(a) nw","(b) swat","(c) gem","(d) kmeans","(e) hmm"),
                       rel_heights = c(0.9, 1, 1),
                       label_x = c(0.06,0.05,0.035,0.01,0.034), #adjust x offset of each row label
                       label_y = c(1.0,1.0,1.085,1.085,1.085)) #adjust y offset of each row label

legend_generic <- get_legend(plot.kmeans.small + theme(legend.title=element_text(face="bold"),
                                                       legend.position="bottom",legend.justification="right"))

p <- plot_grid(smallr, #add plots
               legend_generic,#add legend
               ncol = 1, nrow = 2,#specify layout
               rel_heights=c(1,.05))#the legend needs much less space
pdf('../figures/chapter-4/small-bio-run.pdf',width=8.27,height=11.69)
print(ggdraw(p))
dev.off()

