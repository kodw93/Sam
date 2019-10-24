# Samuel Ko
# Data Management
# R Assignment

library(tidyverse)

vehicles <- read_csv("https://s3.amazonaws.com/itao-30230/vehicles.csv",
                     col_types="inincicccici")
vehicles$class <- as.factor(vehicles$class)
vehicles$drive <- as.factor(vehicles$drive)
vehicles$make <- as.factor(vehicles$make)
vehicles$transmissiontype <- as.factor(vehicles$transmissiontype)

#Problem 1
  #Part A
  ggplot(data=vehicles) +
    geom_point(mapping = aes(x=citympg, y=co2emissions))
  
  #Part B
  ggplot(data=vehicles) +
    geom_point(mapping = aes(x=citympg, y=co2emissions, color = drive))
  
  #Part C
  ggplot(data=vehicles) +
    geom_bar(mapping = aes(x=year, fill = class))

  #Part D  
  ggplot(data=vehicles) +
    geom_histogram(mapping = aes(x=citympg)) +
    facet_wrap(~transmissiontype)
  
  
#Problem 2
  #Part A
  vehicles %>%
    group_by(class) %>%
    summarize(min_mpg = min(citympg), max_mpg = max(citympg), mean_mpg = as.integer(round(mean(citympg))), median_mpg = median(citympg))
  
  
  #Part B
  vehicles %>%
    group_by(year) %>%
    summarize(city_mpg = mean(citympg), highway_mpg = mean(highwaympg)) %>%
    ggplot() +
    geom_line (mapping = aes(x= year, y=city_mpg), color = "red") +
    geom_line (mapping = aes(x= year, y=highway_mpg), color = "blue") +
    xlab("YEAR") + ylab("AVERAGE MPG")

  
  #Part C
  vehicles %>%
    group_by(year) %>%
    summarize(city_mpg = mean(citympg), highway_mpg = mean(highwaympg), overall_mpg = (city_mpg+highway_mpg)/2) %>%
    ggplot() +
    geom_line (mapping = aes(x= year, y=city_mpg), color = "red") +
    geom_line (mapping = aes(x= year, y=highway_mpg), color = "blue") +
    geom_line (mapping = aes(x= year, y=overall_mpg), color = "green") +
    xlab("YEAR") + ylab("AVERAGE MPG")
  
  #same can be done by using mutate
  vehicles %>%
    group_by(year) %>%
    summarize(city_mpg = mean(citympg), highway_mpg = mean(highwaympg)) %>%
    mutate(overall_mpg = (city_mpg+highway_mpg)/2) %>%
    ggplot() +
    geom_line (mapping = aes(x= year, y=city_mpg), color = "red") +
    geom_line (mapping = aes(x= year, y=highway_mpg), color = "blue") +
    geom_line (mapping = aes(x= year, y=overall_mpg), color = "green") +
    xlab("YEAR") + ylab("AVERAGE MPG")
  
  
  #Part D
  vehicles %>%
    group_by(year, drive) %>%
    summarize(city_mpg = mean(citympg), highway_mpg = mean(highwaympg)) %>%
    mutate(overall_mpg = (city_mpg+highway_mpg)/2) %>%
    ggplot() +
    geom_line (mapping = aes(x= year, y=city_mpg), color = "red") +
    geom_line (mapping = aes(x= year, y=highway_mpg), color = "blue") +
    geom_line (mapping = aes(x= year, y=overall_mpg), color = "green") +
    facet_wrap(~drive) +
    xlab("YEAR") + ylab("AVERAGE MPG")
  

  #Problem 3
  #3-1
  vehicles %>%
    group_by(class, year) %>%
    summarize(emission = mean(co2emissions)) %>%
    ggplot() +
    geom_line(mapping = aes(x=year, y=emission), color = "red") +
    facet_wrap(~class)
  
  #This visualization attempts to explain the co2 emissions of different types of cars over the years.
  #It can be observed that the overall emissions is decreasing in most of the classes.
  #Smaller cars such as compact and subcompact cars have the lowest average co2 emissions whereas bigger cars like vans tend to have higher amount of emission.
  #There's been a sharp decrease for special purpose vehicles.
  
  
  #3-2
  vehicles %>%
    group_by(drive, transmissiontype) %>%
    summarize(emissions = mean(co2emissions)) %>%
    ggplot() +
    geom_col(mapping = aes(x=drive, y=emissions), fill = "orange") +
    facet_wrap(~transmissiontype)
  
  #Continuing with the co2 emissions, I wanted to explore which drive types is the most envronmentally friendly.
  #I also wated to see the differences between the automatic and the manual.
  #It seems that the Front-Wheel Drive causes the least pollution in both automatic and manual.
  #It could also be observed that automatic cars generally have higher co2 emissions than the manual cars. 
   