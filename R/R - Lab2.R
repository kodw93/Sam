vehicles <- read_csv("http://s3.amazonaws.com/itao-30230/vehicles.csv", col_types = "inincicccici")

vehicles$class <- as.factor(vehicles$class)
vehicles$drive <- as.factor(vehicles$drive)
vehicles$make <- as.factor(vehicles$make)
vehicles$transmissiontype <- as.factor(vehicles$transmissiontype)

#1
ggplot(data = vehicles) +
  geom_point(mapping = aes(x=citympg, y=co2emissions))

ggplot(data = vehicles, mapping = aes(x=citympg, y=co2emissions)) +
  geom_point(mapping = aes(color = drive))

ggplot(data = vehicles) +
  geom_point(mapping = aes( x= citympg, y=co2emissions, color = drive))

ggplot(data=vehicles) +
  geom_bar(mapping = aes(x=year, fill = class))

ggplot(data = vehicles) +
  geom_histogram(mapping = aes(x=citympg)) +
  facet_wrap(~transmissiontype)


vehicles %>%
  group_by(class) %>%
  summarize ()

vehicles %>%
  group_by(year) %>%
  summarize(city_mpg = mean(citympg), highway_mpg = mean(highwaympg)) %>%
  ggplot() +
  geom_line (mapping = aes(x= year, y=mean(citympg)), color = "red") +
  geom_line (mapping = aes(x= year, y=mean(highwaympg)), color = "blue") +
  xlab("YEAR") + ylab("AVERAGE MPG")



vehicles %>%
  group_by(year) %>%
  summarize(city_mpg = mean(citympg), highway_mpg = mean(highwaympg)) %>%
  ggplot() +
  geom_line (mapping = aes(x= year, y=city_mpg), color = "red") +
  geom_line (mapping = aes(x= year, y=highway_mpg), color = "blue") +
  xlab("YEAR") + ylab("AVERAGE MPG")










library(tidyverse) 
library(stringr) #manipulate string
library(lubridate) #manipulating dates

disability <- read_csv("https://s3.amazonaws.com/itao-30230/ssadisability.csv")

head(disability)#not tidy because each month is 2 columns, 



#The Social Security Administration is trying to increase the % of claims filed online. They would like to know what the 
# trend for online claims has been in the past.
# Produce a scatterplot showing the percent of internet claims by month.

disability <- disability %>%
  gather(month, applications, -Fiscal_Year) #makes wide datasets long
head(disability)  

disability <- disability %>%
  separate(month, c("month", "format"), "_")
head(disability)


unique(disability$month)

disability <- disability %>%
  mutate(month=str_sub(month,1,3))

unique(disability$month)

unique(disability$Fiscal_Year)

disability <- disability %>%
  mutate(Fiscal_Year = str_replace(Fiscal_Year, "FY", "20")) %>%
  mutate(Fiscal_Year = as.numeric(Fiscal_Year))

disability

table(disability$Fiscal_Year)

disability <- disability %>%
  mutate(Fiscal_Year = ifelse((month == "Oct" | month == "Nov" | month == "Dec"), Fiscal_Year -1, Fiscal_Year))

table(disability$Fiscal_Year)

disability <- disability %>%
  mutate(date = str_c("01-", month, "-", Fiscal_Year)) %>%
  mutate(date = dmy(date)) %>%
  select(date, format, applications) %>%
  arrange(date, format)

disability

disability <- disability %>%
  spread(format, applications)

disability

disability <- disability %>%
  mutate(onlinePerc = Internet / Total)

disability


ggplot(data = disability, mapping = aes(x=date, y=onlinePerc)) +
  geom_point() + geom_smooth()


disability <- disability %>%
  filter(!is.na(Internet))