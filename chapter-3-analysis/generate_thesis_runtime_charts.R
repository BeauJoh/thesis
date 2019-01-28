"%!in%" <- Negate("%in%")
library(ggplot2)
library(cowplot)
library(plyr)
library(viridis)

#source("load_data.R")
load('rundata.all.Rda')
data.all <- rundata.all

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

if(!exists("single.figures")){
drop_phi = FALSE
#generates boxplots of relative execution times
print("generating boxplots...")
applications <- c("kmeans",
                  "lud",
                  "csr",
                  "fft",
                  "dwt",
                  "srad",
                  "crc",
                  "bfs",
                  "nw",
                  "gem",
                  "nqueens",
                  "hmm")
sizes <- c('tiny','small','medium','large')

#generate a plot for each application with all 4 sizes
for(a in applications){
    print(paste("saving ",a,"...",sep=''))
    for(s in sizes){
        #don't generate plots for these medium and large sized problems for these applications
        if(a %in% c("gem","nqueens","hmm") & s %in% c("medium","large")){
            next
        }

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

        #just adjust the size-title since the application row title sits over the top of them
        s_title <- s
        if(a == 'kmeans'){
            if (s == 'tiny'){
                s_title <- '                         tiny'
            }
            if (s == 'medium'){
                s_title <- '                         medium'
            }
        }
        if(a == 'fft'){
            if(s == 'tiny'){
                s_title <- '                   tiny'
            }
            if(s == 'medium'){
                s_title <- '                         medium'
            }
        }

        #only include "size" as a title on these applications
        if(a %in% c("crc","kmeans","fft")){
            p <- p + ggtitle(s_title)
        }

        print(p)
        dev.off()
        assign(paste("plot.",a,".",s,sep=""),p)
    }
}
single.figures <- data.frame()
}
legends <- get_legend(plot.crc.tiny)+theme(legend.title=element_text(face="bold"),
                                           legend.position="top",
                                           legend.justification="left")

#crc results
print("saving crc_row_bandwplot.pdf")
crc_row <- plot_grid(plot.crc.tiny  +theme(legend.position = "none"),
                     plot.crc.small +theme(legend.position = "none"),
                     plot.crc.medium+theme(legend.position = "none"),
                     plot.crc.large +theme(legend.position = "none"),
                     ncol=2,nrow=2)
legend_crc <- get_legend(plot.crc.tiny + theme(legend.title=element_text(face="bold"),
                                             legend.position="bottom",legend.justification="right"))#"center"))
p <- plot_grid(crc_row, legend_crc, ncol = 1, rel_heights = c(1, .05))
pdf('../figures/chapter-3/crc.pdf',width=8,height=8)
print(p)
dev.off()

#4x4 results
print("saving tiny_and_small_times.pdf")
legend_generic <- get_legend(plot.kmeans.tiny + theme(legend.title=element_text(face="bold"),
                                                      legend.position="bottom",legend.justification="right"))

plots <- align_plots(plot.kmeans.tiny  +theme(legend.position = "none"),
                     plot.kmeans.small +theme(legend.position = "none"),
                     plot.kmeans.medium+theme(legend.position = "none"),
                     plot.kmeans.large +theme(legend.position = "none"),
                     plot.lud.tiny  +theme(legend.position = "none"),
                     plot.lud.small +theme(legend.position = "none"),
                     plot.lud.medium+theme(legend.position = "none"),
                     plot.lud.large +theme(legend.position = "none"),
                     plot.csr.tiny  +theme(legend.position = "none"),
                     plot.csr.small +theme(legend.position = "none"),
                     plot.csr.medium+theme(legend.position = "none"),
                     plot.csr.large +theme(legend.position = "none"),
                     plot.dwt.tiny  +theme(legend.position = "none"),
                     plot.dwt.small +theme(legend.position = "none"),
                     plot.dwt.medium+theme(legend.position = "none"),
                     plot.dwt.large +theme(legend.position = "none"),
                     plot.fft.tiny  +theme(legend.position = "none"),
                     plot.fft.small +theme(legend.position = "none"),
                     plot.fft.medium+theme(legend.position = "none"),
                     plot.fft.large +theme(legend.position = "none"),
                     plot.srad.tiny  +theme(legend.position = "none"),
                     plot.srad.small +theme(legend.position = "none"),
                     plot.srad.medium+theme(legend.position = "none"),
                     plot.srad.large +theme(legend.position = "none"),
                     plot.nw.tiny  +theme(legend.position = "none"),
                     plot.nw.small +theme(legend.position = "none"),
                     plot.nw.medium+theme(legend.position = "none"),
                     plot.nw.large +theme(legend.position = "none"),
                     align='v',axis='l')

