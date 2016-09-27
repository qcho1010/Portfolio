register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);
subjects = group ntriples by (subject) PARALLEL 50;
count_by_subject = foreach subjects generate flatten($0), COUNT($1) as count PARALLEL 50;
group_by_occurrence = group count_by_subject by count PARALLEL 50;
occurrence_n_subject = foreach group_by_occurrence generate flatten($0), COUNT($1) PARALLEL 50;
store occurrence_n_subject into '/user/hadoop/problem2b.results' using PigStorage();