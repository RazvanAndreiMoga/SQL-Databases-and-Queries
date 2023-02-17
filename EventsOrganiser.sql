USE eventsData

drop table event
drop table country
drop table continent
drop table participant
drop table ticket

create table continent(
id int primary key,
name varchar(50) unique
);


create table country(
id int primary key,
name varchar(50) unique,
continent_id int foreign key references continent(id)
);

create table event(
id int primary key,
name varchar(50) unique,
eventdate date,
descript varchar(200),
cid int foreign key references country(id)
);

create table participant(
id int primary key,
name varchar(50),
dob date,
nationality varchar(50)
);

create table ticket(
pid int foreign key references participant(id),
eid int foreign key references event(id),
primary key(pid, eid)
);

create table CountryEvents(
cid int foreign key references country(id),
eid int foreign key references event(id),
primary key(cid, eid)
)

-- inserting some data


insert into continent values
(1,'A'),
(2,'B'),
(3,'C');

insert into country values
(1,'Romania',1),
(2,'CB',2),
(3,'CC',3),
(4,'CD',1);

insert into event values
(1,'EA','01.01.2000','EDA',1),
(2,'EB','02.02.2002','EDB',2),
(3,'EC','06.04.2010','EDC',3);

insert into participant values
(1,'PA','01.02.2000','PCA'),
(2,'PB','02.03.2010','PCB'),
(3,'PC','03.09.2004','PCC'),
(4,'PD','04.08.2003','PCD'),
(5,'PE','05.07.2005','PCE');


insert into ticket values
(1,1),
(2,2),
(3,3),
(1,2),
(2,3);

insert into CountryEvents values
(1,1),
(2,2);

--2

go
CREATE OR ALTER PROCEDURE addEvent(@eDate date, @eName varchar(50), @eDesc varchar(50), @eCountry INT)
AS
BEGIN
	
	IF @eCountry=NULL
		BEGIN
			SET @eCountry=1;
		END

	IF NOT EXISTS (SELECT* FROM country C WHERE C.id = @eCountry)
		BEGIN
			RAISERROR('No such country!',10,1);
		END

	IF EXISTS (SELECT* FROM event E WHERE E.name = @eName)
		BEGIN
			RAISERROR('Event already exists!',10,1);
		END


	INSERT into event values (10 ,@eName, @eDate, @eDesc, @eCountry);
END

exec addEvent '03.03.2002','EA','ED','A'

select * from event

exec addEvent '03.03.2002','EE','ED',NULL

select * from event

--3

go
create or alter view showEvents2023
AS
	SELECT *
	FROM event E
	WHERE e.eventdate <= '31.12.2023' AND e.eventdate >= '01.01.2023'


--4


go
create or alter function showEvents(@nr int)
RETURNS TABLE 
AS
RETURN
		SELECT C.name, count(SELECT *
								FROM country C inner join CountryEvents CE
								ON C.id = CE.cid
								GROUP BY C.name
							)
		FROM country C inner join CountryEvents CE
			ON C.id = CE.cid
		GROUP BY C.name
		HAVING count(CE.eid) >= @nr)

go
