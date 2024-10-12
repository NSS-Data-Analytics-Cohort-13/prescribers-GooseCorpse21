1. 
    --a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
	-- SELECT *	FROM prescription
	-- SELECT MAX(npi) AS npi, COUNT(total_claim_count) AS total_claim_count
 --    FROM prescription
	-- WHERE total_claim_count IS NOT NULL;
	
	--My report shows that npi number 1992999791 has a total of 656058 claims making it the prescriber with highest number of claims
	
   SELECT DISTINCT npi
		,	SUM(total_claim_count) as total_claims
	FROM prescription
	GROUP BY npi
	ORDER BY total_claims DESC
	LIMIT 1;
	
   --b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
 --    SELECT MAX(p1.nppes_provider_first_name) AS nppes_first_name, MAX(p1.nppes_provider_last_org_name) AS nppes_last_org_name, MAX(p1.specialty_description) AS specialty_description, COUNT(p2.total_claim_count) AS total_claim_count
	-- FROM prescriber AS p1
	-- INNER JOIN prescription AS p2
	-- USING(npi) 
	-- WHERE p2.total_claim_count IS NOT NULL;
	
	SELECT nppes_provider_first_name,nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS total_claim_count_over_all_drugs
FROM prescription
INNER JOIN prescriber
ON prescriber.npi=prescription.npi
GROUP BY nppes_provider_first_name,nppes_provider_last_org_name, specialty_description
ORDER BY total_claim_count_over_all_drugs DESC

  2.
  	 --a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT p1.specialty_description, MAX(p2.total_claim_count_g) AS total_claim_count
	FROM prescriber AS p1
	INNER JOIN prescription AS p2
	USING(npi)
	WHERE p2.total_claim_count_ge65 IS NOT NULL
	GROUP BY p2.total_claim_count_ge65
	ORDER BY p2.total_claim_count_ge65 DESC;
	
     --b. Which specialty had the most total number of claims for opioids?
SELECT p.specialty_description, --p.npi, d.opioid_drug_flag, 
SUM(total_claim_count) as total_sum
FROM prescriber as p
INNER JOIN prescription as pr
ON p.npi=PR.npi
INNER JOIN drug as d
ON pr.drug_name=d.drug_name
WHERE d.opioid_drug_flag = 'Y'
GROUP BY 1 --2,3
ORDER BY total_sum DESC;

     --c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

     --d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

3. 
   --a. Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name
	, SUM(prescription.total_drug_cost) AS total_cost
FROM drug
INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name
WHERE prescription.total_drug_cost IS NOT NULL
GROUP BY drug.generic_name
ORDER BY total_cost DESC
LIMIT 10;

   --b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT drug.generic_name
		,	(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply)) :: MONEY as daily_drug_cost
	FROM prescription
		INNER JOIN drug
			USING (drug_name)
	GROUP BY drug.generic_name
	ORDER BY daily_drug_cost DESC
	
4. 
   --a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 
SELECT drug_name,
	CASE 
		WHEN d1.opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN d1.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' 
		END AS drug_type
FROM drug AS d1

   --b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT 
	CASE 
		WHEN opioid_drug_flag= 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag= 'Y' THEN 'antibiotic'
		ELSE 'neither'
		END as drug_type,
	SUM (total_drug_cost) ::MONEY
FROM drug
INNER JOIN prescription
ON drug.drug_name=prescription.drug_name
GROUP BY drug_type;

5. 
   -- a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(*) 
FROM fips_county AS f
INNER JOIN cbsa AS c
ON f.fipscounty = c.fipscounty
WHERE f.state = 'TN
  
  --b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

(
SELECT cbsaname, SUM(population) AS total_population, 'largest' as flag
FROM cbsa 
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC
limit 1
)
UNION
(
SELECT cbsaname, SUM(population) AS total_population, 'smallest' as flag
FROM cbsa 
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population 
limit 1
) order by total_population desc
  
  --c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT f.county, 
		f.state, 
		SUM(p.population) AS total_pop
FROM population AS p
INNER JOIN fips_county AS f
USING(fipscounty)
LEFT JOIN cbsa as c 
USING (fipscounty)
WHERE c.cbsaname IS NULL
GROUP BY f.county, 
		 f.state
ORDER BY total_pop DESC;

6. 
   --a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT p.drug_name, SUM(p.total_claim_count)
FROM prescription AS p
WHERE p.total_claim_count >=3000
GROUP BY p.drug_name
ORDER BY SUM(p.total_claim_count) DESC;

   --b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
 SELECT d.drug_name,
	       p.total_claim_count,d.opioid_drug_flag,
	 CASE
	 WHEN d.opioid_drug_flag = 'Y' THEN 'YES'
	 ELSE 'NO'
	 END AS is_opioid
	 FROM prescription P
	 INNER JOIN drug AS d
	 ON p.drug_name = d.drug_name
	WHERE total_claim_count >= 3000;
	
   --c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT total_claim_count,d.drug_name,CONCAT(pres.nppes_provider_last_org_name,' ',
		pres.nppes_provider_first_name) as prescriber_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
	WHEN opioid_drug_flag = 'N' THEN 'Not Opioid' END as opioid
FROM prescription as pr
INNER JOIN drug as d
ON pr.drug_name=d.drug_name
INNER JOIN prescriber as pres
ON pr.npi=pres.npi
WHERE total_claim_count >= 3000;

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.
SELECT 	p.npi
	, 	d.drug_name
FROM prescriber as p
CROSS JOIN drug as d
	WHERE 	p.specialty_description ='Pain Management' 
	AND 	p.nppes_provider_city = 'NASHVILLE' 
	AND 	d.opioid_drug_flag = 'Y'
	
    --a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT pr.npi
	,	d.drug_name
FROM prescriber AS pr
	INNER JOIN drug AS d 
		ON d.opioid_drug_flag = 'Y'
WHERE pr.specialty_description = 'Pain Management' 
    AND pr.nppes_provider_city = 'NASHVILLE';
	
   -- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
    SELECT prescriber.npi
		,	drug.drug_name
		,	SUM(prescription.total_claim_count) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;
	
    --c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
	SELECT prescriber.npi
		,	drug.drug_name
		,	COALESCE(SUM(prescription.total_claim_count), 0) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;