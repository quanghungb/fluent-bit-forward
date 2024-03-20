# Fluent Bit forward test

## Introduction 
The objective is having this following chain 

|fluent-bit-shipper| -> |fluent-bit-aggregator| -> |final destination| 

where we will have 
* fluent-bit-shipper (see [fluent-bit-shipper.conf](./fluent-bit/fluent-bit-shipper.conf)):
    * uses `tail` input to ship the log 
    * uses `record_modifier` filter to enrich the data with the source metadata
    * displays the data by using `stdout` output for testing purpose
    * send the log to the aggregator through `forward` output

* fluent-bit-aggregator(see [fluent-bit-aggregator.conf](./fluent-bit/fluent-bit-aggregator.conf)):
    * uses `forward` input to receive the log 
    * uses `multiline` filter to parse the multiline log
    * uses `regex` parser to parse the log
    * simulate the final destination by using `file` output that will write file into the [output](./fluent-bit/output/) folder

The [parsers_multiline.conf](./fluent-bit/parsers_multiline.conf) is included. 

Except the regex for the parsing (that is specific to the data) most of configuration settings are extracted from the online official documentation https://docs.fluentbit.io/manual

## Run the test
**NOTE** Here the test has been executed with `podman-compose` but it should work with `docker compose`

```bash
podman-compose version 
podman-compose version: 1.0.6
['podman', '--version', '']
using podman version: 4.6.2
podman-compose version 1.0.6
podman --version 
podman version 4.6.2
exit code: 0
```

The containers configuration and all the mounted volumes are in the [docker-compose.yaml](./docker-compose.yaml)

The Fluent Bit shipper is tailing the logs file in the foler [log](./log/). 

### Launching the stack 
```bash
podman-compose up

podman start -a fluent-bit-forward_fluent-bit-aggregator_1
Fluent Bit v2.2.2
* Copyright (C) 2015-2024 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

____________________
< Fluent Bit v2.2.2 >
 -------------------
          \
           \
            \          __---__
                    _-       /--______
               __--( /     \ )XXXXXXXXXXX\v.
             .-XXX(   O   O  )XXXXXXXXXXXXXXX-
            /XXX(       U     )        XXXXXXX\
          /XXXXX(              )--_  XXXXXXXXXXX\
         /XXXXX/ (      O     )   XXXXXX   \XXXXX\
         XXXXX/   /            XXXXXX   \__ \XXXXX
         XXXXXX__/          XXXXXX         \__---->
 ---___  XXX__/          XXXXXX      \__         /
   \-  --__/   ___/\  XXXXXX            /  ___--/=
    \-\    ___/    XXXXXX              '--- XXXXXX
       \-\/XXX\ XXXXXX                      /XXXXX
         \XXXXXXXXX   \                    /XXXXX/
          \XXXXXX      >                 _/XXXXX/
            \XXXXX--__/              __-- XXXX/
             -XXXXXXXX---------------  XXXXXX-
                \XXXXXXXXXXXXXXXXXXXXXXXXXX/
                  ""VXXXXXXXXXXXXXXXXXXV""

[2024/03/20 22:45:43] [ info] [fluent bit] version=2.2.2, commit=eeea396e88, pid=1
[2024/03/20 22:45:43] [ info] [storage] ver=1.5.1, type=memory+filesystem, sync=normal, checksum=off, max_chunks_up=128
[2024/03/20 22:45:43] [ info] [storage] backlog input plugin: storage_backlog.1
[2024/03/20 22:45:43] [ info] [cmetrics] version=0.6.6
[2024/03/20 22:45:43] [ info] [ctraces ] version=0.4.0
[2024/03/20 22:45:43] [ info] [input:forward:forward.0] initializing
[2024/03/20 22:45:43] [ info] [input:forward:forward.0] storage_strategy='memory' (memory only)
[2024/03/20 22:45:43] [ info] [input:forward:forward.0] listening on 0.0.0.0:24284
[2024/03/20 22:45:43] [ info] [input:storage_backlog:storage_backlog.1] initializing
[2024/03/20 22:45:43] [ info] [input:storage_backlog:storage_backlog.1] storage_strategy='memory' (memory only)
[2024/03/20 22:45:43] [ info] [input:storage_backlog:storage_backlog.1] queue memory limit: 95.4M
[2024/03/20 22:45:43] [ info] [filter:multiline:multiline.0] created emitter: emitter_for_multiline.0
[2024/03/20 22:45:43] [ info] [input:emitter:emitter_for_multiline.0] initializing
[2024/03/20 22:45:43] [ info] [input:emitter:emitter_for_multiline.0] storage_strategy='filesystem' (memory + filesystem)
[2024/03/20 22:45:43] [ info] [sp] stream processor started
[2024/03/20 22:45:43] [ info] [output:file:file.0] worker #0 started
podman start -a fluent-bit-forward_fluent-bit-shipper_1
Fluent Bit v2.2.2
* Copyright (C) 2015-2024 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

____________________
< Fluent Bit v2.2.2 >
 -------------------
          \
           \
            \          __---__
                    _-       /--______
               __--( /     \ )XXXXXXXXXXX\v.
             .-XXX(   O   O  )XXXXXXXXXXXXXXX-
            /XXX(       U     )        XXXXXXX\
          /XXXXX(              )--_  XXXXXXXXXXX\
         /XXXXX/ (      O     )   XXXXXX   \XXXXX\
         XXXXX/   /            XXXXXX   \__ \XXXXX
         XXXXXX__/          XXXXXX         \__---->
 ---___  XXX__/          XXXXXX      \__         /
   \-  --__/   ___/\  XXXXXX            /  ___--/=
    \-\    ___/    XXXXXX              '--- XXXXXX
       \-\/XXX\ XXXXXX                      /XXXXX
         \XXXXXXXXX   \                    /XXXXX/
          \XXXXXX      >                 _/XXXXX/
            \XXXXX--__/              __-- XXXX/
             -XXXXXXXX---------------  XXXXXX-
                \XXXXXXXXXXXXXXXXXXXXXXXXXX/
                  ""VXXXXXXXXXXXXXXXXXXV""

[2024/03/20 22:45:44] [ info] [fluent bit] version=2.2.2, commit=eeea396e88, pid=1
[2024/03/20 22:45:44] [ info] [storage] ver=1.5.1, type=memory, sync=normal, checksum=off, max_chunks_up=128
[2024/03/20 22:45:44] [ info] [cmetrics] version=0.6.6
[2024/03/20 22:45:44] [ info] [ctraces ] version=0.4.0
[2024/03/20 22:45:44] [ info] [input:tail:tail.0] initializing
[2024/03/20 22:45:44] [ info] [input:tail:tail.0] storage_strategy='memory' (memory only)
[2024/03/20 22:45:44] [ info] [input:tail:tail.1] initializing
[2024/03/20 22:45:44] [ info] [input:tail:tail.1] storage_strategy='memory' (memory only)
[2024/03/20 22:45:44] [ info] [output:stdout:stdout.0] worker #0 started
[2024/03/20 22:45:44] [ info] [sp] stream processor started
[2024/03/20 22:45:44] [ info] [output:forward:forward.1] worker #1 started
[2024/03/20 22:45:44] [ info] [output:forward:forward.1] worker #0 started
[2024/03/20 22:45:44] [ info] [input:tail:tail.0] inotify_fs_add(): inode=2622158 watch_fd=1 name=/data/server.log
[2024/03/20 22:45:44] [ info] [input:tail:tail.1] inotify_fs_add(): inode=2622152 watch_fd=1 name=/data/system.log

```

