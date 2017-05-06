require("lib.model")

local Person = Model:extend("Person", { columns = {
    age = {},
    surname = { notNull=true }}}
  )

function Person:init(columns)
    Person.super:init(columns, self)
end

return Person