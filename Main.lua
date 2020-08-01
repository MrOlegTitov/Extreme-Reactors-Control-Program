-- Import libraries
local GUI = require("GUI")
local image = require("Image")
local system = require("System")
local component = require("component")
local fs = require("Filesystem")
local event = require("Event")
local number = require("Number")
local internet = require("Internet")
local text = require("Text")
local screen = require("Screen")
---------------------------------------------------------------------------------
local reactor

local l = system.getCurrentScriptLocalization()
local SD = fs.path(system.getCurrentScript())

local cfgPath = SD .. "/config.cfg"

local cfgData

local getCfg = function()
  local downloadedData = ""
	local result, reason = internet.rawRequest(
		"https://raw.githubusercontent.com/MrOlegTitov/Extreme-Reactors-Control-Program/master/config.cfg",
		nil,
		nil,
		function(chunk)
			downloadedData = downloadedData .. chunk
		end,
		2
	)
	if result then
    GUI.alert(cfgSF)
    return downloadedData
	end
end

if fs.exists(cfgPath) == true then
  cfgData = fs.readTable(cfgPath)
else
  GUI.alert(cfgLoad)
  repeat
    tempData = getCfg()
    fs.writeTable(cfgPath, text.deserialize(tempData))
  until fs.exists(cfgPath) == true

  cfgData = fs.readTable(cfgPath)
end

