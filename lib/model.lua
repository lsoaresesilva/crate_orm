local sqlite3 = require( "sqlite3" )

local path = system.pathForFile( "data.db", system.DocumentsDirectory )

--[[local tablesetup = "CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY autoincrement, name, description, website);"
db:exec( tablesetup )
for row in db:nrows("SELECT * FROM test") do
    print( "Row " .. row.id )
 
    -- Create table at the next available array index
    people[#people+1] =
    {
        name = row.name,
        description = row.description,
        website = row.website
    }
end]]
class = require("lib.external.30log")
require("lib.table")
require("lib.util.table_util")

Model = class("Model")

function Model:init(columns, model)

    if columns == nil or type(columns) ~= "table" then
        error("A model cannot be instantiated without column")
    end
    
    if model == nil or type(model) ~= "table" then
        error("Did you missed to pass your model?!")
    end
    
    if model.columns == nil or type(model.columns) ~= "table" then
        error("Did you missed to create your model columns definitions?")
    end
    -- percorrer a tabela
    
    -- save columns values in model.
    for columnName, value in pairs(columns) do
        if columnName ~= nil then              
              model[columnName] = value
        end
    end
    
    self:_createTableSQL(model)
end

function Model:findAll()
    local generatedSql = Table:_generateSQLSelect(self)
    print(generatedSql)
    -- reset clauses, so it can be set next time.
    self.whereClause = nil
    self.orClause = nil
    --local rawResults = DBAdapter:querySQL(generatedSql)
    
    local models = self:buildModels(generatedSql)

    return models
end

function Model:where(conditions)
    self.whereClause = Table:_generateSQLWhere(conditions)
    return self
end

function Model:OR(conditions)
    if self.whereClause == nil or type(self.whereClause) ~= "string" then
        error("You must call WHERE before calling or.")
    end

    self.orClause = Table:_generateSQLWhereOR(conditions)
    return self
end

function Model:buildModels( SQL )
    local db = sqlite3.open( path )
    if SQL == nil then
        error("Cannot generate models without SQL.")
    end

    if type(SQL) ~= "string" then
        error("Cannot generate models without a valid raw sql.")
    end

    local models = {}
    
    for row in db:nrows(SQL) do
        
        local model = {}
        local belongedModels = {}
        local hasManyModels = {}

        if self.belongsTo ~= nil then
            for foreignKey, foreignTable in pairs(self.belongsTo) do

                belongedModels[foreignKey] = {}
            end
        end

        if self.hasMany ~= nil and type(self.hasMany) == "table" then
            for foreignKey, foreignTable in pairs(self.hasMany) do

                hasManyModels[foreignKey] = {}
            end
        end

        for column, columnValue in pairs(row) do
        
            local columnNameWithAlias = column
            
            local columnNameWithoutAlias = string.gsub(columnNameWithAlias, "^(.*)_", "")
            local alias = string.gsub(columnNameWithAlias, "_(.*)", "")
            

            if alias == self.name then
                model[columnNameWithoutAlias] = columnValue
            else
                if self.belongsTo ~= nil and self.belongsTo[alias] ~= nil then
                    belongedModels[alias][columnNameWithoutAlias] = columnValue
                end
            end

            for foreignKeyName, v in pairs(belongedModels) do
                if self.belongsTo ~= nil and self.belongsTo[foreignKeyName] ~= nil then

                    local belongedClass = require("models."..self.belongsTo[foreignKeyName])
                    local belongedModel = belongedClass(belongedModels[foreignKeyName])

                    model[foreignKeyName] = belongedModel

                end
            end

            if model.rowid ~= nil then
                for recordsName, className in pairs(hasManyModels) do
                    local foreignKey = self.name.."_id"
                    local condition = {}
                    condition[foreignKey] = model.rowid
                    local hasManyClass = require("models."..self.hasMany[recordsName])
                    local foreignRows = hasManyClass:where(condition):findAll()
                    if foreignRows ~= nil and type(foreignRows) == "table" and #foreignRows > 0 then
                        model[recordsName] = foreignRows
                    else
                        model[recordsName] = {}
                    end
                end
            end
            
            
            
        end
        local myClass = require("models."..self.name)
        local myModel = myClass(model)
        table.insert(models, myModel)
    end
    self:_closeDatabase(db)
    
    return models
end

function Model:_createTableSQL(model)
    local db = sqlite3.open( path )
    local result = false
    if model.isTableCreated == nil or model.isTableCreated == false then

        if model.columns == nil and model.name == nil then
          error( "You should not call this method directly.")
        end

        local sql = Table:_generateSQL(model)
      
      
        local sqlStatus = db:exec( sql )

        if sqlStatus == 0 then
            -- should not create a table everytime a new instance is created
            local myClass = require("models."..model.name)
            myClass.isTableCreated = true
            return true
        end
    end
    
    self:_closeDatabase(db)
    return result
end

function Model:delete()
    local db = sqlite3.open( path )
    local generatedSql = Table:_generateSQLDelete(self)
    local result = db:exec(generatedSql)
    if result then
        self.rowid = nil
        return true
    end
    self:_closeDatabase(db)
    return false
end

function Model:save()
    local db = sqlite3.open( path )
    local result = false
    if self.rowid == nil then

        local generatedSqlSave = Table:_generateSQLInsert(self)
        local result = db:exec(generatedSqlSave)
        print("opa")
        if result == 0 then
            --[[local sqlGetLastPK = "SELECT rowid FROM "..self.name.." ORDER BY ROWID DESC LIMIT 1"
            for row in db:nrows(sqlGetLastPK) do
                primaryKey = row.rowid
            end]]
            local primaryKey = db:last_insert_rowid()
            if primaryKey ~= 0 then
                self.rowid = primaryKey
                result = true
            else
                result = false
            end
        end

        result = false
    else
        local generatedSql = Table:_generateSQLUpdate(self)
        local result = db:exec(generatedSql)
        if result == 0 then
            result = true
        end

        result = false
    end
    self:_closeDatabase()
    return result
end

function Model:_closeDatabase(db)
    if ( db and db:isopen() ) then
            db:close()
    end
end

function Model:_dropDatabase()
    local lfs = require( "lfs" )
    os.remove(path)
    
end

return Model