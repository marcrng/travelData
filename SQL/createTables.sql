# Create flights table
create table flights
(
    travelCode INT    not null,
    userCode   INT    not null,
    `from`     TEXT   null,
    `to`       TEXT   null,
    flightType TEXT   null,
    price      DOUBLE null,
    time       DOUBLE null,
    distance   DOUBLE null,
    agency     TEXT   null,
    date       text   null
);

# Create transaction table
create table transactions
(
    userCode int not null,
    travelCode int not null,
    transType varchar(255),
    vendor varchar(255),
    price double,
    reimbGroup int,
    datetime datetime
);

# Create users table
create table users
(
    code int not null primary key,
    company varchar(255),
    name varchar(255),
    gender char(1),
    age tinyint
);

# Update datatypes for existing tables
alter table users
modify column company varchar(255);

# Update dates to date format in flight table
update flights
set date = str_to_date(date, '%m/%d/%Y');

# Alter date column to date datatype in flight table
alter table flights
modify column `date` date;

# Add primary/foreign keys
alter table users
add primary key (code);

alter table flights
add foreign key (userCode) references users(code);

alter table hotels
add primary key (travelCode);

alter table hotels
add foreign key (userCode) references users(code);

alter table transactions
add foreign key (userCode) references users(code);

# Add internal/external booking method field flights and hotels
alter table flights
add column bookMethod varchar(50);

alter table hotels
add column bookMethod varchar(50);

# Add constraint to only allow internal/external as input for flights and hotels
alter table flights
add constraint chk_bookMethod check (bookMethod in ('internal', 'external'));

alter table hotels
add constraint chk_bookMethod check (bookMethod in ('internal', 'external'));

# Populate bookMethod with random inputs
update flights
# ELT chooses a string, while RAND produces a random int used for picking
set bookMethod = ELT(1 + RAND() * 1, 'internal', 'external');

update hotels
set bookMethod = ELT(1 + RAND() * 1, 'internal', 'external');

# Add ratings column to flights and hotels
alter table flights
add column rating tinyint;

alter table hotels
add column rating tinyint;

# Add random ratings to flights and hotels
update flights
# FLOOR returns the largest integer value <= to a number
set rating = FLOOR(RAND()*(5-0));

update hotels
set rating = FLOOR(RAND()*(5-0));

# Set ratings of 0 to null to indicate trips that weren't rated
update flights
set rating = null
where rating = 0;

update hotels
set rating = null
where rating = 0;


select company, count(*)
from users
group by company
