require("lib.model")

local Animal = Model:extend("Animal", { columns = {
    nickname = {}
    },
    belongsTo={aPerson="Person"}
    }
  )

function Animal:init(columns)
    Animal.super:init(columns, self)
end

return Animal