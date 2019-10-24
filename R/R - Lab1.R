library(tidyverse)
college <- read_csv("http://s3.amazonaws.com/itao-30230/college.csv")

college$state <- as.factor(college$state)
college$region <- as.factor(college$region)
college$highest_degree <- as.factor(college$highest_degree)
college$control <- as.factor(college$control)
college$gender <- as.factor(college$gender)
college$loan_default_rate <- as.numeric(college$loan_default_rate)



#Create a scatterplot with tuition on the x-axis and loan default rate on the y-axis 
ggplot(data = college) + 
  geom_point(mapping = aes(x = tuition, y=loan_default_rate))


#Enhance your scatterplot by fitting a line to the data
ggplot(data = college) + 
  geom_point(mapping = aes(x = tuition, y=loan_default_rate)) +
  geom_smooth(mapping = aes(x = tuition, y=loan_default_rate))

ggplot(data = college, mapping = aes(x = tuition, y=loan_default_rate)) + 
  geom_point() +
  geom_smooth()


#Change the color of the points to represent the region without altering the line
ggplot(data = college) + 
  geom_point(mapping = aes(x = tuition, y=loan_default_rate, color = region)) +
  geom_smooth(mapping = aes(x = tuition, y=loan_default_rate))

ggplot(data = college, mapping = aes(x = tuition, y=loan_default_rate)) + 
  geom_point(mapping=aes(color=region)) +
  geom_smooth()

#Produce a statistical summary of all of the schools with a loan default rate over 20%
college %>%
  filter(loan_default_rate>175) %>%
  summary()

#Fit a line to the data showing median debt on the x-axis and loan default rate on the y-axis
ggplot(data = college, mapping = aes(x = median_debt, y=loan_default_rate)) + 
  geom_point(mapping=aes(color=region)) +
  geom_smooth()

##Create the box plot showing faculty salary broken out by the highest degree awarded by the institution
ggplot(data = college, mapping = aes(x = name, y=median_debt)) + 
  geom_boxplot()

#Create a new data frame that contains only institutions with a faculty salary over $10k/month, sorted in desc order 
#of salary and including only the institution name, state, and average salary

HIGH_SALARY <- college%>%
  filter(faculty_salary_avg > 10000) %>%
  arrange(desc(faculty_salary_avg)) %>%
  select(name, state, faculty_salary_avg)


#Create a new data frame showing the number of high salary schools in each state. 
HIGH_SALARY_BY_STATE <- HIGH_SALARY %>%
  group_by(state) %>%
  summarize(count = n()) %>%
  arrange (desc(count))

#Create a new data frame showing the number of high salary schools in each state. 
HIGH_SALARY_BY_STATE_2 <- HIGH_SALARY %>%
  group_by(state) %>%
  summarize(count = n()) %>%
  arrange (desc(count))


#Produce a data frame summarizing the total number of schools in each state
count_school <- college %>%
  group_by(state) %>%
  summarize(count = n()) %>%
  arrange (desc(count))

#Join the two previous data frames together so that you a record for every state
augmented_state_data <- count_school %>%
  left_join(HIGH_SALARY_BY_STATE, by = 'state')
augmented_state_data

#NEED TO GO OVRE!!!
#Create column containing the % of schools in each state that are high salary, 
#sort by that percentage in descending ordr and only show states where the value is 30% or higher
augmented_state_data <- augmented_state_data %>%
  rename(schools = count.x, HIGH_SALARY_BY_STATE = count.y)

augmented_state_data <- augmented_state_data %>%
  mutate(high_salary_percent = HIGH_SALARY_BY_STATE/count_school*100) %>%
  arrange(desc(high_salary_percent)) %>%
  filter(high_salary_percent >= .3)
  




