local tmpCount = 0;

function resetDB()
  InventoryCounterDB = {};
  InventoryCounterDB[currentCharacter] = {};
end

function InventoryCounter_UpdateBagsAndBank()
  --http://www.wowwiki.com/BagId
  position = "bank";
  InventoryCounterDB[currentCharacter][position] = nil;
  InventoryCounterDB[currentCharacter][position] = {};
  for bag = -1, 10 do
    if(bag == 0) then
      position = "bag";
      InventoryCounterDB[currentCharacter][position] = nil;
      InventoryCounterDB[currentCharacter][position] = {};
    end
    if(bag == 5) then
      position = "bank";
    end
    bagSize = GetContainerNumSlots(bag);
    if (bagSize>0) then
      for slot=1,bagSize do
        local _, itemCount = GetContainerItemInfo(bag, slot);
        local itemLink = GetContainerItemLink(bag, slot);
        if(itemCount and itemCount > 0) then
          local itemstring = string.sub(itemLink, string.find(itemLink, "%[")+1, string.find(itemLink, "%]")-1);
          tmpCount = InventoryCounterDB[currentCharacter][position][itemstring];
          if not tmpCount then
            InventoryCounterDB[currentCharacter][position][itemstring] = itemCount;
          else
            InventoryCounterDB[currentCharacter][position][itemstring] = tmpCount + itemCount;
          end
        end
      end
    end
  end
end
InventoryCounter_Tooltip = CreateFrame( "GameTooltip", "InventoryCounter_Tooltip", UIParent, "GameTooltipTemplate" );
InventoryCounterFrame = CreateFrame('Frame', "InventoryCounterFrame", GameTooltipTemplate)
InventoryCounterFrame:RegisterEvent("VARIABLES_LOADED");
InventoryCounterFrame:RegisterEvent("BAG_UPDATE");
InventoryCounterFrame:RegisterEvent("BANKFRAME_OPENED");
InventoryCounterFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
InventoryCounterFrame:SetScript("OnEvent", function (self)
    if event == "VARIABLES_LOADED" then
      currentCharacter = UnitName("player");
      if not InventoryCounterDB then
        InventoryCounterDB = {};
      end
      if not InventoryCounterDB[currentCharacter] then
        InventoryCounterDB[currentCharacter] = {};
      end
    end
    if event == "BAG_UPDATE" then
      position = "bag";
      InventoryCounterDB[currentCharacter][position] = nil;
      InventoryCounterDB[currentCharacter][position] = {};
      for bag = 0, 4 do
        bagSize = GetContainerNumSlots(bag);
        if (bagSize>0) then
          for slot=1,bagSize do
            local _, itemCount = GetContainerItemInfo(bag, slot);
            local itemLink = GetContainerItemLink(bag, slot);
            if(itemCount and itemCount > 0) then
              local itemstring = string.sub(itemLink, string.find(itemLink, "%[")+1, string.find(itemLink, "%]")-1);
              tmpCount = InventoryCounterDB[currentCharacter][position][itemstring];
              if not tmpCount then
                InventoryCounterDB[currentCharacter][position][itemstring] = itemCount;
              else
                InventoryCounterDB[currentCharacter][position][itemstring] = tmpCount + itemCount;
              end
            end
          end
        end
      end
    end
    if event == "BANKFRAME_OPENED" then
      InventoryCounter_UpdateBagsAndBank();
    end
    if event == "PLAYERBANKSLOTS_CHANGED" then
      InventoryCounter_UpdateBagsAndBank();
    end
  end)
InventoryCounterFrameToolTip = CreateFrame( "Frame" , "InventoryCounterFrameToolTip", GameTooltip )
InventoryCounterFrameToolTip:SetScript("OnShow", function (self)
    if InventoryCounterDB and not MerchantFrame:IsVisible() then
      local lbl = getglobal("GameTooltipTextLeft1");
      if lbl then
        local itemName = lbl:GetText();
        local totalCount = 0;
        local initLineAdded = nil;
        for char,_ in pairs(InventoryCounterDB) do
          for slot,_ in pairs(InventoryCounterDB[char]) do
            local count = InventoryCounterDB[char][slot][itemName];
            if count then
              if not initLineAdded then
                GameTooltip:AddLine(" ", 0, 0, 0, 0)
                initLineAdded = true
              end
              totalCount = totalCount + count;
              GameTooltip:AddDoubleLine(char .. " |cff556677[" .. slot .. "]", count, 0.65, 0.75, 0.85, 0.65, 0.75, 0.85)
            end
          end
        end
        if (totalCount>0) then
          GameTooltip:AddDoubleLine("Total:", totalCount, 0, 0.8, 1, 0, 0.8, 1)
        end
      end
    end
    GameTooltip:Show()
  end)