### Simulating the log generation
There is a very simple bash script [generate_dummy_log.sh](./log/generate_dummy_log.sh) that simulates the log generation by the applications. 

It will write about `150k` lines (hard coded in the script) into the given file [system.log](./log/system.log) or [server.log](./log/server.log). Here we don't really care about the content of the log we want only the file is containing more than `100k` lines with the expected format. 

Example of output log (1 multiline log for every 5 log lines)
```bash
2024-03-04 01:29:09.533811 INFO Message line 1
2024-03-04 01:29:09.533811 INFO Message line 2
2024-03-04 01:29:09.533811 INFO Message line 3
2024-03-04 01:29:09.533811 INFO Message line 4
2024-03-04 01:29:09.533811 INFO Message multiline 5
 subline 5 - 1 
 subline 5 - 2
2024-03-04 01:29:09.533811 INFO Message line 6
```

Excute the command for generating the log (that could take some time) - The generated file should be around 8Mb.

```bash
cd log 
./generate_dummy_log.sh server.log
```

## Observation 

### Issue 1 - Output data does not contain enchired attributes
The shipper has enriched the log with new attributes `instance`, `host`, `source` like below 

```bash
[fluent-bit-shipper]    | [17] log-system: [[1710975265.255214778, {}], {"log"=>"2024-03-04 01:29:09.533811 INFO Message line 14", "host"=>"my-host", "instance"=>"126", "source"=>"system"}]
```

But the output data file does not contain these added attributes 
```bash
log-system: [1710975265.255214778, {"timestamp":"2024-03-04 01:29:09.533811","level":"INFO","log":"Message line 14"}]
```

### Issue 2 - Aggregator CPU usage is 100%
Before generating the log, the resource consumption is very low 

```bash
podman stats

ID            NAME                                        CPU %       MEM USAGE / LIMIT  MEM %       NET IO             BLOCK IO           PIDS        CPU TIME    AVG CPU %
388a3ad1031c  fluent-bit-forward_fluent-bit-shipper_1     0.11%       3.416MB / 16.49GB  0.02%       3.02kB / 3.831kB   0B / 0B            6           1.130557s   0.13%
a4ed4cdcc80d  fluent-bit-forward_fluent-bit-aggregator_1  0.07%       2.859MB / 16.49GB  0.02%       5.825kB / 1.318kB  6.627MB / 4.096kB  4           805.454ms   0.09%
```

By generating few lines, the resources consumption still stays low. 

But by generating some more significant logs (around `150k` lines), the `aggregator` CPU usage is inscreasing to  `100%` quite quickly

```bash
ID            NAME                                        CPU %       MEM USAGE / LIMIT  MEM %       NET IO             BLOCK IO           PIDS        CPU TIME    AVG CPU %
388a3ad1031c  fluent-bit-forward_fluent-bit-shipper_1     15.14%      5.96MB / 16.49GB   0.04%       12.64kB / 3.748MB  0B / 0B            6           2.48267s    0.24%
a4ed4cdcc80d  fluent-bit-forward_fluent-bit-aggregator_1  100.19%     5.997MB / 16.49GB  0.04%       3.749MB / 10.31kB  6.627MB / 1.978MB  4           7.403018s   0.71%
```

**NOTE** 
1. The total execution time is not measured but we can observe that the number of lines in the output data file is increasing very slowly (about 15~20 seconds for adding around 10k lines)
```bash
watch -n 1 "cat fluent-bit/output/log-server | wc -l"
```

2. The CPU usage goes back to normal after the processing

3. When the whole pipeline is processing on the same instance (without the `forward` input/output), we does not observe such CPU usage and eveything is working perfectly. 