ts_one <- plot_grid(plots[[1]],  plots[[2]],
                    plots[[5]],  plots[[6]],
                    plots[[9]],  plots[[10]],
                    plots[[13]], plots[[14]],
                    ncol=2,nrow=4,
                    labels=c("(a) kmeans",'',"(b) lud",'', "(c) csr",'',"(d) dwt",''),
                    label_x = c(0,0,0.05,0,0.051,0,0.045,0), #adjust x offset of each row label
                    label_y = c(1.0,1.0,1.085,1.0,1.085,1.0,1.08,1.0)) #adjust y offset of each row label

ts_two <- plot_grid(plots[[17]], plots[[18]],
                    plots[[21]], plots[[22]],
                    plots[[25]], plots[[26]],
                    ncol=2,nrow=3,
                    labels=c("(a) fft",'',"(b) srad",'', "(c) nw",''),
                    label_x = c(0.06,0,0.035,0,0.051,0), #adjust x offset of each row label
                    label_y = c(1.0,1.0,1.085,1.0,1.085,1.0)) #adjust y offset of each row label

ml_one <- plot_grid(plots[[3]],  plots[[4]],
                    plots[[7]],  plots[[8]],
                    plots[[11]], plots[[12]],
                    plots[[15]], plots[[16]],
                    ncol=2,nrow=4,
                    labels=c("(a) kmeans",'',"(b) lud",'', "(c) csr",'',"(d) dwt",''),
                    label_x = c(0,0,0.05,0,0.051,0,0.045,0), #adjust x offset of each row label
                    label_y = c(1.0,1.0,1.085,1.0,1.085,1.0,1.08,1.0)) #adjust y offset of each row label

ml_two    <- plot_grid(plots[[19]], plots[[20]],
                       plots[[23]], plots[[24]],
                       plots[[27]], plots[[28]],
                       ncol=2,nrow=3,
                       labels=c("(a) fft",'',"(b) srad",'', "(c) nw",''),
                       label_x = c(0.06,0,0.035,0,0.051,0), #adjust x offset of each row label
                       label_y = c(1.0,1.0,1.085,1.0,1.085,1.0)) #adjust y offset of each row label

p <- plot_grid(ts_one, #add plots
               legend_generic,#add legend
               ncol = 1, nrow = 2,#specify layout
               rel_heights=c(1,.05))#the legend needs much less space
pdf('../figures/chapter-3/tiny_and_small_times_for_kmeans_lud_csr_dwt.pdf',width=8.27,height=11.69)
print(ggdraw(p))
dev.off()

p <- plot_grid(ts_two, #add plots
               legend_generic,#add legend
               ncol = 1, nrow = 2,#specify layout
               rel_heights=c(1,.05))#the legend needs much less space
pdf('../figures/chapter-3/tiny_and_small_times_for_fft_srad_nw.pdf',width=8.27,height=11.69)
print(ggdraw(p))
dev.off()

p <- plot_grid(ml_one, #add plots
               legend_generic,#add legend
               ncol = 1, nrow = 2,#specify layout
               rel_heights=c(1,.05))#the legend needs much less space
pdf('../figures/chapter-3/medium_and_large_times_for_kmeans_lud_csr_dwt.pdf',width=8.27,height=11.69)
print(ggdraw(p))
dev.off()

p <- plot_grid(ml_two, #add plots
               legend_generic,#add legend
               ncol = 1, nrow = 2,#specify layout
               rel_heights=c(1,.05))#the legend needs much less space
pdf('../figures/chapter-3/medium_and_large_times_for_fft_srad_nw.pdf',width=8.27,height=11.69)
print(ggdraw(p))
dev.off()

# just the medium figures

