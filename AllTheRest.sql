USE sakila;
# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
show create table address;
/**
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
*/
  # Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT 
    staff.first_name, staff.last_name, address.address, city.city, country.country
FROM
    staff
        INNER JOIN
    address ON staff.address_id = address.address_id 
		INNER JOIN
	city ON address.city_id = city.city_id
		INNER JOIN
	country ON city.country_id = country.country_id;


# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT 
    staff.first_name, staff.last_name, SUM(payment.amount) AS revenue_received
FROM
    staff
        INNER JOIN
    payment ON staff.staff_id = payment.staff_id
WHERE
    payment.payment_date LIKE '2005-08%'
GROUP BY payment.staff_id;
# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT 
    title, COUNT(actor_id) AS number_of_actors
FROM
    film
        INNER JOIN
    film_actor ON film.film_id = film_actor.film_id
GROUP BY title;
# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT 
    title, COUNT(inventory_id) AS copies
FROM
    film
        INNER JOIN
    inventory ON film.film_id = inventory.film_id
WHERE
    title = 'Hunchback Impossible';
# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT 
    last_name, first_name, SUM(amount) AS totalpaid
FROM
    payment
        INNER JOIN
    customer ON payment.customer_id = customer.customer_id
GROUP BY payment.customer_id
ORDER BY last_name ASC;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title FROM film
WHERE language_id IN
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
AND (title LIKE "K%") OR (title LIKE "Q%");
# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT last_name, first_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id FROM film_actor
	WHERE film_id IN 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));
# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT 
    customer.last_name, customer.first_name, customer.email
FROM
    customer
        INNER JOIN
    customer_list ON customer.customer_id = customer_list.ID
WHERE
    customer_list.country = 'Canada';
# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT 
    title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_category
        WHERE
            category_id IN (SELECT 
                    category_id
                FROM
                    category
                WHERE
                    name = 'Family'));
# 7e. Display the most frequently rented movies in descending order.
SELECT 
    film.title, COUNT(*) AS 'rental_count'
FROM
    film,
    inventory,
    rental
WHERE
    film.film_id = inventory.film_id
        AND rental.inventory_id = inventory.inventory_id
GROUP BY inventory.film_id
ORDER BY COUNT(*) DESC, film.title ASC;
# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
    store.store_id, SUM(amount) AS money
FROM
    store
        INNER JOIN
    staff ON store.store_id = staff.store_id
        INNER JOIN
    payment ON payment.staff_id = staff.staff_id
GROUP BY store.store_id;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT 
    store.store_id, city.city, country.country
FROM
    store
        INNER JOIN
    address ON store.address_id = address.address_id
        INNER JOIN
    city ON address.city_id = city.city_id
        INNER JOIN
    country ON city.country_id = country.country_id;
# 7h. List the top five genres in gross revenue in descending order. (##Hint##: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
    name, SUM(pay.amount) AS revenue
FROM
    category cat
        INNER JOIN
    film_category filmc ON filmc.category_id = cat.category_id
        INNER JOIN
    inventory inv ON inv.film_id = filmc.film_id
        INNER JOIN
    rental ren ON ren.inventory_id = inv.inventory_id
        RIGHT JOIN
    payment pay ON pay.rental_id = ren.rental_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 5;
# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP VIEW IF EXISTS tpFive;
CREATE VIEW tpFive AS
SELECT 
    name, SUM(pay.amount) AS revenue
FROM
    category cat
        INNER JOIN
    film_category filmc ON filmc.category_id = cat.category_id
        INNER JOIN
    inventory inv ON inv.film_id = filmc.film_id
        INNER JOIN
    rental ren ON ren.inventory_id = inv.inventory_id
        RIGHT JOIN
    payment pay ON pay.rental_id = ren.rental_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 5;
# 8b. How would you display the view that you created in 8a?
select * from tpFive;
# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW tpFive;
