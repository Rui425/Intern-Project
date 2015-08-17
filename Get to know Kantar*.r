################################### Data understanding ###############################
### Discover the features of data by minutes 
data1<-read.csv(file.choose(),header=F)
names(data1)<-c("time","cost","channel","quarter","date","hour","minutes")
plot(data1[,2],type="l",xlab="date", ylab="ad cost ($/spot)",axes=FALSE)
axis(1,at=35000*0:8, lab=c("Fri","Sat","Sun","Mon","Tue","Wed","Thur","Fri","Sat"))
axis(2)
title(main="Average Cost of Ad Per Minute")
box()

### Try Linear regression 
fit<-lm(cost~channel+date+hour+minute,data=data1)
val_cross<-validate(fit,method="crossvalidation", type="residual")


### Reconstruct Kevin's method and test the CV MSE, reference code
Kevin <- read.csv("~/Desktop/data/Kevin.csv", header=FALSE)
names(Kevin)<-c("time","cost","channel","quarter","date","hour")
Kevin$pred=NA
head(Kevin)
fold=50
mse<-NULL
for (j in 1:50){
  truncone<-(j-1)*dim(Kevin)[1]/50+1
  trunctwo<-j*dim(Kevin)[1]/50
  test<-Kevin[truncone:trunctwo,]
  train<-Kevin[-(truncone:trunctwo),]
  for (i in 1:dim(test)[1]) {
    test$pred[i]<-mean(train$cost[train$date==test$date[i] & train$hour==test$hour[i] & train$channel==test$channel[i]])
  }
  newtest<-na.omit(test)
  mse[j]=sqrt(mean((newtest$pred-newtest$cost)^2))
}
mse
## > mse
## [1]  1833.526  9269.318  2539.117  9474.933  3987.492  8508.380  7181.776  3385.158
## [9]  5217.734  3363.777 12789.856 10010.206  4702.361  8583.116  3155.426 14770.307
## [17]  3233.794  4147.449 17660.768  5436.032 16174.934  3929.362  3325.732  3868.037
## [25] 15350.763  5911.942  2951.279  4110.390  3306.019 11517.630  4494.782  5814.932
## [33]  5187.730  5551.367  7899.352  5621.773  4832.819  4018.745  8634.720  8851.182
## [41] 12024.285 13338.791 13477.224 26741.204 17236.165  4442.954  4793.394 33659.123
## [49] 31122.526  7561.335
## > mean(mse)
## [1] 8700.02


######### LOOCV ###############
mse<-NULL
for (j in 1:5000){
  test<-Kevin[100000+j,]
  train<-Kevin[-(10000+j),]
  test$pred<-mean(train$cost[train$date==test$date & train$hour==test$hour & train$channel==test$channel])
  newtest<-na.omit(test)
  mse[j]=sqrt((newtest$pred-newtest$cost)^2)
}
mean(mse)

### find out the worst predicted points ### 
MSEmax<-mse
largest_points<-NULL
for (i in 1:1000){
  maxs<-which.max(MSEmax)
  largest_points[i]=maxs
  MSEmax=MSEmax[-maxs]
}
largest_points
Kevin[100000+largest_points,][1:100,]

#####################################################################################################################################################
#################################### Modeling for only a small set of data to explore the pattern of data ###########################################
#####################################################################################################################################################

################################ Network AMC No Promo No DR #############################
AMC<-read.csv(file.choose(),header=T)
View(AMC)
AMC$Day.of.week<-as.factor(AMC$Day.of.week)
AMC$Hour.of.day<-as.factor(AMC$Hour.of.day)
AMCsmall<-AMC[AMC$Cost.per.30.seconds<10000,]

############### linear regression ################
# for whole set
reg<-lm(Cost.per.30.seconds~Day.of.week+Hour.of.day+Program,data=AMC)
prediction<-predict(reg,AMC[,-2])
diff<-(abs(AMC$Cost.per.30.seconds-prediction)/AMC$Cost.per.30.seconds)
mean(diff)
# for subset
regsmall<-lm(Cost.per.30.seconds~Day.of.week+Hour.of.day+Program,data=AMCsmall)
predictionsmall<-predict(regsmall,AMCsmall[,-2])
diff<-(((AMCsmall$Cost.per.30.seconds-predictionsmall)/AMCsmall$Cost.per.30.seconds)^2)
sqrt(mean(diff))
plot(diff,type="l")

########################### LOOCV ################################
################ Averaging ##############
# for the whole set
mae<-NULL
dim(AMC)
for (j in 1:49790){
  test<-AMC[j,]
  train<-AMC[-j,]
  test$pred=NA
  test$pred[j]<-mean(train$Cost.per.30.seconds[train$Day.of.week==test$Day.of.week[j] 
                                           &train$Hour.of.day==test$Hour.of.day[j] 
                                           &train$Program==test$Program[j]])
  mae[j]=(abs(test$pred-test$Cost.per.30.seconds))
}
# for subset
mae<-NULL
for (j in 1:48462){
  test<-AMCsmall[j,]
  test$pred=NA
  test$pred<-mean(AMCsmall$Cost.per.30.seconds[AMCsmall$Day.of.week==test$Day.of.week 
                                               &AMCsmall$Hour.of.day==test$Hour.of.day 
                                               &AMCsmall$Program==test$Program])
  mae[j]=(abs(test$pred-test$Cost.per.30.seconds))
}
##################### Tree ######################
library(rpart)
#for whole set
dim(AMC)
mae<-NULL
for (i in 1:49790){
  test<-AMC[i,]
  train<-AMC[-i,]
  fit <- rpart(Cost.per.30.seconds~Day.of.week+Hour.of.day+Program, 
               method="anova", data=train)
  AMCpred<-predict(fit,test[,-2])
  test$pred<-AMCpred
  mae[i]<-abs(test$Cost.per.30.seconds-test$pred)
}
mean(mae)

# for subset
dim(AMCsmall)
maesmall<-NULL
for (i in 1:48462){
  test<-AMCsmall[i,]
  train<-AMCsmall[-i,]
  fitsmall <- rpart(Cost.per.30.seconds~Day.of.week+Hour.of.day+Program, 
               method="anova", data=train)
  AMCpredsmall<-predict(fitsmall,test[,-2])
  test$pred<-AMCpredsmall
  maesmall[i]<-abs(test$Cost.per.30.seconds-test$pred)
}
mean(maesmall)
################### linear regression #################
# for whole set
maereg<-NULL
for (i in 1:49790){
  test<-AMC[i,]
  train<-AMC[-i,]
  reg<-lm(Cost.per.30.seconds~Day.of.week+Hour.of.day+Program,data=train)
  prediction<-predict(reg,test[,-2])
  test$pred<-prediction
  maereg[i]<-abs(AMC$Cost.per.30.seconds-test$pred)
}
mean(maereg)

# for subset
maeregsmall<-NULL
for (i in 1:48462){
  test<-AMCsmall[i,]
  train<-AMCsmall[-i,]
  regsmall<-lm(Cost.per.30.seconds~Day.of.week+Hour.of.day+Program,data=train)
  predictionsmall<-predict(regsmall,test[,-2])
  test$pred<-predictionsmall
  maeregsmall[i]<-abs(AMCsmall$Cost.per.30.seconds- test$pred)
}
mean(maeregsmall)

