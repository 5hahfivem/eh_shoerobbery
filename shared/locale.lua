lib.locale()

function T(key, ...)
    local ok, result = pcall(locale, key, ...)
    if ok and result then
        return result
    end

    return key
end
