use foodonline;

-- cau a --
CREATE VIEW Food_Info AS
	SELECT f.food_name, f.food_price, r.restaurant_name, t.food_type
    FROM restaurants r, foods f, typeoffood t
    WHERE f.restaurant_id=r.restaurant_id 
			AND f.type_of_food_id=t.type_of_food_id;
    
SELECT * FROM Food_Info;
-- cau  b --

DELIMITER $$
CREATE FUNCTION TotalFood(
	cust_id INT
)
RETURNS INT 
DETERMINISTIC
BEGIN 
	DECLARE Total_Food INT;
    SELECT COUNT(food_id) INTO Total_Food
    FROM order_food O
    WHERE customer_id=cust_id
    GROUP BY customer_id;
    RETURN (Total_Food);
END$$
DELIMITER ;

SELECT TotalFood(1);

-- CAU C--
DELIMITER $$
CREATE FUNCTION order_food_Date(
	FoodId INT,
    cust_id INT
)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN 
	DECLARE value_date VARCHAR(100);
    SELECT concat('FROM ', order_date,' TO ', delivery_date) 
    INTO value_date
    FROM order_food
    WHERE food_id=FoodId
			AND customer_id=cust_id;
    RETURN value_date; 
   
END$$
DELIMITER ;

SELECT order_food_Date(1,2);

-- CAU D--
DELIMITER $$
CREATE PROCEDURE Order_Food_Update_Message ()
BEGIN 
	DECLARE finished INTEGER DEFAULT 0;
    DECLARE cust_Id INT;
	DECLARE fd_Id INT;
    DECLARE date_Order TIMESTAMP;
    DECLARE deli_Date TIMESTAMP;
    
    DEClARE curMessage  CURSOR FOR SELECT customer_id, food_id, order_date, delivery_date
									FROM order_food; 
                                    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
 
    OPEN curMessage;
    WHILE finished = 0 DO
		FETCH curMessage 
			INTO cust_Id, fd_Id,date_Order, deli_Date;
        
		IF TIMESTAMPDIFF(day,date_Order,deli_Date) >7 THEN
			UPDATE order_food SET message="It's late" 
				WHERE customer_id=cust_Id AND food_id = fd_Id;
        END IF;
        
	END WHILE;
    CLOSE curMessage;
END$$
DELIMITER ;
CALL Order_Food_Update_Message;
SELECT * FROM order_food;

-- CAU E --
DELIMITER $$
CREATE PROCEDURE Update_Food_Price ()
BEGIN
	DECLARE finished INTEGER DEFAULT 0;
    DECLARE type_Food VARCHAR(100);
    DECLARE fd_id INT;
    DECLARE fd_Price FLOAT;
    
    DEClARE curPrice CURSOR FOR SELECT  food_id, food_price, food_type
									FROM foods, typeoffood 
                                    WHERE foods.type_of_food_id = typeoffood.type_of_food_id;
                                    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
 
    OPEN curPrice;
    WHILE finished = 0 DO
		FETCH curPrice 
			INTO fd_id, fd_Price,type_Food;
        
		IF (type_Food="dish" AND fd_Price<100000) THEN
			UPDATE foods SET food_price= food_price+ food_price*0.2
				WHERE food_id=fd_id;
			ELSEIF (type_Food="drink" AND fd_Price>100000) THEN
				UPDATE foods SET food_price= food_price+ food_price*0.1
					WHERE food_id=fd_id;
        END IF;
        
	END WHILE;
    CLOSE curPrice;
END$$
DELIMITER ;
CALL Update_Food_Price;
SELECT * FROM foods;