if cfgData["displayMode"] == 0 then
  local workspace, window = system.addWindow(GUI.filledWindow(1, 1, 118, 31, 0xE1E1E1))

  local menu = workspace:addChild(GUI.menu(1, 1, workspace.width, 0xEEEEEE, 0x666666, 0x3366CC, 0xFFFFFF))
  if component.isAvailable("br_reactor") then
    reactor = component.get("br_reactor")
  else
    GUI.alert(l.noReactor)
    window:remove()
    menu:remove()
  end
  local FileM = menu:addContextMenuItem(l.menuPTT)
  FileM:addItem(l.menuCLS).onTouch = function()
    window:remove()
    menu:remove()
  end
  local CtrlM = menu:addContextMenuItem(l.menuCTT)
  CtrlM:addItem(l.menuERF).onTouch = function()
    reactor.doEjectFuel()
    GUI.alert(l.ctrlFS)
  end
  CtrlM:addItem(l.menuERW).onTouch = function()
    reactor.doEjectWaste()
    GUI.alert(l.ctrlWS)
  end
  CtrlM:addItem(l.menuSRS).onTouch = function()
    if reactor.getActive() == true then
      reactor.setActive(false)
    else
      reactor.setActive(true)
    end
  end

  window.showDesktopOnMaximize = true

  window.actionButtons.close.onTouch = function()
    window:remove()
    menu:remove()
  end
  
  local list = window:addChild(GUI.list(1, 4, 22, 1, 3, 0, 0x4B4B4B, 0xE1E1E1, 0x4B4B4B, 0xE1E1E1, 0xE1E1E1, 0x3C3C3C))
  local listCover = window:addChild(GUI.panel(1, 1, list.width, 3, 0x4B4B4B))
  local layout = window:addChild(GUI.layout(list.width + 1, 1, 1, 1, 1, 1))
  
  local lx = layout.localX
  
  window.backgroundPanel.localX = lx
  
  function n2s(num)
    return number.roundToDecimalPlaces(num, 3)
  end
  
  local function addTab(text, func)
    list:addItem(text).onTouch = function()
      layout:removeChildren()
      func()
      workspace:draw()
    end
  end
  
  local function addText(text)
    newText = layout:addChild(GUI.text(workspace.width, workspace.height, 0x3C3C3C, text))
    return newText
  end
  
  local function addButton(text, func)
    newButton = layout:addChild(GUI.roundedButton(1, 1, 24, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, text))
    newButton.onTouch = function()
      func()
    end
    return newButton
  end

  local function addSwitch(func)
    newSwitch = layout:addChild(GUI.switch(3, 2, 8, 0x66DB80, 0x1D1D1D, 0xEEEEEE, reactor.getActive()))
    newSwitch.onStateChanged = function(state)
      func()
    end
    return newSwitch
  end

  local function addComboBox()
    newCombobox = layout:addChild(GUI.comboBox(3, 2, 30, 3, 0xEEEEEE, 0x2D2D2D, 0xCCCCCC, 0x888888))
    return newCombobox
  end
  
  local function drawIcon(pic)
    return layout:addChild(GUI.image(2, 2, image.load(pic)))
  end

  -- Main Program:
  addTab(l.helloTT, function() --Hello TAB
    drawIcon(SD .. "Icon.pic")
    addText(l.greeting .. system.getUser() .. "!")
    addText(l.helloAM)
    appMode = addComboBox()
    appMode:addItem(l.helloM1).onTouch = function()
      cfgData["displayMode"] = 0
      fs.writeTable(cfgPath, cfgData)
      GUI.alert(l.helloCM1 .. tostring(appMode:getItem(appMode.selectedItem)["text"]) .. l.helloCM2)
    end
    appMode:addItem(l.helloM2).onTouch = function()
      cfgData["displayMode"] = 1
      fs.writeTable(cfgPath, cfgData)
      GUI.alert(l.helloCM1 .. tostring(appMode:getItem(appMode.selectedItem)["text"]) .. l.helloCM2)
    end
    appMode:addItem(l.helloM3).onTouch = function()
      cfgData["displayMode"] = 2
      fs.writeTable(cfgPath, cfgData)
      GUI.alert(l.helloCM1 .. tostring(appMode:getItem(appMode.selectedItem)["text"]) .. l.helloCM2)
    end
  end)

  addTab(l.infoTT, function() -- Indicators TAB
    infoFT = addText(l.infoFT)
    infoCT = addText(l.infoCT)
    infoFA = addText(l.infoFA)
    infoWA = addText(l.infoWA)
    infoMF = addText(l.infoMF)
    infoFR = addText(l.infoFR)
    infoFC = addText(l.infoFC)
    infoEP = addText(l.infoEP)
    infoEC = addText(l.infoEC)
    infoES = addText(l.infoES)
    infoRA = addText(l.infoRA)
    mainhandler=event.addHandler(function()
      infoFT.text = l.infoFT .. tostring(n2s(reactor.getFuelTemperature()))
      infoCT.text = l.infoCT .. tostring(n2s(reactor.getCasingTemperature()))
      infoFA.text = l.infoFA .. tostring(n2s(reactor.getFuelAmount()))
      infoWA.text = l.infoWA .. tostring(n2s(reactor.getWasteAmount()))
      infoMF.text = l.infoMF .. tostring(n2s(reactor.getFuelAmountMax()))
      infoFR.text = l.infoFR .. tostring(n2s(reactor.getFuelReactivity()))
      infoFC.text = l.infoFC .. tostring(n2s(reactor.getFuelConsumedLastTick()))
      infoEP.text = l.infoEP .. tostring(n2s(reactor.getEnergyProducedLastTick()))
      infoEC.text = l.infoEC .. tostring(n2s(reactor.getEnergyCapacity()))
      infoES.text = l.infoES .. tostring(n2s(reactor.getEnergyStored()))
      if reactor.getActive() == true then
        infoRA.text = l.infoRA .. l.infoRO
      else
        infoRA.text = l.infoRA .. l.infoRF
      end
    end, 0.15)
  end)

  addTab(l.ctrlTT, function() -- Control TAB
    addButton(l.ctrlEF, function()
      reactor.doEjectFuel()
      GUI.alert(l.ctrlFS)
    end)
    addButton(l.ctrlEW, function()
      reactor.doEjectWaste()
      GUI.alert(l.ctrlWS)
    end)
    addText(l.ctrlRA)
    r_as = addSwitch(function()
      reactor.setActive(r_as.state)
    end)
  end)

  addTab(l.aboutTT, function() -- About TAB
    addText(l.aboutCT)
    addText(l.aboutPV .. "1.1 Realease")
    addText(l.aboutBT)
    addText(l.aboutTY1)
    addText(l.aboutTY2)
  end)

  -- GUI Actions:
  list.eventHandler = function(workspace, list, e1, e2, e3, e4, e5)
    if e1 == "scroll" then
      local horizontalMargin, verticalMargin = list:getMargin()
      list:setMargin(horizontalMargin, math.max(-list.itemSize * (#list.children - 1), math.min(0, verticalMargin + e5)))
  
      workspace:draw()
    end
  end
  
  local function calculateSizes()
    list.height = window.height
  
    window.backgroundPanel.width = window.width - list.width
    window.backgroundPanel.height = window.height
  
    layout.width = window.backgroundPanel.width
    layout.height = window.height
  end
  
  window.onResize = function()
    calculateSizes()
  end
  
  calculateSizes()
  window.actionButtons:moveToFront()
  list:getItem(1).onTouch()
elseif cfgData["displayMode"] == 1 then
  local yText = 2
  local workspace, window = system.addWindow(GUI.filledWindow(1, 1, screen.getWidth(), screen.getHeight(), 0xE1E1E1))
  local list = window:addChild(GUI.list(1, 4, 20, 1, 3, 0, 0xE1E1E1, 0xE1E1E1, 0xE1E1E1, 0xE1E1E1, 0xE1E1E1, 0x3C3C3C))
  local listCover = window:addChild(GUI.panel(1, 1, list.width, 3, 0xE1E1E1))
  local layout = window:addChild(GUI.layout(list.width + 1, 1, 1, 1, 1, 1))

  local lx = layout.localX
  
  window.backgroundPanel.localX = lx

  if component.isAvailable("br_reactor") then
    reactor = component.get("br_reactor")
  else
    GUI.alert(l.noReactor)
    window:remove()
    menu:remove()
  end
  function n2s(num)
    return number.roundToDecimalPlaces(num, 3)
  end
  local function addText(text)
    newText = layout:addChild(GUI.text(workspace.width, workspace.height, 0x3C3C3C, text))
    return newText
  end
  
  local function addButton(text, func)
    newButton = layout:addChild(GUI.roundedButton(1, 1, 24, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, text))
    newButton.onTouch = function()
      func()
    end
    return newButton
  end

  local function addSwitch(func)
    newSwitch = layout:addChild(GUI.switch(3, 2, 8, 0x66DB80, 0x1D1D1D, 0xEEEEEE, reactor.getActive()))
    newSwitch.onStateChanged = function(state)
      func()
    end
    return newSwitch
  end

  local function addComboBox()
    newCombobox = layout:addChild(GUI.comboBox(3, 2, 30, 3, 0xEEEEEE, 0x2D2D2D, 0xCCCCCC, 0x888888))
    return newCombobox
  end
  
  local function drawIcon(pic)
    return layout:addChild(GUI.image(2, 2, image.load(pic)))
  end
  appMode = addComboBox()
  appMode:addItem(l.helloM1).onTouch = function()
    cfgData["displayMode"] = 0
    fs.writeTable(cfgPath, cfgData)
    GUI.alert(l.helloCM1 .. tostring(appMode:getItem(appMode.selectedItem)["text"]) .. l.helloCM2)
  end
  appMode:addItem(l.helloM2).onTouch = function()
    cfgData["displayMode"] = 1
    fs.writeTable(cfgPath, cfgData)
    GUI.alert(l.helloCM1 .. tostring(appMode:getItem(appMode.selectedItem)["text"]) .. l.helloCM2)
  end
  appMode:addItem(l.helloM3).onTouch = function()
    cfgData["displayMode"] = 2
    fs.writeTable(cfgPath, cfgData)
    GUI.alert(l.helloCM1 .. tostring(appMode:getItem(appMode.selectedItem)["text"]) .. l.helloCM2)
  end
  addText(l.helloAM)
  infoFT = addText(l.infoFT)
  infoCT = addText(l.infoCT)
  infoFA = addText(l.infoFA)
  infoWA = addText(l.infoWA)
  infoMF = addText(l.infoMF)
  infoFR = addText(l.infoFR)
  infoFC = addText(l.infoFC)
  infoEP = addText(l.infoEP)
  infoEC = addText(l.infoEC)
  infoES = addText(l.infoES)
  infoRA = addText(l.infoRA)
  mainhandler=event.addHandler(function()
    infoFT.text = l.infoFT .. tostring(n2s(reactor.getFuelTemperature()))
    infoCT.text = l.infoCT .. tostring(n2s(reactor.getCasingTemperature()))
    infoFA.text = l.infoFA .. tostring(n2s(reactor.getFuelAmount()))
    infoWA.text = l.infoWA .. tostring(n2s(reactor.getWasteAmount()))
    infoMF.text = l.infoMF .. tostring(n2s(reactor.getFuelAmountMax()))
    infoFR.text = l.infoFR .. tostring(n2s(reactor.getFuelReactivity()))
    infoFC.text = l.infoFC .. tostring(n2s(reactor.getFuelConsumedLastTick()))
    infoEP.text = l.infoEP .. tostring(n2s(reactor.getEnergyProducedLastTick()))
    infoEC.text = l.infoEC .. tostring(n2s(reactor.getEnergyCapacity()))
    infoES.text = l.infoES .. tostring(n2s(reactor.getEnergyStored()))
    if reactor.getActive() == true then
      infoRA.text = l.infoRA .. l.infoRO
    else
      infoRA.text = l.infoRA .. l.infoRF
    end
  end, 0.15)

  local function calculateSizes()
    list.height = window.height
  
    window.backgroundPanel.width = window.width - list.width
    window.backgroundPanel.height = window.height
  
    layout.width = window.backgroundPanel.width - 15
    layout.height = window.height
  end
  
  window.onResize = function()
    calculateSizes()
  end
  
  calculateSizes()
  window.actionButtons:moveToFront()

elseif cfgData["displayMode"] == 2 then
  local yText = 2
  local workspace, window = system.addWindow(GUI.filledWindow(1, 1, screen.getWidth(), screen.getHeight(), 0xE1E1E1))
  local list = window:addChild(GUI.list(1, 4, 20, 1, 3, 0, 0xE1E1E1, 0xE1E1E1, 0xE1E1E1, 0xE1E1E1, 0xE1E1E1, 0x3C3C3C))
  local listCover = window:addChild(GUI.panel(1, 1, list.width, 3, 0xE1E1E1))
  local layout = window:addChild(GUI.layout(list.width + 1, 1, 1, 1, 1, 1))

  local lx = layout.localX
  
  window.backgroundPanel.localX = lx

  if component.isAvailable("br_reactor") then
    reactor = component.get("br_reactor")
  else
    GUI.alert(l.noReactor)
    window:remove()
    menu:remove()
  end
  function n2s(num)
    return number.roundToDecimalPlaces(num, 3)
  end
  local function addText(text)
    newText = layout:addChild(GUI.text(workspace.width, workspace.height, 0x3C3C3C, text))
    return newText
  end
  
  local function addButton(text, func)
    newButton = layout:addChild(GUI.roundedButton(1, 1, 24, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, text))
    newButton.onTouch = function()
      func()
    end
    return newButton
  end

  local function addSwitch(func)
    newSwitch = layout:addChild(GUI.switch(3, 2, 8, 0x66DB80, 0x1D1D1D, 0xEEEEEE, reactor.getActive()))
    newSwitch.onStateChanged = function(state)
      func()
    end
    return newSwitch
  end

  local function addComboBox()
    newCombobox = layout:addChild(GUI.comboBox(3, 2, 30, 3, 0xEEEEEE, 0x2D2D2D, 0xCCCCCC, 0x888888))
    return newCombobox
  end
  
  local function drawIcon(pic)
    return layout:addChild(GUI.image(2, 2, image.load(pic)))
  end
  appMode = addComboBox()
  appMode:addItem(l.helloM1).onTouch = function()
    cfgData["displayMode"] = 0
    fs.writeTable(cfgPath, cfgData)
    GUI.alert(l.helloCM1 .. tostring(appMode:getItem(appMode.selectedItem)["text"]) .. l.helloCM2)
  end
  appMode:addItem(l.helloM2).onTouch = function()
    cfgData["displayMode"] = 1
    fs.writeTable(cfgPath, cfgData)
    GUI.alert(l.helloCM1 .. tostring(appMode:getItem(appMode.selectedItem)["text"]) .. l.helloCM2)
  end
  appMode:addItem(l.helloM3).onTouch = function()
    cfgData["displayMode"] = 2
    fs.writeTable(cfgPath, cfgData)
    GUI.alert(l.helloCM1 .. tostring(appMode:getItem(appMode.selectedItem)["text"]) .. l.helloCM2)
  end
  addText(l.helloAM)
  addButton(l.ctrlEF, function()
    reactor.doEjectFuel()
    GUI.alert(l.ctrlFS)
  end)
  addButton(l.ctrlEW, function()
    reactor.doEjectWaste()
    GUI.alert(l.ctrlWS)
  end)
  addText(l.ctrlRA)
  r_as = addSwitch(function()
    reactor.setActive(r_as.state)
  end)

  local function calculateSizes()
    list.height = window.height
  
    window.backgroundPanel.width = window.width - list.width
    window.backgroundPanel.height = window.height
  
    layout.width = window.backgroundPanel.width - 15
    layout.height = window.height
  end
  
  window.onResize = function()
    calculateSizes()
  end
  
  calculateSizes()
  window.actionButtons:moveToFront()
else
  GUI.alert("Unkown display mode!")
end