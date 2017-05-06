-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here


local Person = require("models.Person")
local Animal = require("models.Animal")
--Person:_dropDatabase()
local personInstance = Person({age="30", surname="Soares"})

--personInstance:save()
local pessoas = Person:findAll()
print(#pessoas)
if #pessoas > 0 then
    for i=1, #pessoas do
        --pessoas[i].age = 28
        print(pessoas[i].rowid)
        --local animalInstance = Animal({nickName="tob", aPerson=pessoas[i]})
        --animalInstance:save()
        --pessoas[i]:delete()
    end
end

local animals = Animal:findAll()
print(#animals)
if #animals > 0 then
    for i=1, #animals do
        --pessoas[i].age = 28
        print(animals[i].aPerson.age)
        --local animalInstance = Animal({nickName="tob", aPerson=pessoas[i]})
        --animalInstance:save()
        --pessoas[i]:delete()
    end
end