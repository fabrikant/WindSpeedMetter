using Toybox.System;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application;

class WeatherMenuHourly extends WeatherMenu{

	function initialize(){
		storageKey = STORAGE_KEY_HOURLY;
		var itemHeight = Graphics.getFontHeight(Fonts.getMenuListFont()) * 2;
		WeatherMenu.initialize(itemHeight);
	}

	function addItems(){
		//var data = Tools.getStorage(storageKey, null);
		var data = Application.Storage.getValue(storageKey);
		var dataSize = 1;
		if (data != null){
			dataSize = data.size();
		}
		var interval = Tools.getProperty("HourlyIntrval");
		for (var i = itemsCount; i < dataSize; i+=interval){
			itemsCount = i+1;
			addItem(new WeatherMenuItemHourly(i, storageKey, self));
		}
	}

	function getTitleText(){
		return Application.loadResource(Rez.Strings.ForecastHourly);
	}
}

class WeatherMenuItemHourly extends WeatherMenuItem{

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
        var font = Fonts.getMenuListFont();
        var fontH = Graphics.getFontHeight(font);
  
        //Date
        var dt = new Time.Moment(data["dt"]);
        var info = Gregorian.info(dt, Time.FORMAT_MEDIUM);
        x += drawDate(dc, x, y, info);
        if (res != null){
        	dc.drawBitmap(x, (dc.getHeight()-res.getHeight())/2, res);
        	x = x + res.getWidth();
        }else{
        	ownerMenu.startRequestImage(iconName, size);
        }
        
        //Temperature
		font = Graphics.FONT_SYSTEM_LARGE;
		var tmp = getTemperature(data);
		dc.setColor(ToolsGlance.getTempColor(data["temp"]) , Graphics.COLOR_TRANSPARENT);
		dc.drawText(x, halfY, font, tmp, Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
		x += Tools.max(dc.getTextWidthInPixels(tmp, font),dc.getTextWidthInPixels("-40°", font)) + columnInterval/2;
		
		//Wind
		font = Graphics.FONT_LARGE;
		var windArSize = Graphics.getFontHeight(font);
		var wind = new WindDirectionField(
			{:x => x,:y => 0, :h => windArSize, :w=> windArSize, :color => Tools.getWindColor(data["wind_speed"])}
		);
		wind.draw(dc, data["wind_deg"]);
		
		//Wind speed
		font = Fonts.getMenuListFont();
		var wSpeed = Tools.windSpeedConvert(data["wind_speed"]);
		x += windArSize;
		x = Tools.min(x, dc.getWidth()-dc.getTextWidthInPixels(wSpeed[:valueString], font)-5);
      	dc.drawText(x, 0, font, wSpeed[:valueString], Graphics.TEXT_JUSTIFY_LEFT);
       	
       	font = Fonts.getMenuListFont();
       	x = dc.getWidth() - 10 - Tools.max(dc.getTextWidthInPixels(wSpeed[:valueString], font), dc.getTextWidthInPixels(wSpeed[:unit], font));
       	dc.drawText(x, halfY, font, wSpeed[:unit], Graphics.TEXT_JUSTIFY_LEFT);
		
		border(dc);
	}

	function drawDate(dc, x, y, info){
        var font = Fonts.getMenuListFont();
        var fontH = Graphics.getFontHeight(font);
		var tmp = Tools.infoToString(info);
        dc.drawText(x, y, font, info.day_of_week, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(x, y + fontH, font, tmp, Graphics.TEXT_JUSTIFY_LEFT);
        return dc.getTextWidthInPixels(tmp, font);
	}

	function getTemperature(data){
		return data["temp"].format("%d")+"°";
	}

}