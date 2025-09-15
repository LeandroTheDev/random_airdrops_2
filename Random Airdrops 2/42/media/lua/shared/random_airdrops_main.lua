RandomAidropsCompatibility = true;
RandomAidropsName = "RandomAidrops";
RandomAidropsIsSinglePlayer = false;

if not isClient() and not isServer() then
    RandomAidropsIsSinglePlayer = true;
end

function DebugPrintRandomAidrops(log)
    if RandomAidropsIsSinglePlayer then
        print("[" .. RandomAidropsName .. "] " .. log);
    else
        if isClient() then
            print("[" .. RandomAidropsName .. "-Client] " .. log);
        else
            if isServer() then
                print("[" .. RandomAidropsName .. "-Server] " .. log);
            else
                print("[" .. RandomAidropsName .. "-Unkown] " .. log);
            end
        end
    end
end