-- Adopted the example from djungelorm/protobuf-lua
function vartix(rec, id, name, email)
  local person_pb = require "person_pb"

  -- Serialize Example
  local msg = person_pb.Person()
  msg.id = id
  msg.name = name
  msg.email = email
  local pb_data = msg:SerializeToString()
  rec["person"] = pb_data
  if aerospike:exists(rec) then
    aerospike:update(rec)
  else
    aerospike:create(rec)
  end
end

function velkor(rec)
  local person_pb = require "person_pb"

  -- Parse Example
  local pb_data = rec["person"]
  local msg = person_pb.Person()
  msg:ParseFromString(pb_data)
  return msg.id
end
