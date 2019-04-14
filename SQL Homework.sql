USE sakila;

# OK let's do some queries!
#1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

#1b Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS `Actor Name` FROM actor;

#2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE 'Joe';

#2b Find all actors whose last name contain the letters GEN:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%gen%';

#2c Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name 
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name;

#2d this one is messed up cuz i thought we were doing actor stuff and now you want country info? cmon...
#Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT * 
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

#3a You want to keep a description of each actor. 
#You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB

ALTER TABLE actor
ADD COLUMN description BLOB;
SELECT * FROM actor;

#3b Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;
SELECT * FROM actor;

#4a  List the last names of actors, as well as how many actors have that last name.
SELECT last_name,
  COUNT(*) AS `count`
FROM
  actor
GROUP BY
  last_name;

#4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name,
  COUNT(*) AS `count`
FROM
  actor
GROUP BY
  last_name
HAVING `count` > 1;

#4c The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor SET `first_name` = 'Harpo' WHERE `first_name` = 'Groucho' AND `last_name` = 'Williams';

#4d Perhaps we were too hasty in changing GROUCHO to HARPO.
# It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor SET `first_name` = 'Groucho' WHERE `first_name` = 'Harpo' AND `last_name` = 'Williams';

#5a You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
#Here are the results from that query.  I'd use this if i needed to recreate it...
#'CREATE TABLE `address` (
#  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
#  `address` varchar(50) NOT NULL,
#  `address2` varchar(50) DEFAULT NULL,
#  `district` varchar(20) NOT NULL,
#  `city_id` smallint(5) unsigned NOT NULL,
#  `postal_code` varchar(10) DEFAULT NULL,
#  `phone` varchar(20) NOT NULL,
#  `location` geometry NOT NULL,
#  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#  PRIMARY KEY (`address_id`),
#  KEY `idx_fk_city_id` (`city_id`),
#  SPATIAL KEY `idx_location` (`location`),
#  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
#) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8'

#6a Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
# am i going to lose points for not using JOIN?  You can just select this ....
SELECT first_name, last_name, address FROM `staff`,`address` WHERE staff.address_id = address.address_id;
#fine ill do the join.....
SELECT staff.first_name, staff.last_name, address.address
FROM address
JOIN staff ON
staff.address_id = address.address_id;

#6b Do i really have to do the join?  cmon....  display the total amount rung up by each staff member in August of 2005
SELECT first_name, last_name, SUM(amount) from `staff`, `payment` WHERE staff.staff_id = payment.staff_id AND payment.payment_date BETWEEN '08/01/2005' AND '09/01/2005' GROUP BY staff.staff_id;
#Fine i'll do the join.....
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'Total Amount'
FROM payment
LEFT JOIN staff ON staff.staff_id = payment.staff_id
WHERE payment.payment_date BETWEEN '08/01/2005' AND '09/01/2005' 
GROUP BY payment.staff_id;

#6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS 'Number of Actors'
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

#6d How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, film.film_id, COUNT(inventory.film_id) AS 'Number of Copies'
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE film.title = 'HUNCHBACK IMPOSSIBLE';

#6e Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(amount)
FROM payment
JOIN customer on customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY customer.last_name ASC; 

#7a Find all english movies that start with K or Q (use subqueries)
#you can do this really easily in a single query...... I'm going to do it this way
SELECT title
FROM film
WHERE title LIKE 'K%' OR title LIKE 'Q%' AND language_id = '1';
# Ok here's the subquery version
SELECT title
 FROM film
 WHERE language_id = '1' AND title IN
    (
     SELECT title
     FROM film
     WHERE title LIKE 'K%' OR title LIKE 'Q%'
       );

#7b display all actors who appear in the film Alone Trip  I think it's easier to do this with joins.....
SELECT actor.first_name, actor.last_name
FROM actor
JOIN film_actor
ON film_actor.actor_id = actor.actor_id
JOIN film
ON film.film_id = film_actor.film_id
WHERE film.title = 'ALONE TRIP';

#7c  You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name
FROM customer
JOIN address
ON address.address_id = customer.customer_id
JOIN city
ON city.city_id = address.city_id
JOIN country
ON country.country_id = city.country_id 
WHERE country.country = 'Canada';

#7d Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT film.title
FROM film
JOIN film_category
ON film_category.film_id = film.film_id
JOIN category
ON film_category.category_id = category.category_id
WHERE category.name = 'Family';

#7e Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.inventory_id) AS 'Number of Rentals'
FROM rental
JOIN inventory
ON rental.inventory_id = inventory.inventory_id
JOIN film
ON inventory.film_id = film.film_id
GROUP BY rental.inventory_id
ORDER BY `Number of Rentals` DESC;
    
#7f Write a query to display how much business, in dollars, each store brought in.  Well since there's only one employee per store, i can take the lazy approach and do this by staff
SELECT first_name, last_name, SUM(amount) from `staff`, `payment` WHERE staff.staff_id = payment.staff_id GROUP BY staff.staff_id;
#Fine i'll do the join.....
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'Total Amount'
FROM payment
LEFT JOIN staff ON staff.staff_id = payment.staff_id
GROUP BY staff.staff_id;

#7g  Write a query to display for each store its store ID, city, and country.
SELECT store_id, city.city, country.country
FROM store
JOIN address ON store.address_id = address.address_id
JOIN city ON address.city_id= city.city_id
JOIN country ON city.country_id = country.country_id;


#7h List the top five genres in gross revenue in descending order.
SELECT category.name, SUM(payment.amount) AS revenue
FROM payment
JOIN rental ON payment.rental_id = rental.rental_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film_category ON inventory.film_id = film_category.film_id
JOIN category ON category.category_id = film_category.category_id
GROUP BY category.category_id
ORDER BY revenue DESC LIMIT 5;



#8a  How do you create that as a data view....
CREATE VIEW top_categories AS
SELECT category.name, SUM(payment.amount) AS revenue
FROM payment
JOIN rental ON payment.rental_id = rental.rental_id
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film_category ON inventory.film_id = film_category.film_id
JOIN category ON category.category_id = film_category.category_id
GROUP BY category.category_id
ORDER BY revenue DESC LIMIT 5;


#8b How would you show the view?
SELECT * FROM top_categories;

#8c How would you delete the view? 
DROP VIEW top_categories;
