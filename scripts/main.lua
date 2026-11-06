print("[ShaChi] Mod Load! VERSION------0.1.0")
-- Hook Damage

local hookPath =
    "/PBZCombatAsset/Prototypes/Abilities/GA_CommonUtilitiesPassive.GA_CommonUtilitiesPassive_C:OnTaken"

local UEHelpers = require("UEHelpers")

local cacheedAttribytes = nil --属性集缓存

local function GetDamageValue(payload,targetTag) --获取指定标签的伤害
    if not payload or not payload:IsValid() then
        print("[ShaChiProbe] Invalid Payload")
        return 0
    end

    local ok,result = pcall(function()

        for key,value in pairs(payload:GetDamageData()) do
            local tag = key:get().TagName:ToString()

            if tag == targetTag then
                return value:get()
            end
        end
        print("no targetTag return 0")
        return 0
    end)

    if not ok then --pcall throw error
        print(
            "[ShaChiProbe] GetDamageValue Error:"..result.."\n"
        )
        return 0
    end
    return result
end

local function CalculateShaChiRecovery(payload)--根据标签伤害计算煞气回复量
    if not payload or not payload:IsValid() then
        print("return 0,0,0")
        return 0,0,0
    end

    local physical = GetDamageValue(payload,"Damage.Damage.Target.GeneralDamage.Physical")--获取物理伤害
    print("[ShaChiProbe]Physical DamageValue: "..physical.."\n")
    local poise = GetDamageValue(
        payload,
        "Damage.Damage.Target.PoiseDamage"
    ) --获取架势条伤害
    print("[ShaChiProbe]Poise DamageValue: "..poise.."\n")

    local recoveries = (physical+poise)*0.01

    return physical,poise,recoveries
end

local function BelongtoPlayer(attributes,playerAddress) --判断是不是属于玩家
    if not attributes or not attributes:IsValid() then
        return false
    end

    local outer = attributes:GetOuter() --获取该属性集在那个组件下

    return outer and outer:IsValid() and outer:GetAddress() == playerAddress
end

RegisterHook(hookPath,function(Context,Event) --注册hook
    local ok,result = pcall(function()

        local ability = Context:get()

        if not ability or not ability:IsValid() then
            print("not ability or not ability:IsValid()")
            return 
        end

        local avatar = ability:GetAvatarActorFromActorInfo()

        if not avatar or not avatar:IsValid() then
            print("not avatar or not avatar:IsValid()")
            return 
        end

        local eventData = Event:get()

        if not eventData then
            return
        end

        local payload = eventData.OptionalObject

        if not payload or not payload:IsValid() then
            print("not payloda or not payload:IsValid()")
            return 
        end

        local player = UEHelpers:GetPlayer()

        if not player or not player:IsValid() then
            return 
        end

        if avatar:GetAddress() ~= player:GetAddress() then --只处理玩家发出的攻击事件
            return
        end

        local target = payload.TargetActor --获取被打的

        if not target or not target:IsValid() then
            return 
        end

        if target:GetAddress() == player:GetAddress() then --玩家受伤不算
            return
        end
        local physical ,poise,recoveries = CalculateShaChiRecovery(payload) --得到需要恢复的数值

        local playerAddress = player:GetAddress()

        if not BelongtoPlayer(cacheedAttribytes,playerAddress) then --缓存无效
            cacheedAttribytes = nil
            for _,attributes in pairs(
                FindAllOf("BasicAttributeSet") or {}
            ) do
                if BelongtoPlayer(attributes,playerAddress) then
                    cacheedAttribytes = attributes
                    break
                end
            end
        end
        cacheedAttribytes.ShaChi.BaseValue = math.min(cacheedAttribytes.ShaChi.BaseValue + recoveries,
        cacheedAttribytes.Shachi_Max.CurrentValue) --煞气恢复
        print("[ShaChiProbe] ShaChi recover"..recoveries.."to"..cacheedAttribytes.ShaChi.BaseValue.."\n")
            
    end)
    
    if not ok then
        print("[ShaChiProbe] HOOK error: "..tostring(result).."\n")
    end

end)
