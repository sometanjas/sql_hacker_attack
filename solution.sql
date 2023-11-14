CREATE TABLE "person"(
  "person_id" VARCHAR(9) PRIMARY KEY,
  "full_name" TEXT,
  "address" TEXT,
  "building_number" TEXT,
  "phone_number" TEXT
);
.mode csv
.import --skip 1 person.csv person
.mode column

CREATE TABLE "teacher"(
  "person_id" VARCHAR(9) PRIMARY KEY,
  "class_code" TEXT
);
.mode csv
.import --skip 1 teacher.csv teacher
.mode column

CREATE TABLE "student"(
"person_id" VARCHAR(9) PRIMARY KEY,
"grade_code" TEXT
);

INSERT INTO student(person_id)
SELECT person_id 
FROM person
WHERE person_id not in (SELECT person_id FROM teacher);

CREATE TABLE "score1"(
"person_id" VARCHAR(9),
"score" INTEGER
);
.mode csv
.import --skip 1 score1.csv score1
.mode column

CREATE TABLE "score2"(
"person_id" VARCHAR(9),
"score" INTEGER
);
.mode csv
.import --skip 1 score2.csv score2
.mode column

CREATE TABLE "score3"(
"person_id" VARCHAR(9),
"score" INTEGER
);
.mode csv
.import --skip 1 score3.csv score3
.mode column


CREATE TABLE "score"(
"person_id" VARCHAR(9),
"score" INTEGER
);

INSERT INTO score(person_id, score)
SELECT person_id, score
FROM (
SELECT person_id, score
FROM score1 
UNION ALL
SELECT person_id, score
FROM score2
UNION ALL
SELECT person_id, score
FROM score3
);

DROP TABLE score1;
DROP TABLE score2;
DROP TABLE score3;

UPDATE student
SET grade_code = 'GD-09'
WHERE student.person_id not in (SELECT person_id FROM score
GROUP BY person_id
HAVING count(score) IS NULL);

UPDATE student
SET grade_code = 'GD-10'
WHERE student.person_id in (SELECT person_id FROM score
GROUP BY person_id
HAVING count(score) = 1);

UPDATE student
SET grade_code = 'GD-11'
WHERE student.person_id in (SELECT person_id FROM score
GROUP BY person_id
HAVING count(score) = 2);

UPDATE student
SET grade_code = 'GD-12'
where student.person_id in (SELECT person_id FROM score
GROUP BY person_id
HAVING count(score) = 3);

with cte as (SELECT student.person_id FROM student WHERE grade_code = 'GD-12')

SELECT score.person_id, ROUND(AVG(score.score), 2) as avg_score
FROM score
INNER JOIN cte
ON cte.person_id = score.person_id
GROUP BY score.person_id
ORDER BY avg_score DESC
