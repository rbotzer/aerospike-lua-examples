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
Version 3.15.1.2
C Client Version 4.3.0
Copyright 2012-2017 Aerospike. All rights reserved.
aql> register module 'pbuf.lua'
OK, 1 module added.

aql> register module 'person_pb.lua'
OK, 1 module added.

aql> register module 'pbuf.lua'
OK, 1 module added.

aql> show modules
+--------------------------------------------+-----------------+-------+
| hash                                       | module          | type  |
+--------------------------------------------+-----------------+-------+
| "e5b2f02687fa070649832bce6400e920b827b44e" | "person_pb.lua" | "lua" |
| "f83e960f4c5ef4693ea06a3f1f4f6f356194d7f1" | "pbuf.lua"      | "lua" |
+--------------------------------------------+-----------------+-------+
2 rows in set (0.001 secs)

aql> select * from test.foo where PK='1'
Error: (2) AEROSPIKE_ERR_RECORD_NOT_FOUND

aql> execute pbuf.vartix(123, 'Wil', 'wil.jamieson@gmail.com') on test.foo where PK='1'
+--------+
| vartix |
+--------+
|        |
+--------+
1 row in set (0.001 secs)

aql> select * from test.foo where PK='1'
+-----------------------------------+
| person                            |
+-----------------------------------+
| {Wilwil.jamieson@gmail.com" |
+-----------------------------------+
1 row in set (0.000 secs)

aql> execute pbuf.velkor() on test.foo where PK='1'
+--------+
| velkor |
+--------+
| 123    |
+--------+
1 row in set (0.000 secs)
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
