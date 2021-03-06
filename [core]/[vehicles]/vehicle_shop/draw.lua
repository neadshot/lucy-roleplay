Events = {
    window = nil,
    debug = false,
    vGUI = {
        gridlist = {},
        button = {},
    },
    _temptable = {},
    preview = nil,
    rotation = nil,

    __security = function(self)
    	if fileExists('draw.lua') then
    		fileDelete('draw.lua')
    	end
	end,

    __click = function(self, ped)
        if (ped and isElement(ped)) and (ped:getData('carshop') and ped:getData('brand')) then
            if not isElement(self.window) then
                self.__create(Events, ped:getData('brand'));
            end
        end
    end,

    __create = function(self, brand, data)
        if (isElement(self.window) and data) then
            if (isElement(loading)) then loading:destroy() end
            guiSetEnabled(self.window, true)
            self.vGUI.grid = guiCreateGridList(9, 26, 781+50, 520, false, self.window)
            guiGridListSetSelectionMode ( self.vGUI.grid, 2 )
            self.vGUI.gridlist.colID = guiGridListAddColumn(self.vGUI.grid, "ID", 0.08)
            self.vGUI.gridlist.colName = guiGridListAddColumn(self.vGUI.grid, "Araba Adı", 0.15)
            self.vGUI.gridlist.colYear = guiGridListAddColumn(self.vGUI.grid, "Yıl", 0.1)
            self.vGUI.gridlist.colBrand = guiGridListAddColumn(self.vGUI.grid, "Marka", 0.1)
            self.vGUI.gridlist.colModel = guiGridListAddColumn(self.vGUI.grid, "Model", 0.2 )
            self.vGUI.gridlist.colPrice = guiGridListAddColumn(self.vGUI.grid, "Fiyat", 0.1 )
            self.vGUI.gridlist.colTax = guiGridListAddColumn(self.vGUI.grid, "Vergi", 0.18)

            table.sort ( data, function ( a, b )
                local idA = a.id
                local idB = b.id
        
                return tonumber(idA) < tonumber(idB)
            end)
            for index, value in ipairs(data) do
                local row = guiGridListAddRow(self.vGUI.grid)
		    	guiGridListSetItemText(self.vGUI.grid, row, self.vGUI.gridlist.colID, value.id, false, true)
                guiGridListSetItemData(self.vGUI.grid, row, self.vGUI.gridlist.colID, value.id)

                guiGridListSetItemText(self.vGUI.grid, row, self.vGUI.gridlist.colName, getVehicleNameFromModel(value.vehmtamodel) or "N/A", false, true)
                guiGridListSetItemText(self.vGUI.grid, row, self.vGUI.gridlist.colYear, value.vehyear or "N/A", false, true)
                guiGridListSetItemText(self.vGUI.grid, row, self.vGUI.gridlist.colBrand, value.vehbrand or "N/A", false, true)
                guiGridListSetItemText(self.vGUI.grid, row, self.vGUI.gridlist.colModel, value.vehmodel or "N/A", false, true)
                guiGridListSetItemText(self.vGUI.grid, row, self.vGUI.gridlist.colPrice, (exports.global:formatMoney(value.vehprice).."$") or "N/A", false, true)
                guiGridListSetItemData(self.vGUI.grid, row, self.vGUI.gridlist.colPrice, value.vehprice)
                guiGridListSetItemText(self.vGUI.grid, row, self.vGUI.gridlist.colTax, value.vehtax.."$" or "N/A", false, true)
            end

            self.vGUI.button.order = guiCreateButton(10, 552, 636, 38, "Satın Al", false, self.window)
            guiSetEnabled(self.vGUI.button.order, false)

            self.vGUI.button.close = guiCreateButton(706, 552, 176, 38, "Kapat", false, self.window)
            addEventHandler('onClientGUIClick',self.vGUI.button.close,
                function(b)
                    if (source == self.vGUI.button.close) then
                        self.window:destroy()
                    end
                end
            )
            addEventHandler('onClientGUIClick',self.vGUI.grid,
                function(b)
                	if (source == self.vGUI.grid) then
	                    local row, col = guiGridListGetSelectedItem(self.vGUI.grid)
	                    if row ~= -1 and col ~= -1 then
	                        local vehprice = guiGridListGetItemData(self.vGUI.grid, row, self.vGUI.gridlist.colPrice)

	                        if exports.global:hasMoney(localPlayer, vehprice) then
	                            guiSetText(self.vGUI.button.order, "Satın Al ($"..exports.global:formatMoney(vehprice)..")")
	                            guiSetEnabled(self.vGUI.button.order, true)
	                        else
	                            guiSetText(self.vGUI.button.order, "Seçilen Araç İçin Yeterli Paranız Yok")
	                            guiSetEnabled(self.vGUI.button.order, false)
	                        end
	                    end
	                end
                end
            )
            addEventHandler('onClientGUIClick',self.vGUI.button.order,
                function(b)
                	if (source == self.vGUI.button.order) and not isElement(self.vGUI.shown) then
	                    local row, col = guiGridListGetSelectedItem(self.vGUI.grid)
	                    if row ~= -1 and col ~= -1 then
	                		self._temptable = {}
	                        local vehid = guiGridListGetItemData(self.vGUI.grid, row, self.vGUI.gridlist.colID)
	                        for index, value in ipairs(data) do
	                        	if value.id == vehid then
	                        		for i, d in pairs(value) do
	                        			self._temptable[i] = d
	                        		end
	                        	end
	                        end
	                        self.vGUI.shown = guiCreateWindow(718, 388, 508, 306, "Gerçekten Satın Almak İstiyor Musun?", false)
					        guiWindowSetSizable(self.vGUI.shown, false)

					        self.vGUI.veh = Vehicle(self._temptable.vehmtamodel, 0, 0, 0)
					        self.vGUI.veh:setDimension(999)

					        local x, y = self.vGUI.shown:getPosition(false)
					        self.preview = exports['object-preview']:createObjectPreview(self.vGUI.veh, 0, 0, 0, x+9, y+24, 489, 218)

					        local rotZ = 0
					        self.rotation = Timer(
					        	function()
					        		rotZ = rotZ + 4
					        		exports['object-preview']:setRotation(self.preview,0,0,rotZ)
					        	end,
					        100, 0)

					        self.vGUI.button.shownok = guiCreateButton(11, 259, 317, 37, "Evet, Satın Al ($"..exports.global:formatMoney(self._temptable.vehprice)..")", false, self.vGUI.shown)
					        addEventHandler('onClientGUIClick',self.vGUI.button.shownok,
					        	function(b)
					        		if (source == self.vGUI.button.shownok) and isElement(self.vGUI.shown) then
					        			self.window:destroy()
					        			self.vGUI.shown:destroy()
					        			if isTimer(self.rotation) then killTimer(self.rotation) end
					        			exports['object-preview']:destroyObjectPreview(self.preview)
					        			self.vGUI.veh:destroy()
					        			triggerServerEvent('push:carshop:buy',localPlayer,localPlayer,self._temptable)
					        		end
					        	end
					        )
					        self.vGUI.button.shownclose = guiCreateButton(334, 259, 164, 37, "Hayır, Vazgeç", false, self.vGUI.shown)
					        addEventHandler('onClientGUIClick',self.vGUI.button.shownclose,
					        	function(b)
					        		if (source == self.vGUI.button.shownclose) and isElement(self.vGUI.shown) then
					        			self.vGUI.shown:destroy()
					        			if isTimer(self.rotation) then killTimer(self.rotation) end
					        			exports['object-preview']:destroyObjectPreview(self.preview)
					        			self.vGUI.veh:destroy()
					        			guiSetEnabled(self.window, true)
					        		end
					        	end
					        )

	                        --triggerServerEvent('push:carshop:buy',localPlayer,localPlayer,self._temptable)
	                        --self.window:destroy()
	                        guiSetEnabled(self.window, false)
	                    else
	                        guiSetText(self.window, 'Herhangi bir araç seçmediniz.')
	                    end
	                end
                end
            )
        else
            self.window = guiCreateWindow(115, 175, 850, 600, 'Araç Satış Bayisi - '..(brand or 'N/A'), false)
		    guiWindowSetSizable(self.window, false)
            exports.global:centerWindow( self.window )
            guiSetEnabled(self.window, false)
            loading = guiCreateLabel ( 0, 0, 1, 1, "Veritabanından mağaza verileri alınıyor...", true, self.window )
			guiLabelSetHorizontalAlign( loading, 'center' )
            guiLabelSetVerticalAlign( loading, 'center' )
            
            triggerServerEvent('push:carshop:load',localPlayer,localPlayer,brand)
        end
    end,
}
instance = new(Events);
addEventHandler('onClientClick',root,function(b,_,_,_,_,_,_,ped) if (b == 'right') then instance:__click(ped) end end)
addEvent('push:carshop:send', true)
addEventHandler('push:carshop:send',root,function(args, list) instance:__create(args[2],list) end)