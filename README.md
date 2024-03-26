# Fluent Bit forward test

## Introduction 
The objective is having this following chain 

|fluent-bit-shipper| -> |fluent-bit-aggregator| -> |final destination| 

where we will have 
* fluent-bit-shipper (see [fluent-bit-shipper.yaml](./fluent-bit/fluent-bit-shipper.yaml)):
    * uses `tail` input to ship the log 
    * uses the `modify` processor to enrich the data with the source metadata
    * enable the `stdout` output for testing purpose
    * send the log to the aggregator through `forward` output

* fluent-bit-aggregator(see [fluent-bit-aggregator.yaml](./fluent-bit/fluent-bit-aggregator.yaml)):
    * uses `forward` input to receive the log 
    * uses `multiline` filter to parse the multiline log
    * uses `regex` parser to parse the log
    * simulate the final destination by using `file` output that will write file into the [output](./fluent-bit/output/) folder

The [parsers_multiline.conf](./fluent-bit/parsers_multiline.conf) is included. 

Except the regex for the parsing (that is specific to the data) most of configuration settings are extracted from the online official documentation https://docs.fluentbit.io/manual


## Upgrade to v3
**IMPORTANT**
Here we are using the `YAML` configuration files. But inside the container there is the `/fluent-bit/etc/fluent-bit.conf` file that is taken in account by default. Therefore the mounted `YAML` config file is not used. 

That's why we cannot use the [docker-compose.yaml](./docker-compose.yaml). We have to run the container invidually via the scripts [run-shipper.sh](run-shipper.sh) and [run-aggregator.sh](run-aggregator.sh)

In that case we have to create a network first 
```bash
podman create network fluent-bit-network
```


## Run the test
**NOTE** Here the test has been executed with `podman` but it should work with `docker`

```bash
podman --version
podman version 5.0.0
```


The Fluent Bit shipper is tailing the logs file in the foler [log](./log/). 

### Launching the stack 
#### The shipper
```bash
./run-shipper.sh
Fluent Bit v3.0.0
* Copyright (C) 2015-2024 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

___________.__                        __    __________.__  __          ________  
\_   _____/|  |  __ __   ____   _____/  |_  \______   \__|/  |_  ___  _\_____  \ 
 |    __)  |  | |  |  \_/ __ \ /    \   __\  |    |  _/  \   __\ \  \/ / _(__  < 
 |     \   |  |_|  |  /\  ___/|   |  \  |    |    |   \  ||  |    \   / /       \
 \___  /   |____/____/  \___  >___|  /__|    |______  /__||__|     \_/ /______  /
     \/                     \/     \/               \/                        \/ 

```

#### The aggregator
```bash
./run-aggregator.sh
Fluent Bit v3.0.0
* Copyright (C) 2015-2024 The Fluent Bit Authors
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

___________.__                        __    __________.__  __          ________  
\_   _____/|  |  __ __   ____   _____/  |_  \______   \__|/  |_  ___  _\_____  \ 
 |    __)  |  | |  |  \_/ __ \ /    \   __\  |    |  _/  \   __\ \  \/ / _(__  < 
 |     \   |  |_|  |  /\  ___/|   |  \  |    |    |   \  ||  |    \   / /       \
 \___  /   |____/____/  \___  >___|  /__|    |______  /__||__|     \_/ /______  /
     \/                     \/     \/               \/                        \/ 
```

### Simulating the log generation
There is a very simple bash script [generate_dummy_log.sh](./log/generate_dummy_log.sh) that simulates the log generation by the applications. 

It will write log lines into the given file [system.log](./log/system.log) or [server.log](./log/server.log). Here we don't really care about the content of the log we want only the file is containing more than `100k` lines with the expected format. 

Example of output log (1 multiline log for every 5 log lines)
```bash
2024-03-24 01:11:19.553048 INFO Message line 1711239079_1
2024-03-24 01:11:19.556354 INFO Message line 1711239079_2
2024-03-24 01:11:19.559247 INFO Message line 1711239079_3
2024-03-24 01:11:19.562035 INFO Message line 1711239079_4
2024-03-24 01:11:19.564393 ERROR Message multiline error 1711239079_5
 subline 1711239079_5 - 1 
 subline 1711239079_5 - 2
2024-03-24 01:11:19.566622 INFO Message line 1711239079_6
```

Excute the command for generating the `150000` log lines (that could take some time) - The generated file should be around 8Mb.

```bash
cd log 
./generate_dummy_log.sh server.log 150000
```

## Observation 

### Issue 1 - Output data does not contain enriched attributes

The shipper has enriched the log with new attributes `instance`, `host`, `source` like below 

```bash
log.server: [[1711239392.273359423, {}], {"log"=>"2024-03-24 01:16:31.785293 INFO Message line 1711239391_1", "host"=>"9fb58ffe8fd7", "source"=>"server"}]
```


If in the `aggregator` config file, we added the `parser` in `filters` like below. As there are missing data, we tried some configurations and reported the observation.

```yaml
pipeline:
  inputs:
    - name: forward
      listen: 0.0.0.0
      port: 24284
      processors:
        logs:
          - name: multiline
            multiline.parser: multiline-regex-log-with-date-in-timestamp
            multiline.key_content: log
            emitter_storage.type: filesystem
            emitter_mem_buf_limit: 100M

          - name: parser
            Key_Name: log
            Parser: log-with-date-in-timestamp
  
  filters:
     - name: parser
       Match: "log.*"
       Key_Name: log
       Parser: log-with-date-in-timestamp

```

But there are some issues with the aggregator **output data**

| Aggregator Configuration | Structured log | Enriched data |
|-|-|-|
|Parser only present in the processor| **No** | Yes |
|Parser only prensent as filter in `filters:` | Yes | **Missing** |
|Parser present in both part of the processor and as filter | Yes | **Missing** |  



### Issue 2 - Aggregator CPU usage is 100%
Before generating the log, the resource consumption is very low 

```bash
podman stats
ID            NAME            CPU %       MEM USAGE / LIMIT  MEM %       NET IO             BLOCK IO    PIDS        CPU TIME      AVG CPU %
22f9291fcd85  flb-shipper     0.06%       4.35MB / 2.048GB   0.21%       84.84kB / 22.71MB  0B / 0B     5           5.898993s     0.04%
dd15d45ae827  flb-aggregator  0.07%       4.727MB / 2.048GB  0.23%       22.71MB / 83.1kB   0B / 0B     4           6m14.746582s  2.66%
```

By generating few lines, the resources consumption still stays low. 

But by generating some more significant logs (around `150k` lines), the `aggregator` CPU usage is inscreasing to progressively to `100%` in few seconds (unlike the v2.2.2 where the 100% is reached almost immediately)

```bash
ID            NAME            CPU %       MEM USAGE / LIMIT  MEM %       NET IO             BLOCK IO    PIDS        CPU TIME     AVG CPU %
22f9291fcd85  flb-shipper     0.18%       4.379MB / 2.048GB  0.21%       39.76kB / 9.825MB  0B / 0B     5           201.586ms    0.17%
dd15d45ae827  flb-aggregator  99.60%      4.391MB / 2.048GB  0.21%       9.825MB / 38.51kB  0B / 0B     4           1m4.715061s  57.44%
```

**NOTE**

* The shipper CPU usage is low. 
* The aggregator CPU usage goes back to a low level after the processing
