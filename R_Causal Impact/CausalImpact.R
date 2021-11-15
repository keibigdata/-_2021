library(CausalImpact)
library(lubridate)
library(tidyverse)
library(ggplot2)
data <- read_csv("C:/Users/KKD/Desktop/local.csv")
data <- data %>%
          select(Region, Year, CEVAR1_1, INH_1C81T1Z10, DT_1YL6601ET10, DT_1YL20391T10, DT_1BPB001ET100, DT_1YL15009T002)

colnames(data) <- c('Region', 'Year', 'total', 'GRDP', '광공업생산지수', '에너지소비량', '추계인구', '제조업생산지수')
df <- na.omit(data)  # 모든 변수에 결측치 없는 데이터 추출
id <- unique(df$Region)

# 베이지안 구조 시계열 모델을 사용한 인과 추론을위한 R 패키지 
# 가정1 : 특히 CausalImpact 패키지는 결과 시계열이 개입의 영향을받지 않은 일련의 제어 시계열로 설명 될 수 있다고 가정합니다. 
# 가정2 : 또한 처리 된 시리즈와 대조 시리즈 사이의 관계는 개입 후 기간 동안 안정적인 것으로 가정됩니다. 

for (i in 1:16) { 
  sub <- df[df$Region==id[i],]
  sub <- subset(sub, select=-c(Region, Year))
  
  pre.period <- ymd(c(2010, 2012), truncated=2L)
  post.period <- ymd(c(2013, 2018), truncated=2L)
  yrs <- c(2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018)
  time.points <- ymd(yrs, truncated = 2L)
  
  new <- zoo(as.matrix(sub), time.points)
  impact <- CausalImpact(new, pre.period, post.period)
  name1 <- paste0("C:/Users/KKD/Desktop/", id[i], ".jpg")
  impact.plot <- plot(impact) +  labs(y="신재생에너지발전량(합계)", x="연도") + theme_bw(base_size = 15)
  ggsave(name1, dpi = 300) 
  # plot(impact$model$bsts.model, "coefficients")
  name2 <- paste0("C:/Users/KKD/Desktop/", id[i], ".csv")
  report1 <- capture.output(summary(impact))
  # report2 <- paste(capture.output(summary(impact, "report")), collapse="")
  write_csv(data.frame(report1), name2)
}



