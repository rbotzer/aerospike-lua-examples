-- Adopted the example from djungelorm/protobuf-lua
function vartix(rec, id, name, email)
  local person_pb = require "person_pb"

  -- Serialize Example
  local msg = person_pb.Person()
  msg.id = id
  msg.name = name
  msg.email = email
  local pb_data = msg:SerializeToString()
  local pb_bytes = bytes(pb_data:len())
  bytes.set_type(pb_bytes, 4)
  bytes.set_string(pb_bytes, 1, pb_data)
  rec["person"] = pb_bytes
  if aerospike:exists(rec) then
    aerospike:update(rec)
  else
    aerospike:create(rec)
  end
end

function velkor(rec)
  local person_pb = require "person_pb"

  -- Parse Example
  local pb_bytes = rec["person"]
  local pb_data = bytes.get_string(pb_bytes, 1, bytes.size(pb_bytes))
  local msg = person_pb.Person()
  msg:ParseFromString(pb_data)
  return msg.id
end

function is_bytes(rec, bin)
  local t = rec[bin]
  return getmetatable(t) == getmetatable(bytes())
end
