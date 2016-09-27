register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

-- load the test file into Pig
raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray);
-- later you will load to other files, example:
--raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray); 

-- parse each line into ntriples
ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

--group the n-triples by object column
objects = group ntriples by (object) PARALLEL 50;

-- flatten the objects out (because group by produces a tuple of each object
-- in the first column, and we want each object to be a string, not a tuple),
-- and count the number of tuples associated with each object
count_by_object = foreach objects generate flatten($0), COUNT($1) as count PARALLEL 50;

--order the resulting tuples by their count in descending order
count_by_object_ordered = order count_by_object by (count)  PARALLEL 50;

-- store the results in the folder /user/hadoop/problem1-results
store count_by_object_ordered into '/user/hadoop/problem1-results' using PigStorage();
-- Alternatively, you can store the results in S3, see instructions:
-- store count_by_object_ordered into 's3n://superman/example-results';


-------------------------------------------------------------------------------

Problem 2a Pig Code

register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/cse344-test-file' USING TextLoader as (line:chararray);

ntriples = FOREACH raw GENERATE FLATTEN(myudfs.RDFSplit3(line)) AS (subject:chararray,predicate:chararray,object:chararray);

group_subject = GROUP ntriples BY (subject);
-- When I run GROUP, subject becomes the group key. 

subject_counts = FOREACH group_subject GENERATE group AS subject, COUNT(ntriples) AS subject_count;
-- Related to the point above, group is subject.
-- The schema here is: {subject:chararray,subjectcount:long}

group_by_counts = GROUP subject_counts BY (subject_count);
-- The schema here is:  {group: long,subject_counts: {(subject: chararray,subject_count: long)}}

histogram_2a = FOREACH group_by_counts GENERATE group as count_distribution, COUNT(subject_counts) as different_subjects_with_this_count;

store histogram_2a into '/user/hadoop/Problem2a' using PigStorage();

------------------------------------------------------------------------------------
Problem 2b Pig Code

set io.sort.mb 10;
-- to avoid java.lang.OutOfMemoryError: Java heap space (execmode: -x local)

register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray); 

ntriples = FOREACH raw GENERATE FLATTEN(myudfs.RDFSplit3(line)) AS (subject:chararray,predicate:chararray,object:chararray);

group_subject = GROUP ntriples BY (subject);
-- When I run GROUP, subject becomes the group key. 

subject_counts = FOREACH group_subject GENERATE group AS subject, COUNT(ntriples) AS subject_count;
-- Related to the point above, group is subject.
-- The schema here is: {subject:chararray,subjectcount:long}

group_by_counts = GROUP subject_counts BY (subject_count);
-- The schema here is:  {group: long,subject_counts: {(subject: chararray,subject_count: long)}}

histogram_2a = FOREACH group_by_counts GENERATE group AS count_distribution, COUNT(subject_counts) AS different_subjects_with_this_count;
-- Notice the care we take with schemas. We must match schemas, define new schemas, etc. We must understand how we want the data/output of a function in Pig to be represented. 

store histogram_2a into '/user/hadoop/Problem2a' using PigStorage();

------------------------------------------------------------------------------------------------
Problem 3 Pig Code

For the smaller test file: 
set io.sort.mb 10;
-- to avoid java.lang.OutOfMemoryError: Java heap space (execmode: -x local)

register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/cse344-test-file' USING TextLoader as (line:chararray);

ntriples = FOREACH raw GENERATE FLATTEN(myudfs.RDFSplit3(line)) AS (subject:chararray,predicate:chararray,object:chararray);

n_triples_filtered = FILTER ntriples BY subject MATCHES '.*business.*';
-- I have now filtered the data to be all the matches for my subject. 

n_triples_filtered_copy = FOREACH n_triples_filtered GENERATE * AS  (subject2:chararray,predicate2:chararray,object2:chararray);
-- This creates a copy of the filtered triples with a relabelled schema

Two_chainz = JOIN n_triples_filtered BY subject, n_triples_filtered_copy BY subject2; 

Two_chainza = DISTINCT Two_chainz;

STORE Two_chainza into '/user/hadoop/Problem3aaa' using PigStorage();


For the larger chunk file:
set io.sort.mb 10;
-- to avoid java.lang.OutOfMemoryError: Java heap space (execmode: -x local)

register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray); 

ntriples = FOREACH raw GENERATE FLATTEN(myudfs.RDFSplit3(line)) AS (subject:chararray,predicate:chararray,object:chararray);

n_triples_filtered = FILTER ntriples BY subject MATCHES '.*rdfabout\\.com.*';
-- I have now filtered the data to be all the matches for my object. 

n_triples_filtered_copy = FOREACH n_triples_filtered GENERATE * AS (subject2:chararray, predicate2:chararray, object2:chararray);
-- This creates a copy of the filtered triples with a relabelled schema

Two_chainz = JOIN n_triples_filtered BY object, n_triples_filtered_copy BY subject2; 

Two_chainzb = DISTINCT Two_chainz;

STORE Two_chainzb into '/user/hadoop/Problem3bbb' using PigStorage();

--------------------------------------------------------------------------------------------------
Problem 4 Pig Code

set io.sort.mb 10;
-- to avoid java.lang.OutOfMemoryError: Java heap space (execmode: -x local)

register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-*' USING TextLoader as (line:chararray);

ntriples = FOREACH raw GENERATE FLATTEN(myudfs.RDFSplit3(line)) AS (subject:chararray,predicate:chararray,object:chararray);

group_subject = GROUP ntriples BY (subject);
-- When I run GROUP, subject becomes the group key. 

subject_counts = FOREACH group_subject GENERATE group AS subject, COUNT(ntriples) AS subject_count;
-- Related to the point above, group is subject.
-- The schema here is: {subject:chararray,subjectcount:long}

group_by_counts = GROUP subject_counts BY (subject_count);
-- The schema here is:  {group: long,subject_counts: {(subject: chararray,subject_count: long)}}

histogram_4 = FOREACH group_by_counts GENERATE group AS count_distribution, COUNT(subject_counts) AS different_subjects_with_this_count;
-- Notice the care we take with schemas. We must match schemas, define new schemas, etc. We must understand how we want the data/output of a function in Pig to be represented. 

store histogram_4 into '/user/hadoop/Problem4' using PigStorage();