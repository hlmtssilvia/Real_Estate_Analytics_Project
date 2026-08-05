SELECT
    l.listing_id
    ,l.listing_status
    ,l.close_date
    ,t.deal_status
    ,t.deal_date
FROM listings l
JOIN transactions t
ON l.listing_id = t.listing_id
WHERE l.listing_status ='Active' AND t.deal_status IN ('Completed','Disputed');

UPDATE listings l
SET listing_status = 'Closed'
FROM transactions t
WHERE l.listing_id = t.listing_id
AND l.listing_status = 'Active' AND t.deal_status IN('Completed','Disputed');

UPDATE listings l
SET close_date = t.deal_date
FROM transactions t
WHERE l.listing_id = t.listing_id
AND t.deal_status IN ('Completed', 'Disputed')
AND l.close_date IS NULL;

SELECT COUNT(*)
FROM listings l
JOIN transactions t
ON l.listing_id = t.listing_id
WHERE l.listing_status = 'Active' AND t.deal_status IN ('Completed','Disputed');


UPDATE listings l
SET listing_status = 'Closed'
FROM (
    SELECT 
        l.listing_id,
        MIN(t.deal_date) AS first_deal_date
    FROM listings l
    JOIN transactions t
        ON l.property_id = t.property_id
        AND t.deal_date >= l.listing_date
    WHERE l.listing_status = 'Active'
    GROUP BY l.listing_id
) x
WHERE l.listing_id = x.listing_id
AND l.listing_status = 'Active';

UPDATE listings l
SET close_date = x.first_deal_date
FROM (
    SELECT
        l.listing_id,
        MIN(t.deal_date) AS first_deal_date
    FROM listings l
    JOIN transactions t
        ON l.property_id = t.property_id
       AND t.deal_date >= l.listing_date
    GROUP BY l.listing_id
) x
WHERE l.listing_id = x.listing_id
  AND l.listing_status = 'Closed'
  AND l.close_date IS NULL;

