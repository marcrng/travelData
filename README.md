# Travel Data

---

## 1. | Description
A 3-day ad-hoc analysis of flight data meant to demonstrate my ability to quickly build visualizations using data related to the corporate travel sector using tools and methods that can easily scale to support projects with large datasets. 

Created using `SQL` for data storage and wrangling and `Tableau` for data visualization.

## 2. | Goals
Demonstrate ability to push out a minimum viable product within a short time period without calculation errors or broken features, as well as the understanding of the data process in the context of data analysis.

## 3. | Process
### 3.1 | Identifying KPI's
After doing some quick research on common KPI's in travel management, I decided to track:

- Use of approved booking channels
- Use of approved forms of payment
- Realized negotiated savings
- Cabin compliance/non-compliance
- Traveler satisfaction
- Carbon visibility
- Booking tool adoption

---
### 3.2 | Data Collection
I used a dataset from [Kaggle's 2019 Datathon](https://www.kaggle.com/datasets/leomauro/argodatathon2019?select=flights.csv) to provide some base data for our analysis.

This dataset featured 3 tables: `flights`, `hotels`, and `users`. 

#### 3.3 | Data Creation
##### Creating the tables
```sql
create table users
(
    code int not null primary key,
    company varchar(255),
    name varchar(255),
    gender char(1),
    age tinyint
);
```


---
I wasn't satisfied with the datapoints of the sample data, so I created some randomized data so tracking more of the above KPI's would be possible.
##### Adding and populating bookMethod Column
1. Added `bookMethod` column to `flights` and `hotels` to indicate if booking was made using companies internal tool
```sql
alter table flights
add column bookMethod varchar(50);  # Could have used a more efficient datatype
```

2. Added a constraint to both tables so only the values `internal` and `external` can be used in `bookMethod`
```sql
alter table flights
add constraint chk_bookMethod check (bookMethod in ('internal', 'external'));
```

3. Populated `bookMethod` with random values using `ELT()` and `RAND()` to limit random values to 'internal' and 'external'.
```sql
update flights
set bookMethod = ELT(1 + RAND() * 1, 'internal', 'external');
```
---

##### Adding and populating ratings column
1. Added `rating` column to `flights` and `hotels` to indicate ratings for each booking. `tinyint` was used since ratings won't exceed 255.
```sql
alter table flights
add column rating tinyint;
```

2. Populated `rating` with random integers using `RAND()`
```sql
update flights
set rating = FLOOR(RAND()*(5-0));
```

3. Set ratings of 0 to `null` to indicate bookings that weren't rated by the client
```sql
update flights
set rating = null
where rating = 0;
```
---
### 3.4 | Data Cleaning
Compared to previous projects, the data used here required minimal cleaning, since the source dataset was from a 2019 Kaggle competition. This meant that the data didn't have the usual issues found in raw collected data like misspellings, ambiguous entries, outliers due to inaccuracy, and lack of completeness/uniformity.

#### Updating datatypes
- Updating the `date` column in the `flights` table to the **date** datatype
```sql
# Update dates to date format in flight table
update flights
set date = str_to_date(date, '%m/%d/%Y');

# Alter date column to date datatype in flight table
alter table flights
modify column `date` date;
```

### 3.5 | Data Storing
Since an API wasn't used for this project, the data was first downloaded locally in `.csv` form, then uploaded to a mySQL Server. From there, the data was manipulated and then connected to Tableau.

### 3.6 | Exploratory Data Analysis
Since the data was already checked for completeness and accuracy prior to downloading it, there wasn't any need for EDA aimed at exploring data quality issues. 

However, I still conducted some EDA exploring the distribution of `price`, `distance`, `bookMethod`, `rating` and `age` columns in Tableau. All columns were normally distributed and `bookMethod` had a near 50/50 split 

### 3.7 | Initial Dashboard

---
#### Client names and internal booking tool utilization
The first sheet aimed to allow stakeholders to view, filter, and sort client data based on total bookings on record and percentage of bookings created using our internal tool vs. any other third-party tool.

![Names and internal tool utilization](img.png)

---
#### Total spend and bookings by quarter
The second sheet shows total spend on travel per quarter via a bar chart, and total bookings per quarter via a line above the bars. This graph filters dynamically based on which names are selected in the previous sheet.

![Total spend/count of bookings](img_1.png)

---
#### Ratings by quarter
This sheet displays the average ratings per quarter, and is also filtered by the name selection on the first sheet.

![Ratings by quarter](img_2.png)

---
#### Dynamic line graphs
These graphs allow stakeholders to choose which measures they want visualized, along with a pivot table showing the numbers between bookings made with our internal tool and without.

![Dynamic graph with PT](img_3.png)

- The flight/hotel measures selection menu was created using a user-defined parameter field, with a simple calculated field defining what should happen per the selection in 'Flight Measures'.

```sql
# Tableau Calculated Field

CASE [Flight Measures]
WHEN "Transactions" THEN SUM([Price])
WHEN "Booking Count" THEN COUNT([Price])
WHEN "Average Price" THEN AVG([Price])
WHEN "Running Sum" THEN RUNNING_SUM(SUM([Price]))
WHEN "Flight Time" THEN SUM([Time])
END
```
- Other simple calculated fields were used to split internal and external prices and percentages and to calculate total spend.
---


## 4. | Findings
- After filtering for clients with less than 100 flights, use of our internal tool hovers between 38% and 67%
  - Recommend surveying clients to discover why they aren't using the internal tool and what could be changed to increase utilization
  - Savings from higher internal tool adoption rates should justify the cost of conducting survey and updating internal booking tool
- Flight bookings have steadily decreased and have not yet shown any recovery
  - Re-evaluate future expectations for corporate travel 

## 5. | Future Possibilities
- Data on car rentals (pricing, duration, etc.)
- Data on compliance (e.g. first class bookings when only business class allowed in policy)
- Data on discounted/market rates to better emulate a real-world corporate travel program

## 6. | Things to Improve

- Visualizations clearly showing percent difference between periods above bar charts
- Confirm that data makes sense (larger distance flights correlated with longer time, etc.)
- Create auto-increment primary keys for data that is missing a key
- Reach at least third normal form of database normalization
