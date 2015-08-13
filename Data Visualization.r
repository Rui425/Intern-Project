############################## Read data #################################
Kantar<-read.csv(file.choose(),header=F)
names(Kantar)<-c("time","Cost_per30seconds","DOW","Hour","group","program","channel")
Kantar$DOW<-as.factor(Kantar$DOW)
Kantar$Hour<-as.factor(Kantar$Hour)
dim(Kantar)
library(ggplot2)
############################ Visualization ###########################
## By network
sample = sample(1:nrow(Kantar), 1000000,replace=FALSE)
datasample = Kantar[sample,]
datasample = datasample[datasample$Cost_per30seconds<1e+05,]
datasample = datasample[datasample$channel=="ABC" 
                        | datasample$channel=="CBS" 
                        | datasample$channel=="FOX",]
p <- ggplot(datasample, aes(factor(channel), Cost_per30seconds))
p + geom_boxplot(outlier.colour = "grey50",frame.colour = "grey70",aes(fill = factor(group))) +
  xlab("Network") + ylab("Average Cost") + 
  ggtitle("Average Ad Cost by Network and ProductType")


## by DOW
DOW = read.csv(file.choose(),header=F)
names(DOW)<-c("cost","DOW","Network")
DOW$DOW <- factor(DOW$DOW,
                    levels = c(0,1,2,3,4,5,6),
                    labels = c("Sun.", "Mon.", "Tue.","Wed.","Thur.","Fri.","Sat."))
pp <- ggplot(DOW, aes(x=DOW, y=cost, group=Network))
pp + geom_line(aes(colour = Network)) + xlab("Day of Week") + ylab("Average Cost") + 
  geom_bar(stat="identity", position=position_dodge(),aes(fill=Network))+
  scale_fill_manual(values=c("peachpuff", "pink1","plum2")) +
  ggtitle("Average Ad Cost by DOW") + geom_point(aes(colour=Network))

pp <- ggplot(DOW, aes(x=DOW, y=cost, group=Network))
pp + geom_line(aes(colour = Network)) + xlab("Day of Week") + ylab("Average Cost") + 
  geom_bar(stat="identity", position=position_dodge(),aes(fill=Network))+
  scale_fill_manual(values=c("skyblue", "dodgerblue2","blue")) +
  ggtitle("Average Ad Cost by DOW") + geom_point(aes(colour=Network))



## by Hour 
Byhour= read.csv(file.choose(),header=F)
names(Byhour)<-c("cost","Hour","Network")
pp <- ggplot(Byhour, aes(x=factor(Hour), y=cost, group=Network))
pp + geom_line(aes(colour = Network)) + xlab("Hour") + ylab("Average Cost") + 
  ggtitle("Average Ad Cost by Hour") + geom_point(aes(colour=Network))

## by program type
library(ggplot2)
sample = sample(1:nrow(Kantar), 1000000,replace=FALSE)
datasample = Kantar[sample,]
datasample = datasample[datasample$Cost_per30seconds<10000,]
datasample = datasample[datasample$program=="DRAMA/ADVENTURE" 
                        | datasample$program=="TENNIS" 
                        | datasample$program=="SOAP OPERA",]
p <- ggplot(datasample, aes(factor(program), Cost_per30seconds))
p + geom_boxplot(outlier.colour = "grey50",frame.colour = "grey70",aes(fill = factor(group))) +
  xlab("Program Type") + ylab("Average Cost") + 
  ggtitle("Average Ad Cost by Programtype and ProductType")

datasample = Kantar
datasample = datasample[datasample$Cost_per30seconds<3000,]
datasample = datasample[datasample$program=="SCIENCE FICTION" 
                        | datasample$program=="FEATURE FILM" 
                        | datasample$program=="SPORTS ENTERTAINMENT",]
p <- ggplot(datasample, aes(factor(program), Cost_per30seconds))
p + geom_boxplot(outlier.colour = "grey50",frame.colour = "grey70",aes(fill = factor(group))) +
  xlab("Program Type") + ylab("Average Cost") + 
  ggtitle("Average Ad Cost by Programtype and ProductType")
