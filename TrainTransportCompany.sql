USE Seminar6

drop table routeStation
drop table route
drop table station
drop table train
drop table trainType

create table trainType(
id int primary key,
name varchar(30),
description varchar(50),
);

create table train(
id int primary key,
ttid int foreign key references trainType(id),
name varchar(30)
);

create table station(
id int primary key,
name varchar(30) unique
);

create table route(
id int primary key,
tid int,
name varchar(30) unique,
foreign key (tid) references train(id)
);

create table routeStation(
sid int foreign key references station(id),
rid int foreign key references route(id),
arrival time,
departure time,
primary key(sid, rid)
);

-- inserting some data


insert into trainType values
(1,'A',null),
(2,'B',null),
(3,'C',null);

insert into train values
(1,1,'TA'),
(2,2,'TB'),
(3,3,'TC'),
(4,1,'TA2');

insert into station values
(1,'S1'),
(2,'S2'),
(3,'S3');

insert into route values
(1,1,'R1'),
(2,2,'R2'),
(3,3,'R3'),
(4,4,'R4'),
(5,1,'R5'),
(6,1,'R6'),
(7,2,'R7');

insert into routeStation values
(1,1,'5:10','5:30'),
(2,1,'5:10','6:10'),
(3,1,'6:10','7:10'),
(2,2,'6:10','6:40'),
(3,3,'10:20','10:40');


-- 2. Implement a stored procedure that receives a route, a station, arrival and departure times, and adds the station to the route.
--    If the station is already on the route, the departure and arrival times are updated.


go
create or alter procedure addORupdateRouteStation(@rName varchar(30), @sName varchar(30), @arrival time, @departure time)
as
begin

	IF NOT EXISTS (SELECT* FROM route R WHERE R.name = @rName)
		BEGIN
			RAISERROR('Invalid route name!',16,1)
		END
	
	IF NOT EXISTS (SELECT* FROM station S WHERE S.name = @sName)
		BEGIN
			RAISERROR('Invalid station name!', 16, 1)
		END

	DECLARE @routeID int = (SELECT R.id
						FROM route R
						WHERE R.name = @rName)

	DECLARE @stationID int = (SELECT S.id
								FROM station S
								WHERE S.name = @sName)

	IF EXISTS (SELECT *
				FROM routeStation RS
				WHERE RS.rid = @routeID AND RS.sid = @stationID)

		UPDATE routeStation
		SET arrival = @arrival, departure = @departure
		WHERE rid = @routeID AND sid = @stationID

	ELSE
		INSERT into routeStation values (@stationID, @routeID, @arrival, @departure)

end
go

exec addORupdateRouteStation 'R1001','S1','6:10','6:15'

select * from routeStation

exec addORupdateRouteStation 'R4','S1','6:10','6:15'

select * from routeStation

exec addORupdateRouteStation 'R4','S1','7:10','8:15'

select * from routeStation

-- 3. Create a view that shows the names of the routes that pass through all the stations.

go
create or alter view showRoutes
AS
	
	SELECT R.name as Name
	FROM route R inner join routeStation RS
		ON R.id = RS.rid
	GROUP BY R.name
	HAVING count(RS.sid) = (SELECT DISTINCT count(id)
						FROM station)
						
GO

SELECT *
FROM showRoutes

-- 4. Implement a function that lists the names of the stations with more than R routes, where R is a function parameter.


go
create or alter function showStations(@nr int)
RETURNS TABLE 
AS
RETURN
	SELECT S.name
	FROM station S inner join routeStation RS
		ON S.id = RS.sid
	GROUP BY S.name
	HAVING count(RS.rid) > @nr

go

SELECT *
FROM showStations(1)