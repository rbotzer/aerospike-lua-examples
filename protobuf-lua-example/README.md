# Protobuf with protobuf-lua
The [protobuf](https://luarocks.org/modules/djungelorm/protobuf) Lua rock
(source code at [djungelorm/protobuf-lua](https://github.com/djungelorm/protobuf-lua))
provides a Lua wrapper around Google's [Protocol Buffers](https://developers.google.com/protocol-buffers/)
library. It includes a plugin for protoc, which will generate Lua modules from
your `.proto` files. You can register these modules with Aerospike, then
`require` them within your UDF.

## Prerequisites
```
yum install protobuf # or see: https://github.com/google/protobuf#protobuf-runtime-installation
luarocks install protobuf
```

## Compiling Protobuf
After [linking the protoc plugin](https://github.com/djungelorm/protobuf-lua#installation-and-usage)
compile your `.proto` files.

In this example compiling `person.proto` will output a Lua module
`person_pb.lua` that you can register and `require`.
```
protoc --lua_out=./ person.proto
```

## Register and Run
The module pbuf.lua contains two [record UDFs](https://www.aerospike.com/docs/udf/developing_record_udfs.html),
one to serialize a `Person` into protobuf and store it in a record, the other
to unpack the protobuf data from the record's bin, then return one of its fields.

```sql
$ aql
Aerospike Query Client
Version 3.15.3.6
C Client Version 4.3.11
Copyright 2012-2017 Aerospike. All rights reserved.
aql> register module 'pbuf.lua'
OK, 1 module added.

aql> register module 'person_pb.lua'
OK, 1 module added.

aql> show modules
+-----------------+--------------------------------------------+-------+
| filename        | hash                                       | type  |
+-----------------+--------------------------------------------+-------+
| "person_pb.lua" | "e6dee5a956d7be0e8c016df612465c45e39bdd0a" | "LUA" |
| "pbuf.lua"      | "9c714c1e2bbff24cea7531aac881f771ab9a896b" | "LUA" |
+-----------------+--------------------------------------------+-------+
[127.0.0.1:3000] 2 rows in set (0.003 secs)

OK

aql> select * from test.foo where PK='1'
Error: (2) 127.0.0.1:3000 AEROSPIKE_ERR_RECORD_NOT_FOUND

aql> execute pbuf.vartix(123, 'Wil', 'wil.jamieson@gmail.com') on test.foo where PK='1'
+--------+
| vartix |
+--------+
|        |
+--------+
1 row in set (0.001 secs)

OK

aql> select * from test.foo where PK='1'
+----------------------------------------------------------------------------------------------+
| person                                                                                       |
+----------------------------------------------------------------------------------------------+
| 12 03 57 69 6C 08 7B 1A 16 77 69 6C 2E 6A 61 6D 69 65 73 6F 6E 40 67 6D 61 69 6C 2E 63 6F 6D |
+----------------------------------------------------------------------------------------------+
1 row in set (0.000 secs)

OK

aql> execute pbuf.velkor() on test.foo where PK='1'
+--------+
| velkor |
+--------+
| 123    |
+--------+
1 row in set (0.000 secs)

OK
```

### Tips
The protobuf rock installs Lua files and a `pb.so` shared object. See the
[manifest](https://luarocks.org/manifests/djungelorm/protobuf-1.1.1-0.rockspec) for the details.

You can run `lua person_pb.lua` to test if the `protobuf` module loads correctly.
If it doesn't, check the `$LUA_PATH` and `$LUA_CPATH` with [`luarocks path`](https://github.com/luarocks/luarocks/wiki/path).

An ugly fix on CentOS:
```
sudo cp /usr/lib/protobuf/protobuf/pb.so /usr/lib64/lua/5.1/protobuf.so
mkdir -p /usr/share/lua/5.1/protobuf
cp /usr/lib/protobuf/* /usr/share/lua/5.1/protobuf/
```
