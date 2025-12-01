-- some crazy idea with metatables
local resources = {
    framework = {
        ["qb-core"] = {

        },
        es_extended = {

        },
        qbx_core = {

        },
        custom = {

        }
    },
    inventory = {
        ox_inventory = {

        },
        ps_inventory = {

        }
    }
}

local function makeResourceProxy(resourceName, opts)
    opts = opts or {}
    if not resourceName then return end
    return setmetatable({
        __resource = resourceName,
        __tag      = opts.tag or resourceName, 
    }, {
        __call = function(self, exportName, ...)
            local resName = self.__resource

            local state = GetResourceState(resName)
            if state ~= 'started' then
                print(('[ps_lib] resource "%s" is not started (state=%s)'):format(resName, state))
                return nil
            end

            local resExports = exports[resName]
            if not resExports then
                print(('[ps_lib] exports["%s"] is nil'):format(resName))
                return nil
            end

            local fn = resExports[exportName]
            if type(fn) ~= 'function' then
                print(('[ps_lib] export "%s:%s" does not exist'):format(resName, tostring(exportName)))
                return nil
            end

            local packed = table.pack(pcall(fn, ...))
            local ok = packed[1]

            if not ok then
                local err = packed[2]
                print(('[ps_lib] error "%s:%s": %s'):format(resName, tostring(exportName), err))
                return nil, err
            end
            return table.unpack(packed, 2, packed.n)
        end
    })
end

return makeResourceProxy