medium_f <- plot_grid(plots[[3]],
                      plots[[7]],
                      plots[[11]],
                      plots[[15]],
                      plots[[19]],
                      plots[[23]],
                      plots[[27]],
                      ncol=2,nrow=4,
                      labels=c("(a) kmeans","(b) lud","(c) csr","(d) dwt","(e) fft","(f) srad","(g) nw"),
                      label_x = c(0,0,0.05,0,0.051,0,0.045,0), #adjust x offset of each row label
                      label_y = c(1.0,1.0,1.085,1.0,1.085,1.0,1.08,1.0)) #adjust y offset of each row label

p <- plot_grid(medium_f, #add plots
               legend_generic,#add legend
               ncol = 1, nrow = 2,#specify layout
               rel_heights=c(1,.05))#the legend needs much less space
pdf('../figures/chapter-3/medium_apps.pdf',width=8.27,height=11.69)
print(ggdraw(p))
dev.off()

#p <- plot_grid(kmeans_row,#add plots
#               legend_generic,#add legend
#               ncol = 1, nrow = 2,#specify layout
#               rel_heights=c(1,.05))#the legend needs much less space
#pdf('../figures/chapter-3/kmeans.pdf',width=8,height=8)
#print(ggdraw(p))
#dev.off()
#
#p <- plot_grid(lud_row,#add plots
#               legend_generic,#add legend
#               ncol = 1, nrow = 2,#specify layout
#               rel_heights=c(1,.05))#the legend needs much less space
#pdf('../figures/chapter-3/lud.pdf',width=8,height=8)
#print(ggdraw(p))
#dev.off()
#
#p <- plot_grid(csr_row,#add plots
#               legend_generic,#add legend
#               ncol = 1, nrow = 2,#specify layout
#               rel_heights=c(1,.05))#the legend needs much less space
#pdf('../figures/chapter-3/csr.pdf',width=8,height=8)
#print(ggdraw(p))
#dev.off()
#
#p <- plot_grid(dwt_row,#add plots
#               legend_generic,#add legend
#               ncol = 1, nrow = 2,#specify layout
#               rel_heights=c(1,.05))#the legend needs much less space
#pdf('../figures/chapter-3/dwt.pdf',width=8,height=8)
#print(ggdraw(p))
#dev.off()
#
#p <- plot_grid(fft_row,#add plots
#               legend_generic,#add legend
#               ncol = 1, nrow = 2,#specify layout
#               rel_heights=c(1,.05))#the legend needs much less space
#pdf('../figures/chapter-3/fft.pdf',width=8,height=8)
#print(ggdraw(p))
#dev.off()
#
#p <- plot_grid(srad_row,#add plots
#               legend_generic,#add legend
#               ncol = 1, nrow = 2,#specify layout
#               rel_heights=c(1,.05))#the legend needs much less space
#pdf('../figures/chapter-3/srad.pdf',width=8,height=8)
#print(ggdraw(p))
#dev.off()
#
#p <- plot_grid(nw_row,#add plots
#               legend_generic,#add legend
#               ncol = 1, nrow = 2,#specify layout
#               rel_heights=c(1,.05))#the legend needs much less space
#pdf('../figures/chapter-3/nw.pdf',width=8,height=8)
#print(ggdraw(p))
#dev.off()

#2x4 results
#gem, nqueens, hmm and swat only runs on tiny and small problem sizes swat

source('./utils.R')
source('./stats.R')
source('./aes.R')
source('./functions.R')

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

#remove knl from results
data.procswat <- data.procswat[data.procswat$device!='Xeon Phi 7210',]
data.procswat$accelerator_type <- factor(data.procswat$accelerator_type)

library(ggplot2)
library(cowplot)
library(plyr)
library(viridis)

p <- ggplot(data.procswat, aes(x=factor(device), y=time*0.001,colour=accelerator_type)) +
        geom_boxplot(outlier.alpha = 0.1,varwidth=TRUE)+
            labs(colour="accelerator type",y='time (ms)',x='')+
                scale_y_continuous(limit = c(0, max(x$time*0.001)*1.05)) +
                    scale_color_viridis(discrete=TRUE,end=0.75) + theme_bw() +
                        theme(axis.text.x = element_text(size=10, angle = 45, hjust = 1),
                                        title = element_text(size=10, face="bold"),
                                                  plot.margin = unit(c(0,0,0,0), "cm"))

