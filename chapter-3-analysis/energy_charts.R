
library(ggplot2)
library(viridis)
library(cowplot)
library(latex2exp)
library(plyr)

#generated in dwarfs-on-accelerator paper -- analysis tools directory
load('rundata_energy.Rda')

rundata.energy$device <- revalue(rundata.energy$device,
                                 c(
                                   "i7-6700k"="i7-6700K",
                                   "gtx1080"="GTX 1080"
                                   ))

p1 <- ggplot(rundata.energy, aes(x=application,y=energy,color=device)) + geom_boxplot(outlier.alpha = 0.1,varwidth=TRUE) + labs(y=TeX('energy (J)'), x=TeX('benchmark'), colour="accelerator") +
    scale_color_viridis(discrete=TRUE,end=0.25) + theme_bw() + 
    scale_y_continuous(limit = c(0, max(rundata.energy$energy)*1.05)) +
    theme(axis.text.x = element_text(size=10, angle = 45, hjust = 1),
          title = element_text(size=10, face="bold"),
          plot.margin = unit(c(0,0,0,0), "cm"))
pdf('../figures/chapter-3/energy_charts.pdf')
print(p1)
dev.off()

breaks=c(0.02,0.2,2,20,200)
p2 <- ggplot(rundata.energy, aes(x=application,y=energy,color=device)) + geom_boxplot(outlier.alpha = 0.1,varwidth=TRUE) + labs(y=TeX('$\\log_{10}\\left($energy (J)$\\right)$'), x=TeX('benchmark'), colour="accelerator") + scale_y_continuous(trans='log10', breaks=breaks, labels=breaks) +
    scale_color_viridis(discrete=TRUE,end=0.25) + theme_bw() + 
    theme(axis.text.x = element_text(size=10, angle = 45, hjust = 1),
          title = element_text(size=10, face="bold"),
          plot.margin = unit(c(0,0.0,0.0,0.0), "cm"))

pdf('../figures/chapter-3/energy_charts_log10.pdf')
print(p2)
dev.off()


print("saving combined figures.pdf")
plot_row <- plot_grid(p1 + ggtitle("(a)") + theme(legend.position = "none"),
                      p2 + ggtitle("(b)") + theme(legend.position = "none"),
                      ncol=2,nrow=1)

plot_legend <- get_legend(p1 + theme(legend.title=element_text(face="bold"),
                                     legend.position="bottom",
                                     legend.justification="right"))
#p <- plot_grid(plot_row, plot_legend, ncol = 2, rel_widths = c(0.90, .11))
p <- plot_grid(plot_row, plot_legend, nrow = 2, rel_heights = c(1,0.06))

pdf('../figures/chapter-3/energy_combined.pdf',width=9.0,height=6)
print(p)
dev.off()


