context("cpt.reg tests")

# testing functions, aim to get 100% test coverage on exported code
# testing for cpt.reg function

set.seed(1) # Note: new data sets must be added at the end.
singmeandata <- c(rnorm(100,0,1),rnorm(100,10,1))
mulmeandata <- c(rnorm(100,0,1),rnorm(100,10,1),rnorm(100,20,1),rnorm(100,50,1))
nochangedata <- c(rnorm(200,0,1))
singvardata <- c(rnorm(100,10,1),rnorm(100,10,5))
mulvardata <- c(rnorm(100,20,10),rnorm(100,20,15),rnorm(100,20,20),rnorm(100,20,25))
singmeanvardata <- c(rnorm(50,0,1),rnorm(50,3,10))
mulmeanvardata <- c(rnorm(50,0,1),rnorm(50,5,3),rnorm(50,10,1),rnorm(50,3,10))
mulmeanvarexpdata <- c(rexp(50,1), rexp(50,3), rexp(50,5), rexp(50,7)) #rate values correct
mulmeanvarpoisdata <- c(rpois(50,1), rpois(50,2), rpois(50,3), rpois(50,5)) #lambda values correct?
constantdata <- rep(1, 200)
shortdata <- c(2)
negativedata <- jitter(rep(-100, 200) )
characterdata <- rep("ert", 200)
#NAdata - creates 10 random NA within singmeandata
NAdata <- singmeandata
rn <- sample(1:length(singmeandata), 10, replace=F)
for(i in rn){
  NAdata[i] <- NA
}
NAdata[1] <- NA
data <- list(singmeandata,mulmeandata, nochangedata, singvardata, mulvardata, mulmeanvardata, mulmeanvarexpdata, mulmeanvarpoisdata, constantdata, NAdata, shortdata, negativedata, characterdata)
otherdata <- list(singmeandata,mulmeandata, nochangedata, singvardata, mulvardata, mulmeanvardata, mulmeanvarexpdata, mulmeanvarpoisdata, constantdata)

for(i in 1:length(otherdata)){
  expect_error(cpt.reg(design(otherdata[[i]],1), penalty = 1), "Argument 'penalty' is invalid.")

  expect_error(cpt.reg(design(otherdata[[i]],1), method = 1), "Argument 'method' is invalid.")

  expect_error(cpt.reg(design(otherdata[[i]],1), method = "other method"), "Invalid method, must be AMOC or PELT.")

  expect_error(cpt.reg(design(otherdata[[i]],1), dist = 1), "Argument 'dist' is invalid.")

  expect_warning(cpt.reg(design(otherdata[[i]],1), dist = "Exponential"), "dist = Exponential is not supported. Converted to dist='Normal'")

  expect_error(cpt.reg(design(otherdata[[i]],1), class = 1), "Argument 'class' is invalid.")

  expect_error(cpt.reg(design(otherdata[[i]],1), param.estimates = 1), "Argument 'param.estimates' is invalid.")

  expect_error(cpt.reg(design(otherdata[[i]],1), minseglen = "character"), "Argument 'minseglen' is invalid.")

  expect_error(cpt.reg(design(otherdata[[i]],1), minseglen = -2), "Argument 'minseglen' must be positive integer.")

  expect_error(cpt.reg(design(otherdata[[i]],1), tol = "character"), "Argument 'tol' is invalid.")

  expect_error(cpt.reg(design(otherdata[[i]],1), tol = -2), "Argument 'tol' must be positive.")

  expect_warning(cpt.reg(design(otherdata[[i]],2), minseglen = 1), "minseglen is too small, set to: 4")

  for(j in 1:10){
    expect_error(cpt.reg(design(otherdata[[i]],j), minseglen = nrow(design(otherdata[[i]],j))), "Minimum segment length is too large to include a change in this data.")

    expect_error(changepoint:::check_data( data = array(design(otherdata[[i]],j),dim=c(1,dim(design(otherdata[[i]],j)))), minseglen = "a"))
  }

  expect_warning(expect_error(changepoint:::check_data(design(otherdata[[i]],length(otherdata[[i]]) - 1)), "More regressors than observations."), "Due to the order of this model, there is a high risk of overfitting the data")
}

expect_error(changepoint:::check_data(data = c(1,2,3)), "Argument 'data' must be a numerical matrix.")

expect_error(changepoint:::check_data(data = as.array(c(1,2,3))), "Argument 'data' must be a numerical matrix.")



designdata <- list(singmeandata,mulmeandata, nochangedata, singvardata, mulvardata, mulmeanvardata, mulmeanvarexpdata, mulmeanvarpoisdata, constantdata)
for(i in 1:length(designdata)){
 for(j in 1:10){
  expect_equal(class(design(data[[i]],j)), "matrix")
 }
}

for(i in 1:length(data)){
 for(j in 2:10){
  if(is.na(data[[i]][1])==TRUE){
    expect_error(cpt.reg(design(data[[i]],j)), "NA/NaN/Inf in foreign function call (arg 2)", fixed = TRUE)
  }else if(is.na(data[[i]][2])==TRUE){
    suppressWarnings(expect_error(cpt.reg(design(data[[i]],j)), "invalid 'times' argument", fixed = TRUE))
  }else if(is.character(data[[i]][1])==TRUE){
    expect_error(cpt.reg(design(data[[i]],j)), "Argument 'data' must be a numerical matrix/array.", fixed = TRUE)
  }else{
    expect_s4_class(cpt.reg(design(data[[i]],j)), 'cpt.reg')
  }
 }
}