plot.swat.tiny <- p

print("saving main_2x4_bandwplot.pdf")
plots <- align_plots(plot.gem.tiny + ggtitle("(a) gem")  +theme(legend.position = "none"),
                     #plot.gem.small +theme(legend.position = "none"),
                     plot.nqueens.tiny+ ggtitle("(b) nqueens")  +theme(legend.position = "none"),
                     #plot.nqueens.small +theme(legend.position = "none"),
                     plot.hmm.tiny + ggtitle("(c) hmm") +theme(legend.position = "none"),
                     plot.swat.tiny + ggtitle("(d) swat") +theme(legend.position = "none"),
                     #plot.hmm.small +theme(legend.position = "none"),
                     align='v',axis='l')

p <- plot_grid(plot_grid(plots[[1]], plots[[2]], plots[[3]], plots[[4]],
               ncol=2,nrow=2#specify layout
               ),#the legend needs much less space
               ncol=1,nrow=2,
               get_legend(plot.kmeans.tiny + theme(legend.title=element_text(face="bold"),legend.position="bottom",legend.justification="right")),#add legend
               rel_heights=c(1,0.05))
               #label_x = c(.01,.0,0.01), #adjust x offset of each row label
               #label_y = c(1.0 ,1.06,1.06), #adjust y offset of each row label

pdf('../figures/chapter-3/gem_nqueens_hmm_and_swat.pdf',width=8.27,height=8.76)
print(ggdraw(p))
dev.off()

#generate a plot for each application with just the medium problem size
sizes <- c("medium")
a_letters <- c("(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)")
al <- 1
for(a in applications){
    print(paste("saving ",a,"...",sep=''))
    for(s in sizes){
        #don't generate plots for these medium and large sized problems for these applications
        if(a %in% c("gem","nqueens","hmm") & s %in% c("medium","large")){
            next
        }

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

        #just adjust the size-title since the application row title sits over the top of them
        s_title <- s
        if(a == 'kmeans'){
            if (s == 'tiny'){
                s_title <- '                         tiny'
            }
            if (s == 'medium'){
                s_title <- '                         medium'
            }
        }
        if(a == 'fft'){
            if(s == 'tiny'){
                s_title <- '                   tiny'
            }
            if(s == 'medium'){
                s_title <- '                         medium'
            }
        }

        #only include "size" as a title on these applications
        #if(a %in% c("crc","kmeans","fft")){
        #    p <- p + ggtitle(s_title)
        #}
        p <- p + ggtitle(paste(a_letters[al],a))
        print(p)
        dev.off()
        assign(paste("plot.",a,".",s,sep=""),p)
        al <- al+1
    }
}
single.figures <- data.frame()

plots <- align_plots(plot.kmeans.medium+theme(legend.position = "none"),
                     plot.lud.medium+theme(legend.position = "none"),
                     plot.csr.medium+theme(legend.position = "none"),
                     plot.fft.medium+theme(legend.position = "none"),
                     plot.dwt.medium+theme(legend.position = "none"),
                     plot.srad.medium+theme(legend.position = "none"),
                     plot.crc.medium+theme(legend.position = "none"),
                     plot.nw.medium+theme(legend.position = "none"),
                     align='v',axis='l')

medium_f <- plot_grid(plots[[1]],
                      plots[[2]],
                      plots[[3]],
                      plots[[4]],
                      plots[[5]],
                      plots[[6]],
                      plots[[7]],
                      plots[[8]],
                      ncol=2,nrow=4)#,
                      #labels=c("(a) kmeans","(b) lud","(c) csr","(d) fft","(e) dwt","(f) srad","(g) crc", "(h) nw"),
                      #label_x = c(0,0,0.05,0,0.051,0,0.045,0), #adjust x offset of each row label
                      #label_y = c(1.0,1.0,1.085,1.0,1.085,1.0,1.08,1.0)) #adjust y offset of each row label

p <- plot_grid(medium_f, #add plots
               legend_generic,#add legend
               ncol = 1, nrow = 2,#specify layout
               rel_heights=c(1,.05))#the legend needs much less space
pdf('../figures/chapter-3/medium_apps.pdf',width=8.27,height=11.69)
print(ggdraw(p))
dev.off()


