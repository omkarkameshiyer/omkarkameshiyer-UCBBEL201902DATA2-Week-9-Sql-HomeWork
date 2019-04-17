USE sakila;
desc  actor;
# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor ADD description BLOB;
desc  actor;
# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor DROP COLUMN description;
desc  actor;
# 4a. List the last names of actors, as well as how many actors have that last name.
select distinct last_name, count(last_name) as countOfLastName from actor group by last_name;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared 
#by at least two actors
SELECT DISTINCT
    last_name, COUNT(last_name) AS 'name_count'
FROM
    actor
GROUP BY last_name 
HAVING name_count >= 2;


# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
#Write a query to fix the record.
SET @idForUpdate =( select actor_id as actor_id from actor where first_name='GROUCHO' and last_name = 'WILLIAMS' );

UPDATE actor
SET first_name = 'HARPO' 
where actor_id = @idForUpdate;
select actor_id as actor_id from actor where first_name='GROUCHO' and last_name = 'WILLIAMS';
select actor_id as actor_id from actor where first_name='HARPO' and last_name = 'WILLIAMS';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
#In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor
SET first_name = 'GROUCHO' 
where first_name = 'HARPO';
select actor_id as actor_id from actor where first_name='GROUCHO' and last_name = 'WILLIAMS';
select actor_id as actor_id from actor where first_name='HARPO' and last_name = 'WILLIAMS';


