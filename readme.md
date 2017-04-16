# Summary

Corona SDK (http://www.coronalabs.com) lacks a ORM-like to manage SQLite database in a meaniful way. You have to write pure SQL and it is not good, also hard to mantain. This library has three main points:

1. ORM syntax for database manipulation in Corona; 
2. Based on Active record pattern (https://www.martinfowler.com/eaaCatalog/activeRecord.html);
3. Support for object oriented paradigm (class, instances and inherintance)**

** For that I make use of 30log library: https://github.com/Yonaba/30log

# Instalation

Just copy libs folder to your project and import lib.models to every class you create.

# Usage

Create a class that extends Model (our Active Record Pattern). Model is a base class which implements Save, Delete, Find all, Update and support for relationships (at the time one to one and one to many.)

Example:

```lua

require("lib.models")

local Person = Model:extend("Person", { columns = {
    age = {}, 
    surname = { notNull=true }}}
  )

-- This is the constructor. 
function Person:init(columns)
    -- We are calling Model's (super) constructor. It is required.
    Person.super:init(columns, self) 
end
```
Now, just create an instance of Person and start using it:

```lua
local aPerson = Person({age=30, surname="Soares"})
aPerson:save()
```

# Examples

## Simple C.R.U.D.

```lua
-- Every database table must extends Model as it implements basic CRUD operations.
local Person = Model:extend("Person", { columns = { -- database columns should be inside this table
    age = {}, -- every key is a column in Person table.
    surname = { notNull=true }}} -- you can configure not null like this.
  )

-- This is the constructor. 
function Person:init(columns)
    -- You can do anything you want, but you must call its parent constructor (Model)
    Person.super:init(columns, self) 
end

-- Creating a Person instance.
local aPerson = Person({age=30, surname="Soares"})
aPerson:save() -- saves on database
aPerson = 28
aPerson:save() -- updates
local persons = Person:findAll() -- Select * From Person. Returns a table with results.
if #persons > 0 then
    for i=1, #persons do
        print(persons[i].age)
        print(persons[i].rowid)
    end
end
aPerson:delete() -- delete
```

## Support for relationships

```lua
local Animal = Model:extend("Animal", { columns = {
    nickname = {}},
    belongsTo={animalOwner="Person"}
    }
  )

function Animal:init(columns)
    Animal.super:init(columns, self)
end

local animalInstance = Animal({nickName="tob", animalOwner=aPerson})
animalInstance:save()

local animals = Animal:findAll()
print(#animals)
if #animals > 0 then
    for i=1, #animals do
        print(animals[i].aPerson.age) -- should print 28
    end
end
```

# License

MIT.

# Creator

Leonardo Soares e Silva
lsoaresesilva@gmail.com