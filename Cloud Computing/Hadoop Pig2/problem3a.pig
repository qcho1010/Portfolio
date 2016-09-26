register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/cse344-test-file' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

filtered = FILTER ntriples by subject matches '.*business.*' PARALLEL 50;
copy = foreach filtered generate $0 as subject2, $1 as predicate2, $2 as object2 PARALLEL 50;

chained = JOIN filtered BY subject, copy BY subject2 PARALLEL 50;

final = DISTINCT chained PARALLEL 50;

store final into '/tmp/problem3a.results' using PigStorage();