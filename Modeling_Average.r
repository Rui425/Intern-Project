########################## Read table #########################
Kantar<-read.csv(file.choose(),header=F)
names(Kantar)<-c("time","Cost_per30seconds","DOW","Hour","group","program","channel")
Kantar$DOW<-as.factor(Kantar$DOW)
Kantar$Hour<-as.factor(Kantar$Hour)
dim(Kantar)

### convert into dummy variables
model=model.matrix( ~ Cost_per30seconds+DOW+Hour+program+group+channel - 1, data=Kantar )
### convert into sparse matrix
library(Matrix)
Smodel <- sparse.model.matrix(~.-1, data = model)

########################### Modeling #############################
#### Averaging DOW, hour, program type, network and product group
library(matrixStats)
dim(Kantar)
distan<-NULL
range = as.integer(dim(Kantar)[1]/10)
for (i in 1:10){
  truncone<-(i-1)*range+1
  trunctwo<-i*range
  train=Kantarpart[-(truncone:trunctwo),]
  test=Kantarpart[(truncone:trunctwo),]
  test$pred=NA
  test$pred[i]<-mean(train$Cost_per30seconds[train$DOW==test$DOW[i] 
                                            &train$Hour==&test$Hour[i]
                                            &train$program==test$program[i]
                                            &train$group==test$group[i]
                                            &train$channel==test$channel[i]])
  diff=abs(test$pred-test$Cost_per30seconds)/test$Cost_per30seconds
  distan<-cbind(distan,diff)
  disvactor<-as.vector(distan)
}
mpe=colMeans(distan)
medianpe=colMedians(distan)
mean(mpe)
mean(medianpe)

#### Averaging DOW, hour and network 
library(matrixStats)
dim(Kantar)
distan<-NULL
range = as.integer(dim(Kantar)[1]/10)
for (i in 1:10){
  truncone<-(i-1)*range+1
  trunctwo<-i*range
  train=Kantarpart[-(truncone:trunctwo),]
  test=Kantarpart[(truncone:trunctwo),]
  test$pred=NA
  test$pred[i]<-mean(train$Cost_per30seconds[train$DOW==test$DOW[i] 
                                            &train$Hour==&test$Hour[i]
                                            &train$channel==test$channel[i]])
  diff=abs(test$pred-test$Cost_per30seconds)/test$Cost_per30seconds
  distan<-cbind(distan,diff)
  disvactor<-as.vector(distan)
}
mpe=colMeans(distan)
medianpe=colMedians(distan)
mean(mpe)
mean(medianpe)
