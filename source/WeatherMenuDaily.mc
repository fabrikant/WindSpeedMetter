using Toybox.System;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;

class WeatherMenuDaily extends WeatherMenu{
	
	function initialize(){
		storageKey = STORAGE_KEY_DAILY; 
		var itemHeight = Graphics.getFontHeight(Fonts.getMenuListFont()) * 2 + Graphics.getFontHeight(Graphics.FONT_SYSTEM_LARGE);
		WeatherMenu.initialize(itemHeight);
	}

	function addItems(){
		//var data = Tools.getStorage(storageKey, null);
		var data = Application.Storage.getValue(storageKey);
		var dataSize = 1;
		if (data != null){
			dataSize = data.size();
		}
		for (var i = itemsCount; i < dataSize; i++){
			itemsCount = i+1;
			addItem(new WeatherMenuItemDaily(i, storageKey, self));
		}
	}
	
	function getTitleText(){
		return Application.loadResource(Rez.Strings.ForecastDaily);
	}
}

class WeatherMenuItemDaily extends WeatherMenuItem{
	
	function initialize(identifier, key, owner){
		WeatherMenuItem.initialize(identifier, key, owner);
	}

	function draw(dc){
		
		var data = Tools.getStorage(storageKey, null);
		dc.setColor(Tools.getBackgroundColor(), Tools.getBackgroundColor());
		dc.clear();
		dc.setColor(Tools.getForegroundColor(), Graphics.COLOR_TRANSPARENT);

		if (data == null){
			border(dc);
			return;
		}
		
		data = data[getId()];
		
        var iconName = data["weather"][0]["icon"];
        var size = 1;
        var res = Tools.getStorage(iconName+size.format("%d"), null);
        
        var columnInterval = 10;
        var x = columnInterval;
        var y = 0;
        var halfY = dc.getHeight()/2; 
        var font = Graphics.FONT_SYSTEM_LARGE;
        var fontH = Graphics.getFontHeight(font);
  
        //Image
        if (res != null){
        	dc.drawBitmap(x, 0, res);
        	//x = x + res.getWidth();
        }else{
        	ownerMenu.startRequestImage(iconName, size);
        }
 
        //Date
        var dt = new Time.Moment(data["dt"]);
        var info = Gregorian.info(dt, Time.FORMAT_MEDIUM);
        x += drawDate(dc, x, fontH, info)+columnInterval;
         
        //Temperature size calculate
		font = Graphics.FONT_SYSTEM_LARGE;
		var tmpEve = getTemperature(data,"eve");
		var xOffset = Tools.max(0, x+dc.getTextWidthInPixels(tmpEve, font));
		font = Fonts.getMenuListFont();
		var tmpMax = getTemperature(data,"max");
		xOffset = Tools.max(xOffset, x+dc.getTextWidthInPixels(tmpMax, font));
		var tmpMin = getTemperature(data,"min");
		xOffset = Tools.max(xOffset, x+dc.getTextWidthInPixels(tmpMin, font));

		//Wind
		font = Fonts.getMenuListFont();
		var windArSize = fontH+Graphics.getFontHeight(font);
		var wind = new WindDirectionField(
			{:x => Tools.min(dc.getWidth() - windArSize,x+xOffset + columnInterval),
			:y => 0, 
			:h => windArSize, 
			:w=> windArSize, 
			:color => Tools.getWindColor(data["wind_speed"])}
		);
		wind.draw(dc, data["wind_deg"]);

		//Temperature draw
		font = Graphics.FONT_SYSTEM_LARGE;
		dc.setColor(ToolsGlance.getTempColor(data["temp"]["eve"]) , Graphics.COLOR_TRANSPARENT);
		dc.drawText(x, y, font, tmpEve, Graphics.TEXT_JUSTIFY_LEFT);
		y += dc.getFontHeight(font);
		dc.setColor(Tools.getForegroundColor(), Graphics.COLOR_TRANSPARENT);
		
		font = Fonts.getMenuListFont();
		dc.drawText(x, y, font, tmpMax, Graphics.TEXT_JUSTIFY_LEFT);
		y += dc.getFontHeight(font);
		dc.drawText(x, y, font, tmpMin, Graphics.TEXT_JUSTIFY_LEFT);
		
		//Wind speed
		var wSpeed = Tools.windSpeedConvert(data["wind_speed"]);
		var tmp = wSpeed[:valueString]+" "+wSpeed[:unit];
		x = xOffset + columnInterval;
		dc.drawText(x, windArSize, font,tmp, Graphics.TEXT_JUSTIFY_LEFT);
		border(dc);
	}
	
	function drawDate(dc, x, y, info){
        var font = Fonts.getMenuListFont();
        var fontH = Graphics.getFontHeight(font);
		var tmp = info.month+" "+info.day;
        dc.drawText(x, y, font, info.day_of_week, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(x, y + fontH, font, tmp, Graphics.TEXT_JUSTIFY_LEFT);
        return dc.getTextWidthInPixels(tmp, font);
	}
	
	function getTemperature(data, type){
		
		var typeDescr = "";
		var unit = "";
		if(type.equals("eve")){
			if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE){
				unit = "F";
			}else{
				unit = "C";
			}
		}else if (type.equals("min")){
			typeDescr = Application.loadResource(Rez.Strings.Min)+": ";
		}else if (type.equals("max")){
			typeDescr = Application.loadResource(Rez.Strings.Max)+": ";
		}
	
		return typeDescr + data["temp"][type].format("%d")+"°"+unit;
	}
}